import Foundation

/// Aktuelle Marktzinsen & Zinsbindungs-Benchmarks (Interhyp / Bundesbank Standard)
public struct MarketInterestRates: Codable, Equatable {
    public var lastUpdated: Date
    public var rates: [Int: Double] // Zinsbindung in Jahren -> Sollzins in % p.a.
    
    public init() {
        self.lastUpdated = Date()
        // Repräsentative aktuelle Baufinanzierungs-Richtwerte deutscher Banken (Stand 2024 - 2026)
        self.rates = [
            5: 3.40,
            10: 3.60,
            15: 3.80,
            20: 4.00,
            25: 4.15,
            30: 4.25
        ]
    }
    
    public func rate(for years: Int) -> Double {
        if let exact = rates[years] {
            return exact
        }
        // Nächster Nachbar oder lineare Interpolation
        if years <= 5 { return rates[5] ?? 3.40 }
        if years <= 10 { return rates[10] ?? 3.60 }
        if years <= 15 { return rates[15] ?? 3.80 }
        if years <= 20 { return rates[20] ?? 4.00 }
        if years <= 25 { return rates[25] ?? 4.15 }
        return rates[30] ?? 4.25
    }
}

/// Optionen für die Anschlussfinanzierung nach Ende der Zinsbindung
public enum RefinancingOption: String, CaseIterable, Identifiable, Codable {
    case sameRate = "Gleicher Zinssatz (Weiterrechnen)"
    case stressTestPlus1 = "Stresstest (+1,0 % Zinsanstieg)"
    case stressTestPlus2 = "Stresstest (+2,0 % Zinsanstieg)"
    case custom = "Individueller Anschlusszins"
    
    public var id: String { rawValue }
}
