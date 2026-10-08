import Foundation

/// Daten für Kapitalanlage & Vermietungsrechnung
public struct InvestmentInput: Codable, Equatable {
    public var monatlicheKaltmiete: Double = 1_400
    public var nichtUmlegbareKostenMonat: Double = 150 // z.B. Hausverwaltung, Instandhaltungsrücklage
    public var instandhaltungRuecklageMonat: Double = 100
    public var mietsteigerungProJahr: Double = 1.5 // in % p.a.
    
    public init() {}
}

public struct InvestmentResult {
    public let jahresKaltmiete: Double
    public let bruttoMietrendite: Double // (Jahreskaltmiete / Kaufpreis) * 100
    public let nettoMietrendite: Double // (Jahresreinertrag / Gesamtkosten) * 100
    public let mietmultiplikator: Double // Kaufpreis / Jahreskaltmiete (Faktor)
    public let monatlicherCashflowVorSteuer: Double // Kaltmiete - Rate - nicht umlegbare Kosten
    public let jahresCashflowVorSteuer: Double
    
    public init(input: InvestmentInput, propertyInput: PropertyInput, result: CalculationResult) {
        let jahresMiete = input.monatlicheKaltmiete * 12.0
        self.jahresKaltmiete = jahresMiete
        
        let kaufpreis = max(1.0, propertyInput.kaufpreis)
        let gesamtkosten = max(1.0, result.gesamtkosten)
        
        self.bruttoMietrendite = (jahresMiete / kaufpreis) * 100.0
        
        let jahresNichtUmlegbar = (input.nichtUmlegbareKostenMonat + input.instandhaltungRuecklageMonat) * 12.0
        let jahresReinertrag = max(0, jahresMiete - jahresNichtUmlegbar)
        self.nettoMietrendite = (jahresReinertrag / gesamtkosten) * 100.0
        
        self.mietmultiplikator = jahresMiete > 0 ? (kaufpreis / jahresMiete) : 0
        
        let monatlicheAusgaben = result.monatlicheRate + input.nichtUmlegbareKostenMonat + input.instandhaltungRuecklageMonat
        self.monatlicherCashflowVorSteuer = input.monatlicheKaltmiete - monatlicheAusgaben
        self.jahresCashflowVorSteuer = self.monatlicherCashflowVorSteuer * 12.0
    }
}
