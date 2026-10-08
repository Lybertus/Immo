import Foundation
import SwiftUI
import Combine

public class CalculatorViewModel: ObservableObject {
    // MARK: - Inputs
    @Published public var input: PropertyInput {
        didSet { saveCurrentState() }
    }
    
    @Published public var investmentInput: InvestmentInput {
        didSet { saveCurrentState() }
    }
    
    @Published public var affordabilityInput: AffordabilityInput {
        didSet { saveAffordabilityState() }
    }
    
    // MARK: - Market Rates Data (Interhyp Benchmark)
    @Published public var marketRates: MarketInterestRates = MarketInterestRates()
    
    // MARK: - Goal & Mode
    @Published public var selectedGoal: CalculationGoal = .purchasePriceToRate
    @Published public var isInvestmentModeActive: Bool = false
    
    // MARK: - Themes & Customization
    @Published public var selectedAppearanceMode: AppearanceMode = .system {
        didSet { UserDefaults.standard.set(selectedAppearanceMode.rawValue, forKey: appearanceKey) }
    }
    
    @Published public var selectedDesignStyle: DesignStyle = .modern {
        didSet { UserDefaults.standard.set(selectedDesignStyle.rawValue, forKey: styleKey) }
    }
    
    @Published public var selectedAccentColor: AppAccentColor = .appleBlue {
        didSet { UserDefaults.standard.set(selectedAccentColor.rawValue, forKey: colorKey) }
    }
    
    // MARK: - Scenarios
    @Published public var savedScenarios: [SavedScenario] = []
    
    // MARK: - Keys
    private let userDefaultsKey = "immobilien_rechner_state_v3"
    private let affordabilityKey = "immobilien_rechner_affordability_v3"
    private let scenariosKey = "immobilien_rechner_scenarios_v3"
    private let appearanceKey = "immobilien_rechner_appearance_v3"
    private let styleKey = "immobilien_rechner_style_v3"
    private let colorKey = "immobilien_rechner_color_v3"
    
    public init() {
        // Load Property State
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(PropertyInput.self, data) {
            self.input = saved
        } else {
            self.input = PropertyInput()
        }
        
        // Load Affordability State
        if let data = UserDefaults.standard.data(forKey: affordabilityKey),
           let savedAff = try? JSONDecoder().decode(AffordabilityInput.self, data) {
            self.affordabilityInput = savedAff
        } else {
            self.affordabilityInput = AffordabilityInput()
        }
        
        self.investmentInput = InvestmentInput()
        
        // Load Themes
        if let rawApp = UserDefaults.standard.string(forKey: appearanceKey),
           let mode = AppearanceMode(rawValue: rawApp) {
            self.selectedAppearanceMode = mode
        }
        if let rawStyle = UserDefaults.standard.string(forKey: styleKey),
           let style = DesignStyle(rawValue: rawStyle) {
            self.selectedDesignStyle = style
        }
        if let rawColor = UserDefaults.standard.string(forKey: colorKey),
           let col = AppAccentColor(rawValue: rawColor) {
            self.selectedAccentColor = col
        }
        
        self.loadSavedScenarios()
    }
    
    // MARK: - Computed Results
    
    public var result: CalculationResult {
        MortgageCalculator.calculate(input: input)
    }
    
    public var investmentResult: InvestmentResult {
        InvestmentResult(input: investmentInput, propertyInput: input, result: result)
    }
    
    public var affordabilityResult: AffordabilityResult {
        AffordabilityResult(input: affordabilityInput)
    }
    
    public var maxBudgetCalculation: (maxDarlehen: Double, maxKaufpreis: Double, maxGesamtbudget: Double) {
        let nebenkostenSatz = input.aktiverSteuersatz + input.notarGrundbuchSatz + input.aktiverMaklersatz
        return AffordabilityResult.calculateMaxPurchasePrice(
            maxRate: affordabilityResult.maxMonatsrate,
            sollzins: input.sollzins,
            tilgung: input.tilgungssatz,
            eigenkapital: input.eigenkapital,
            nebenkostenSatz: nebenkostenSatz,
            modernisierung: input.modernisierungskosten
        )
    }
    
    public var requiredTilgungForTargetYears: Double {
        AffordabilityResult.calculateRequiredTilgung(
            sollzins: input.sollzins,
            zielJahre: affordabilityInput.geplanteWunschlaufzeitJahre
        )
    }
    
    // MARK: - Market Rates & Term Update
    
    /// Ändert die Zinsbindung und passt automatisch den Sollzins an den aktuellen Interhyp-Marktzins an
    public func setInterestTerm(_ years: Int) {
        input.zinsbindungJahre = years
        if input.autoUpdateInterestWithMarketBenchmark {
            let marketRate = marketRates.rate(for: years)
            input.sollzins = marketRate
        }
    }
    
    public func applyMarketBenchmarkRate() {
        let marketRate = marketRates.rate(for: input.zinsbindungJahre)
        input.sollzins = marketRate
    }
    
    // MARK: - Quick Actions
    
    public func applyBudgetToPurchasePrice() {
        let maxKaufpreis = maxBudgetCalculation.maxKaufpreis
        let gerundet = (maxKaufpreis / 5000.0).rounded() * 5000.0
        input.kaufpreis = max(50_000, gerundet)
        selectedGoal = .purchasePriceToRate
    }
    
    public func applyRecommendedRepayment() {
        input.tilgungssatz = 2.0
    }
    
    public func applyRequiredTilgung() {
        input.tilgungssatz = requiredTilgungForTargetYears
    }
    
    public func setEquityPercentage(_ percentage: Double) {
        let kaufpreis = input.kaufpreis
        let nebenkosten = kaufpreis * ((input.aktiverSteuersatz + input.notarGrundbuchSatz + input.aktiverMaklersatz) / 100.0)
        let total = kaufpreis + nebenkosten + input.modernisierungskosten
        let newEquity = total * (percentage / 100.0)
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
        affordabilityInput = AffordabilityInput()
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
    
    private func saveAffordabilityState() {
        if let encoded = try? JSONEncoder().encode(affordabilityInput) {
            UserDefaults.standard.set(encoded, forKey: affordabilityKey)
        }
    }
    
    // MARK: - Formatters
    
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
        let aff = affordabilityResult
        return """
        ====================================================
        IMMOBILIEN-KAUFRECHNER PRO (Interhyp Standard)
        ====================================================
        Datum: \(Date().formatted(date: .numeric, time: .shortened))

        1. HAUSHALTS- & BUDGETCHECK
        ----------------------------------------------------
        Monatliches Nettoeinkommen:   \(formatCurrency(affordabilityInput.haushaltsNettoeinkommen))
        Wohnkosten-Quote:             \(formatPercent(affordabilityInput.wohnkostenQuote, decimals: 1)) (\(aff.risikotext))
        Verfügbare Monatsrate:        \(formatCurrency(aff.maxMonatsrate, fractionDigits: 2))
        Freies Einkommen nach Rate:   \(formatCurrency(aff.verfuegbarNachFixkosten))

        2. OBJEKT & KOSTEN
        ----------------------------------------------------
        Kaufpreis:                    \(formatCurrency(input.kaufpreis))
        Bundesland:                   \(input.bundesland.rawValue) (\(formatPercent(input.aktiverSteuersatz)))
        Grunderwerbsteuer:            \(formatCurrency(res.grunderwerbsteuer))
        Notar & Grundbuch:            \(formatCurrency(res.notarGrundbuchKosten)) (\(formatPercent(input.notarGrundbuchSatz)))
        Maklerprovision:              \(formatCurrency(res.maklerKosten)) (\(formatPercent(input.aktiverMaklersatz)))
        Kaufnebenkosten gesamt:       \(formatCurrency(res.kaufnebenkostenGesamt)) (\(formatPercent(res.kaufnebenkostenProzent, decimals: 1)))
        Modernisierungsbudget:        \(formatCurrency(input.modernisierungskosten))
        GESAMTINVESTITION:            \(formatCurrency(res.gesamtkosten))

        3. FINANZIERUNGSKONDITIONEN
        ----------------------------------------------------
        Eigenkapital:                 \(formatCurrency(input.eigenkapital)) (\(formatPercent(res.eigenkapitalQuote, decimals: 1)))
        Darlehensbetrag:              \(formatCurrency(res.darlehensbetrag))
        Sollzinssatz:                 \(formatPercent(input.sollzins)) p.a. (Interhyp Referenz für \(input.zinsbindungJahre) Jahre)
        Zinsbindung:                  \(input.zinsbindungJahre) Jahre
        Anschlussfinanzierung:        \(input.anschlussOption.rawValue) (\(formatPercent(input.effektiverAnschlussZins)))
        Anfängliche Tilgung:          \(formatPercent(res.anfaenglicherTilgungssatz)) p.a. (Empfehlung: 2,0 %)
        Sondertilgung pro Jahr:       \(formatCurrency(input.sondertilgungProJahr))

        4. FINANZIERUNGSERGEBNIS
        ----------------------------------------------------
        MONATLICHE RATE:              \(formatCurrency(res.monatlicheRate, fractionDigits: 2))
        - Davon anfänglicher Zins:    \(formatCurrency(res.anfaenglicheMonatsZinsen, fractionDigits: 2))
        - Davon anfängliche Tilgung:  \(formatCurrency(res.anfaenglicheMonatsTilgung, fractionDigits: 2))

        Restschuld nach Zinsbindung:  \(formatCurrency(res.restschuldNachZinsbindung))
        Gezahlte Zinsen (Bindung):    \(formatCurrency(res.gezahlteZinsenInZinsbindung))
        Gezahlte Tilgung (Bindung):   \(formatCurrency(res.gezahlteTilgungInZinsbindung))
        Laufzeit bis Volltilgung:     \(formatDuration(years: res.gesamtlaufzeitJahre))
        Gesamtzinsen bis 0 €:         \(formatCurrency(res.zinsenBisVolltilgung))
        Gesamtrückzahlung:            \(formatCurrency(res.gesamtRueckzahlung))
        
        Erstellt mit ImmobilienRechner Pro (iOS & macOS)
        ====================================================
        """
    }
}
