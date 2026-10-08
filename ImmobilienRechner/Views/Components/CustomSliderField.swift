import SwiftUI

public struct CustomSliderField: View {
    public let title: String
    public let subtitle: String?
    @Binding public var value: Double
    public let range: ClosedRange<Double>
    public let step: Double
    public let unit: String
    public let decimals: Int
    public var presetButtons: [Double]? = nil
    
    public init(
        title: String,
        subtitle: String? = nil,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 0.05,
        unit: String = "%",
        decimals: Int = 2,
        presetButtons: [Double]? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self._value = value
        self.range = range
        self.step = step
        self.unit = unit
        self.decimals = decimals
        self.presetButtons = presetButtons
    }
    
    private var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de_DE")
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        let numStr = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
        return "\(numStr) \(unit)"
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(formattedValue)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    let next = max(range.lowerBound, value - step)
                    value = (next * 1000).rounded() / 1000
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 32, height: 28)
                        .background(Color(PlatformColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                
                Slider(value: $value, in: range, step: step)
                    .accentColor(.blue)
                
                Button(action: {
                    let next = min(range.upperBound, value + step)
                    value = (next * 1000).rounded() / 1000
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 32, height: 28)
                        .background(Color(PlatformColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            
            if let presets = presetButtons, !presets.isEmpty {
                HStack(spacing: 6) {
                    ForEach(presets, id: \.self) { preset in
                        Button(action: {
                            value = preset
                        }) {
                            let isSelected = abs(value - preset) < 0.01
                            Text("\(String(format: decimals == 0 ? "%.0f" : "%.1f", preset))\(unit)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isSelected ? Color.blue.opacity(0.2) : Color(PlatformColor.secondarySystemBackground))
                                )
                                .foregroundColor(isSelected ? .blue : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
