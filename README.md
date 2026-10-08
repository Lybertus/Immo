# 🏠 ImmobilienRechner Pro (Interhyp-Standard)

Ein hochmoderner, nativer **Immobilien-Kauf- & Baufinanzierungsrechner**, entwickelt mit **SwiftUI** für das **iPhone 15 Pro Max** und den **MacBook Pro M4 (Apple Silicon)**.

Mit flexiblem **Dark Mode / OLED-Dunkelmodus**, **16 wählbaren Apple-Akzentfarben**, **verschiedenen UI-Designstilen** sowie einem integrierten **Haushalts- & Budgetrechner nach Interhyp-Standard**.

---

## ✨ Neue Features & Highlights

### 🎨 1. Dark Mode & Großes Design-System
* **Erscheinungsbild wählbar**: *System*, *Hell* oder *Dunkel (OLED)*.
* **16 kuratierte Akzentfarben**:
  * Apple Blau, Ocean Cyan, Tiefes Indigo, Royal Lila
  * Magenta Pink, Rubinrot, Sunset Koralle, Warmes Bernstein
  * Champagner Gold, Smaragdgrün, Frische Minze, Petrol Teal
  * Waldgrün, Cyber Neon, Schiefergrau, Kupfer Bronze
* **3 Design-Stile**:
  * *Modern Apple* (weiche Rundungen, Glaseffekte)
  * *Minimal Clean* (flach, puristisch, klare Linien)
  * *Finanz-Kompakt* (hohe Informationsdichte, perfekt für Mac)

### 💼 2. Haushaltsrechner & Leistbarkeit (Interhyp-Prinzip)
* **Haushaltsnettoeinkommen** eingeben (z. B. 4.500 € monatlich).
* **Wohnkosten-Abschlag einstellen (20 % bis 45 %)**:
  * 25 % = Sehr vorsichtig
  * 30 % = Solide & konservativ
  * 35 % = **Empfohlener Standard** (Interhyp & Verbraucherzentrale) ⭐
  * 40 % = Maximal vertretbare Belastungsgrenze
* **Banken-Ampel**: Zeigt sofort an, ob die Rate für Banken finanzierbar ist.
* **Maximaler Kaufpreis ermitteln**:
  * Berechnet unter Berücksichtigung von Nebenkosten, Grunderwerbsteuer und Eigenkapital, wie teuer deine Immobilie maximal sein darf.
  * **1-Klick-Übernahme**: Überträgt das Budget sofort in den Hauptrechner!

### 🎯 3. Multi-Ziel-Berechnung (Reverse-Calculator)
* **Ziel A: Kaufpreis ➔ Rate** (Klassische Darlehensberechnung).
* **Ziel B: Budget / Max. Kaufpreis** (Ausgehend von der Monatsrate).
* **Ziel C: Wunschlaufzeit ➔ Tilgung** (z. B. schuldenfrei in 25 Jahren bis zur Rente – berechnet die exakt dafür nötige Tilgung!).
* **2 % Tilgungsempfehlung**:
  * Schnellbutton `⭐ 2,0 % Empfehlung setzen`.
  * Ausführliche Erklärung, warum Banken 2,0 % Tilgung bei Zinsen um 3,5–4 % verlangen (Schuldenfreiheit in ~27 Jahren statt über 40 Jahren).

### 💶 4. Kaufnebenkosten & 16 Bundesländer
* Aktuelle Grunderwerbsteuer für alle 16 Bundesländer (Bayern 3,5 %, NRW 6,5 %, etc.).
* Notar & Grundbuch (1,0 % – 3,0 %, Standard 2,0 %).
* Maklerprovision konfigurierbar (z. B. 3,57 % inkl. MwSt. oder 0 %).
* Modernisierungs- & Renovierungsbudget.

### 📅 5. Tilgungsplan & Rendite (Kapitalanlage)
* Jahr-für-Jahr-Tilgungsplan mit Restschuld am Jahresende und Markierung des Zinsbindungsendes.
* Renditerechner für Vermieter mit Kaltmiete, Instandhaltungsrücklage und Netto-Cashflow vor Steuer.
* Szenarien speichern und direkt vergleichen.

---

## 📱 & 💻 Plattform-Optimierung

| Plattform | Highlights |
| :--- | :--- |
| **iPhone 15 Pro Max** | Speziell angepasst an das 6,7-Zoll Display, Dynamic Island, native TabBar, haptisches Feedback und große Slider. |
| **MacBook Pro M4** | Apple Silicon M4 Support: Nativer Split-View mit Sidebar-Navigation, Fensterskalierung und Tastatur-Shortcuts. |

---

## 📁 Projektstruktur

```
ImmobilienRechner/
├── .gitignore
├── LICENSE
├── README.md
├── ImmobilienRechner.xcodeproj/       # Xcode-Projekt für iOS & macOS
│   ├── project.pbxproj
│   └── xcshareddata/xcschemes/
│       └── ImmobilienRechner.xcscheme
├── ImmobilienRechner/
│   ├── ImmobilienRechnerApp.swift    # App-Startpunkt
│   ├── Info.plist
│   ├── Assets.xcassets/              # Icons & Akzentfarben
│   ├── Models/
│   │   ├── FederalState.swift        # 16 Bundesländer & Steuersätze
│   │   ├── AmortizationYear.swift    # Tilgungsplan-Modell
│   │   ├── CalculationModel.swift    # Finanzmathematik
│   │   ├── InvestmentModel.swift     # Rendite & Cashflow
│   │   ├── ComparisonScenario.swift  # Variantenvergleich
│   │   ├── ThemeModel.swift          # Dark Mode & 16 Akzentfarben
│   │   └── AffordabilityModel.swift  # Haushaltsrechner & 30-35% Regel
│   ├── ViewModels/
│   │   └── CalculatorViewModel.swift # State & Persistenz
│   └── Views/
│       ├── ContentView.swift         # Adaptives SplitView/TabBar Layout
│       ├── Components/               # Karten, Slider, Donut-Diagramm
│       └── Tabs/
│           ├── CalculatorInputView.swift   # Rechner & 2% Badge
│           ├── AffordabilityView.swift     # Haushalts- & Budgetcheck
│           ├── ResultsSummaryView.swift    # Ergebnisse & Diagramme
│           ├── AmortizationTableView.swift # Tilgungsplan
│           ├── InvestmentYieldView.swift   # Mietrendite & Cashflow
│           ├── ComparisonView.swift        # Szenarien
│           └── SettingsView.swift          # Dark Mode & Farbpalette
└── WebPreview/
    └── index.html                    # Interaktive Web-Vorschau für Mac
```

---

## ⚡ Schnellstart & Testen auf dem Mac

### Option 1: Sofortiger Browser-Test (ohne Xcode)
```bash
open /Users/eugen/.gemini/antigravity/scratch/ImmobilienRechner/WebPreview/index.html
```

### Option 2: In Xcode für iPhone 15 Pro Max & Mac M4 öffnen
```bash
open /Users/eugen/.gemini/antigravity/scratch/ImmobilienRechner/ImmobilienRechner.xcodeproj
```
Wähle als Zielgerät:
* **iPhone 15 Pro Max**
* oder **My Mac (Mac Catalyst)** für native Mac-Ausführung.
Drücke `Cmd + R` zum Starten!

---

## 🚀 Auf GitHub hochladen

```bash
cd /Users/eugen/.gemini/antigravity/scratch/ImmobilienRechner
git remote add origin https://github.com/<DEIN-NUTZERNAME>/<DEIN-REPO-NAME>.git
git push -u origin main
```
