import SwiftUI

public struct CurrencyInputField: View {
    public let title: String
    public let subtitle: String?
    @Binding public var value: Double
    public let step: Double
    public let minValue: Double
    public let maxValue: Double
    public var quickButtons: [Double]? = nil
    
    @State private var isEditingText: Bool = false
    @State private var tempText: String = ""
    @FocusState private var isFocused: Bool
    
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
                
                // Editable text box: can be clicked to type directly
                if isEditingText {
                    HStack(spacing: 4) {
                        TextField("Betrag", text: $tempText)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.trailing)
                            #if !os(macOS)
                            .keyboardType(.numberPad)
                            #endif
                            .focused($isFocused)
                            .onSubmit {
                                commitText()
                            }
                            .frame(minWidth: 90, maxWidth: 140)
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
                        tempText = "\(Int(value))"
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
            
            // Stepper & Slider controls
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
                    .accentColor(.accentColor)
                
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
            
            // Quick Buttons
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
                                            .fill(abs(value - amount) < 1 ? Color.accentColor.opacity(0.2) : Color(PlatformColor.secondarySystemBackground))
                                    )
                                    .foregroundColor(abs(value - amount) < 1 ? .accentColor : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
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
        let cleaned = tempText.replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "€", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let parsed = Double(cleaned) {
            self.value = min(maxValue, max(minValue, parsed))
        }
        isEditingText = false
    }
}
