import SwiftUI

/// Interaktive Karte zur Berechnung der maximalen Kreditsumme aus Laufzeit & monatlichem Abschlag inkl. Sondertilgungs- & Tilgungs-Empfehlungen
public struct LoanCapacityCardView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    @State private var showAppliedBanner: Bool = false
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        let cap = viewModel.loanCapacityResult
        let accent = viewModel.selectedAccentColor.color
        let radius = viewModel.selectedDesignStyle.cornerRadius
        
        VStack(alignment: .leading, spacing: 16) {
            // MARK: Header & Modus-Info
            HStack(spacing: 8) {
                Image(systemName: "banknote.fill")
                    .foregroundColor(accent)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Kreditrechner nach Gesamtlaufzeit & Rate")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Lege fest, wie viele Jahre der Kredit laufen soll und wie viel du monatlich zahlst.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Divider()
            
            // MARK: Eingaben
            // 1. Gesamtlaufzeit
            CustomSliderField(
                title: "Geplante Gesamtlaufzeit",
                subtitle: "In wie vielen Jahren soll der Kredit vollständig abbezahlt sein?",
                value: $viewModel.targetLoanTermYears,
                range: 10...40,
                step: 1,
                unit: "Jahre",
                decimals: 0,
                presetButtons: [15, 20, 25, 30]
            )
            
            // 2. Monatlicher Abschlag / Rate
            VStack(alignment: .leading, spacing: 6) {
                Toggle(isOn: $viewModel.useNetIncomeForDeduction) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monatsabschlag aus Haushaltsnetto berechnen")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("35 % von \(viewModel.formatCurrency(viewModel.affordabilityInput.haushaltsNettoeinkommen)) Netto = \(viewModel.formatCurrency(viewModel.affordabilityResult.maxMonatsrate)) / Monat")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: accent))
                .padding(.vertical, 2)
                
                if !viewModel.useNetIncomeForDeduction {
                    CurrencyInputField(
                        title: "Monatlicher Abschlag / Wunschrate",
                        subtitle: "Dein monatliches Budget für die Kreditrate",
                        value: $viewModel.targetMonthlyPayment,
                        step: 50,
                        minValue: 300,
                        maxValue: 10_000,
                        quickButtons: [1_200, 1_500, 1_800, 2_200, 2_800]
                    )
                }
            }
            
            // 3. Jährliche Sondertilgung
            CurrencyInputField(
                title: "Jährliche Sondertilgung",
                subtitle: "Einmalzahlung pro Jahr (z. B. aus Urlaubsgeld, Bonus oder Steuern)",
                value: $viewModel.targetAnnualSondertilgung,
                step: 500,
                minValue: 0,
                maxValue: 50_000,
                quickButtons: [0, 1_500, 2_500, 5_000, 10_000]
            )
            
            Divider()
            
            // MARK: Live-Ergebnis
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("MAXIMAL MÖGLICHE KREDITSUMME")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(accent)
                        .tracking(1.0)
                    
                    Text(viewModel.formatCurrency(cap.maxDarlehen))
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Daraus mögl. Kaufpreis:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(viewModel.formatCurrency(cap.maxKaufpreis))
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Anfängliche Tilgung:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(viewModel.formatPercent(cap.effTilgungssatz))
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(accent)
                    }
                }
                .padding(.horizontal, 4)
                
                if cap.mehrKreditDurchSondertilgung > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("Durch Sondertilgung: **+\(viewModel.formatCurrency(cap.mehrKreditDurchSondertilgung))** mehr Kreditspielraum!")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(accent.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(accent.opacity(0.25), lineWidth: 1)
                    )
            )
            
            // MARK: Experten-Empfehlungen für diese Kreditsumme
            VStack(alignment: .leading, spacing: 10) {
                Label("Empfehlungen für diese Kreditsumme", systemImage: "sparkles")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(accent)
                
                // Tilgungs-Empfehlung
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("📐 Tilgungssatz-Empfehlung:")
                            .font(.caption2)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("Mind. \(viewModel.formatPercent(cap.empfohleneMindestTilgung))")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(accent)
                    }
                    Text(cap.tilgungsEmpfehlungText)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
                .padding(10)
                .background(Color(PlatformColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Sondertilgungs-Empfehlung & Hebel
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("💡 Sondertilgungs-Hebel:")
                            .font(.caption2)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("Limit: \(viewModel.formatCurrency(cap.maxBankSondertilgungJahr))/J.")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    Text(cap.sondertilgungsEmpfehlungText)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                    
                    if cap.zinsErsparnisDurchSondertilgung > 0 {
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 10))
                                Text("ca. \(String(format: "%.1f", cap.laufzeitVerkuerzungJahre)) J. früher fertig")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.purple)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    .font(.system(size: 10))
                                Text("+\(viewModel.formatCurrency(cap.zinsErsparnisDurchSondertilgung)) Zinsersparnis")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.green)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(10)
                .background(Color(PlatformColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // MARK: Übernehmen-Button
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.applyLoanCapacityToCalculator()
                    showAppliedBanner = true
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.forward.circle.fill")
                    Text("Diese Kreditsumme (\(viewModel.formatCurrency(cap.maxDarlehen))) im Rechner aktivieren")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(accent)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            
            if showAppliedBanner {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Kaufpreis (\(viewModel.formatCurrency(cap.maxKaufpreis))) & Tilgung übernommen!")
                        .font(.caption2)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .transition(.opacity)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: radius)
                .fill(Color(PlatformColor.secondarySystemGroupedBackground))
        )
    }
}
