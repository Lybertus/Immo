# 🏠 ImmobilienRechner Pro (Interhyp-Standard)

Ein hochmoderner, nativer **Immobilien-Kauf- & Baufinanzierungsrechner**, entwickelt mit **SwiftUI** für das **iPhone 15 Pro Max** und den **MacBook Pro M4 (Apple Silicon)**.

Mit flexiblem **Dark Mode / OLED-Dunkelmodus**, **16 wählbaren Apple-Akzentfarben**, **verschiedenen UI-Designstilen**, **Mieten-vs-Kaufen-Vergleich** sowie dem offiziellen **Interhyp-Erschwinglichkeitsindex**.

---

## ✨ Alle Features & Werkzeuge im Überblick

### ⚖️ 1. Mieten vs. Kaufen: Wohnst du aktuell günstig?
* **Mietmultiplikator & Ampelbewertung**:
  * Setzt deine aktuelle Kaltmiete ins Verhältnis zum Kaufpreis der Immobilie.
  * Zeigt sofort an: **Extrem günstig gemietet**, **Günstig**, **Marktüblich** oder **Teuer gemietet**.
  * Wenn du sehr günstig wohnst, erfährst du direkt, warum ein Kauf finanziell oft erst nach vielen Jahren Sinn ergibt!
* **Vermögensvergleich über 10 bis 30 Jahre**:
  * **Käufer**: Immobilienwert nach Wertsteigerung abzüglich Restschuld.
  * **Mieter**: Eigenkapital + monatlich gesparte Differenz angelegt im ETF (z. B. MSCI World / S&P mit Zinseszins).
  * **Break-Even-Jahr**: Zeigt das exakte Jahr an, ab dem der Kauf finanziell im Vorteil ist!

### 📊 2. Interhyp-Erschwinglichkeitsindex
* Misst die reale Erschwinglichkeit von Wohneigentum basierend auf:
  * Haushaltsnettoeinkommen
  * Aktuellem Zinsniveau & Tilgung
  * Quadratmeterpreisen
* **Index-Score (Basis 100)** mit Ampel:
  * $\ge 110$ = Hervorragend erschwinglich (Käufermarkt)
  * $90 - 110$ = Ausgewogener Markt
  * $< 90$ = Angespannter / schwer erschwinglicher Markt
* **Leistbare Quadratmeter**: Zeigt konkret an, wie viel Wohnfläche sich dein Haushalt aktuell leisten kann.

### ⌨️ 3. Zwei-Wege-Eingabe (Schieberegler + Tastatur)
* Alle Zahlen (Kaufpreis, Eigenkapital, Sollzins, Tilgungssatz, Miete etc.) können:
  * über flüssige **Schieberegler** angepasst werden
  * oder **direkt angeklickt und mit der Tastatur umgetippt** werden!

### ⚡ 4. Reale Interhyp-Marktzinsen & Anschlussfinanzierung
* **Automatische Zinsanpassung**:
  * Wählst du **20 Jahre Zinsbindung**, wird automatisch der aktuelle Marktzins (ca. **4,00 %**) voreingestellt.
  * Bei **10 Jahren**: ca. **3,60 %**, bei **15 Jahren**: ca. **3,80 %**.
* **Anschlussfinanzierung**:
  * Standardmäßig „Gleicher Zinssatz“, damit man realistisch durchrechnen kann.
  * Optionaler **Stresstest (+1 % oder +2 %)** nach Ende der Zinsbindung.

### 📈 5. Interaktives Kurvendiagramm (Amortisation)
* **Restschuld-Kurve**: Visualisiert den exakten Schuldenabbau von Tag 1 bis zur vollständigen Tilgung (`0 €`).
* **Zins-Kurve**: Zeigt die gezahlten Zinskosten im Zeitverlauf.
* **Zielflagge (`🏁`)**: Markiert das Ende der Zinsbindung mit verbleibender Restschuld.

### 🎨 6. Dark Mode & 16 Apple-Akzentfarben
* Echtes **OLED-Schwarz**, Hell oder System-Erscheinungsbild.
* 16 kuratierte Akzentfarben (Apple Blau, Smaragdgrün, Cyan, Royal Lila, etc.).
* 3 Design-Stile: *Modern Apple*, *Minimal Clean* und *Finanz-Kompakt*.

### 📍 7. Ortssuche & Immobilien-Marktpreise (38 deutsche Städte & Regionen)
* **Live-Suche & Filter nach 4 Preisklassen**:
  * 🟢 **Günstig** (< 2.800 €/m²): z. B. Dortmund, Essen, Chemnitz, Magdeburg, Görlitz
  * 🟡 **Mittel / Fair** (2.800 – 4.500 €/m²): z. B. Nürnberg, Hannover, Leipzig, Dresden, Bremen
  * 🟠 **Teuer** (4.500 – 6.500 €/m²): z. B. Berlin, Köln, Düsseldorf, Münster, Mainz
  * 🔴 **Sehr teuer (Metropolen)** (> 6.500 €/m²): München, Frankfurt, Hamburg, Stuttgart, Freiburg, Potsdam
* **Detaillierte Kennzahlen je Stadt**:
  * Durchschnittspreis Wohnung pro m² (sowie typischer Kaufpreis 80 m²)
  * Durchschnittspreis Haus pro m² (sowie typischer Kaufpreis 140 m²)
  * Durchschnittliche Kaltmiete pro m² (sowie typische Monatsmiete)
  * Exakter Grunderwerbsteuersatz des zugehörigen Bundeslandes
### 💡 8. Fundierte Experten-Empfehlungen & Faustregeln für Einsteiger
* **In jedem Reiter integriert**:
  * **Kaufrechner**: 20 % Eigenkapital-Regel, Notgroschen-Puffer (3–6 Monatsgehälter), 2 % Tilgungsminimum, 15–20 Jahre Zinsbindung, kostenlose Sondertilgung.
  * **Orte & Marktpreise**: Mikrolage vs. Makrolage, Grunderwerbsteuer-Gefälle (3,5 % vs. 6,5 %), Rücklagen für Haus vs. Eigentumswohnung.
  * **Mieten vs. Kaufen**: Mietmultiplikator-Ampel (< 20x vs. > 30x), Kaufnebenkosten als verlorenes Geld, Opportunitätskosten des ETF-Depots, Interhyp-Index.
  * **Haushalt & Budget**: Die 30–35 % Regel, Warmkosten-Aufschlag (3,50 €/m²), Schuldenfreiheit bis Renteneintritt (67 Jahre).
  * **Auswertung & Tilgungsplan**: Restschuldfalle am Bindungsende, Annuitäten-Effekt, Zinsersparnis durch Sondertilgungen.
  * **Rendite**: Brutto- vs. Netto-Mietrendite, Cashflow-Risiken.
* **Ein- und Ausblendbar**: Über die Einstellungen oder direkt per Klick ein- und ausklappbar, damit Fortgeschrittene die Ansicht kompakt halten können.

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
│   │   ├── CityMarketData.swift      # 38 Städte, Preisklassen & qm-Preise
│   │   ├── TabRecommendationsModel.swift # Experten-Tipps für alle 9 Reiter
│   │   ├── AmortizationYear.swift    # Tilgungsplan-Modell
│   │   ├── CalculationModel.swift    # Finanzmathematik
│   │   ├── InvestmentModel.swift     # Rendite & Cashflow
│   │   ├── ComparisonScenario.swift  # Variantenvergleich
│   │   ├── ThemeModel.swift          # Dark Mode & 16 Akzentfarben
│   │   ├── AffordabilityModel.swift  # Haushaltsrechner & 30-35% Regel
│   │   ├── MarketRatesModel.swift    # Interhyp Marktzins-Benchmarks
│   │   ├── RentVsBuyModel.swift      # Mieten vs. Kaufen Simulation
│   │   └── AffordabilityIndexModel.swift # Interhyp Erschwinglichkeitsindex
│   ├── ViewModels/
│   │   └── CalculatorViewModel.swift # State & Persistenz
│   └── Views/
│       ├── ContentView.swift         # Adaptives SplitView/TabBar Layout
│       ├── Components/               # Karten, Slider, Donut-Diagramm, Kurvendiagramm
│       │   ├── ExpertTipsCardView.swift  # Ausklappbare Empfehlungskarte
│       │   ├── CurrencyInputField.swift  # Direkte Tastatureingabe
│       │   └── AmortizationChartView.swift # Interaktive Kurve
│       └── Tabs/
│           ├── CalculatorInputView.swift   # Rechner & 2% Badge
│           ├── CityLocationSearchView.swift # Ortssuche, Preise & Filter
│           ├── RentVsBuyView.swift         # Mieten vs. Kaufen & Index
│           ├── AffordabilityView.swift     # Haushalts- & Budgetcheck
│           ├── ResultsSummaryView.swift    # Ergebnisse & Kurvendiagramm
│           ├── AmortizationTableView.swift # Tilgungsplan
│           ├── InvestmentYieldView.swift   # Mietrendite & Cashflow
│           ├── ComparisonView.swift        # Szenarien
│           └── SettingsView.swift          # Dark Mode, Farbpalette & Tipps
└── WebPreview/
    └── index.html                    # Interaktive Web-Vorschau für Mac
```

---

## ⚡ Schnellstart auf dem Mac

### 1. Sofort im Browser testen (ohne Xcode)
```bash
open /Users/eugen/.gemini/antigravity/scratch/ImmobilienRechner/WebPreview/index.html
```

### 2. In Xcode für iPhone 15 Pro Max & Mac M4 öffnen
```bash
open /Users/eugen/.gemini/antigravity/scratch/ImmobilienRechner/ImmobilienRechner.xcodeproj
```

### 3. Auf GitHub hochladen
```bash
cd /Users/eugen/.gemini/antigravity/scratch/ImmobilienRechner
git push -u origin main
```
