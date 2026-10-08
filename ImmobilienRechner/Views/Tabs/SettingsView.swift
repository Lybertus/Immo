import SwiftUI

public struct SettingsView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    @State private var showResetDialog: Bool = false
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Form {
            // MARK: 1. Erscheinungsbild & Dark Mode
            Section(header: Label("Erscheinungsbild", systemImage: "circle.lefthalf.filled")) {
                Picker("Farbschema", selection: $viewModel.selectedAppearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Designstil", selection: $viewModel.selectedDesignStyle) {
                    ForEach(DesignStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
            }
            
            // MARK: 2. Große Akzentfarben-Palette
            Section(header: Label("Akzentfarbe (\(viewModel.selectedAccentColor.rawValue))", systemImage: "paintpalette.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Wähle deine persönliche Akzentfarbe für Diagramme, Buttons und Kennzahlen:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(AppAccentColor.allCases) { option in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectedAccentColor = option
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 42, height: 42)
                                        .shadow(color: option.color.opacity(0.35), radius: 4, x: 0, y: 2)
                                    
                                    if viewModel.selectedAccentColor == option {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .help(option.rawValue)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .padding(.vertical, 4)
            }
            
            // MARK: 3. Lernhilfe & Einsteiger-Tipps
            Section(header: Label("Lernhilfe & Einsteiger-Tipps", systemImage: "graduationcap.fill")) {
                Toggle(isOn: $viewModel.showBeginnerTips) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Experten-Tipps in allen Reitern anzeigen")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Blendet fundierte Faustregeln, Interhyp-Standards und Warnhinweise für Einsteiger in jedem Reiter ein.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .tint(viewModel.selectedAccentColor.color)
                
                if viewModel.showBeginnerTips {
                    ExpertTipsCardView(
                        tab: .einstellungen,
                        accentColor: viewModel.selectedAccentColor.color,
                        cornerRadius: viewModel.selectedDesignStyle.cornerRadius
                    )
                    .padding(.vertical, 4)
                }
            }
            
            // MARK: 3b. Interhyp-Wissen
            Section(header: Label("Finanz-Wissen", systemImage: "lightbulb.fill")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                        Text("Warum werden 2 % Tilgung empfohlen?")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Bei einem Zinsniveau von 3,5 % bis 4,0 % sorgt eine anfängliche Tilgung von 2,0 % für eine solide Gesamtlaufzeit von ca. 26–29 Jahren. Eine Tilgung von unter 1,5 % verlängert die Laufzeit oft auf über 40 Jahre und birgt ein hohes Zinsänderungsrisiko nach Ende der Zinsbindung.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .foregroundColor(.orange)
                        Text("Die 30–35 % Haushaltsnetto-Regel")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Banken und Verbraucherschützer (wie Interhyp & Stiftung Warentest) empfehlen, maximal 30 % bis 35 % des bereinigten Haushaltsnettoeinkommens für die monatliche Kreditrate aufzuwenden. So bleibt genügend Spielraum für Instandhaltungsrücklagen, Nebenkosten und unvorhergesehene Ausgaben.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            // MARK: 4. Zurücksetzen
            Section {
                Button(role: .destructive, action: { showResetDialog = true }) {
                    Label("Alle Eingaben zurücksetzen", systemImage: "arrow.counterclockwise")
                        .foregroundColor(.red)
                }
            }
        }
        .confirmationDialog("Zurücksetzen?", isPresented: $showResetDialog) {
            Button("Auf Standardwerte zurücksetzen", role: .destructive) {
                viewModel.resetToDefaults()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Möchtest du wirklich alle Rechenwerte und Budgets auf die Standardwerte zurücksetzen?")
        }
    }
}
