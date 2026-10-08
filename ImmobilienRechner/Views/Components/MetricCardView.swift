import SwiftUI

public struct MetricCardView: View {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let systemImage: String
    public let tintColor: Color
    public var isHighlighted: Bool = false
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        systemImage: String,
        tintColor: Color,
        isHighlighted: Bool = false
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tintColor = tintColor
        self.isHighlighted = isHighlighted
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(tintColor)
                    .frame(width: 28, height: 28)
                    .background(tintColor.opacity(0.12))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(isHighlighted ? .title2 : .headline, design: .rounded))
                .fontWeight(isHighlighted ? .bold : .semibold)
                .foregroundColor(isHighlighted ? tintColor : .primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isHighlighted ? tintColor.opacity(0.08) : Color(PlatformColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isHighlighted ? tintColor.opacity(0.3) : Color.clear, lineWidth: 1.5)
                )
        )
    }
}

// Cross-platform color abstraction for macOS & iOS
public enum PlatformColor {
    #if os(macOS)
    public static var secondarySystemBackground: NSColor {
        NSColor.controlBackgroundColor
    }
    public static var systemBackground: NSColor {
        NSColor.windowBackgroundColor
    }
    #else
    public static var secondarySystemBackground: UIColor {
        UIColor.secondarySystemGroupedBackground
    }
    public static var systemBackground: UIColor {
        UIColor.systemGroupedBackground
    }
    #endif
}
