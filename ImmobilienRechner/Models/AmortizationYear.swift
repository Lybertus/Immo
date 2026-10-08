import Foundation

/// Ein Jahr im Tilgungsplan
public struct AmortizationYear: Identifiable, Codable {
    public var id: Int { jahr }
    
    public let jahr: Int
    public let anfangsRestschuld: Double
    public let gezahlteZinsen: Double
    public let gezahlteTilgung: Double
    public let sondertilgung: Double
    public let gesamtZahlung: Double
    public let endRestschuld: Double
    public let kumulierteZinsen: Double
    public let kumulierteTilgung: Double
    public let istEndeZinsbindung: Bool
    
    public init(
        jahr: Int,
        anfangsRestschuld: Double,
        gezahlteZinsen: Double,
        gezahlteTilgung: Double,
        sondertilgung: Double,
        gesamtZahlung: Double,
        endRestschuld: Double,
        kumulierteZinsen: Double,
        kumulierteTilgung: Double,
        istEndeZinsbindung: Bool
    ) {
        self.jahr = jahr
        self.anfangsRestschuld = anfangsRestschuld
        self.gezahlteZinsen = gezahlteZinsen
        self.gezahlteTilgung = gezahlteTilgung
        self.sondertilgung = sondertilgung
        self.gesamtZahlung = gesamtZahlung
        self.endRestschuld = endRestschuld
        self.kumulierteZinsen = kumulierteZinsen
        self.kumulierteTilgung = kumulierteTilgung
        self.istEndeZinsbindung = istEndeZinsbindung
    }
}
