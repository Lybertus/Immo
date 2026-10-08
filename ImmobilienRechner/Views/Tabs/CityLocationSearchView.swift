import SwiftUI

public struct CityLocationSearchView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    @State private var searchText: String = ""
    @State private var selectedCategory: PriceLevelCategory = .all
    @State private var showAppliedAlert: Bool = false
    @State private var appliedMessage: String = ""
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    private var accent: Color {
        viewModel.selectedAccentColor.color
    }
    
    private var filteredCities: [CityLocation] {
        CityMarketDatabase.allCities.filter { city in
            let matchesCategory = (selectedCategory == .all) || (city.priceCategory == selectedCategory)
            let matchesSearch = searchText.isEmpty ||
                city.name.localizedCaseInsensitiveContains(searchText) ||
                city.bundesland.rawValue.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Category Filter Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PriceLevelCategory.allCases) { cat in
                        Button(action: {
                            withAnimation {
                                selectedCategory = cat
                            }
                        }) {
                            Text(cat.rawValue)
                                .font(.caption)
                                .fontWeight(selectedCategory == cat ? .bold : .medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == cat ? accent.opacity(0.18) : Color(PlatformColor.secondarySystemBackground))
                                )
                                .foregroundColor(selectedCategory == cat ? accent : .secondary)
                                .overlay(
                                    Capsule()
                                        .stroke(selectedCategory == cat ? accent : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(Color(PlatformColor.secondarySystemBackground).opacity(0.5))
            
            Divider()
            
            // Cities List
            List {
                if viewModel.showBeginnerTips {
                    Section {
                        ExpertTipsCardView(
                            tab: .orte,
                            accentColor: accent,
                            cornerRadius: viewModel.selectedDesignStyle.cornerRadius
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                
                Section(header: Text("\(filteredCities.count) gefundene Städte / Regionen")) {
                    ForEach(filteredCities) { city in
                        cityCard(city)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Ort oder Bundesland suchen (z. B. München, Köln, Leipzig)")
        }
        .alert("Ort übernommen", isPresented: $showAppliedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(appliedMessage)
        }
    }
    
    private func cityCard(_ city: CityLocation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(city.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(city.bundesland.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Category Badge
                Text(city.priceCategory.rawValue)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorForCategory(city.priceCategory).opacity(0.15))
                    .foregroundColor(colorForCategory(city.priceCategory))
                    .clipShape(Capsule())
            }
            
            Divider()
            
            // Prices Overview
            HStack(spacing: 12) {
                // Apartment
                VStack(alignment: .leading, spacing: 2) {
                    Text("🏢 Wohnung (Ø)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.formatCurrency(city.avgQmPreisWohnung)) / m²")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("ca. \(viewModel.formatCurrency(city.avgWohnung80qm)) (80 m²)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // House
                VStack(alignment: .leading, spacing: 2) {
                    Text("🏡 Haus (Ø)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.formatCurrency(city.avgQmPreisHaus)) / m²")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("ca. \(viewModel.formatCurrency(city.avgHaus140qm)) (140 m²)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Rent
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Miete (Ø)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f € / m²", city.avgKaltmieteQm))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Text("ca. \(viewModel.formatCurrency(city.avgMiete80qm)) / M.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons to apply to Calculator
            HStack(spacing: 10) {
                Button(action: {
                    viewModel.applyCityData(city, isHouse: false)
                    appliedMessage = "Wohnung in \(city.name) (\(viewModel.formatCurrency(city.avgWohnung80qm)) für 80 m², \(city.bundesland.rawValue)) wurde in den Hauptrechner übertragen!"
                    showAppliedAlert = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "building.2.fill")
                        Text("Als Wohnung (80 m²) übernehmen")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(accent.opacity(0.12))
                    .foregroundColor(accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    viewModel.applyCityData(city, isHouse: true)
                    appliedMessage = "Haus in \(city.name) (\(viewModel.formatCurrency(city.avgHaus140qm)) für 140 m², \(city.bundesland.rawValue)) wurde in den Hauptrechner übertragen!"
                    showAppliedAlert = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "house.fill")
                        Text("Als Haus (140 m²) übernehmen")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(PlatformColor.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: viewModel.selectedDesignStyle.cornerRadius)
                .fill(Color(PlatformColor.secondarySystemBackground))
        )
    }
    
    private func colorForCategory(_ cat: PriceLevelCategory) -> Color {
        switch cat {
        case .all: return accent
        case .guenstig: return .green
        case .mittel: return .yellow
        case .teuer: return .orange
        case .sehrTeuer: return .red
        }
    }
}
