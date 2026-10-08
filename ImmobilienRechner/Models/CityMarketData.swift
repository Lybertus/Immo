import Foundation

/// Preisniveau-Einstufung einer Stadt oder Region
public enum PriceLevelCategory: String, CaseIterable, Identifiable, Codable {
    case all = "Alle Preisklassen"
    case guenstig = "Günstig"
    case mittel = "Mittel / Fair"
    case teuer = "Teuer"
    case sehrTeuer = "Sehr teuer (Metropolen)"
    
    public var id: String { rawValue }
    
    public var badgeColorName: String {
        switch self {
        case .all: return "blue"
        case .guenstig: return "green"
        case .mittel: return "yellow"
        case .teuer: return "orange"
        case .sehrTeuer: return "red"
        }
    }
}

/// Marktdaten für eine deutsche Stadt oder Region
public struct CityLocation: Identifiable, Codable, Equatable {
    public var id: String { name }
    public let name: String
    public let bundesland: FederalState
    public let avgQmPreisWohnung: Double // € / m²
    public let avgQmPreisHaus: Double // € / m²
    public let avgKaltmieteQm: Double // € / m²
    public let priceCategory: PriceLevelCategory
    
    /// Durchschnittlicher Kaufpreis für eine typische 80 m² Wohnung
    public var avgWohnung80qm: Double {
        avgQmPreisWohnung * 80.0
    }
    
    /// Durchschnittlicher Kaufpreis für ein typisches 140 m² Haus
    public var avgHaus140qm: Double {
        avgQmPreisHaus * 140.0
    }
    
    /// Typische Kaltmiete für 80 m²
    public var avgMiete80qm: Double {
        avgKaltmieteQm * 80.0
    }
}

/// Statische Datenbank mit repräsentativen deutschen Städten und Regionen
public enum CityMarketDatabase {
    public static let allCities: [CityLocation] = [
        // SEHR TEUER (> 6.500 € / m²)
        CityLocation(name: "München", bundesland: .bayern, avgQmPreisWohnung: 8_400, avgQmPreisHaus: 8_900, avgKaltmieteQm: 21.50, priceCategory: .sehrTeuer),
        CityLocation(name: "Frankfurt am Main", bundesland: .hessen, avgQmPreisWohnung: 6_300, avgQmPreisHaus: 5_900, avgKaltmieteQm: 17.00, priceCategory: .sehrTeuer),
        CityLocation(name: "Hamburg", bundesland: .hamburg, avgQmPreisWohnung: 6_100, avgQmPreisHaus: 5_400, avgKaltmieteQm: 15.80, priceCategory: .sehrTeuer),
        CityLocation(name: "Stuttgart", bundesland: .badenWuerttemberg, avgQmPreisWohnung: 5_100, avgQmPreisHaus: 5_300, avgKaltmieteQm: 15.50, priceCategory: .sehrTeuer),
        CityLocation(name: "Freiburg im Breisgau", bundesland: .badenWuerttemberg, avgQmPreisWohnung: 5_300, avgQmPreisHaus: 5_600, avgKaltmieteQm: 15.50, priceCategory: .sehrTeuer),
        CityLocation(name: "Heidelberg", bundesland: .badenWuerttemberg, avgQmPreisWohnung: 5_200, avgQmPreisHaus: 5_400, avgKaltmieteQm: 15.20, priceCategory: .sehrTeuer),
        CityLocation(name: "Potsdam", bundesland: .brandenburg, avgQmPreisWohnung: 5_100, avgQmPreisHaus: 5_200, avgKaltmieteQm: 14.00, priceCategory: .sehrTeuer),

        // TEUER (4.500 € – 6.500 € / m²)
        CityLocation(name: "Berlin", bundesland: .berlin, avgQmPreisWohnung: 5_200, avgQmPreisHaus: 4_800, avgKaltmieteQm: 15.50, priceCategory: .teuer),
        CityLocation(name: "Düsseldorf", bundesland: .nordrheinWestfalen, avgQmPreisWohnung: 4_900, avgQmPreisHaus: 4_700, avgKaltmieteQm: 14.50, priceCategory: .teuer),
        CityLocation(name: "Köln", bundesland: .nordrheinWestfalen, avgQmPreisWohnung: 4_700, avgQmPreisHaus: 4_400, avgKaltmieteQm: 14.20, priceCategory: .teuer),
        CityLocation(name: "Regensburg", bundesland: .bayern, avgQmPreisWohnung: 4_800, avgQmPreisHaus: 4_900, avgKaltmieteQm: 13.50, priceCategory: .teuer),
        CityLocation(name: "Augsburg", bundesland: .bayern, avgQmPreisWohnung: 4_500, avgQmPreisHaus: 4_600, avgKaltmieteQm: 13.00, priceCategory: .teuer),
        CityLocation(name: "Münster", bundesland: .nordrheinWestfalen, avgQmPreisWohnung: 4_600, avgQmPreisHaus: 4_400, avgKaltmieteQm: 13.20, priceCategory: .teuer),
        CityLocation(name: "Mainz", bundesland: .rheinlandPfalz, avgQmPreisWohnung: 4_500, avgQmPreisHaus: 4_300, avgKaltmieteQm: 13.50, priceCategory: .teuer),

        // MITTEL / FAIR (2.800 € – 4.500 € / m²)
        CityLocation(name: "Nürnberg", bundesland: .bayern, avgQmPreisWohnung: 3_900, avgQmPreisHaus: 4_100, avgKaltmieteQm: 12.20, priceCategory: .mittel),
        CityLocation(name: "Wiesbaden", bundesland: .hessen, avgQmPreisWohnung: 4_200, avgQmPreisHaus: 4_300, avgKaltmieteQm: 13.00, priceCategory: .mittel),
        CityLocation(name: "Bonn", bundesland: .nordrheinWestfalen, avgQmPreisWohnung: 3_900, avgQmPreisHaus: 3_800, avgKaltmieteQm: 12.50, priceCategory: .mittel),
        CityLocation(name: "Karlsruhe", bundesland: .badenWuerttemberg, avgQmPreisWohnung: 4_100, avgQmPreisHaus: 4_200, avgKaltmieteQm: 12.80, priceCategory: .mittel),
        CityLocation(name: "Mannheim", bundesland: .badenWuerttemberg, avgQmPreisWohnung: 3_600, avgQmPreisHaus: 3_800, avgKaltmieteQm: 12.00, priceCategory: .mittel),
        CityLocation(name: "Hannover", bundesland: .niedersachsen, avgQmPreisWohnung: 3_500, avgQmPreisHaus: 3_600, avgKaltmieteQm: 11.20, priceCategory: .mittel),
        CityLocation(name: "Leipzig", bundesland: .sachsen, avgQmPreisWohnung: 3_200, avgQmPreisHaus: 3_400, avgKaltmieteQm: 9.80, priceCategory: .mittel),
        CityLocation(name: "Dresden", bundesland: .sachsen, avgQmPreisWohnung: 3_100, avgQmPreisHaus: 3_300, avgKaltmieteQm: 9.50, priceCategory: .mittel),
        CityLocation(name: "Bremen", bundesland: .bremen, avgQmPreisWohnung: 2_900, avgQmPreisHaus: 2_800, avgKaltmieteQm: 9.80, priceCategory: .mittel),
        CityLocation(name: "Kiel", bundesland: .schleswigHolstein, avgQmPreisWohnung: 3_400, avgQmPreisHaus: 3_300, avgKaltmieteQm: 10.80, priceCategory: .mittel),
        CityLocation(name: "Lübeck", bundesland: .schleswigHolstein, avgQmPreisWohnung: 3_600, avgQmPreisHaus: 3_500, avgKaltmieteQm: 11.00, priceCategory: .mittel),
        CityLocation(name: "Rostock", bundesland: .mecklenburgVorpommern, avgQmPreisWohnung: 3_600, avgQmPreisHaus: 3_500, avgKaltmieteQm: 10.50, priceCategory: .mittel),
        CityLocation(name: "Erfurt", bundesland: .thueringen, avgQmPreisWohnung: 2_900, avgQmPreisHaus: 2_900, avgKaltmieteQm: 9.20, priceCategory: .mittel),

        // GÜNSTIG (< 2.800 € / m²)
        CityLocation(name: "Dortmund", bundesland: .nordrheinWestfalen, avgQmPreisWohnung: 2_400, avgQmPreisHaus: 2_600, avgKaltmieteQm: 8.90, priceCategory: .guenstig),
        CityLocation(name: "Essen", bundesland: .nordrheinWestfalen, avgQmPreisWohnung: 2_500, avgQmPreisHaus: 2_700, avgKaltmieteQm: 9.10, priceCategory: .guenstig),
        CityLocation(name: "Bielefeld", bundesland: .nordrheinWestfalen, avgQmPreisWohnung: 2_700, avgQmPreisHaus: 2_800, avgKaltmieteQm: 9.50, priceCategory: .guenstig),
        CityLocation(name: "Kassel", bundesland: .hessen, avgQmPreisWohnung: 2_600, avgQmPreisHaus: 2_700, avgKaltmieteQm: 8.80, priceCategory: .guenstig),
        CityLocation(name: "Saarbrücken", bundesland: .saarland, avgQmPreisWohnung: 2_300, avgQmPreisHaus: 2_200, avgKaltmieteQm: 8.50, priceCategory: .guenstig),
        CityLocation(name: "Magdeburg", bundesland: .sachsenAnhalt, avgQmPreisWohnung: 2_100, avgQmPreisHaus: 2_300, avgKaltmieteQm: 7.80, priceCategory: .guenstig),
        CityLocation(name: "Halle (Saale)", bundesland: .sachsenAnhalt, avgQmPreisWohnung: 2_200, avgQmPreisHaus: 2_400, avgKaltmieteQm: 7.90, priceCategory: .guenstig),
        CityLocation(name: "Chemnitz", bundesland: .sachsen, avgQmPreisWohnung: 1_650, avgQmPreisHaus: 1_950, avgKaltmieteQm: 6.20, priceCategory: .guenstig),
        CityLocation(name: "Gelsenkirchen", bundesland: .nordrheinWestfalen, avgQmPreisWohnung: 1_750, avgQmPreisHaus: 2_100, avgKaltmieteQm: 7.20, priceCategory: .guenstig),
        CityLocation(name: "Görlitz", bundesland: .sachsen, avgQmPreisWohnung: 1_450, avgQmPreisHaus: 1_750, avgKaltmieteQm: 5.90, priceCategory: .guenstig)
    ]
}
