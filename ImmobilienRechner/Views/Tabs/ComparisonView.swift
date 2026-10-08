import SwiftUI

public struct ComparisonView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    @State private var showingAddAlert = false
    @State private var newScenarioName = ""
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.savedScenarios.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "square.split.2x2")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Keine Szenarien gespeichert")
                        .font(.headline)
                    
                    Text("Speichere verschiedene Zins- oder Eigenkapital-Varianten ab, um sie direkt miteinander zu vergleichen.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: {
                        newScenarioName = "\(viewModel.formatCurrency(viewModel.input.kaufpreis)) (\(viewModel.input.zinsbindungJahre) J.)"
                        showingAddAlert = true
                    }) {
                        Label("Aktuelle Berechnung speichern", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    Section {
                        Button(action: {
                            newScenarioName = "\(viewModel.formatCurrency(viewModel.input.kaufpreis)) (\(viewModel.input.zinsbindungJahre) J.)"
                            showingAddAlert = true
                        }) {
                            Label("Aktuelles Setup als neues Szenario speichern", systemImage: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Section(header: Text("Gespeicherte Varianten")) {
                        ForEach(viewModel.savedScenarios) { scenario in
                            let scenarioResult = MortgageCalculator.calculate(input: scenario.input)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(scenario.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(scenario.datum.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Rate/Monat")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(viewModel.formatCurrency(scenarioResult.monatlicheRate, fractionDigits: 2))
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Zins / Bindung")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text("\(viewModel.formatPercent(scenario.input.sollzins)) / \(scenario.input.zinsbindungJahre) J.")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Restschuld")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(viewModel.formatCurrency(scenarioResult.restschuldNachZinsbindung))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.purple)
                                    }
                                }
                                
                                HStack {
                                    Button(action: {
                                        viewModel.applyScenario(scenario)
                                    }) {
                                        Text("In den Rechner laden")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.12))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                }
                                .padding(.top, 4)
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete(perform: viewModel.deleteScenario)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .alert("Szenario speichern", isPresented: $showingAddAlert) {
            TextField("Name (z.B. 10 Jahre Zinsbindung)", text: $newScenarioName)
            Button("Speichern") {
                viewModel.saveScenario(name: newScenarioName)
            }
            Button("Abbrechen", role: .cancel) {}
        }
    }
}
