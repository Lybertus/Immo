import Foundation

/// Rechenziel des Immobilienrechners (Multi-Goal System)
public enum CalculationGoal: String, CaseIterable, Identifiable, Codable {
    case purchasePriceToRate = "Kaufpreis ➔ Rate"
    case rateToPurchasePrice = "Budget / Max. Kaufpreis"
    case targetTermToRate = "Wunschlaufzeit ➔ Tilgung"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .purchasePriceToRate: return "eurosign.circle.fill"
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
