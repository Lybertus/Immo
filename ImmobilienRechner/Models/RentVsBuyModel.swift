import Foundation

/// Eingabedaten für den Mieten-vs-Kaufen-Vergleich
public struct RentVsBuyInput: Codable, Equatable {
    public var aktuelleKaltmiete: Double = 1_250 // monatliche Kaltmiete
    public var wohnflaecheQm: Double = 95 // Quadratmeter der Wohnung/des Hauses
    public var mietsteigerungProJahr: Double = 2.0 // % p.a.
    public var etfRenditeProJahr: Double = 5.5 // Alternative ETF-Depotrendite % p.a.
    public var instandhaltungKaeuferMonat: Double = 220 // Instandhaltungsrücklage Käufer
    public var immobilienWertsteigerungProJahr: Double = 1.5 // % p.a.
    public var betrachtungszeitraumJahre: Int = 20 // 10, 15, 20, 25, 30 Jahre
    
    public init() {}
}

/// Ergebnis des Mieten-vs-Kaufen-Vergleichs
public struct RentVsBuyResult {
    public let mietmultiplikator: Double // Kaufpreis / (Kaltmiete * 12)
    public let guenstigWohnenScore: RentQuality
    public let guenstigWohnenText: String
    
    public let monatlicheKostenMieterAnfang: Double
    public let monatlicheKostenKaeuferAnfang: Double
    public let anfaenglicheDifferenz: Double // Käufer zahlt anfangs meist mehr
    
    public let vermoegenKaeufer: Double
    public let vermoegenMieter: Double
    public let vermoegensDifferenz: Double // Positiv = Kaufen vorteilhaft, Negativ = Mieten vorteilhaft
    public let breakEvenJahr: Int? // Jahr, ab dem Kaufen besser ist
    
    public let jahresVergleich: [RentVsBuyYear]
    
    public enum RentQuality: String {
        case extremGuenstig = "Extrem günstig"
        case guenstig = "Günstig"
        case durchschnittlich = "Marktüblich"
        case teuer = "Teuer gemietet"
        
        public var colorName: String {
            switch self {
            case .extremGuenstig, .guenstig: return "green"
            case .durchschnittlich: return "orange"
            case .teuer: return "red"
            }
        }
    }
}

public struct RentVsBuyYear: Identifiable, Codable {
    public var id: Int { jahr }
    public let jahr: Int
    public let monatsMiete: Double
    public let vermoegenKaeufer: Double
    public let vermoegenMieter: Double
    public let kaeuferIstBesser: Bool
}

/// Simulationslogik für Mieten vs. Kaufen
public enum RentVsBuyCalculator {
    public static func calculate(
        input: RentVsBuyInput,
        propertyInput: PropertyInput,
        mortgageResult: CalculationResult
    ) -> RentVsBuyResult {
        let kaufpreis = max(1.0, propertyInput.kaufpreis)
        let jahresKaltmiete = input.aktuelleKaltmiete * 12.0
        let multiplikator = jahresKaltmiete > 0 ? (kaufpreis / jahresKaltmiete) : 0
        
        // Bewertung: Wohnst du günstig?
        let quality: RentVsBuyResult.RentQuality
        let qualityText: String
        
        if multiplikator >= 33.0 {
            quality = .extremGuenstig
            qualityText = "Du wohnst aktuell extrem günstig zur Miete (Faktor \(String(format: "%.1f", multiplikator))). Finanziell ist Mieten bei dir aktuell im Vorteil."
        } else if multiplikator >= 27.0 {
            quality = .guenstig
            qualityText = "Deine Miete ist im Verhältnis zum Kaufpreis günstig (Faktor \(String(format: "%.1f", multiplikator))). Der Kauf amortisiert sich erst nach vielen Jahren."
        } else if multiplikator >= 21.0 {
            quality = .durchschnittlich
            qualityText = "Deine Miete ist marktüblich (Faktor \(String(format: "%.1f", multiplikator))). Mieten und Kaufen halten sich in etwa die Waage."
        } else {
            quality = .teuer
            qualityText = "Deine aktuelle Miete ist sehr teuer im Verhältnis zum Kaufpreis (Faktor \(String(format: "%.1f", multiplikator))). Ein Kauf lohnt sich für dich besonders schnell!"
        }
        
        let anfangsKostenMieter = input.aktuelleKaltmiete
        let anfangsKostenKaeufer = mortgageResult.monatlicheRate + input.instandhaltungKaeuferMonat
        let initialDiff = anfangsKostenKaeufer - anfangsKostenMieter
        
        // Multi-Jahre Vermögenssimulation
        var mieterDepot = propertyInput.eigenkapital // Mieter investiert das EK in ETF
        var jahreData: [RentVsBuyYear] = []
        var gefundenerBreakEven: Int? = nil
        
        let jahre = max(5, min(40, input.betrachtungszeitraumJahre))
        let etfMonatsRendite = pow(1.0 + (input.etfRenditeProJahr / 100.0), 1.0 / 12.0) - 1.0
        let mietSteigerungsFaktor = 1.0 + (input.mietsteigerungProJahr / 100.0)
        let immoSteigerungsFaktor = 1.0 + (input.immobilienWertsteigerungProJahr / 100.0)
        
        var aktuelleMonatsMiete = input.aktuelleKaltmiete
        var laufendeInstandhaltung = input.instandhaltungKaeuferMonat
        var kaeuferSparDepot = 0.0
        
        for y in 1...jahre {
            // Tilgungsplan-Daten für Jahr y abrufen
            let restschuldAmJahresende = mortgageResult.tilgungsplan.first(where: { $0.jahr == y })?.endRestschuld ?? 0.0
            
            // Monat für Monat im Jahr y simulieren
            for _ in 1...12 {
                // Verzinsung der Depots
                mieterDepot *= (1.0 + etfMonatsRendite)
                kaeuferSparDepot *= (1.0 + etfMonatsRendite)
                
                let monatAusgabenMieter = aktuelleMonatsMiete
                let monatAusgabenKaeufer = mortgageResult.monatlicheRate + laufendeInstandhaltung
                
                if monatAusgabenKaeufer > monatAusgabenMieter {
                    // Mieter hat monatlichen Überschuss und spart ihn im ETF
                    let ersparnis = monatAusgabenKaeufer - monatAusgabenMieter
                    mieterDepot += ersparnis
                } else {
                    // Miete ist höher als Kreditkosten: Käufer spart monatlich die Differenz
                    let ersparnis = monatAusgabenMieter - monatAusgabenKaeufer
                    kaeuferSparDepot += ersparnis
                }
            }
            
            // Immobilienwert im Jahr y
            let aktuellerImmobilienWert = kaufpreis * pow(immoSteigerungsFaktor, Double(y))
            let kaeuferNettoVermoegen = (aktuellerImmobilienWert - restschuldAmJahresende) + kaeuferSparDepot
            let mieterNettoVermoegen = mieterDepot
            
            if gefundenerBreakEven == nil && kaeuferNettoVermoegen > mieterNettoVermoegen {
                gefundenerBreakEven = y
            }
            
            jahreData.append(
                RentVsBuyYear(
                    jahr: y,
                    monatsMiete: aktuelleMonatsMiete,
                    vermoegenKaeufer: kaeuferNettoVermoegen,
                    vermoegenMieter: mieterNettoVermoegen,
                    kaeuferIstBesser: kaeuferNettoVermoegen >= mieterNettoVermoegen
                )
            )
            
            // Jährliche Steigerungen
            aktuelleMonatsMiete *= mietSteigerungsFaktor
            laufendeInstandhaltung *= 1.015 // ca. 1.5% Inflation auf Instandhaltung
        }
        
        let endKaeufer = jahreData.last?.vermoegenKaeufer ?? 0.0
        let endMieter = jahreData.last?.vermoegenMieter ?? 0.0
        
        return RentVsBuyResult(
            mietmultiplikator: multiplikator,
            guenstigWohnenScore: quality,
            guenstigWohnenText: qualityText,
            monatlicheKostenMieterAnfang: anfangsKostenMieter,
            monatlicheKostenKaeuferAnfang: anfangsKostenKaeufer,
            anfaenglicheDifferenz: initialDiff,
            vermoegenKaeufer: endKaeufer,
            vermoegenMieter: endMieter,
            vermoegensDifferenz: endKaeufer - endMieter,
            breakEvenJahr: gefundenerBreakEven,
            jahresVergleich: jahreData
        )
    }
}
