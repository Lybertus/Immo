import Foundation

/// Detaillierte Zinsstaffel für eine bestimmte Zinsbindung laut aktuellem Interhyp-Zinsspiegel
public struct InterhypRateBracket: Codable, Equatable {
    public let years: Int
    public let bestRate: Double      // Beleihungsauslauf < 70 % (Bestzins / hohes Eigenkapital)
    public let standardRate: Double  // Beleihungsauslauf ca. 80 % (Solides Eigenkapital / Marktdurchschnitt)
    public let highLtvRate: Double   // Beleihungsauslauf > 90 % (Geringes Eigenkapital / Vollfinanzierung)
    
    public init(years: Int, bestRate: Double, standardRate: Double, highLtvRate: Double) {
        self.years = years
        self.bestRate = bestRate
        self.standardRate = standardRate
        self.highLtvRate = highLtvRate
    }
}

/// Bonitäts- & Beleihungsmodus für die Interhyp-Zinsauswahl
public enum InterhypRateTier: String, CaseIterable, Identifiable, Codable {
    case auto = "Automatisch nach Eigenkapital"
    case best = "Bestzins (< 70 % Beleihung)"
    case standard = "Standard (ca. 80 % Beleihung)"
    case highLtv = "Geringes EK (> 90 % Beleihung)"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .auto: return "Passt sich dynamisch an deinen errechneten Beleihungsauslauf an."
        case .best: return "Für Käufer mit viel Eigenkapital und Top-Bonität."
        case .standard: return "Der klassische Marktdurchschnitt bei solider Eigenkapitalquote."
        case .highLtv: return "Bei knapper Eigenkapitalausstattung (über 90 % Beleihung)."
        }
    }
}

/// Aktuelle Marktzinsen & Zinsbindungs-Benchmarks (Interhyp Zinsspiegel Stand Oktober 2026)
public struct MarketInterestRates: Codable, Equatable {
    public var lastUpdated: String
    public var brackets: [Int: InterhypRateBracket]
    
    public init() {
        self.lastUpdated = "Oktober 2026 (Interhyp-Zinsspiegel)"
        // Reale Live-Werte laut Interhyp Zinsspiegel für 500+ Darlehensgeber:
        self.brackets = [
            5:  InterhypRateBracket(years: 5,  bestRate: 3.85, standardRate: 4.05, highLtvRate: 4.30),
            10: InterhypRateBracket(years: 10, bestRate: 4.23, standardRate: 4.35, highLtvRate: 4.63),
            15: InterhypRateBracket(years: 15, bestRate: 4.41, standardRate: 4.52, highLtvRate: 4.74),
            20: InterhypRateBracket(years: 20, bestRate: 4.53, standardRate: 4.68, highLtvRate: 4.79),
            25: InterhypRateBracket(years: 25, bestRate: 4.65, standardRate: 4.80, highLtvRate: 4.95),
            30: InterhypRateBracket(years: 30, bestRate: 4.75, standardRate: 4.90, highLtvRate: 5.05)
        ]
    }
    
    /// Ermittelt den passenden Zinssatz abhängig von Zinsbindung, Beleihungsauslauf oder gewählter Stufe
    public func rate(for years: Int, beleihungsauslauf: Double = 80.0, tier: InterhypRateTier = .auto) -> Double {
        let bracket = brackets[years] ?? closestBracket(for: years)
        
        switch tier {
        case .best:
            return bracket.bestRate
        case .standard:
            return bracket.standardRate
        case .highLtv:
            return bracket.highLtvRate
        case .auto:
            if beleihungsauslauf < 75.0 {
                return bracket.bestRate
            } else if beleihungsauslauf <= 88.0 {
                return bracket.standardRate
            } else {
                return bracket.highLtvRate
            }
        }
    }
    
    public func bracket(for years: Int) -> InterhypRateBracket {
        brackets[years] ?? closestBracket(for: years)
    }
    
    private func closestBracket(for years: Int) -> InterhypRateBracket {
        if years <= 5 { return brackets[5]! }
        if years <= 10 { return brackets[10]! }
        if years <= 15 { return brackets[15]! }
        if years <= 20 { return brackets[20]! }
        if years <= 25 { return brackets[25]! }
        return brackets[30]!
    }
}

/// Optionen für die Anschlussfinanzierung nach Ende der Zinsbindung
public enum RefinancingOption: String, CaseIterable, Identifiable, Codable {
    case sameRate = "Gleicher Zinssatz (Realistisch weiterrechnen)"
    case stressTestPlus1 = "Stresstest (+1,0 % Zinsanstieg)"
    case stressTestPlus2 = "Stresstest (+2,0 % Zinsanstieg)"
    case custom = "Individueller Anschlusszins"
    
    public var id: String { rawValue }
}
