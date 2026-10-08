import SwiftUI

public struct CalculatorInputView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    private var accent: Color {
        viewModel.selectedAccentColor.color
    }
    
    public var body: some View {
        Form {
            // MARK: Rechenziel-Auswahl
            Section(header: Label("Rechenziel wählen", systemImage: "target")) {
                Picker("Ziel", selection: $viewModel.selectedGoal) {
                    ForEach(CalculationGoal.allCases) { goal in
                        Label(goal.rawValue, systemImage: goal.icon).tag(goal)
                    }
                }
                .pickerStyle(.segmented)
                
                if viewModel.selectedGoal == .rateToPurchasePrice {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text("Im Tab **Budget** kannst du dein Haushaltsnetto eingeben und deinen maximalen Kaufpreis exakt berechnen.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            
            // Live Quick Banner
            Section {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MONATLICHE RATE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Text(viewModel.formatCurrency(viewModel.result.monatlicheRate, fractionDigits: 2))
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.heavy)
                                .foregroundColor(accent)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("DARLEHEN")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Text(viewModel.formatCurrency(viewModel.result.darlehensbetrag))
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Label("Gesamtkosten: \(viewModel.formatCurrency(viewModel.result.gesamtkosten))", systemImage: "cart.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label("EK-Quote: \(viewModel.formatPercent(viewModel.result.eigenkapitalQuote, decimals: 1))", systemImage: "shield.fill")
                            .font(.caption)
                            .foregroundColor(viewModel.result.eigenkapitalQuote >= 20 ? .green : .orange)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // 1. Objekt & Kaufpreis
            Section(header: Label("Objekt & Kaufnebenkosten", systemImage: "house.fill")) {
                CurrencyInputField(
                    title: "Kaufpreis (Tippen zum Ändern)",
                    subtitle: "Reiner Kaufpreis der Immobilie",
                    value: $viewModel.input.kaufpreis,
                    step: 10_000,
                    minValue: 50_000,
                    maxValue: 3_000_000,
                    quickButtons: [250_000, 350_000, 450_000, 600_000, 800_000, 1_000_000]
                )
                
                Picker("Bundesland", selection: $viewModel.input.bundesland) {
                    ForEach(FederalState.allCases) { state in
                        HStack {
                            Text(state.rawValue)
                            Spacer()
                            Text("\(String(format: "%.1f", state.taxRate)) %")
                                .foregroundColor(.secondary)
                        }
                        .tag(state)
                    }
                }
                
                CustomSliderField(
                    title: "Grunderwerbsteuer",
                    subtitle: "Automatisch nach Bundesland (\(viewModel.input.bundesland.rawValue))",
                    value: Binding(
                        get: { viewModel.input.aktiverSteuersatz },
                        set: { viewModel.input.customGrunderwerbsteuer = $0 }
                    ),
                    range: 3.5...7.5,
                    step: 0.1,
                    unit: "%",
                    decimals: 1
                )
                
                CustomSliderField(
                    title: "Notar & Grundbucheintrag",
                    subtitle: "Üblich sind ca. 1.5 % bis 2.0 %",
                    value: $viewModel.input.notarGrundbuchSatz,
                    range: 1.0...3.0,
                    step: 0.1,
                    unit: "%",
                    decimals: 1,
                    presetButtons: [1.5, 2.0]
                )
                
                Toggle("Maklerprovision anfällig", isOn: $viewModel.input.hatMakler)
                
                if viewModel.input.hatMakler {
                    CustomSliderField(
                        title: "Maklerprovision",
                        subtitle: "Käuferanteil inkl. MwSt. (oft 3,57 %)",
                        value: $viewModel.input.maklerSatz,
                        range: 0.5...7.14,
                        step: 0.01,
                        unit: "%",
                        decimals: 2,
                        presetButtons: [2.38, 3.57]
                    )
                }
                
                CurrencyInputField(
                    title: "Modernisierung / Renovierung",
                    subtitle: "Geplante Sanierungsmaßnahmen",
                    value: $viewModel.input.modernisierungskosten,
                    step: 5_000,
                    minValue: 0,
                    maxValue: 500_000,
                    quickButtons: [0, 15_000, 30_000, 50_000, 100_000]
                )
            }
            
            // 2. Eigenkapital
            Section(header: Label("Eigenkapital", systemImage: "banknote.fill")) {
                CurrencyInputField(
                    title: "Eigenkapital (Tippen zum Ändern)",
                    subtitle: "Verfügbares Erspartes für den Kauf",
                    value: $viewModel.input.eigenkapital,
                    step: 5_000,
                    minValue: 0,
                    maxValue: 2_000_000
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Schnellwahl Eigenkapital:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Button("Nur Nebenkosten") {
                            viewModel.input.eigenkapital = viewModel.result.kaufnebenkostenGesamt
                        }
                        .buttonStyle(.bordered)
                        
                        Button("15 % Quote") {
                            viewModel.setEquityPercentage(15)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("20 % Quote") {
                            viewModel.setEquityPercentage(20)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("30 % Quote") {
                            viewModel.setEquityPercentage(30)
                        }
                        .buttonStyle(.bordered)
                    }
                    .font(.caption2)
                }
            }
            
            // 3. Finanzierungskonditionen & Live-Zinsen
            Section(header: Label("Kreditkonditionen & Live-Zinsen", systemImage: "percent")) {
                // Zinsbindung Picker mit automatischer Interhyp-Marktzins-Anpassung
                VStack(alignment: .leading, spacing: 6) {
                    Text("Zinsbindung")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Zinsbindung", selection: Binding(
                        get: { viewModel.input.zinsbindungJahre },
                        set: { viewModel.setInterestTerm($0) }
                    )) {
                        Text("5 Jahre").tag(5)
                        Text("10 Jahre").tag(10)
                        Text("15 Jahre").tag(15)
                        Text("20 Jahre").tag(20)
                        Text("25 Jahre").tag(25)
                        Text("30 Jahre").tag(30)
                    }
                    .pickerStyle(.segmented)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Text("Aktueller Interhyp-Referenzzins (\(viewModel.input.zinsbindungJahre) J.): **\(viewModel.formatPercent(viewModel.marketRates.rate(for: viewModel.input.zinsbindungJahre)))**")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }
                
                CustomSliderField(
                    title: "Sollzins (p.a.)",
                    subtitle: "Aktuell voreingestellt nach Interhyp-Benchmark",
                    value: $viewModel.input.sollzins,
                    range: 0.5...8.0,
                    step: 0.05,
                    unit: "%",
                    decimals: 2,
                    presetButtons: [3.4, 3.6, 3.8, 4.0, 4.2]
                )
                
                // Anschlussfinanzierung
                VStack(alignment: .leading, spacing: 6) {
                    Picker("Anschlussfinanzierung", selection: $viewModel.input.anschlussOption) {
                        ForEach(RefinancingOption.allCases) { opt in
                            Text(opt.rawValue).tag(opt)
                        }
                    }
                    
                    Text("Nach Ablauf der \(viewModel.input.zinsbindungJahre) Jahre: Rechnet mit \(viewModel.formatPercent(viewModel.input.effektiverAnschlussZins)) weiter.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Picker("Berechnungsart", selection: $viewModel.input.calculationMode) {
                    ForEach(CalculationMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                if viewModel.input.calculationMode == .tilgungssatz {
                    VStack(alignment: .leading, spacing: 6) {
                        CustomSliderField(
                            title: "Anfängliche Tilgung (p.a.)",
                            subtitle: "Banken fordern meist mind. 1.5 - 2 %",
                            value: $viewModel.input.tilgungssatz,
                            range: 1.0...6.0,
                            step: 0.1,
                            unit: "%",
                            decimals: 1,
                            presetButtons: [1.5, 2.0, 2.5, 3.0]
                        )
                        
                        // 2% Empfehlungs-Badge
                        HStack(spacing: 8) {
                            Button(action: {
                                viewModel.applyRecommendedRepayment()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 11))
                                    Text("⭐ 2,0 % Empfehlung setzen")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(accent.opacity(0.12))
                                .foregroundColor(accent)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            Text("Empfehlung für solide Entschuldung")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 2)
                    }
                } else {
                    CurrencyInputField(
                        title: "Wunschrate monatlich",
                        subtitle: "Maximale Wunschrate für den Kredit",
                        value: $viewModel.input.wunschrate,
                        step: 50,
                        minValue: 300,
                        maxValue: 10_000
                    )
                }
                
                CurrencyInputField(
                    title: "Sondertilgung pro Jahr",
                    subtitle: "Oft bis zu 5 % der Kreditsumme kostenfrei möglich",
                    value: $viewModel.input.sondertilgungProJahr,
                    step: 500,
                    minValue: 0,
                    maxValue: 50_000,
                    quickButtons: [0, 1_500, 2_500, 5_000, 10_000]
                )
            }
            
            // MARK: Experten-Empfehlungen für Einsteiger
            if viewModel.showBeginnerTips {
                Section {
                    ExpertTipsCardView(
                        tab: .eingabe,
                        accentColor: accent,
                        cornerRadius: viewModel.selectedDesignStyle.cornerRadius
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 4, bottom: 6, trailing: 4))
                    .listRowBackground(Color.clear)
                }
            }
        }
    }
}
