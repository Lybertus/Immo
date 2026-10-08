import SwiftUI

public struct ChartSlice: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: Double
    public let color: Color
    
    public init(label: String, value: Double, color: Color) {
        self.label = label
        self.value = value
        self.color = color
    }
}

public struct DonutChartView: View {
    public let slices: [ChartSlice]
    public let centerTitle: String
    public let centerValue: String
    
    public init(slices: [ChartSlice], centerTitle: String, centerValue: String) {
        self.slices = slices
        self.centerTitle = centerTitle
        self.centerValue = centerValue
    }
    
    private var total: Double {
        slices.reduce(0) { $0 + max(0, $1.value) }
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Donut Rings
                ForEach(0..<slices.count, id: \.self) { index in
                    let slice = slices[index]
                    let angles = calculateAngles(for: index)
                    
                    if total > 0 && slice.value > 0 {
                        Circle()
                            .trim(from: angles.start, to: angles.end)
                            .stroke(slice.color, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: slice.value)
                    }
                }
                
                // Center text
                VStack(spacing: 2) {
                    Text(centerTitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(centerValue)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .frame(width: 140, height: 140)
            .padding(.vertical, 8)
            
            // Legend
            VStack(spacing: 6) {
                ForEach(slices) { slice in
                    if slice.value > 0 {
                        HStack {
                            Circle()
                                .fill(slice.color)
                                .frame(width: 8, height: 8)
                            
                            Text(slice.label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            let pct = total > 0 ? (slice.value / total) * 100 : 0
                            Text(String(format: "%.1f %%", pct))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(PlatformColor.secondarySystemBackground))
        )
    }
    
    private func calculateAngles(for index: Int) -> (start: CGFloat, end: CGFloat) {
        guard total > 0 else { return (0, 0) }
        
        var currentSum = 0.0
        for i in 0..<index {
            currentSum += max(0, slices[i].value)
        }
        
        let start = CGFloat(currentSum / total)
        let end = CGFloat((currentSum + max(0, slices[index].value)) / total)
        return (start, max(start, end - 0.005)) // small gap
    }
}
