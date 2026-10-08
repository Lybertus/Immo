# 🏠 ImmobilienRechner (ImmoCalc Pro)

Ein nativer, moderner **Immobilien-Kauf- & Baufinanzierungsrechner**, entwickelt mit **SwiftUI** für das **iPhone 15 Pro Max** und den **MacBook Pro M4 (Apple Silicon)**.

Entwickelt für den universellen Einsatz: Läuft sowohl nativ auf iOS als auch auf macOS (via Mac Catalyst / "Designed for iPad on Mac") mit adaptivem Split-View-Layout.

---

## ✨ Features im Überblick

### 1. 💶 Exakte Kaufpreis- & Nebenkostenkalkulation
* **Reiner Kaufpreis** mit dynamischen Schiebereglern und Schnellauswahl-Buttons.
* **Alle 16 deutschen Bundesländer** mit den jeweils aktuellen Grunderwerbsteuersätzen (z. B. Bayern 3,5 %, NRW 6,5 %, Hessen 6,0 %).
* **Notar & Grundbucheintrag** (flexibel einstellbar, Richtwert 1,5 % – 2,0 %).
* **Maklerprovision** an-/abschaltbar mit konfigurierbarem Käuferanteil (z. B. 3,57 % inkl. MwSt.).
* **Modernisierungs- & Renovierungsbudget** zur Ermittlung der tatsächlichen Gesamtinvestition.

### 2. 🏦 Finanzierungs- & Zinskonditionen
* **Eigenkapital-Rechner** mit praktischer Schnellwahl (15 %, 20 %, 30 % Eigenkapitalquote oder reine Nebenkosten).
* **Sollzins p.a.** mit Feinabstimmung (Schrittweite 0,05 %).
* **Zinsbindung** (5, 10, 15, 20, 25 oder 30 Jahre).
* **Berechnungsmodi**:
  * *Über Tilgungssatz* (z. B. anfänglich 2,0 % p.a.)
  * *Über Wunschrate* (maximale monatliche Rate vorgeben)
* **Jährliche Sondertilgung** (z. B. bis zu 5 % der Darlehenssumme).

### 3. 📈 Ergebnisse & Banken-Kennzahlen
* **Monatliche Rate (Annuität)** mit visueller Aufteilung in Zins- und Tilgungsanteil ab dem 1. Monat.
* **Restschuld** nach Ablauf der Zinsbindungsfrist.
* **Gesamtlaufzeit** bis zur vollständigen Entschuldung (Monate und Jahre).
* **Zinskosten gesamt** über die gesamte Kreditlaufzeit.
* **Empfohlenes Mindest-Nettoeinkommen** nach der gängigen 35 %-Wohnkosten-Faustregel deutscher Banken.

### 4. 📅 Detaillierter Tilgungsplan
* **Jahr-für-Jahr-Tabelle**: Anfangsschuld, gezahlte Zinsen, Tilgung, Sondertilgung und Restschuld.
* Visuelle Hervorhebung des **Endes der Zinsbindung** mit Zielflagge.
* Filterbar (Alle Jahre vs. nur Zinsbindungsjahre).

### 5. 🏢 Rendite- & Cashflow-Rechner (Kapitalanlage / Vermieter)
* Eingabe von **Kaltmiete**, nicht umlegbaren Nebenkosten und **Instandhaltungsrücklage**.
* Automatische Berechnung von **Brutto-Mietrendite**, **Netto-Mietrendite** und **Mietmultiplikator** (Kaufpreisfaktor).
* **Monatlicher Netto-Cashflow vor Steuer** mit dynamischer Farbcodierung (Überschuss vs. monatliche Zuzahlung).

### 6. ⚖️ Szenarien-Vergleich & Export
* Beliebig viele Finanzierungsvarianten lokal speichern (z. B. *10 Jahre Zinsbindung bei 3,4 %* vs. *15 Jahre Zinsbindung bei 3,7 %*).
* Varianten nebeneinander vergleichen und mit einem Klick wieder in den Rechner laden.
* **Zusammenfassung teilen / exportieren** via ShareSheet (Text/PDF-fähig).

---

## 📱 & 💻 Plattform-Optimierung

| Plattform | Highlights |
| :--- | :--- |
| **iPhone 15 Pro Max** | Optimiert für das 6,7-Zoll Display & Dynamic Island, flüssige Gesten, große Touch-Ziele, haptisches Feedback, native TabBar. |
| **MacBook Pro M4** | Nutzen des Apple Silicon M4-Chips: Nativer Split-View mit Sidebar-Navigation, skalierbares Fenster, Tastatur-Shortcuts. |

---

## 🚀 Projektstruktur

```
ImmobilienRechner/
├── .gitignore
├── LICENSE
├── README.md
├── ImmobilienRechner.xcodeproj/       # Xcode-Projekt (iOS + macOS)
│   ├── project.pbxproj
│   └── xcshareddata/xcschemes/
│       └── ImmobilienRechner.xcscheme
├── ImmobilienRechner/
│   ├── ImmobilienRechnerApp.swift    # App-Startpunkt
│   ├── Info.plist
│   ├── Assets.xcassets/              # App-Icons & Akzentfarben
│   ├── Models/
│   │   ├── FederalState.swift        # Bundesländer & Steuersätze
│   │   ├── AmortizationYear.swift    # Tilgungsplan-Datenmodell
│   │   ├── CalculationModel.swift    # Finanzmathematik & Simulation
│   │   ├── InvestmentModel.swift     # Rendite- & Cashflow-Formeln
│   │   └── ComparisonScenario.swift  # Gespeicherte Szenarien
│   ├── ViewModels/
│   │   └── CalculatorViewModel.swift # State, Berechnungen & Persistenz
│   └── Views/
│       ├── ContentView.swift         # Adaptives Navigation-Layout
│       ├── Components/               # Reusable UI (Cards, Sliders, Donut-Chart)
│       └── Tabs/                     # Eingabe, Übersicht, Tilgungsplan, Rendite, Vergleich
└── WebPreview/
    └── index.html                    # Sofortiger Browser-Test auf Mac/PC
```

---

## 🛠️ Öffnen & Starten in Xcode

1. **Voraussetzung**: Ein Mac mit macOS 14+ und [Xcode](https://developer.apple.com/xcode/) (kostenlos im Mac App Store).
2. Doppelklicke auf die Datei `ImmobilienRechner.xcodeproj`, um das Projekt in Xcode zu öffnen.
3. Wähle oben in der Menüleiste dein Zielgerät:
   - Für das iPhone: **iPhone 15 Pro Max** (Simulator oder angeschlossenes Gerät)
   - Für das MacBook Pro M4: **My Mac (Mac Catalyst)** oder **My Mac (Designed for iPad)**
4. Drücke `Cmd + R` (oder klicke auf den Play-Button ▶️) zum Starten!

---

## 🌐 Sofortige Vorschau im Browser (ohne Xcode)

Möchtest du den Rechner sofort auf deinem MacBook Pro M4 ausprobieren, ohne vorher Xcode zu öffnen?
* Öffne einfach die Datei `WebPreview/index.html` in Safari oder Chrome:
  ```bash
  open WebPreview/index.html
  ```

---

## 📤 Auf GitHub hochladen

Führe im Projektverzeichnis folgende Befehle im Terminal aus:

```bash
# 1. In das Projektverzeichnis wechseln
cd /Users/eugen/.gemini/antigravity/scratch/ImmobilienRechner

# 2. Git initialisieren
git init

# 3. Dateien zur Versionskontrolle hinzufügen
git add .

# 4. Ersten Commit erstellen
git commit -m "Initial commit: Immobilien-Kaufrechner für iPhone 15 Pro Max & MacBook Pro M4"

# 5. Remote-Repository bei GitHub verknüpfen (Erstelle vorher ein leeres Repo auf github.com)
git branch -M main
git remote add origin https://github.com/<DEIN-GITHUB-NUTZERNAME>/<DEIN-REPO-NAME>.git

# 6. Auf GitHub pushen
git push -u origin main
```

---

## 📄 Lizenz

Dieses Projekt ist unter der [MIT-Lizenz](LICENSE) lizenziert.
