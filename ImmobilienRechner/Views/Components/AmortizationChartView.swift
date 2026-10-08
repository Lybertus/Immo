import SwiftUI

/// Interaktives Kurvendiagramm für Tilgungsverlauf, Restschuld und Zinsen über die Jahre
public struct AmortizationChartView: View {
    public let tilgungsplan: [AmortizationYear]
    public let zinsbindungJahre: Int
    public let darlehensbetrag: Double
    public let accentColor: Color
    
    @State private var selectedYearIndex: Int? = nil
    
    public init(
        tilgungsplan: [AmortizationYear],
        zinsbindungJahre: Int,
        darlehensbetrag: Double,
        accentColor: Color
    ) {
        self.tilgungsplan = tilgungsplan
        self.zinsbindungJahre = zinsbindungJahre
        self.darlehensbetrag = darlehensbetrag
        self.accentColor = accentColor
    }
    
    private var maxAmount: Double {
        max(darlehensbetrag, tilgungsplan.last?.kumulierteTilgung ?? darlehensbetrag)
    }
    
    private var totalYears: Int {
        max(1, tilgungsplan.count)
    }
    
    private var activeYear: AmortizationYear? {
        if let idx = selectedYearIndex, idx >= 0 && idx < tilgungsplan.count {
            return tilgungsplan[idx]
        }
        // Standardmäßig das Zinsbindungsjahr oder letztes Jahr
        let fixedYear = tilgungsplan.first { $0.jahr == zinsbindungJahre }
        return fixedYear ?? tilgungsplan.last
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Chart Header & Active Tooltip
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tilgungsverlauf & Restschuld-Kurve")
                        .font(.headline)
                    
                    if let cur = activeYear {
                        HStack(spacing: 8) {
                            Text("Jahr \(cur.jahr):")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Rest: \(formatEur(cur.endRestschuld))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(accentColor)
                            
                            Text("Zinsen ges.: \(formatEur(cur.kumulierteZinsen))")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                // Legend
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(accentColor).frame(width: 8, height: 8)
                        Text("Restschuld").font(.caption2).foregroundColor(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.orange).frame(width: 8, height: 8)
                        Text("Zinsen").font(.caption2).foregroundColor(.secondary)
                    }
                }
            }
            
            // Interactive Curve Canvas
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack(alignment: .topLeading) {
                    // Background grid horizontal lines
                    VStack(spacing: 0) {
                        ForEach(0..<4) { i in
                            Divider()
                            if i < 3 { Spacer() }
                        }
                    }
                    
                    // Fixed period vertical dashed line
                    if let fixedIndex = tilgungsplan.firstIndex(where: { $0.jahr == zinsbindungJahre }) {
                        let xPos = xPosition(for: fixedIndex, width: w)
                        Path { path in
                            path.move(to: CGPoint(x: xPos, y: 0))
                            path.addLine(to: CGPoint(x: xPos, y: h))
                        }
                        .stroke(Color.blue.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                        
                        // Milestone flag badge
                        VStack(spacing: 2) {
                            Text("🏁 Ende Bindung (\(zinsbindungJahre) J.)")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                        .position(x: min(max(60, xPos), w - 60), y: 12)
                    }
                    
                    // 1. Paid Interest Curve (Orange Area & Line)
                    interestPath(width: w, height: h)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    
                    // 2. Remaining Debt Curve (Accent Gradient Area & Line)
                    debtAreaPath(width: w, height: h)
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.25), accentColor.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    debtPath(width: w, height: h)
                        .stroke(accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    
                    // Interactive Scrubbing Indicator
                    if let idx = selectedYearIndex, idx < tilgungsplan.count {
                        let xPos = xPosition(for: idx, width: w)
                        let yPos = yPosition(amount: tilgungsplan[idx].endRestschuld, height: h)
                        
                        Path { p in
                            p.move(to: CGPoint(x: xPos, y: 0))
                            p.addLine(to: CGPoint(x: xPos, y: h))
                        }
                        .stroke(Color.primary.opacity(0.4), lineWidth: 1)
                        
                        Circle()
                            .fill(accentColor)
                            .frame(width: 10, height: 10)
                            .shadow(radius: 2)
                            .position(x: xPos, y: yPos)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { val in
                            let ratio = max(0, min(1, val.location.x / w))
                            let targetIdx = Int(round(ratio * Double(tilgungsplan.count - 1)))
                            selectedYearIndex = max(0, min(tilgungsplan.count - 1, targetIdx))
                        }
                )
            }
            .frame(height: 180)
            
            // X-Axis Year Labels
            HStack {
                Text("Jahr 0")
                Spacer()
                Text("Jahr \(zinsbindungJahre)")
                Spacer()
                Text("Jahr \(totalYears)")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(PlatformColor.secondarySystemBackground))
        )
    }
    
    // MARK: - Path Calculators
    
    private func xPosition(for index: Int, width: CGFloat) -> CGFloat {
        guard tilgungsplan.count > 1 else { return width / 2 }
        return (CGFloat(index) / CGFloat(tilgungsplan.count - 1)) * width
    }
    
    private func yPosition(amount: Double, height: CGFloat) -> CGFloat {
        guard maxAmount > 0 else { return height }
        let ratio = CGFloat(amount / maxAmount)
        return height - (ratio * height * 0.9) - 6 // safe bottom offset
    }
    
    private func debtPath(width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        guard !tilgungsplan.isEmpty else { return path }
        
        let startPoint = CGPoint(x: 0, y: yPosition(amount: darlehensbetrag, height: height))
        path.move(to: startPoint)
        
        for (i, item) in tilgungsplan.enumerated() {
            let pt = CGPoint(x: xPosition(for: i, width: width), y: yPosition(amount: item.endRestschuld, height: height))
            path.addLine(to: pt)
        }
        return path
    }
    
    private func debtAreaPath(width: CGFloat, height: CGFloat) -> Path {
        var path = debtPath(width: width, height: height)
        guard !tilgungsplan.isEmpty else { return path }
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }
    
    private func interestPath(width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        guard !tilgungsplan.isEmpty else { return path }
        
        let startPoint = CGPoint(x: 0, y: height - 6)
        path.move(to: startPoint)
        
        for (i, item) in tilgungsplan.enumerated() {
            let pt = CGPoint(x: xPosition(for: i, width: width), y: yPosition(amount: item.kumulierteZinsen, height: height))
            path.addLine(to: pt)
        }
        return path
    }
    
    private func formatEur(_ val: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "€"
        f.locale = Locale(identifier: "de_DE")
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: val)) ?? "\(Int(val)) €"
    }
}
