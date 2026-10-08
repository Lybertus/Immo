import SwiftUI

public struct InvestmentYieldView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        let inv = viewModel.investmentResult
        
        ScrollView {
            VStack(spacing: 20) {
                // Cashflow Hero Card
                VStack(spacing: 10) {
                    Text("MONATLICHER CASHFLOW (VOR STEUER)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .tracking(1.2)
                    
                    Text(viewModel.formatCurrency(inv.monatlicherCashflowVorSteuer, fractionDigits: 2))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(inv.monatlicherCashflowVorSteuer >= 0 ? .green : .red)
                    
                    HStack(spacing: 6) {
                        Image(systemName: inv.monatlicherCashflowVorSteuer >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundColor(inv.monatlicherCashflowVorSteuer >= 0 ? .green : .red)
                        Text(inv.monatlicherCashflowVorSteuer >= 0 ? "Positiver Überschuss jeden Monat" : "Monatliche Eigenleistung/Zuzahlung nötig")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill((inv.monatlicherCashflowVorSteuer >= 0 ? Color.green : Color.red).opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke((inv.monatlicherCashflowVorSteuer >= 0 ? Color.green : Color.red).opacity(0.25), lineWidth: 1.5)
                        )
                )
                
                // Key Yield Metrics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    MetricCardView(
                        title: "Brutto-Mietrendite",
                        value: viewModel.formatPercent(inv.bruttoMietrendite),
                        subtitle: "Jahresmiete / Kaufpreis",
                        systemImage: "chart.pie.fill",
                        tintColor: .blue
                    )
                    
                    MetricCardView(
                        title: "Netto-Mietrendite",
                        value: viewModel.formatPercent(inv.nettoMietrendite),
                        subtitle: "nach Nebenkosten & Instandh.",
                        systemImage: "chart.bar.fill",
                        tintColor: .indigo
                    )
                    
                    MetricCardView(
                        title: "Mietmultiplikator",
                        value: String(format: "%.1f x", inv.mietmultiplikator),
                        subtitle: "Kaufpreisfaktor",
                        systemImage: "multiply.circle.fill",
                        tintColor: .purple
                    )
                    
                    MetricCardView(
                        title: "Jahres-Cashflow",
                        value: viewModel.formatCurrency(inv.jahresCashflowVorSteuer),
                        subtitle: "Überschuss pro Jahr",
                        systemImage: "eurosign.circle.fill",
                        tintColor: inv.jahresCashflowVorSteuer >= 0 ? .green : .red
                    )
                }
                
                // Input Section for Rental Details
                VStack(alignment: .leading, spacing: 14) {
                    Text("Mieteinnahmen & Bewirtschaftung")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 16) {
                        CurrencyInputField(
                            title: "Monatliche Kaltmiete",
                            subtitle: "Erzielbare Mieteinnahme ohne Nebenkosten",
                            value: $viewModel.investmentInput.monatlicheKaltmiete,
                            step: 50,
                            minValue: 100,
                            maxValue: 20_000,
                            quickButtons: [800, 1_200, 1_500, 2_000, 2_500]
                        )
                        
                        CurrencyInputField(
                            title: "Nicht umlegbare Nebenkosten",
                            subtitle: "z.B. WEG-Verwaltung pro Monat",
                            value: $viewModel.investmentInput.nichtUmlegbareKostenMonat,
                            step: 10,
                            minValue: 0,
                            maxValue: 1_000
                        )
                        
                        CurrencyInputField(
                            title: "Instandhaltungsrücklage",
                            subtitle: "Eigene Rücklage für Reparaturen pro Monat",
                            value: $viewModel.investmentInput.instandhaltungRuecklageMonat,
                            step: 10,
                            minValue: 0,
                            maxValue: 1_000
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(PlatformColor.secondarySystemBackground))
                    )
                }
                
                // Monthly Cashflow Breakdown
                VStack(alignment: .leading, spacing: 14) {
                    Text("Cashflow-Aufstellung pro Monat")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("+ Kaltmiete")
                                .font(.subheadline)
                            Spacer()
                            Text(viewModel.formatCurrency(viewModel.investmentInput.monatlicheKaltmiete))
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("- Kreditrate (Zins & Tilgung)")
                                .font(.subheadline)
                            Spacer()
                            Text("- " + viewModel.formatCurrency(viewModel.result.monatlicheRate))
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("- Nicht umlegbare Kosten")
                                .font(.subheadline)
                            Spacer()
                            Text("- " + viewModel.formatCurrency(viewModel.investmentInput.nichtUmlegbareKostenMonat))
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("- Instandhaltungsrücklage")
                                .font(.subheadline)
                            Spacer()
                            Text("- " + viewModel.formatCurrency(viewModel.investmentInput.instandhaltungRuecklageMonat))
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("= Monatlicher Überschuss")
                                .fontWeight(.bold)
                            Spacer()
                            Text(viewModel.formatCurrency(inv.monatlicherCashflowVorSteuer))
                                .fontWeight(.bold)
                                .foregroundColor(inv.monatlicherCashflowVorSteuer >= 0 ? .green : .red)
                        }
                        .font(.subheadline)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(PlatformColor.secondarySystemBackground))
                    )
                }
            }
            .padding(16)
        }
    }
}
