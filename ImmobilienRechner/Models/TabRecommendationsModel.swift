import Foundation
import SwiftUI

/// Kategorie eines Experten-Tipps
public enum TipBadgeType: String, Codable {
    case formula = "Faustformel"
    case interhyp = "Interhyp-Standard"
    case warning = "Achtung Falle"
    case saving = "Spartipp"
    case info = "Experten-Wissen"
    
    public var icon: String {
        switch self {
        case .formula: return "function"
        case .interhyp: return "checkmark.seal.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .saving: return "banknote.fill"
        case .info: return "lightbulb.fill"
        }
    }
    
    public var badgeColor: Color {
        switch self {
        case .formula: return .blue
        case .interhyp: return .teal
        case .warning: return .orange
        case .saving: return .green
        case .info: return .purple
        }
    }
}

/// Einzelner Experten-Tipp für Neulinge
public struct ExpertTip: Identifiable, Codable, Equatable {
    public var id: String { headline }
    public let headline: String
    public let text: String
    public let badgeType: TipBadgeType
    public let systemIcon: String
    
    public init(headline: String, text: String, badgeType: TipBadgeType, systemIcon: String) {
        self.headline = headline
        self.text = text
        self.badgeType = badgeType
        self.systemIcon = systemIcon
    }
}

/// Gebündelte Empfehlungen für einen bestimmten Reiter (Tab)
public struct TabRecommendation: Identifiable, Equatable {
    public var id: String { tabTitle }
    public let tabTitle: String
    public let summary: String
    public let tips: [ExpertTip]
    
    public init(tabTitle: String, summary: String, tips: [ExpertTip]) {
        self.tabTitle = tabTitle
        self.summary = summary
        self.tips = tips
    }
}

/// Statische Datenbank mit fundierten Empfehlungen für jeden App-Reiter
public enum TabRecommendationsDatabase {
    
    public static func recommendation(for tab: NavigationTab) -> TabRecommendation {
        switch tab {
        case .eingabe:
            return TabRecommendation(
                tabTitle: "Empfehlungen für die Baufinanzierung",
                summary: "Das Fundament: Mit diesen Faustregeln sicherst du dir die besten Zinsen und vermeidest teure Anfängerfehler.",
                tips: [
                    ExpertTip(
                        headline: "20 % Eigenkapital + Nebenkosten mitbringen",
                        text: "Zahle die Kaufnebenkosten (ca. 10–12 %) sowie mindestens 20 % des Kaufpreises aus Eigenkapital. So stufen dich Banken in die beste Bonitätsklasse ein und erlassen teure Zinsaufschläge.",
                        badgeType: .formula,
                        systemIcon: "percent"
                    ),
                    ExpertTip(
                        headline: "Notgroschen niemals für den Kauf opfern",
                        text: "Stecke niemals alle Ersparnisse in die Immobilie! Behalte zwingend 3 bis 6 Netto-Monatsgehälter auf dem Tagesgeld für Umzug, Küche oder plötzliche Reparaturen.",
                        badgeType: .warning,
                        systemIcon: "shield.lefthalf.filled"
                    ),
                    ExpertTip(
                        headline: "Mindestens 2,0 % anfängliche Tilgung wählen",
                        text: "Interhyp und Verbraucherzentralen raten dringend zu mindestens 2,0 % (besser 2,5–3 %). Bei nur 1 % Tilgung zahlst du über 40 Jahre lang ab und verschenkst zehntausende Euro an Zinsen.",
                        badgeType: .interhyp,
                        systemIcon: "arrow.up.right.circle.fill"
                    ),
                    ExpertTip(
                        headline: "15 bis 20 Jahre Zinsbindung bevorzugen",
                        text: "Wähle lange Planungssicherheit. Bei nur 10 Jahren Zinsbindung ist die Restschuld noch sehr hoch. Steigen die Zinsen danach, droht eine unbezahlbare Monatsrate.",
                        badgeType: .info,
                        systemIcon: "calendar.badge.clock"
                    ),
                    ExpertTip(
                        headline: "5 % jährliche Sondertilgung kostenfrei vereinbaren",
                        text: "Bestehe im Darlehensvertrag auf eine kostenlose Sondertilgungsoption von mind. 5 % p.a. So kannst du Boni, Urlaubs- oder Weihnachtsgeld direkt schuldenmindernd einbringen.",
                        badgeType: .saving,
                        systemIcon: "plus.circle.fill"
                    )
                ]
            )
            
        case .orte:
            return TabRecommendation(
                tabTitle: "Empfehlungen für Orte & Marktpreise",
                summary: "Lage, Lage, Lage: Wie du Quadratmeterpreise richtig bewertest und regionale Steuerfallen umgehst.",
                tips: [
                    ExpertTip(
                        headline: "Mikrolage schlägt Makrolage",
                        text: "Günstige Orte (< 2.800 €/m²) bieten oft attraktive Mietrenditen, aber geringere Wertsteigerung. In Metropolen (> 6.500 €/m²) ist der Einstieg teuer, die Wiederverkäuflichkeit jedoch extrem krisenfest.",
                        badgeType: .formula,
                        systemIcon: "map.fill"
                    ),
                    ExpertTip(
                        headline: "Grunderwerbsteuer-Unterschied von bis zu 3,0 %",
                        text: "In Bayern zahlst du nur 3,5 % Grunderwerbsteuer, in NRW, Saarland oder Brandenburg dagegen 6,5 %. Bei 500.000 € Kaufpreis macht das 15.000 € Unterschied an reinem Eigenkapital!",
                        badgeType: .warning,
                        systemIcon: "building.columns.fill"
                    ),
                    ExpertTip(
                        headline: "Haus vs. Wohnung: Rücklagen bedenken",
                        text: "In einer Eigentumswohnung teilst du Sanierungskosten mit der WEG, zahlst aber Hausgeld. Beim Haus trägst du Dach und Heizung allein – plane mind. 1,50–2,50 €/m² monatlich als Rücklage ein.",
                        badgeType: .info,
                        systemIcon: "house.fill"
                    )
                ]
            )
            
        case .mietenVsKaufen:
            return TabRecommendation(
                tabTitle: "Empfehlungen für Mieten vs. Kaufen",
                summary: "Finanzieller Realitätscheck: Wann sich Kaufen wirklich lohnt und wann Mieten mit ETF-Depot gewinnt.",
                tips: [
                    ExpertTip(
                        headline: "Mietmultiplikator als Orientierung nutzen",
                        text: "Kaufpreis geteilt durch Jahreskaltmiete: Unter 20x ist Kaufen historisch attraktiv. Liegt der Faktor über 28–30x, ist die Miete so günstig, dass Mieten rein finanziell oft überlegen ist.",
                        badgeType: .formula,
                        systemIcon: "scalemass.fill"
                    ),
                    ExpertTip(
                        headline: "Kaufnebenkosten sind verlorenes Geld",
                        text: "Notar, Grunderwerbsteuer und Makler (ca. 10 %) steigern nicht den Immobilienwert. Es dauert in der Regel 5 bis 8 Jahre Wertsteigerung, nur um diese Nebenkosten wieder auszugleichen.",
                        badgeType: .warning,
                        systemIcon: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90"
                    ),
                    ExpertTip(
                        headline: "Die Macht des Mieter-ETF-Depots",
                        text: "Als Mieter bindest du kein Eigenkapital im Beton. Wenn du das nicht eingesetzte Eigenkapital plus die monatliche Ersparnis diszipliniert in weltweite ETFs anlegst, baust du oft ein höheres Endvermögen auf.",
                        badgeType: .saving,
                        systemIcon: "chart.line.uptrend.xyaxis"
                    ),
                    ExpertTip(
                        headline: "Erschwinglichkeitsindex über 100 Punkte",
                        text: "Der Interhyp-Index misst, ob sich ein Durchschnittshaushalt mit aktuellen Zinsen eine Familienwohnung leisten kann. Werte über 100 signalisieren gute Kaufchancen.",
                        badgeType: .interhyp,
                        systemIcon: "gauge.with.needle.fill"
                    )
                ]
            )
            
        case .budget:
            return TabRecommendation(
                tabTitle: "Empfehlungen für Haushaltsrechner & Budget",
                summary: "Sicher kalkulieren: So stellst du sicher, dass die monatliche Kreditrate deine Lebensqualität nicht einschränkt.",
                tips: [
                    ExpertTip(
                        headline: "Die goldene 30–35 % Regel einhalten",
                        text: "Die Monatsrate sollte maximal 30 % bis 35 % deines Haushaltsnettoeinkommens betragen. Steigt die Belastung über 40 %, werten Banken den Kredit als Hochrisiko und lehnen ab.",
                        badgeType: .formula,
                        systemIcon: "wallet.pass.fill"
                    ),
                    ExpertTip(
                        headline: "Warmkosten & Instandhaltung zur Rate addieren",
                        text: "Die Kreditrate ist nur die Kaltmiete an die Bank! Rechne noch ca. 3,50 €/m² für Heizung, Müll, Grundsteuer und Instandhaltungsrücklage dazu, um die reale Belastung zu kennen.",
                        badgeType: .warning,
                        systemIcon: "flame.fill"
                    ),
                    ExpertTip(
                        headline: "Schuldenfrei bis zum 67. Lebensjahr",
                        text: "Plane die Gesamtlaufzeit so, dass das Darlehen spätestens mit Renteneintritt vollständig auf 0 € getilgt ist. Eine Kreditrate von der gesetzlichen Rente abzuzahlen ist riskant.",
                        badgeType: .interhyp,
                        systemIcon: "person.crop.circle.badge.checkmark"
                    )
                ]
            )
            
        case .uebersicht:
            return TabRecommendation(
                tabTitle: "Empfehlungen für die Gesamtauswertung",
                summary: "Zahlen richtig deuten: Achte auf die Restschuld nach der Zinsbindung und die Gesamtzinskosten.",
                tips: [
                    ExpertTip(
                        headline: "Restschuld-Risiko nach Zinsbindungsende",
                        text: "Prüfe genau, wie viel Restschuld am Ende der Zinsbindung verbleibt. Beträgt sie mehr als 50 %, sichere dir rechtzeitig (3 Jahre vor Ablauf) ein Forward-Darlehen bei guten Marktzinsen.",
                        badgeType: .warning,
                        systemIcon: "clock.badge.exclamationmark"
                    ),
                    ExpertTip(
                        headline: "Zinskosten ins Verhältnis zum Kaufpreis setzen",
                        text: "Über 25 bis 30 Jahre zahlst du oft 40 % bis 70 % des ursprünglichen Kaufpreises zusätzlich an Zinsen an die Bank. Jeder Prozentpunkt mehr Tilgung spart bares Geld.",
                        badgeType: .info,
                        systemIcon: "eurosign.circle.fill"
                    )
                ]
            )
            
        case .tilgungsplan:
            return TabRecommendation(
                tabTitle: "Empfehlungen für den Tilgungsplan",
                summary: "Das Annuitäten-Prinzip verstehen: Wie Zins- und Tilgungsanteile Monat für Monat ineinandergreifen.",
                tips: [
                    ExpertTip(
                        headline: "Die Annuitäten-Dynamik nutzen",
                        text: "Zu Beginn zahlst du überwiegend Zinsen an die Bank. Weil die Restschuld sinkt, verringert sich der Zinsanteil jeden Monat – und dein Tilgungsanteil wächst automatisch rasant an.",
                        badgeType: .info,
                        systemIcon: "chart.bar.doc.horizontal"
                    ),
                    ExpertTip(
                        headline: "Die enorme Wirkung kleiner Sondertilgungen",
                        text: "Schon eine jährliche Sondertilgung von 2.000 € verkürzt die Gesamtlaufzeit oft um 3 bis 5 Jahre und spart dir über 15.000 € an Zinskosten!",
                        badgeType: .saving,
                        systemIcon: "sparkles"
                    )
                ]
            )
            
        case .rendite:
            return TabRecommendation(
                tabTitle: "Empfehlungen für Kapitalanleger & Mietrendite",
                summary: "Erfolgreich vermieten: So kalkulierst du deine Rendite realistisch und verhinderst negative Cashflows.",
                tips: [
                    ExpertTip(
                        headline: "Niemals nur auf die Brutto-Mietrendite achten",
                        text: "Die Brutto-Mietrendite (Jahreskaltmiete / Kaufpreis) ignoriert Kaufnebenkosten und Instandhaltung. Nur die Netto-Mietrendite zeigt den echten Ertrag deines eingesetzten Kapitals.",
                        badgeType: .formula,
                        systemIcon: "chart.pie.fill"
                    ),
                    ExpertTip(
                        headline: "Negativen monatlichen Cashflow vermeiden",
                        text: "Reicht die Kaltmiete nicht aus, um Zins, Tilgung, Verwaltung und Instandhaltungsrücklage zu decken, musst du jeden Monat aus eigenem Gehalt zuschießen. Achte auf soliden Puffer.",
                        badgeType: .warning,
                        systemIcon: "arrow.down.right.and.arrow.up.left"
                    )
                ]
            )
            
        case .vergleich:
            return TabRecommendation(
                tabTitle: "Empfehlungen für den Varianten-Vergleich",
                summary: "Verschiedene Finanzierungsangebote gegeneinander ausspielen und den besten Deal finden.",
                tips: [
                    ExpertTip(
                        headline: "Zinsbindung 10 vs. 20 Jahre vergleichen",
                        text: "10 Jahre bieten einen niedrigeren Zinssatz, bergen aber das Risiko steigender Anschlusszinsen. Vergleiche beide Varianten, um den Preis deiner Planungssicherheit zu kennen.",
                        badgeType: .info,
                        systemIcon: "square.split.2x2.fill"
                    ),
                    ExpertTip(
                        headline: "Mehr Eigenkapital gegen monatliche Rate abwägen",
                        text: "Prüfe, wie sich 20.000 € mehr Eigenkapital auf deine Monatsrate und die Gesamtzinsen auswirken. Manchmal lohnt es sich, mehr Puffer auf dem Tagesgeld zu behalten.",
                        badgeType: .saving,
                        systemIcon: "slider.horizontal.2.square"
                    )
                ]
            )
            
        case .einstellungen:
            return TabRecommendation(
                tabTitle: "Tipps & Hinweise zu den Einstellungen",
                summary: "Passe die App an deine Vorlieben an. Du kannst diese Tipps hier jederzeit ein- oder ausblenden.",
                tips: [
                    ExpertTip(
                        headline: "Einsteiger-Tipps ein- oder ausblenden",
                        text: "Sobald du die wichtigsten Finanzierungsregeln verinnerlicht hast, kannst du die Einsteiger-Empfehlungen hier mit dem Schalter deaktivieren.",
                        badgeType: .info,
                        systemIcon: "lightbulb.fill"
                    ),
                    ExpertTip(
                        headline: "OLED-Dunkelmodus schont Akku & Augen",
                        text: "Auf dem iPhone 15 Pro Max und MacBook Pro M4 spart das echte OLED-Schwarz im Dunkelmodus Energie und sorgt bei Nacht für blendfreies Rechnen.",
                        badgeType: .saving,
                        systemIcon: "moon.stars.fill"
                    )
                ]
            )
        }
    }
}
