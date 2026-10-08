import Foundation

/// Interhyp Erschwinglichkeitsindex (Leistbarkeits-Index)
public struct AffordabilityIndexResult {
    public let indexScore: Double // 100 = Historischer Standard-Ausgangswert
    public let leistbareWohnflaecheQm: Double // Wie viele m² kann sich der Haushalt leisten
    public let qmPreisObjekt: Double // Kaufpreis / Wohnfläche
    public let bewertungStufe: RatingLevel
    public let beschreibung: String
    
    public enum RatingLevel: String {
        case sehrGut = "Sehr gut erschwinglich"
        case normal = "Ausgewogener Markt"
        case angespannt = "Angespannter Markt"
        case kritisch = "Schwer erschwinglich"
        
        public var colorName: String {
            switch self {
            case .sehrGut: return "green"
            case .normal: return "blue"
            case .angespannt: return "orange"
            case .kritisch: return "red"
            }
        }
    }
    
    public static func calculate(
        haushaltsNetto: Double,
        wohnkostenQuote: Double,
        sollzins: Double,
        tilgung: Double,
        eigenkapital: Double,
        kaufpreis: Double,
        wohnflaecheQm: Double
    ) -> AffordabilityIndexResult {
        let flaeche = max(20.0, wohnflaecheQm)
        let qmPreis = kaufpreis / flaeche
        
        // Maximale Monatsrate bei der Quote
        let rate = max(100.0, haushaltsNetto * (wohnkostenQuote / 100.0))
        let annuitaetFaktor = max(0.01, (sollzins + tilgung) / 100.0)
        let maxDarlehen = (rate * 12.0) / annuitaetFaktor
        
        // Gesamtbudget inkl. Eigenkapital abzüglich ca. 8,5 % Kaufnebenkosten
        let maxGesamtbudget = (maxDarlehen + eigenkapital) / 1.085
        let leistbareQm = max(10.0, maxGesamtbudget / max(1.0, qmPreis))
        
        // Interhyp-Normierung: 85 m² entspricht dem historischen Indexwert von 100 Punkten
        let index = (leistbareQm / 85.0) * 100.0
        
        let stufe: RatingLevel
        let text: String
        
        if index >= 110.0 {
            stufe = .sehrGut
            text = "Hervorragende Erschwinglichkeit! Dein Haushalt kann sich mit \(Int(leistbareQm)) m² deutlich mehr Fläche als der Bundesdurchschnitt leisten."
        } else if index >= 90.0 {
            stufe = .normal
            text = "Ausgewogene Erschwinglichkeit. Der Kauf ist im historischen Vergleich gut finanzierbar (\(Int(leistbareQm)) m² leistbar)."
        } else if index >= 75.0 {
            stufe = .angespannt
            text = "Angespannter Markt. Die Kombination aus Kaufpreis und aktuellem Zinsniveau erfordert eine spürbare Budgetdisziplin (\(Int(leistbareQm)) m² leistbar)."
        } else {
            stufe = .kritisch
            text = "Schwer erschwinglich. Das Zins- und Preisniveau liegt deutlich über dem optimalen Durchschnitt (nur \(Int(leistbareQm)) m² leistbar)."
        }
        
        return AffordabilityIndexResult(
            indexScore: index,
            leistbareWohnflaecheQm: leistbareQm,
            qmPreisObjekt: qmPreis,
            bewertungStufe: stufe,
            beschreibung: text
        )
    }
}
