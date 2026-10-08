import Foundation

/// Berechnungsmodus für die Baufinanzierung
public enum CalculationMode: String, CaseIterable, Identifiable, Codable {
    case tilgungssatz = "Über Tilgungssatz"
    case wunschrate = "Über Wunschrate"
    
    public var id: String { rawValue }
}

/// Eingabedaten für die Immobilienberechnung
public struct PropertyInput: Codable, Equatable {
    // Basisdaten
    public var kaufpreis: Double = 450_000
    public var bundesland: FederalState = .bayern
    public var customGrunderwerbsteuer: Double? = nil
    public var notarGrundbuchSatz: Double = 2.0 // üblich ca. 1.5 - 2.0%
    public var maklerSatz: Double = 3.57 // üblich 3.57% inkl. MwSt.
    public var hatMakler: Bool = true
    public var modernisierungskosten: Double = 20_000
    
    // Finanzierungsdaten
    public var eigenkapital: Double = 90_000
    public var sollzins: Double = 3.80 // in % p.a. (Interhyp Referenz für 15 J.)
    public var zinsbindungJahre: Int = 15 // 5, 10, 15, 20, 25, 30
    public var autoUpdateInterestWithMarketBenchmark: Bool = true
    public var anschlussOption: RefinancingOption = .sameRate
    public var anschlussZinsCustom: Double? = nil
    
    public var calculationMode: CalculationMode = .tilgungssatz
    public var tilgungssatz: Double = 2.0 // in % p.a.
    public var wunschrate: Double = 1_800 // € pro Monat
    public var sondertilgungProJahr: Double = 2_500 // € pro Jahr
    
    public init() {}
    
    /// Aktiver Grunderwerbsteuersatz
    public var aktiverSteuersatz: Double {
        customGrunderwerbsteuer ?? bundesland.taxRate
    }
    
    /// Aktiver Maklersatz
    public var aktiverMaklersatz: Double {
        hatMakler ? maklerSatz : 0.0
    }
    
    /// Effektiver Zinssatz für die Anschlussfinanzierung nach Zinsbindung
    public var effektiverAnschlussZins: Double {
        switch anschlussOption {
        case .sameRate:
            return sollzins
        case .stressTestPlus1:
            return sollzins + 1.0
        case .stressTestPlus2:
            return sollzins + 2.0
        case .custom:
            return anschlussZinsCustom ?? sollzins
        }
    }
}

/// Ergebnis der Immobilienberechnung
public struct CalculationResult {
    // Nebenkosten
    public let grunderwerbsteuer: Double
    public let notarGrundbuchKosten: Double
    public let maklerKosten: Double
    public let kaufnebenkostenGesamt: Double
    public let kaufnebenkostenProzent: Double
    
    // Gesamtkosten & Darlehen
    public let gesamtkosten: Double
    public let darlehensbetrag: Double
    public let eigenkapitalQuote: Double
    public let beleihungsauslauf: Double
    
    // Rate & Ratenaufteilung
    public let monatlicheRate: Double
    public let anfaenglicherTilgungssatz: Double
    public let anfaenglicheMonatsZinsen: Double
    public let anfaenglicheMonatsTilgung: Double
    
    // Zinsbindungsende
    public let restschuldNachZinsbindung: Double
    public let gezahlteZinsenInZinsbindung: Double
    public let gezahlteTilgungInZinsbindung: Double
    public let geleisteteSondertilgungInZinsbindung: Double
    
    // Gesamtlaufzeit bis Volltilgung
    public let gesamtlaufzeitJahre: Double
    public let gesamtlaufzeitMonate: Int
    public let zinsenBisVolltilgung: Double
    public let gesamtRueckzahlung: Double
    
    // Bonitäts-Faustregel
    public let empfohlenesNettoeinkommen: Double
    
    // Detaillierter Tilgungsplan
    public let tilgungsplan: [AmortizationYear]
}

/// Logik zur Berechnung der Finanzierungsdaten
public enum MortgageCalculator {
    public static func calculate(input: PropertyInput) -> CalculationResult {
        let kaufpreis = max(0, input.kaufpreis)
        
        // 1. Nebenkosten
        let grunderwerbsteuer = kaufpreis * (input.aktiverSteuersatz / 100.0)
        let notarGrundbuchKosten = kaufpreis * (input.notarGrundbuchSatz / 100.0)
        let maklerKosten = kaufpreis * (input.aktiverMaklersatz / 100.0)
        let kaufnebenkostenGesamt = grunderwerbsteuer + notarGrundbuchKosten + maklerKosten
        let kaufnebenkostenProzent = kaufpreis > 0 ? (kaufnebenkostenGesamt / kaufpreis) * 100.0 : 0.0
        
        // 2. Gesamtkosten & Darlehen
        let modernisierung = max(0, input.modernisierungskosten)
        let gesamtkosten = kaufpreis + kaufnebenkostenGesamt + modernisierung
        let eigenkapital = max(0, input.eigenkapital)
        let darlehensbetrag = max(0, gesamtkosten - eigenkapital)
        
        let eigenkapitalQuote = gesamtkosten > 0 ? (eigenkapital / gesamtkosten) * 100.0 : 0.0
        let beleihungsauslauf = kaufpreis > 0 ? (darlehensbetrag / kaufpreis) * 100.0 : 0.0
        
        // 3. Rate ermitteln
        let sollzins = max(0.01, input.sollzins)
        let monatlicherZinssatzAnfang = (sollzins / 100.0) / 12.0
        
        let monatlicheRate: Double
        let effTilgungssatz: Double
        
        if darlehensbetrag <= 0 {
            monatlicheRate = 0
            effTilgungssatz = 0
        } else {
            switch input.calculationMode {
            case .tilgungssatz:
                let initialTilgung = max(0.1, input.tilgungssatz)
                effTilgungssatz = initialTilgung
                let jahresAnnuität = darlehensbetrag * ((sollzins + initialTilgung) / 100.0)
                monatlicheRate = jahresAnnuität / 12.0
            case .wunschrate:
                monatlicheRate = max(darlehensbetrag * monatlicherZinssatzAnfang + 10, input.wunschrate)
                let jahresAnnuität = monatlicheRate * 12.0
                effTilgungssatz = max(0.1, ((jahresAnnuität / darlehensbetrag) * 100.0) - sollzins)
            }
        }
        
        let anfaenglicheMonatsZinsen = darlehensbetrag * monatlicherZinssatzAnfang
        let anfaenglicheMonatsTilgung = max(0, monatlicheRate - anfaenglicheMonatsZinsen)
        
        // 4. Monatliche Simulation für exakten Tilgungsplan
        var restschuld = darlehensbetrag
        var kumulierteZinsen = 0.0
        var kumulierteTilgung = 0.0
        var kumulierteSondertilgung = 0.0
        
        var zinsenInZinsbindung = 0.0
        var tilgungInZinsbindung = 0.0
        var sondertilgungInZinsbindung = 0.0
        var restschuldAmZinsbindungsende = 0.0
        
        var tilgungsplanJahre: [AmortizationYear] = []
        var monate = 0
        let maxMonate = 600 // max 50 Jahre
        let zinsbindungMonate = input.zinsbindungJahre * 12
        
        var jahresZinsen = 0.0
        var jahresTilgung = 0.0
        var jahresSondertilgung = 0.0
        var anfangsRestschuldDesJahres = restschuld
        
        var laufendeMonatsRate = monatlicheRate
        
        while restschuld > 0.01 && monate < maxMonate {
            monate += 1
            
            // Wenn Zinsbindung abläuft: ggf. Anschlussfinanzierungs-Zinssatz verwenden
            let aktiverZins = (monate <= zinsbindungMonate) ? sollzins : input.effektiverAnschlussZins
            let monatsZinsSatz = (aktiverZins / 100.0) / 12.0
            
            // Wenn Zinsbindung abgelaufen ist und der Zins sich geändert hat, Ratenanpassung
            if monate == zinsbindungMonate + 1 && input.effektiverAnschlussZins != sollzins {
                // Rate neu berechnen basierend auf Restschuld und Restlaufzeit / Annuität
                let neuJahresAnnuitaet = restschuld * ((aktiverZins + effTilgungssatz) / 100.0)
                laufendeMonatsRate = neuJahresAnnuitaet / 12.0
            }
            
            let monatsZins = restschuld * monatsZinsSatz
            let verfuegbareTilgung = laufendeMonatsRate - monatsZins
            let monatsTilgung = min(restschuld, max(0, verfuegbareTilgung))
            
            restschuld -= monatsTilgung
            kumulierteZinsen += monatsZins
            kumulierteTilgung += monatsTilgung
            jahresZinsen += monatsZins
            jahresTilgung += monatsTilgung
            
            // Jährliche Sondertilgung am Ende des Jahres
            var monatsSondertilgung = 0.0
            if monate % 12 == 0 && input.sondertilgungProJahr > 0 && restschuld > 0.01 {
                monatsSondertilgung = min(restschuld, input.sondertilgungProJahr)
                restschuld -= monatsSondertilgung
                kumulierteSondertilgung += monatsSondertilgung
                kumulierteTilgung += monatsSondertilgung
                jahresSondertilgung += monatsSondertilgung
            }
            
            // Stand am Ende der Zinsbindung festhalten
            if monate == zinsbindungMonate {
                restschuldAmZinsbindungsende = restschuld
                zinsenInZinsbindung = kumulierteZinsen
                tilgungInZinsbindung = kumulierteTilgung
                sondertilgungInZinsbindung = kumulierteSondertilgung
            }
            
            // Jahresabschluss
            if monate % 12 == 0 || restschuld <= 0.01 {
                let aktuellesJahr = (monate + 11) / 12
                let istZinsbindungsJahr = (monate == zinsbindungMonate) || (monate < zinsbindungMonate && restschuld <= 0.01)
                
                let eintrag = AmortizationYear(
                    jahr: aktuellesJahr,
                    anfangsRestschuld: anfangsRestschuldDesJahres,
                    gezahlteZinsen: jahresZinsen,
                    gezahlteTilgung: jahresTilgung,
                    sondertilgung: jahresSondertilgung,
                    gesamtZahlung: jahresZinsen + jahresTilgung + jahresSondertilgung,
                    endRestschuld: max(0, restschuld),
                    kumulierteZinsen: kumulierteZinsen,
                    kumulierteTilgung: kumulierteTilgung,
                    istEndeZinsbindung: istZinsbindungsJahr
                )
                tilgungsplanJahre.append(eintrag)
                
                anfangsRestschuldDesJahres = restschuld
                jahresZinsen = 0
                jahresTilgung = 0
                jahresSondertilgung = 0
            }
        }
        
        if monate < zinsbindungMonate {
            restschuldAmZinsbindungsende = 0
            zinsenInZinsbindung = kumulierteZinsen
            tilgungInZinsbindung = kumulierteTilgung
            sondertilgungInZinsbindung = kumulierteSondertilgung
        }
        
        let gesamtlaufzeitJahre = Double(monate) / 12.0
        let gesamtRueckzahlung = darlehensbetrag + kumulierteZinsen
        let empfohlenesNettoeinkommen = monatlicheRate > 0 ? (monatlicheRate / 0.35) : 0
        
        return CalculationResult(
            grunderwerbsteuer: grunderwerbsteuer,
            notarGrundbuchKosten: notarGrundbuchKosten,
            maklerKosten: maklerKosten,
            kaufnebenkostenGesamt: kaufnebenkostenGesamt,
            kaufnebenkostenProzent: kaufnebenkostenProzent,
            gesamtkosten: gesamtkosten,
            darlehensbetrag: darlehensbetrag,
            eigenkapitalQuote: eigenkapitalQuote,
            beleihungsauslauf: beleihungsauslauf,
            monatlicheRate: monatlicheRate,
            anfaenglicherTilgungssatz: effTilgungssatz,
            anfaenglicheMonatsZinsen: anfaenglicheMonatsZinsen,
            anfaenglicheMonatsTilgung: anfaenglicheMonatsTilgung,
            restschuldNachZinsbindung: restschuldAmZinsbindungsende,
            gezahlteZinsenInZinsbindung: zinsenInZinsbindung,
            gezahlteTilgungInZinsbindung: tilgungInZinsbindung,
            geleisteteSondertilgungInZinsbindung: sondertilgungInZinsbindung,
            gesamtlaufzeitJahre: gesamtlaufzeitJahre,
            gesamtlaufzeitMonate: monate,
            zinsenBisVolltilgung: kumulierteZinsen,
            gesamtRueckzahlung: gesamtRueckzahlung,
            empfohlenesNettoeinkommen: empfohlenesNettoeinkommen,
            tilgungsplan: tilgungsplanJahre
        )
    }
}
