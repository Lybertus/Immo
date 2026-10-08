import SwiftUI

public struct AffordabilityView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    @State private var showAppliedAlert: Bool = false
    @State private var alertMessage: String = ""
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        let aff = viewModel.affordabilityResult
        let budget = viewModel.maxBudgetCalculation
        let accentColor = viewModel.selectedAccentColor.color
        
        ScrollView {
            VStack(spacing: 20) {
                // MARK: 1. Hero Card: Maximale Rate & Freies Netto
                VStack(spacing: 12) {
                    Text("MAXIMAL EMPFOHLENE MONATSRATE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(accentColor)
                        .tracking(1.2)
                    
                    Text(viewModel.formatCurrency(aff.maxMonatsrate, fractionDigits: 2))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    // Risk badge
                    HStack(spacing: 6) {
                        Image(systemName: aff.risikostufe == .optimal ? "checkmark.circle.fill" : "info.circle.fill")
                        Text(aff.risikotext)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(colorForRisk(aff.risikostufe))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(colorForRisk(aff.risikostufe).opacity(0.12))
                    .clipShape(Capsule())
                    
                    Divider().padding(.horizontal, 20)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Freies Einkommen danach:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(viewModel.formatCurrency(aff.verfuegbarNachFixkosten))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Wohnkosten-Quote:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(viewModel.formatPercent(viewModel.affordabilityInput.wohnkostenQuote, decimals: 1))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(accentColor)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: viewModel.selectedDesignStyle.cornerRadius)
                        .fill(accentColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: viewModel.selectedDesignStyle.cornerRadius)
                                .stroke(accentColor.opacity(0.25), lineWidth: 1.5)
                        )
                )
                
                // MARK: 2. Maximaler Kaufpreis (Budget-Kalkulation)
                VStack(alignment: .leading, spacing: 14) {
                    Text("Dein maximaler Immobilien-Kaufpreis")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Max. Kaufpreis der Immobilie:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(viewModel.formatCurrency(budget.maxKaufpreis))
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(accentColor)
                            }
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Gesamtbudget:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(viewModel.formatCurrency(budget.maxGesamtbudget))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Text("Berechnet bei \(viewModel.formatPercent(viewModel.input.sollzins)) Zins, \(viewModel.formatPercent(viewModel.input.tilgungssatz)) Tilgung, \(viewModel.formatCurrency(viewModel.input.eigenkapital)) Eigenkapital und \(viewModel.input.bundesland.rawValue) als Standort.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            viewModel.applyBudgetToPurchasePrice()
                            alertMessage = "Der Kaufpreis von \(viewModel.formatCurrency(budget.maxKaufpreis)) wurde in den Hauptrechner übertragen!"
                            showAppliedAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.forward.and.arrow.up.backward")
                                Text("Diesen Kaufpreis in den Hauptrechner übernehmen")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(accentColor)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: viewModel.selectedDesignStyle.cornerRadius)
                            .fill(Color(PlatformColor.secondarySystemBackground))
                    )
                }
                
                // MARK: 3. Haushaltsdaten Eingabe
                VStack(alignment: .leading, spacing: 14) {
                    Text("Haushaltseinkommen & Fixkosten")
                        .font(.headline)
                    
                    VStack(spacing: 16) {
                        CurrencyInputField(
                            title: "Monatliches Haushaltsnettoeinkommen",
                            subtitle: "Alle regelmäßigen Nettoeinkünfte zusammen",
                            value: $viewModel.affordabilityInput.haushaltsNettoeinkommen,
                            step: 100,
                            minValue: 1_000,
                            maxValue: 25_000,
                            quickButtons: [3_000, 4_000, 4_500, 5_500, 7_000, 9_000]
                        )
                        
                        // Wohnkosten Quote Slider mit Schnellwahl-Buttons
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Wohnkosten-Abschlag für die Kreditrate")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(viewModel.formatPercent(viewModel.affordabilityInput.wohnkostenQuote, decimals: 1))
                                    .font(.headline)
                                    .foregroundColor(accentColor)
                            }
                            
                            Slider(value: $viewModel.affordabilityInput.wohnkostenQuote, in: 20...45, step: 1.0)
                                .accentColor(accentColor)
                            
                            HStack(spacing: 8) {
                                quotePill(25, label: "25 % (Vorsichtig)")
                                quotePill(30, label: "30 % (Konservativ)")
                                quotePill(35, label: "35 % (Empfehlung ⭐)")
                                quotePill(40, label: "40 % (Maximum)")
                            }
                        }
                        
                        CurrencyInputField(
                            title: "Bestehende monatliche Raten",
                            subtitle: "z.B. Autokredite, Leasing, Unterhalt etc.",
                            value: $viewModel.affordabilityInput.sonstigeVerbindlichkeiten,
                            step: 50,
                            minValue: 0,
                            maxValue: 5_000,
                            quickButtons: [0, 150, 300, 500]
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: viewModel.selectedDesignStyle.cornerRadius)
                            .fill(Color(PlatformColor.secondarySystemBackground))
                    )
                }
                
                // MARK: 4. Wunschlaufzeit & Tilgungsziel (z.B. bis zur Rente)
                VStack(alignment: .leading, spacing: 14) {
                    Text("Laufzeit-Ziel (z. B. Schuldenfrei bis zur Rente)")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        CustomSliderField(
                            title: "Geplante Gesamtlaufzeit",
                            subtitle: "In wie vielen Jahren möchtest du schuldenfrei sein?",
                            value: $viewModel.affordabilityInput.geplanteWunschlaufzeitJahre,
                            range: 10...40,
                            step: 1.0,
                            unit: "Jahre",
                            decimals: 0,
                            presetButtons: [15, 20, 25, 30]
                        )
                        
                        HStack {
                            Text("Dafür erforderliche Tilgung:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.formatPercent(viewModel.requiredTilgungForTargetYears))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(accentColor)
                        }
                        .padding(.top, 4)
                        
                        Button(action: {
                            viewModel.applyRequiredTilgung()
                            alertMessage = "Tilgungssatz von \(viewModel.formatPercent(viewModel.requiredTilgungForTargetYears)) wurde im Rechner hinterlegt!"
                            showAppliedAlert = true
                        }) {
                            Text("Diese Tilgung (\(viewModel.formatPercent(viewModel.requiredTilgungForTargetYears))) im Rechner aktivieren")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(accentColor.opacity(0.12))
                                .foregroundColor(accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: viewModel.selectedDesignStyle.cornerRadius)
                            .fill(Color(PlatformColor.secondarySystemBackground))
                    )
                }
                
                // MARK: Experten-Empfehlungen
                if viewModel.showBeginnerTips {
                    ExpertTipsCardView(
                        tab: .budget,
                        accentColor: accentColor,
                        cornerRadius: viewModel.selectedDesignStyle.cornerRadius
                    )
                }
            }
            .padding(16)
        }
        .alert("Wert übernommen", isPresented: $showAppliedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func quotePill(_ value: Double, label: String) -> some View {
        Button(action: {
            viewModel.affordabilityInput.wohnkostenQuote = value
        }) {
            let isSelected = abs(viewModel.affordabilityInput.wohnkostenQuote - value) < 0.5
            Text(label)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? viewModel.selectedAccentColor.color.opacity(0.2) : Color(PlatformColor.secondarySystemBackground))
                )
                .foregroundColor(isSelected ? viewModel.selectedAccentColor.color : .secondary)
        }
        .buttonStyle(.plain)
    }
    
    private func colorForRisk(_ risk: AffordabilityResult.RiskLevel) -> Color {
        switch risk {
        case .konservativ: return .green
        case .optimal: return viewModel.selectedAccentColor.color
        case .erhoeht: return .orange
        case .kritisch: return .red
        }
    }
}
