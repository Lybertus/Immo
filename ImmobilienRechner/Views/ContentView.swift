import SwiftUI

public enum NavigationTab: String, CaseIterable, Identifiable {
    case eingabe = "Eingabe"
    case budget = "Budget"
    case uebersicht = "Übersicht"
    case tilgungsplan = "Tilgungsplan"
    case rendite = "Rendite"
    case vergleich = "Vergleich"
    case einstellungen = "Einstellungen"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .eingabe: return "slider.horizontal.3"
        case .budget: return "wallet.pass.fill"
        case .uebersicht: return "chart.pie.fill"
        case .tilgungsplan: return "list.bullet.rectangle.portrait.fill"
        case .rendite: return "eurosign.circle.fill"
        case .vergleich: return "square.split.2x2.fill"
        case .einstellungen: return "gearshape.fill"
        }
    }
}

public struct ContentView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @State private var selectedTab: NavigationTab = .eingabe
    @State private var showResetConfirmation: Bool = false
    
    public init() {}
    
    public var body: some View {
        #if os(macOS)
        // MacBook Pro M4 Native Split-View Layout
        NavigationSplitView {
            List(NavigationTab.allCases, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.rawValue, systemImage: tab.icon)
                }
            }
            .navigationTitle("ImmoCalc Pro")
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem {
                    Button(action: { showResetConfirmation = true }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .help("Auf Standardwerte zurücksetzen")
                }
            }
        } detail: {
            NavigationStack {
                detailView(for: selectedTab)
                    .navigationTitle(selectedTab.rawValue)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            ShareLink(item: viewModel.generateExportSummary()) {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .help("Zusammenfassung exportieren")
                        }
                    }
            }
        }
        .frame(minWidth: 880, minHeight: 620)
        .preferredColorScheme(viewModel.selectedAppearanceMode.colorScheme)
        .tint(viewModel.selectedAccentColor.color)
        .confirmationDialog("Zurücksetzen?", isPresented: $showResetConfirmation) {
            Button("Auf Standardwerte zurücksetzen", role: .destructive) {
                viewModel.resetToDefaults()
            }
            Button("Abbrechen", role: .cancel) {}
        }
        #else
        // iPhone 15 Pro Max Layout with Native TabBar & NavigationStack
        TabView(selection: $selectedTab) {
            NavigationStack {
                CalculatorInputView(viewModel: viewModel)
                    .navigationTitle("Immobilien-Rechner")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showResetConfirmation = true }) {
                                Image(systemName: "arrow.counterclockwise")
                            }
                        }
                    }
            }
            .tabItem {
                Label("Eingabe", systemImage: "slider.horizontal.3")
            }
            .tag(NavigationTab.eingabe)
            
            NavigationStack {
                AffordabilityView(viewModel: viewModel)
                    .navigationTitle("Budget & Haushalt")
            }
            .tabItem {
                Label("Budget", systemImage: "wallet.pass.fill")
            }
            .tag(NavigationTab.budget)
            
            NavigationStack {
                ResultsSummaryView(viewModel: viewModel)
                    .navigationTitle("Ergebnis")
            }
            .tabItem {
                Label("Übersicht", systemImage: "chart.pie.fill")
            }
            .tag(NavigationTab.uebersicht)
            
            NavigationStack {
                AmortizationTableView(viewModel: viewModel)
                    .navigationTitle("Tilgungsplan")
            }
            .tabItem {
                Label("Tilgungsplan", systemImage: "list.bullet.rectangle.portrait.fill")
            }
            .tag(NavigationTab.tilgungsplan)
            
            NavigationStack {
                InvestmentYieldView(viewModel: viewModel)
                    .navigationTitle("Rendite")
            }
            .tabItem {
                Label("Rendite", systemImage: "eurosign.circle.fill")
            }
            .tag(NavigationTab.rendite)
            
            NavigationStack {
                ComparisonView(viewModel: viewModel)
                    .navigationTitle("Vergleich")
            }
            .tabItem {
                Label("Vergleich", systemImage: "square.split.2x2.fill")
            }
            .tag(NavigationTab.vergleich)
            
            NavigationStack {
                SettingsView(viewModel: viewModel)
                    .navigationTitle("Einstellungen")
            }
            .tabItem {
                Label("Design", systemImage: "paintpalette.fill")
            }
            .tag(NavigationTab.einstellungen)
        }
        .preferredColorScheme(viewModel.selectedAppearanceMode.colorScheme)
        .tint(viewModel.selectedAccentColor.color)
        .confirmationDialog("Zurücksetzen?", isPresented: $showResetConfirmation) {
            Button("Auf Standardwerte zurücksetzen", role: .destructive) {
                viewModel.resetToDefaults()
            }
            Button("Abbrechen", role: .cancel) {}
        }
        #endif
    }
    
    @ViewBuilder
    private func detailView(for tab: NavigationTab) -> some View {
        switch tab {
        case .eingabe:
            CalculatorInputView(viewModel: viewModel)
        case .budget:
            AffordabilityView(viewModel: viewModel)
        case .uebersicht:
            ResultsSummaryView(viewModel: viewModel)
        case .tilgungsplan:
            AmortizationTableView(viewModel: viewModel)
        case .rendite:
            InvestmentYieldView(viewModel: viewModel)
        case .vergleich:
            ComparisonView(viewModel: viewModel)
        case .einstellungen:
            SettingsView(viewModel: viewModel)
        }
    }
}
