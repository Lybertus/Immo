import SwiftUI

public struct AmortizationTableView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    @State private var onlyFixedInterestPeriod: Bool = false
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    private var displayedYears: [AmortizationYear] {
        let all = viewModel.result.tilgungsplan
        if onlyFixedInterestPeriod {
            return all.filter { $0.jahr <= viewModel.input.zinsbindungJahre }
        }
        return all
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Filter Bar
            HStack {
                Picker("Ansicht", selection: $onlyFixedInterestPeriod) {
                    Text("Alle Jahre (\(viewModel.result.tilgungsplan.count))").tag(false)
                    Text("Nur Zinsbindung (\(viewModel.input.zinsbindungJahre) J.)").tag(true)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            // Table Header
            HStack(spacing: 6) {
                Text("Jahr")
                    .frame(width: 44, alignment: .leading)
                Text("Zins")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("Tilgung")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("Restschuld")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(PlatformColor.secondarySystemBackground).opacity(0.8))
            
            Divider()
            
            // List of Years
            List {
                ForEach(displayedYears) { year in
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Text("J. \(year.jahr)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 44, alignment: .leading)
                            
                            Text(viewModel.formatCurrency(year.gezahlteZinsen))
                                .font(.caption)
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text(viewModel.formatCurrency(year.gezahlteTilgung + year.sondertilgung))
                                .font(.caption)
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text(viewModel.formatCurrency(year.endRestschuld))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(year.endRestschuld == 0 ? .green : .primary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        if year.sondertilgung > 0 {
                            HStack {
                                Spacer()
                                Text("inkl. \(viewModel.formatCurrency(year.sondertilgung)) Sondertilgung")
                                    .font(.caption2)
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        if year.istEndeZinsbindung {
                            HStack {
                                Image(systemName: "flag.checkered")
                                    .foregroundColor(.blue)
                                Text("Ende der \(viewModel.input.zinsbindungJahre)-jährigen Zinsbindung")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Spacer()
                                Text("Rest: \(viewModel.formatCurrency(year.endRestschuld))")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.blue.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(
                        year.istEndeZinsbindung ? Color.blue.opacity(0.05) : Color.clear
                    )
                }
            }
            .listStyle(.plain)
        }
    }
}
