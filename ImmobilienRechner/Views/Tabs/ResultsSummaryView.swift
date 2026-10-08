import SwiftUI

public struct ResultsSummaryView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    @State private var showShareSheet: Bool = false
    @State private var saveScenarioAlert: Bool = false
    @State private var scenarioName: String = ""
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        let res = viewModel.result
        
        ScrollView {
            VStack(spacing: 20) {
                // Hero Rate Card
                VStack(spacing: 12) {
                    Text("MONATLICHE RATE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .tracking(1.5)
                    
                    Text(viewModel.formatCurrency(res.monatlicheRate, fractionDigits: 2))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    // Initial split between interest & repayment
                    HStack(spacing: 24) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.orange).frame(width: 8, height: 8)
                            Text("Zins: \(viewModel.formatCurrency(res.anfaenglicheMonatsZinsen, fractionDigits: 0))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 6) {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                            Text("Tilgung: \(viewModel.formatCurrency(res.anfaenglicheMonatsTilgung, fractionDigits: 0))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.blue.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.blue.opacity(0.25), lineWidth: 1.5)
                        )
                )
                
                // Key Metrics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    MetricCardView(
                        title: "Darlehensbetrag",
                        value: viewModel.formatCurrency(res.darlehensbetrag),
                        subtitle: "Nötiger Kredit",
                        systemImage: "banknote.fill",
                        tintColor: .indigo
                    )
                    
                    MetricCardView(
                        title: "Nebenkosten",
                        value: viewModel.formatCurrency(res.kaufnebenkostenGesamt),
                        subtitle: "\(viewModel.formatPercent(res.kaufnebenkostenProzent, decimals: 1)) vom Kaufpreis",
                        systemImage: "doc.text.fill",
                        tintColor: .orange
                    )
                    
                    MetricCardView(
                        title: "Restschuld",
                        value: viewModel.formatCurrency(res.restschuldNachZinsbindung),
                        subtitle: "nach \(viewModel.input.zinsbindungJahre) J. Zinsbindung",
                        systemImage: "calendar.badge.clock",
                        tintColor: .purple
                    )
                    
                    MetricCardView(
                        title: "Gesamtlaufzeit",
                        value: viewModel.formatDuration(years: res.gesamtlaufzeitJahre),
                        subtitle: "bis Schuldenfreiheit",
                        systemImage: "hourglass",
                        tintColor: .teal
                    )
                    
                    MetricCardView(
                        title: "Zinskosten gesamt",
                        value: viewModel.formatCurrency(res.zinsenBisVolltilgung),
                        subtitle: "über gesamte Laufzeit",
                        systemImage: "chart.line.uptrend.xyaxis",
                        tintColor: .red
                    )
                    
                    MetricCardView(
                        title: "Empfohlenes Netto",
                        value: viewModel.formatCurrency(res.empfohlenesNettoeinkommen),
                        subtitle: "bei 35 % Wohnkosten-Regel",
                        systemImage: "person.crop.circle.badge.checkmark",
                        tintColor: .green
                    )
                }
                
                // Graphical Charts Breakdown
                VStack(alignment: .leading, spacing: 14) {
                    Text("Finanzierungsaufteilung")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    DonutChartView(
                        slices: [
                            ChartSlice(label: "Eigenkapital", value: viewModel.input.eigenkapital, color: .green),
                            ChartSlice(label: "Bankdarlehen", value: res.darlehensbetrag, color: .indigo)
                        ],
                        centerTitle: "Gesamtkosten",
                        centerValue: viewModel.formatCurrency(res.gesamtkosten)
                    )
                }
                
                // Cost Breakdown
                VStack(alignment: .leading, spacing: 14) {
                    Text("Kaufpreis & Nebenkosten im Detail")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 10) {
                        costRow(title: "Reiner Kaufpreis", value: viewModel.input.kaufpreis, percentage: nil)
                        Divider()
                        costRow(title: "Grunderwerbsteuer (\(viewModel.input.bundesland.rawValue))", value: res.grunderwerbsteuer, percentage: viewModel.input.aktiverSteuersatz)
                        costRow(title: "Notar & Grundbucheintrag", value: res.notarGrundbuchKosten, percentage: viewModel.input.notarGrundbuchSatz)
                        if viewModel.input.hatMakler {
                            costRow(title: "Maklerprovision", value: res.maklerKosten, percentage: viewModel.input.aktiverMaklersatz)
                        }
                        if viewModel.input.modernisierungskosten > 0 {
                            Divider()
                            costRow(title: "Modernisierung / Renovierung", value: viewModel.input.modernisierungskosten, percentage: nil)
                        }
                        Divider()
                        HStack {
                            Text("Gesamter Finanzierungsbedarf")
                                .fontWeight(.bold)
                            Spacer()
                            Text(viewModel.formatCurrency(res.gesamtkosten))
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .font(.subheadline)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(PlatformColor.secondarySystemBackground))
                    )
                }
                
                // Action Buttons: Save & Share
                HStack(spacing: 12) {
                    Button(action: {
                        scenarioName = "\(viewModel.formatCurrency(viewModel.input.kaufpreis)) (\(viewModel.input.zinsbindungJahre)J)"
                        saveScenarioAlert = true
                    }) {
                        Label("Als Szenario speichern", systemImage: "bookmark.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    ShareLink(item: viewModel.generateExportSummary()) {
                        Label("Teilen", systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Color(PlatformColor.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
            }
            .padding(16)
        }
        .alert("Szenario speichern", isPresented: $saveScenarioAlert) {
            TextField("Name des Szenarios", text: $scenarioName)
            Button("Speichern") {
                viewModel.saveScenario(name: scenarioName)
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Gib dem aktuellen Berechnungs-Szenario einen Namen, um es später zu vergleichen.")
        }
    }
    
    private func costRow(title: String, value: Double, percentage: Double?) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let p = percentage {
                Text("(\(String(format: "%.2f", p)) %)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(viewModel.formatCurrency(value))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}
