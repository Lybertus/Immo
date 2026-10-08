import SwiftUI

/// Erscheinungsbild-Modus (Light, Dark, System)
public enum AppearanceMode: String, CaseIterable, Identifiable, Codable {
    case dark = "Dunkel (OLED)"
    case light = "Hell"
    case system = "System"
    
    public var id: String { rawValue }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// UI-Designstil
public enum DesignStyle: String, CaseIterable, Identifiable, Codable {
    case modern = "Modern Apple"
    case minimal = "Minimal Clean"
    case compact = "Finanz-Kompakt"
    
    public var id: String { rawValue }
    
    public var cornerRadius: CGFloat {
        switch self {
        case .modern: return 18
        case .minimal: return 8
        case .compact: return 12
        }
    }
}

/// Große Palette an Akzentfarben
public enum AppAccentColor: String, CaseIterable, Identifiable, Codable {
    case appleBlue = "Apple Blau"
    case oceanCyan = "Ocean Cyan"
    case deepIndigo = "Tiefes Indigo"
    case royalPurple = "Royal Lila"
    case magenta = "Magenta Pink"
    case rubyRed = "Rubinrot"
    case sunsetOrange = "Sunset Koralle"
    case warmAmber = "Warmes Bernstein"
    case gold = "Champagner Gold"
    case emeraldGreen = "Smaragdgrün"
    case freshMint = "Frische Minze"
    case teal = "Petrol Teal"
    case pineGreen = "Waldgrün"
    case cyberLime = "Cyber Neon"
    case spaceSlate = "Schiefergrau"
    case copperBronze = "Kupfer Bronze"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .appleBlue: return Color(red: 0.00, green: 0.48, blue: 1.00)
        case .oceanCyan: return Color(red: 0.00, green: 0.65, blue: 0.95)
        case .deepIndigo: return Color(red: 0.35, green: 0.34, blue: 0.84)
        case .royalPurple: return Color(red: 0.68, green: 0.32, blue: 0.87)
        case .magenta: return Color(red: 1.00, green: 0.18, blue: 0.45)
        case .rubyRed: return Color(red: 1.00, green: 0.23, blue: 0.19)
        case .sunsetOrange: return Color(red: 1.00, green: 0.40, blue: 0.20)
        case .warmAmber: return Color(red: 1.00, green: 0.60, blue: 0.00)
        case .gold: return Color(red: 0.85, green: 0.65, blue: 0.15)
        case .emeraldGreen: return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .freshMint: return Color(red: 0.00, green: 0.78, blue: 0.75)
        case .teal: return Color(red: 0.19, green: 0.69, blue: 0.78)
        case .pineGreen: return Color(red: 0.14, green: 0.54, blue: 0.24)
        case .cyberLime: return Color(red: 0.60, green: 0.85, blue: 0.00)
        case .spaceSlate: return Color(red: 0.45, green: 0.48, blue: 0.53)
        case .copperBronze: return Color(red: 0.72, green: 0.45, blue: 0.25)
        }
    }
}
