import SwiftUI

public struct RentVsBuyView: View {
    @ObservedObject public var viewModel: CalculatorViewModel
    
    public init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    private var accent: Color {
        viewModel.selectedAccentColor.color
    }
    
    public var body: some View {
        let rvb = viewModel.rentVsBuyResult
        let idx = viewModel.affordabilityIndexResult
        let cornerRadius = viewModel.selectedDesignStyle.cornerRadius
        
        ScrollView {
            VStack(spacing: 20) {
                // MARK: 1. Hero Check: Wohnst du aktuell günstig?
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "house.and.flag.fill")
                            .foregroundColor(accent)
                        Text("MIET-BEWERTUNG")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(accent)
                            .tracking(1.2)
                        Spacer()
                        Text("Faktor \(String(format: "%.1f", rvb.mietmultiplikator))")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(accent.opacity(0.12))
                            .foregroundColor(accent)
                            .clipShape(Capsule())
                    }
                    
                    Text(rvb.guenstigWohnenScore.rawValue)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(colorForRentQuality(rvb.guenstigWohnenScore))
                    
                    Text(rvb.guenstigWohnenText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    Divider().padding(.horizontal, 20)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Monatlich Mieter (Start):")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(viewModel.formatCurrency(rvb.monatlicheKostenMieterAnfang))
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Monatlich Käufer (Rate + Rücklage):")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(viewModel.formatCurrency(rvb.monatlicheKostenKaeuferAnfang))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(accent)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(accent.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(accent.opacity(0.25), lineWidth: 1.5)
                        )
                )
                
                // MARK: 2. Interhyp Erschwinglichkeitsindex
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Interhyp-Erschwinglichkeitsindex")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(idx.indexScore)) Punkte")
                            .font(.subheadline)
                            .fontWeight(.heavy)
                            .foregroundColor(colorForIndexRating(idx.bewertungStufe))
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // Progress / Index Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(PlatformColor.secondarySystemBackground))
                                    .frame(height: 10)
                                
                                let pct = min(1.0, max(0.0, idx.indexScore / 140.0))
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(colorForIndexRating(idx.bewertungStufe))
                                    .frame(width: geo.size.width * pct, height: 10)
                            }
                        }
                        .frame(height: 10)
                        
                        HStack {
                            Text("Historischer Referenzwert: 100")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(idx.bewertungStufe.rawValue)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(colorForIndexRating(idx.bewertungStufe))
                        }
                        
                        Divider()
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Leistbare Wohnfläche:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(Int(idx.leistbareWohnflaecheQm)) m²")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(accent)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Quadratmeterpreis:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.formatCurrency(idx.qmPreisObjekt)) / m²")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Text(idx.beschreibung)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(PlatformColor.secondarySystemBackground))
                    )
                }
                
                // MARK: 3. Vermögensvergleich nach X Jahren
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Vermögen nach \(viewModel.rentVsBuyInput.betrachtungszeitraumJahre) Jahren")
                            .font(.headline)
                        Spacer()
                        if let be = rvb.breakEvenJahr {
                            Text("Kauf amortisiert: Jahr \(be)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack(spacing: 14) {
                        // Käufer Vermögen
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .foregroundColor(accent)
                                Text("Käufer-Vermögen")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            Text(viewModel.formatCurrency(rvb.vermoegenKaeufer))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(accent)
                            Text("Immobilienwert minus Restschuld")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(PlatformColor.secondarySystemBackground))
                        )
                        
                        // Mieter Vermögen
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(.orange)
                                Text("Mieter-Vermögen")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            Text(viewModel.formatCurrency(rvb.vermoegenMieter))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Investiertes EK + ETF-Zinseszins")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(PlatformColor.secondarySystemBackground))
                        )
                    }
                    
                    // Differenz-Ergebnis
                    HStack {
                        Text("Vermögensvorteil:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(viewModel.formatCurrency(abs(rvb.vermoegensDifferenz))) Vorteil für \(rvb.vermoegensDifferenz >= 0 ? "Käufer" : "Mieter")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(rvb.vermoegensDifferenz >= 0 ? .green : .orange)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((rvb.vermoegensDifferenz >= 0 ? Color.green : Color.orange).opacity(0.1))
                    )
                }
                
                // MARK: 4. Eingaben Mieten vs. Kaufen
                VStack(alignment: .leading, spacing: 14) {
                    Text("Vergleichs-Parameter")
                        .font(.headline)
                    
                    VStack(spacing: 16) {
                        CurrencyInputField(
                            title: "Aktuelle monatliche Kaltmiete",
                            subtitle: "Reine Kaltmiete deiner jetzigen Mietwohnung",
                            value: $viewModel.rentVsBuyInput.aktuelleKaltmiete,
                            step: 50,
                            minValue: 200,
                            maxValue: 6_000,
                            quickButtons: [800, 1_100, 1_350, 1_600, 2_000]
                        )
                        
                        CustomSliderField(
                            title: "Wohnfläche der Immobilie",
                            subtitle: "Größe des Objekts in Quadratmetern",
                            value: $viewModel.rentVsBuyInput.wohnflaecheQm,
                            range: 30...300,
                            step: 5,
                            unit: "m²",
                            decimals: 0,
                            presetButtons: [65, 85, 100, 120, 150]
                        )
                        
                        CustomSliderField(
                            title: "Erwartete Mietsteigerung p.a.",
                            subtitle: "Historischer Schnitt ca. 1,5 % bis 2,5 %",
                            value: $viewModel.rentVsBuyInput.mietsteigerungProJahr,
                            range: 0.0...5.0,
                            step: 0.1,
                            unit: "%",
                            decimals: 1,
                            presetButtons: [1.5, 2.0, 2.5]
                        )
                        
                        CustomSliderField(
                            title: "Alternative ETF-Rendite für Mieter",
                            subtitle: "Rendite, wenn EK im MSCI World / S&P angelegt wird",
                            value: $viewModel.rentVsBuyInput.etfRenditeProJahr,
                            range: 2.0...9.0,
                            step: 0.25,
                            unit: "%",
                            decimals: 2,
                            presetButtons: [4.5, 5.5, 6.5]
                        )
                        
                        CurrencyInputField(
                            title: "Instandhaltungsrücklage Käufer",
                            subtitle: "Monatlicher Puffer für Sanierungen & Hausgeld",
                            value: $viewModel.rentVsBuyInput.instandhaltungKaeuferMonat,
                            step: 25,
                            minValue: 50,
                            maxValue: 1_000,
                            quickButtons: [150, 200, 250, 350]
                        )
                        
                        CustomSliderField(
                            title: "Immobilien-Wertsteigerung p.a.",
                            subtitle: "Langfristige Wertentwicklung der Immobilie",
                            value: $viewModel.rentVsBuyInput.immobilienWertsteigerungProJahr,
                            range: 0.0...4.0,
                            step: 0.1,
                            unit: "%",
                            decimals: 1,
                            presetButtons: [1.0, 1.5, 2.0]
                        )
                        
                        Picker("Betrachtungszeitraum", selection: $viewModel.rentVsBuyInput.betrachtungszeitraumJahre) {
                            Text("10 Jahre").tag(10)
                            Text("15 Jahre").tag(15)
                            Text("20 Jahre").tag(20)
                            Text("25 Jahre").tag(25)
                            Text("30 Jahre").tag(30)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(PlatformColor.secondarySystemBackground))
                    )
                }
            }
            .padding(16)
        }
    }
    
    private func colorForRentQuality(_ q: RentVsBuyResult.RentQuality) -> Color {
        switch q {
        case .extremGuenstig, .guenstig: return .green
        case .durchschnittlich: return .orange
        case .teuer: return .red
        }
    }
    
    private func colorForIndexRating(_ r: AffordabilityIndexResult.RatingLevel) -> Color {
        switch r {
        case .sehrGut: return .green
        case .normal: return accent
        case .angespannt: return .orange
        case .kritisch: return .red
        }
    }
}
