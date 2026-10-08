import Foundation

/// Rechenziel des Immobilienrechners (Multi-Goal System)
public enum CalculationGoal: String, CaseIterable, Identifiable, Codable {
    case purchasePriceToRate = "Kaufpreis ➔ Rate"
    case termAndRateToLoan = "Laufzeit & Rate ➔ Kredit"
    case rateToPurchasePrice = "Budget ➔ Kaufpreis"
    case targetTermToRate = "Wunschlaufzeit ➔ Tilgung"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .purchasePriceToRate: return "eurosign.circle.fill"
        case .termAndRateToLoan: return "banknote.fill"
        case .rateToPurchasePrice: return "building.2.crop.circle.fill"
        case .targetTermToRate: return "hourglass.badge.plus"
        }
    }
}

/// Haushaltsrechner & Leistbarkeit (Interhyp-Prinzip)
public struct AffordabilityInput: Codable, Equatable {
    public var haushaltsNettoeinkommen: Double = 4_500 // Monatliches Netto
    public var wohnkostenQuote: Double = 35.0 // Empfehlung: 30-35%
    public var sonstigeVerbindlichkeiten: Double = 0 // Ratenkredite, Leasing etc.
    public var geplanteWunschlaufzeitJahre: Double = 25 // z.B. bis zur Rente
    
    public init() {}
}

/// Ergebnis der Leistbarkeitsprüfung
public struct AffordabilityResult {
    public let maxMonatsrate: Double
    public let verfuegbarNachFixkosten: Double
    public let risikostufe: RiskLevel
    public let risikotext: String
    
    public enum RiskLevel {
        case konservativ // <= 30%
        case optimal // 30 - 35%
        case erhoeht // 35 - 40%
        case kritisch // > 40%
        
        public var colorName: String {
            switch self {
            case .konservativ: return "green"
            case .optimal: return "blue"
            case .erhoeht: return "orange"
            case .kritisch: return "red"
            }
        }
    }
    
    public init(input: AffordabilityInput) {
        let bruttoAnteil = input.haushaltsNettoeinkommen * (input.wohnkostenQuote / 100.0)
        self.maxMonatsrate = max(0, bruttoAnteil - input.sonstigeVerbindlichkeiten)
        self.verfuegbarNachFixkosten = max(0, input.haushaltsNettoeinkommen - self.maxMonatsrate - input.sonstigeVerbindlichkeiten)
        
        if input.wohnkostenQuote <= 30.0 {
            self.risikostufe = .konservativ
            self.risikotext = "Sehr solide & finanzierbar. Bleibt viel finanzieller Freiraum."
        } else if input.wohnkostenQuote <= 35.0 {
            self.risikostufe = .optimal
            self.risikotext = "Optimaler Banken-Standard! Wird von Interhyp & Banken empfohlen."
        } else if input.wohnkostenQuote <= 40.0 {
            self.risikostufe = .erhoeht
            self.risikotext = "Erhöhter Anteil. Machbar, erfordert aber disziplinierte Haushaltsführung."
        } else {
            self.risikostufe = .kritisch
            self.risikotext = "Kritisch! Über 40 % lehnen die meisten Banken ohne Sonderbonität ab."
        }
    }
    
    /// Berechnet maximalen Kaufpreis bei gegebener Monatsrate
    public static func calculateMaxPurchasePrice(
        maxRate: Double,
        sollzins: Double,
        tilgung: Double,
        eigenkapital: Double,
        nebenkostenSatz: Double,
        modernisierung: Double
    ) -> (maxDarlehen: Double, maxKaufpreis: Double, maxGesamtbudget: Double) {
        guard maxRate > 0 else { return (0, 0, 0) }
        
        let annuitaetFaktor = (sollzins + tilgung) / 100.0
        guard annuitaetFaktor > 0 else { return (0, 0, 0) }
        
        let jahresRate = maxRate * 12.0
        let maxDarlehen = jahresRate / annuitaetFaktor
        let maxGesamtbudget = maxDarlehen + eigenkapital
        
        // gesamtkosten = kaufpreis * (1 + nebenkostenSatz / 100) + modernisierung
        // kaufpreis = (maxGesamtbudget - modernisierung) / (1 + nebenkostenSatz / 100)
        let faktorNebenkosten = 1.0 + (nebenkostenSatz / 100.0)
        let verfuegbarFuerObjekt = max(0, maxGesamtbudget - modernisierung)
        let maxKaufpreis = verfuegbarFuerObjekt / faktorNebenkosten
        
        return (maxDarlehen, maxKaufpreis, maxGesamtbudget)
    }
    
    /// Berechnet die exakt benötigte Anfangstilgung bei einer gewünschten Laufzeit in Jahren (unterjährige Monatsannuität)
    public static func calculateRequiredTilgung(
        sollzins: Double,
        zielJahre: Double
    ) -> Double {
        guard zielJahre > 0 else { return 2.0 }
        let iMonat = (sollzins / 100.0) / 12.0
        if iMonat <= 0.000001 {
            return max(0.5, (100.0 / zielJahre * 100).rounded() / 100.0)
        }
        let monate = zielJahre * 12.0
        let qM = 1.0 + iMonat
        let qMn = pow(qM, monate)
        let monatsAnnuitaetFaktor = (qMn * iMonat) / (qMn - 1.0)
        let jahresAnnuitaetFaktor = monatsAnnuitaetFaktor * 12.0
        let tilgung = (jahresAnnuitaetFaktor - (sollzins / 100.0)) * 100.0
        return max(0.5, (tilgung * 100).rounded() / 100.0)
    }
}

/// Ergebnis der Kredithöhen-Berechnung aus Gesamtlaufzeit, monatlicher Rate und Sondertilgung
public struct LoanCapacityResult: Equatable {
    public let zielLaufzeitJahre: Double
    public let monatlicheRate: Double
    public let sondertilgungProJahr: Double
    public let sollzins: Double
    
    public let maxDarlehen: Double
    public let darlehenOhneSondertilgung: Double
    public let mehrKreditDurchSondertilgung: Double
    public let maxKaufpreis: Double
    public let effTilgungssatz: Double
    
    // Empfehlungen
    public let empfohleneMindestTilgung: Double
    public let empfohleneMonatsTilgungBetrag: Double
    public let maxBankSondertilgungJahr: Double // ca. 5% Bank-Standard
    public let empfohleneSondertilgungJahr: Double // realistischer Zielwert (1 - 2%)
    public let zinsErsparnisDurchSondertilgung: Double
    public let laufzeitVerkuerzungJahre: Double
    public let tilgungsEmpfehlungText: String
    public let sondertilgungsEmpfehlungText: String
    
    public static func calculate(
        zielLaufzeitJahre: Double,
        monatlicheRate: Double,
        sondertilgungProJahr: Double,
        sollzins: Double,
        eigenkapital: Double,
        nebenkostenSatz: Double,
        modernisierung: Double
    ) -> LoanCapacityResult {
        let jahre = max(1.0, zielLaufzeitJahre)
        let rate = max(0.0, monatlicheRate)
        let sondertilg = max(0.0, sondertilgungProJahr)
        let zins = max(0.01, sollzins)
        let iMonat = (zins / 100.0) / 12.0
        let nMonate = jahre * 12.0
        
        guard rate > 0 else {
            return LoanCapacityResult(
                zielLaufzeitJahre: jahre,
                monatlicheRate: 0,
                sondertilgungProJahr: 0,
                sollzins: zins,
                maxDarlehen: 0,
                darlehenOhneSondertilgung: 0,
                mehrKreditDurchSondertilgung: 0,
                maxKaufpreis: 0,
                effTilgungssatz: 0,
                empfohleneMindestTilgung: 2.0,
                empfohleneMonatsTilgungBetrag: 0,
                maxBankSondertilgungJahr: 0,
                empfohleneSondertilgungJahr: 0,
                zinsErsparnisDurchSondertilgung: 0,
                laufzeitVerkuerzungJahre: 0,
                tilgungsEmpfehlungText: "Gib einen monatlichen Abschlag ein.",
                sondertilgungsEmpfehlungText: ""
            )
        }
        
        // Barwert der monatlichen Rate über nMonate
        let pvMonatlich = rate * (1.0 - pow(1.0 + iMonat, -nMonate)) / iMonat
        
        // Barwert der jährlichen Sondertilgung über jahre
        let annEffZins = pow(1.0 + iMonat, 12.0) - 1.0
        let pvSondertilg: Double
        if sondertilg > 0 && annEffZins > 0.000001 {
            pvSondertilg = sondertilg * (1.0 - pow(1.0 + annEffZins, -jahre)) / annEffZins
        } else {
            pvSondertilg = 0.0
        }
        
        let maxDarlehen = pvMonatlich + pvSondertilg
        let darlehenOhneSondertilgung = pvMonatlich
        let mehrKreditDurchSondertilgung = pvSondertilg
        
        // Kaufpreis aus Budget
        let gesamtbudget = maxDarlehen + max(0, eigenkapital)
        let verfuegbarFuerKauf = max(0, gesamtbudget - max(0, modernisierung))
        let faktorNebenkosten = 1.0 + (nebenkostenSatz / 100.0)
        let maxKaufpreis = verfuegbarFuerKauf / faktorNebenkosten
        
        // Effektiver Tilgungssatz zu Beginn
        let jahresRate = rate * 12.0
        let effTilgungssatz = max(0.1, ((jahresRate / max(1.0, maxDarlehen)) * 100.0) - zins)
        
        // Empfehlungen für Kreditsumme & Tilgung
        let empfohleneMindestTilgung: Double = (zins >= 4.0) ? 2.0 : ((zins >= 2.5) ? 2.5 : 3.0)
        let empfohleneMonatsTilgungBetrag = maxDarlehen * (empfohleneMindestTilgung / 100.0) / 12.0
        
        let maxBankSondertilgungJahr = maxDarlehen * 0.05 // 5 % üblicher Rahmen
        let empfohleneSondertilgungJahr = min(maxBankSondertilgungJahr, max(1_000, maxDarlehen * 0.015)) // ca. 1.5 %
        
        // Zinsersparnis und Zeitersparnis durch Sondertilgung berechnen
        var zinsErsparnis: Double = 0
        var zeitErsparnisJahre: Double = 0
        
        if sondertilg > 0 {
            let monatsZins = maxDarlehen * iMonat
            if rate > monatsZins {
                let monateOhne = -log(1.0 - (maxDarlehen * iMonat / rate)) / log(1.0 + iMonat)
                let zinsenOhne = (monateOhne * rate) - maxDarlehen
                let gezahltMit = (rate * nMonate) + (sondertilg * jahre)
                let zinsenMit = max(0, gezahltMit - maxDarlehen)
                zinsErsparnis = max(0, zinsenOhne - zinsenMit)
                zeitErsparnisJahre = max(0, (monateOhne / 12.0) - jahre)
            } else {
                zeitErsparnisJahre = 15.0
            }
        }
        
        let tilgText: String
        if zins >= 4.0 {
            tilgText = "Bei aktuellen Zinsen von \(String(format: "%.2f", zins)) % empfehlen Banken mind. 2,0 % bis 2,5 % Anfangstilgung (ca. \(Int(empfohleneMonatsTilgungBetrag)) €/Monat). Dadurch bleibt die Monatsrate bezahlbar und der Kredit ist in unter 25–28 Jahren getilgt."
        } else {
            tilgText = "Bei moderaten Zinsen wird eine höhere Tilgung von 2,5 % bis 3,0 % empfohlen, um das Zinsänderungsrisiko der Anschlussfinanzierung zu minimieren."
        }
        
        let sondertilgText: String
        if sondertilg > 0 {
            sondertilgText = "Banken erlauben meist bis zu 5 % kostenfreie Sondertilgung p.a. (\(Int(maxBankSondertilgungJahr)) €/Jahr). Mit deinen \(Int(sondertilg)) €/Jahr sparst du rund \(Int(zinsErsparnis)) € Zinsen und ca. \(String(format: "%.1f", zeitErsparnisJahre)) Jahre Laufzeit!"
        } else {
            sondertilgText = "Tipp: Vereinbare immer 5 % kostenfreie Sondertilgung im Darlehensvertrag (\(Int(maxBankSondertilgungJahr)) €/Jahr möglich). Schon 1.500 € – 2.500 € jährlich aus Boni oder Steuerrückzahlungen verkürzen die Gesamtlaufzeit um mehrere Jahre."
        }
        
        return LoanCapacityResult(
            zielLaufzeitJahre: jahre,
            monatlicheRate: rate,
            sondertilgungProJahr: sondertilg,
            sollzins: zins,
            maxDarlehen: maxDarlehen,
            darlehenOhneSondertilgung: darlehenOhneSondertilgung,
            mehrKreditDurchSondertilgung: mehrKreditDurchSondertilgung,
            maxKaufpreis: maxKaufpreis,
            effTilgungssatz: effTilgungssatz,
            empfohleneMindestTilgung: empfohleneMindestTilgung,
            empfohleneMonatsTilgungBetrag: empfohleneMonatsTilgungBetrag,
            maxBankSondertilgungJahr: maxBankSondertilgungJahr,
            empfohleneSondertilgungJahr: empfohleneSondertilgungJahr,
            zinsErsparnisDurchSondertilgung: zinsErsparnis,
            laufzeitVerkuerzungJahre: zeitErsparnisJahre,
            tilgungsEmpfehlungText: tilgText,
            sondertilgungsEmpfehlungText: sondertilgText
        )
    }
}
