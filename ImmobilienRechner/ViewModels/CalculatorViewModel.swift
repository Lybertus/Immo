import Foundation
import SwiftUI
import Combine

public class CalculatorViewModel: ObservableObject {
    @Published public var input: PropertyInput {
        didSet {
            saveCurrentState()
        }
    }
    
    @Published public var investmentInput: InvestmentInput {
        didSet {
            saveCurrentState()
        }
    }
    
    @Published public var isInvestmentModeActive: Bool = false
    @Published public var savedScenarios: [SavedScenario] = []
    
    private let userDefaultsKey = "immobilien_rechner_state_v1"
    private let scenariosKey = "immobilien_rechner_scenarios_v1"
    
    public init() {
        // Load saved state or default
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(PropertyInput.self, data) {
            self.input = saved
        } else {
            self.input = PropertyInput()
        }
        
        self.investmentInput = InvestmentInput()
        self.loadSavedScenarios()
    }
    
    // MARK: - Computed Results
    
    public var result: CalculationResult {
        MortgageCalculator.calculate(input: input)
    }
    
    public var investmentResult: InvestmentResult {
        InvestmentResult(input: investmentInput, propertyInput: input, result: result)
    }
    
    // MARK: - Quick Actions
    
    public func setEquityPercentage(_ percentage: Double) {
        // Calculate based on Kaufpreis + Nebenkosten
        let kaufpreis = input.kaufpreis
        let nebenkosten = kaufpreis * ((input.aktiverSteuersatz + input.notarGrundbuchSatz + input.aktiverMaklersatz) / 100.0)
        let total = kaufpreis + nebenkosten + input.modernisierungskosten
        let newEquity = total * (percentage / 100.0)
        // Round to clean thousands
        input.eigenkapital = (newEquity / 1000.0).rounded() * 1000.0
    }
    
    public func adjustInterest(delta: Double) {
        let updated = max(0.1, input.sollzins + delta)
        input.sollzins = (updated * 100).rounded() / 100.0
    }
    
    public func adjustRepayment(delta: Double) {
        let updated = max(0.5, input.tilgungssatz + delta)
        input.tilgungssatz = (updated * 100).rounded() / 100.0
    }
    
    public func resetToDefaults() {
        input = PropertyInput()
        investmentInput = InvestmentInput()
    }
    
    // MARK: - Scenarios
    
    public func saveScenario(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty ? "Szenario \(savedScenarios.count + 1)" : trimmed
        let scenario = SavedScenario(name: finalName, input: input)
        savedScenarios.append(scenario)
        persistScenarios()
    }
    
    public func applyScenario(_ scenario: SavedScenario) {
        self.input = scenario.input
    }
    
    public func deleteScenario(at offsets: IndexSet) {
        savedScenarios.remove(atOffsets: offsets)
        persistScenarios()
    }
    
    private func persistScenarios() {
        if let encoded = try? JSONEncoder().encode(savedScenarios) {
            UserDefaults.standard.set(encoded, forKey: scenariosKey)
        }
    }
    
    private func loadSavedScenarios() {
        if let data = UserDefaults.standard.data(forKey: scenariosKey),
           let decoded = try? JSONDecoder().decode([SavedScenario].self, data) {
            self.savedScenarios = decoded
        }
    }
    
    private func saveCurrentState() {
        if let encoded = try? JSONEncoder().encode(input) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Formatting Helpers
    
    public func formatCurrency(_ value: Double, fractionDigits: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        formatter.locale = Locale(identifier: "de_DE")
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value)) €"
    }
    
    public func formatPercent(_ value: Double, decimals: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de_DE")
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
        return "\(formatted) %"
    }
    
    public func formatDuration(years: Double) -> String {
        let totalMonths = Int((years * 12).rounded())
        let y = totalMonths / 12
        let m = totalMonths % 12
        if m == 0 {
            return "\(y) Jahre"
        } else {
            return "\(y) J. \(m) M."
        }
    }
    
    // MARK: - Export Summary
    
    public func generateExportSummary() -> String {
        let res = result
        return """
        ========================================
        IMMOBILIEN-KAUFRECHNER - ZUSAMMENFASSUNG
        ========================================
        Datum: \(Date().formatted(date: .numeric, time: .shortened))

        1. OBJEKT & KOSTEN
        ----------------------------------------
        Kaufpreis:              \(formatCurrency(input.kaufpreis))
        Bundesland:             \(input.bundesland.rawValue) (\(formatPercent(input.aktiverSteuersatz)))
        Grunderwerbsteuer:      \(formatCurrency(res.grunderwerbsteuer))
        Notar & Grundbuch:      \(formatCurrency(res.notarGrundbuchKosten)) (\(formatPercent(input.notarGrundbuchSatz)))
        Maklerprovision:        \(formatCurrency(res.maklerKosten)) (\(formatPercent(input.aktiverMaklersatz)))
        Kaufnebenkosten gesamt: \(formatCurrency(res.kaufnebenkostenGesamt)) (\(formatPercent(res.kaufnebenkostenProzent, decimals: 1)))
        Modernisierungskosten:  \(formatCurrency(input.modernisierungskosten))
        GESAMTKOSTEN:           \(formatCurrency(res.gesamtkosten))

        2. FINANZIERUNG
        ----------------------------------------
        Eigenkapital:           \(formatCurrency(input.eigenkapital)) (\(formatPercent(res.eigenkapitalQuote, decimals: 1)))
        Darlehensbetrag:        \(formatCurrency(res.darlehensbetrag))
        Sollzins:               \(formatPercent(input.sollzins)) p.a.
        Zinsbindung:            \(input.zinsbindungJahre) Jahre
        Anfängliche Tilgung:    \(formatPercent(res.anfaenglicherTilgungssatz)) p.a.
        Sondertilgung/Jahr:     \(formatCurrency(input.sondertilgungProJahr))

        3. ERGEBNISSE & RATEN
        ----------------------------------------
        MONATLICHE RATE:        \(formatCurrency(res.monatlicheRate, fractionDigits: 2))
        - Anfänglicher Zins:    \(formatCurrency(res.anfaenglicheMonatsZinsen, fractionDigits: 2)) / Monat
        - Anfängliche Tilgung:  \(formatCurrency(res.anfaenglicheMonatsTilgung, fractionDigits: 2)) / Monat

        Restschuld nach \(input.zinsbindungJahre) J.:   \(formatCurrency(res.restschuldNachZinsbindung))
        Gezahlte Zinsen (Bindung):  \(formatCurrency(res.gezahlteZinsenInZinsbindung))
        Gezahlte Tilgung (Bindung): \(formatCurrency(res.gezahlteTilgungInZinsbindung))
        Laufzeit bis Volltilgung:   \(formatDuration(years: res.gesamtlaufzeitJahre))
        Gesamtzinsen (Volltilgung): \(formatCurrency(res.zinsenBisVolltilgung))
        Gesamtrückzahlung:          \(formatCurrency(res.gesamtRueckzahlung))
        Empfohlenes Netto-Einkommen: \(formatCurrency(res.empfohlenesNettoeinkommen)) / Monat

        Erstellt mit ImmobilienRechner für iPhone & Mac
        ========================================
        """
    }
}
