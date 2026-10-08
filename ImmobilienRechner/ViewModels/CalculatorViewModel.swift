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
    
    @Published public var rentVsBuyInput: RentVsBuyInput {
        didSet { saveRentVsBuyState() }
    }
    
    // MARK: - Market Rates Data (Interhyp Benchmark)
    @Published public var marketRates: MarketInterestRates = MarketInterestRates()
    @Published public var selectedCity: CityLocation? = nil
    
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
    
    // MARK: - Einsteiger-Empfehlungen
    @Published public var showBeginnerTips: Bool = true {
        didSet { UserDefaults.standard.set(showBeginnerTips, forKey: beginnerTipsKey) }
    }
    
    // MARK: - Scenarios
    @Published public var savedScenarios: [SavedScenario] = []
    
    // MARK: - Keys
    private let userDefaultsKey = "immobilien_rechner_state_v4"
    private let affordabilityKey = "immobilien_rechner_affordability_v4"
    private let rentVsBuyKey = "immobilien_rechner_rentvsbuy_v4"
    private let scenariosKey = "immobilien_rechner_scenarios_v4"
    private let appearanceKey = "immobilien_rechner_appearance_v4"
    private let styleKey = "immobilien_rechner_style_v4"
    private let colorKey = "immobilien_rechner_color_v4"
    private let beginnerTipsKey = "immobilien_rechner_beginnertips_v4"
    
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
        
        // Load Rent vs Buy State
        if let data = UserDefaults.standard.data(forKey: rentVsBuyKey),
           let savedRvB = try? JSONDecoder().decode(RentVsBuyInput.self, data) {
            self.rentVsBuyInput = savedRvB
        } else {
            self.rentVsBuyInput = RentVsBuyInput()
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
        
        // Load Beginner Tips setting
        if UserDefaults.standard.object(forKey: beginnerTipsKey) != nil {
            self.showBeginnerTips = UserDefaults.standard.bool(forKey: beginnerTipsKey)
        } else {
            self.showBeginnerTips = true
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
    
    public var rentVsBuyResult: RentVsBuyResult {
        RentVsBuyCalculator.calculate(
            input: rentVsBuyInput,
            propertyInput: input,
            mortgageResult: result
        )
    }
    
    public var affordabilityIndexResult: AffordabilityIndexResult {
        AffordabilityIndexResult.calculate(
            haushaltsNetto: affordabilityInput.haushaltsNettoeinkommen,
            wohnkostenQuote: affordabilityInput.wohnkostenQuote,
            sollzins: input.sollzins,
            tilgung: input.tilgungssatz,
            eigenkapital: input.eigenkapital,
            kaufpreis: input.kaufpreis,
            wohnflaecheQm: rentVsBuyInput.wohnflaecheQm
        )
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
    
    /// Übernimmt die Marktdaten einer Stadt in den Kaufrechner
    public func applyCityData(_ city: CityLocation, isHouse: Bool) {
        self.selectedCity = city
        self.input.bundesland = city.bundesland
        if isHouse {
            self.input.kaufpreis = city.avgHaus140qm
            self.rentVsBuyInput.wohnflaecheQm = 140
            self.rentVsBuyInput.aktuelleKaltmiete = city.avgKaltmieteQm * 140.0
        } else {
            self.input.kaufpreis = city.avgWohnung80qm
            self.rentVsBuyInput.wohnflaecheQm = 80
            self.rentVsBuyInput.aktuelleKaltmiete = city.avgMiete80qm
        }
        self.selectedGoal = .purchasePriceToRate
    }
    
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
        rentVsBuyInput = RentVsBuyInput()
        showBeginnerTips = true
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
    
    private func saveRentVsBuyState() {
        if let encoded = try? JSONEncoder().encode(rentVsBuyInput) {
            UserDefaults.standard.set(encoded, forKey: rentVsBuyKey)
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
        let rvb = rentVsBuyResult
        let idx = affordabilityIndexResult
        
        return """
        ====================================================
        IMMOBILIEN-KAUFRECHNER PRO (Interhyp Standard)
        ====================================================
        Datum: \(Date().formatted(date: .numeric, time: .shortened))

        1. INTERHYP-ERSCHWINGLICHKEITSINDEX
        ----------------------------------------------------
        Indexwert:                    \(Int(idx.indexScore)) Punkte (\(idx.bewertungStufe.rawValue))
        Leistbare Wohnfläche:         \(Int(idx.leistbareWohnflaecheQm)) m²
        Quadratmeterpreis Objekt:     \(formatCurrency(idx.qmPreisObjekt)) / m²
        Fazit:                        \(idx.beschreibung)

        2. MIETEN VS. KAUFEN VERGLEICH
        ----------------------------------------------------
        Aktuelle Kaltmiete:           \(formatCurrency(rentVsBuyInput.aktuelleKaltmiete)) / Monat
        Mietmultiplikator:            Faktor \(String(format: "%.1f", rvb.mietmultiplikator))
        Miet-Bewertung:               \(rvb.guenstigWohnenScore.rawValue)
        Break-Even (Kauf im Vorteil): \(rvb.breakEvenJahr.map { "nach \($0) Jahren" } ?? "über 40 Jahre")
        Vermögen Käufer (\(rentVsBuyInput.betrachtungszeitraumJahre) J.):     \(formatCurrency(rvb.vermoegenKaeufer))
        Vermögen Mieter (\(rentVsBuyInput.betrachtungszeitraumJahre) J.):     \(formatCurrency(rvb.vermoegenMieter))
        Vermögensvorteil:             \(formatCurrency(abs(rvb.vermoegensDifferenz))) zugunsten \(rvb.vermoegensDifferenz >= 0 ? "Käufer" : "Mieter")

        3. HAUSHALT & BUDGET
        ----------------------------------------------------
        Monatliches Nettoeinkommen:   \(formatCurrency(affordabilityInput.haushaltsNettoeinkommen))
        Wohnkosten-Quote:             \(formatPercent(affordabilityInput.wohnkostenQuote, decimals: 1)) (\(aff.risikotext))
        Verfügbare Monatsrate:        \(formatCurrency(aff.maxMonatsrate, fractionDigits: 2))

        4. OBJEKT & DARLEHEN
        ----------------------------------------------------
        Kaufpreis:                    \(formatCurrency(input.kaufpreis))
        Darlehensbetrag:              \(formatCurrency(res.darlehensbetrag))
        Sollzins:                     \(formatPercent(input.sollzins)) p.a.
        Zinsbindung:                  \(input.zinsbindungJahre) Jahre
        MONATLICHE RATE:              \(formatCurrency(res.monatlicheRate, fractionDigits: 2))
        Restschuld nach Bindung:      \(formatCurrency(res.restschuldNachZinsbindung))

        Erstellt mit ImmobilienRechner Pro (iOS & macOS)
        ====================================================
        """
    }
}
