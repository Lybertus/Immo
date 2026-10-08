import SwiftUI

public struct CurrencyInputField: View {
    public let title: String
    public let subtitle: String?
    @Binding public var value: Double
    public let step: Double
    public let minValue: Double
    public let maxValue: Double
    public var quickButtons: [Double]? = nil
    
    public init(
        title: String,
        subtitle: String? = nil,
        value: Binding<Double>,
        step: Double = 5_000,
        minValue: Double = 0,
        maxValue: Double = 5_000_000,
        quickButtons: [Double]? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self._value = value
        self.step = step
        self.minValue = minValue
        self.maxValue = maxValue
        self.quickButtons = quickButtons
    }
    
    private var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        formatter.locale = Locale(identifier: "de_DE")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value)) €"
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
            
            // Stepper controls
            HStack(spacing: 8) {
                Button(action: {
                    let next = max(minValue, value - step)
                    value = next
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 36, height: 32)
                        .background(Color(PlatformColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                
                Slider(value: $value, in: minValue...maxValue, step: step)
                    .accentColor(.blue)
                
                Button(action: {
                    let next = min(maxValue, value + step)
                    value = next
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 36, height: 32)
                        .background(Color(PlatformColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            
            // Optional quick buttons
            if let quick = quickButtons, !quick.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(quick, id: \.self) { amount in
                            Button(action: {
                                value = amount
                            }) {
                                Text("\(Int(amount / 1000))k €")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(value == amount ? Color.blue.opacity(0.2) : Color(PlatformColor.secondarySystemBackground))
                                    )
                                    .foregroundColor(value == amount ? .blue : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
