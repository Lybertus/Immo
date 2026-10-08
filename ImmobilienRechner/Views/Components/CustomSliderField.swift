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
    
    @State private var isEditingText: Bool = false
    @State private var tempText: String = ""
    @FocusState private var isFocused: Bool
    
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
            HStack(alignment: .center) {
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
                
                // Editable text box
                if isEditingText {
                    HStack(spacing: 4) {
                        TextField("Wert", text: $tempText)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.trailing)
                            #if !os(macOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .focused($isFocused)
                            .onSubmit {
                                commitText()
                            }
                            .frame(minWidth: 70, maxWidth: 110)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(PlatformColor.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.accentColor, lineWidth: 1.5)
                                    )
                            )
                        
                        Button(action: commitText) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Button(action: {
                        let formatter = NumberFormatter()
                        formatter.locale = Locale(identifier: "de_DE")
                        formatter.maximumFractionDigits = decimals
                        tempText = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
                        isEditingText = true
                        isFocused = true
                    }) {
                        HStack(spacing: 4) {
                            Text(formattedValue)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                            
                            Image(systemName: "pencil")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(PlatformColor.secondarySystemBackground).opacity(0.8))
                        )
                    }
                    .buttonStyle(.plain)
                    .help("Klicken zum manuellen Eintippen")
                }
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
                    .accentColor(.accentColor)
                
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
                                        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color(PlatformColor.secondarySystemBackground))
                                )
                                .foregroundColor(isSelected ? .accentColor : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .onChange(of: isFocused) { focused in
            if !focused && isEditingText {
                commitText()
            }
        }
    }
    
    private func commitText() {
        let cleaned = tempText.replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let parsed = Double(cleaned) {
            self.value = min(range.upperBound, max(range.lowerBound, parsed))
        }
        isEditingText = false
    }
}
