import Foundation

/// Gespeichertes Szenario zum Vergleichen von Finanzierungsoptionen
public struct SavedScenario: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public let datum: Date
    public var input: PropertyInput
    
    public init(name: String, input: PropertyInput) {
        self.id = UUID()
        self.name = name
        self.datum = Date()
        self.input = input
    }
}
