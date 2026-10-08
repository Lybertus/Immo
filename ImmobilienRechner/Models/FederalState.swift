import Foundation

/// Bundesländer in Deutschland mit ihren aktuellen Grunderwerbsteuersätzen
public enum FederalState: String, CaseIterable, Identifiable, Codable {
    case badenWuerttemberg = "Baden-Württemberg"
    case bayern = "Bayern"
    case berlin = "Berlin"
    case brandenburg = "Brandenburg"
    case bremen = "Bremen"
    case hamburg = "Hamburg"
    case hessen = "Hessen"
    case mecklenburgVorpommern = "Mecklenburg-Vorpommern"
    case niedersachsen = "Niedersachsen"
    case nordrheinWestfalen = "Nordrhein-Westfalen"
    case rheinlandPfalz = "Rheinland-Pfalz"
    case saarland = "Saarland"
    case sachsen = "Sachsen"
    case sachsenAnhalt = "Sachsen-Anhalt"
    case schleswigHolstein = "Schleswig-Holstein"
    case thueringen = "Thüringen"
    
    public var id: String { rawValue }
    
    /// Grunderwerbsteuersatz in Prozent
    public var taxRate: Double {
        switch self {
        case .bayern:
            return 3.5
        case .badenWuerttemberg, .bremen, .niedersachsen, .rheinlandPfalz, .sachsenAnhalt, .thueringen:
            return 5.0
        case .hamburg, .sachsen:
            return 5.5
        case .berlin, .hessen:
            return 6.0
        case .brandenburg, .mecklenburgVorpommern, .nordrheinWestfalen, .saarland, .schleswigHolstein:
            return 6.5
        }
    }
    
    public var abbreviation: String {
        switch self {
        case .badenWuerttemberg: return "BW"
        case .bayern: return "BY"
        case .berlin: return "BE"
        case .brandenburg: return "BB"
        case .bremen: return "HB"
        case .hamburg: return "HH"
        case .hessen: return "HE"
        case .mecklenburgVorpommern: return "MV"
        case .niedersachsen: return "NI"
        case .nordrheinWestfalen: return "NW"
        case .rheinlandPfalz: return "RP"
        case .saarland: return "SL"
        case .sachsen: return "SN"
        case .sachsenAnhalt: return "ST"
        case .schleswigHolstein: return "SH"
        case .thueringen: return "TH"
        }
    }
}
