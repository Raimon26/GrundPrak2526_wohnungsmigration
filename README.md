# 📊 Wohnungsmigration in München (2000-2024): Eine explorative Datenanalyse (EDA)

## 🎯 Über das Projekt
Dieses Projekt ist eine umfassende **explorative Datenanalyse (EDA)** der demografischen Entwicklung und Migrationsströme in München über einen Zeitraum von fast 25 Jahren. 

Im Fokus der Untersuchung standen exakt drei Kernfragen:
1. **Zuzüge & Umzüge als Markt-Proxy:** Wie entwickeln sich Zu- und Umzüge in die 25 Stadtbezirke (als Proxy für neu abgeschlossene Mietverhältnisse)? Dabei wurde strikt zwischen Deutschen und Nicht-Deutschen unterschieden, um demografische Ausreißer sichtbar zu machen.
2. **Abwanderungsdynamik:** Wie entwickeln sich die Wegzüge aus den 25 Stadtbezirken über die Zeit, differenziert nach Bewegungen *innerhalb* und *außerhalb* der Stadtgrenzen?
3. **Wachstum & Dichte:** Wie stellen sich die generelle Bevölkerungsentwicklung und die Veränderung der Bevölkerungsdichte (Einwohner pro km²) in den einzelnen Bezirken dar?

Dieses Projekt entstand im Rahmen des "Grundlegenden Praxisprojekts" an der LMU (Betreuung: Christina Sauer) von:
**Heinz Calderón, Christian Lex, Dennis Ley, Haoyang Yang.**

## 📂 Datenbasis
Die Analyse stützt sich auf zwei Hauptdatenquellen der Stadt München:
* **Mobilitäts- und Dichte-Indikatoren (2000–2024):** Generelle Mobilitätsströme sowie die Bevölkerungsdichte für die 25 Münchner Stadtbezirke.
* **Wechselmatrizen der Binnenmigration (2005–2024):** 20 Origin-Destination-Matrizen (Excel), die exakt aufschlüsseln, wie viele Personen zwischen den spezifischen Bezirken umgezogen sind.

## 🛠️ Tech Stack & Methodik (EDA)
Das Projekt wurde vollständig in **R** umgesetzt, mit einem starken Fokus auf robuste Datenaufbereitung und aussagekräftige Visualisierung (DataViz), ohne Rückgriff auf prädiktive Modelle:
* **Data Wrangling:** `dplyr`, `tidyr`, `readxl` (Zusammenführung von Excel-Kreuztabellen, Transformation von Wide- zu Long-Formaten).
* **Feature Engineering:** Methodische Kategorisierung der 25 Bezirke in Strukturtypen (*Zentrum, Innenstadt-Rand, Peripherie*) zur Reduktion von Verzerrungen durch Ausreißer.
* **Geodatenverarbeitung:** `sf` (Einlesen von GeoJSON-Polygonen für Choropleth-Karten).
* **Advanced DataViz:** `ggplot2`, `ggalluvial` (Sankey-Diagramme für absolute Binnenströme, 100% Stacked Bar Charts für relative Verteilungen, Facet-Time-Series).

## 📈 Key Insights
Aus der deskriptiven Analyse ergaben sich folgende konsistente Trends:
* **Nationalität als Differenzierungsfaktor:** Die Zuzüge deutscher Staatsangehöriger weisen ein stabiles, leicht degressives Niveau auf, während die Migration nicht-deutscher Staatsangehöriger hohe Volatilität mit einem insgesamt steigenden Trend zeigt.
* **Suburbanisierung & Binnenmigration:** Es zeigt sich eine stetige Abwanderungstendenz aus dem Zentrum in die Peripherie. Gleichzeitig zeigt die EDA, dass etwa die Hälfte der Bewohner des Zentrums und der Peripherie bei einem Umzug im eigenen Bezirkstyp bleibt.
* **Flächendeckende Verdichtung:** Die Bevölkerungsdichte ist über den gesamten Untersuchungszeitraum in nahezu allen 25 Stadtbezirken kontinuierlich gestiegen.

## 🏗️ Projektstruktur
* `env_setup.R`: Dependency-Management.
* `01_data_wrangling.R`: Automatisierter Daten-Import und Bereinigung.
* `02_feature_engineering.R`: Zuweisung von Geografie- und Struktur-Features.
* `03_eda_tabellen.R`: Explorative Basis-Analyse (Ausreißer via IQR-Methode).
* `04_geodaten_vorbereitung.R`: Bereinigung der Geometrien.
* `05_visualisierungen_final.R`: Erstellung der Hauptgrafiken (Zeitreihen, Karten).
* `06_vergleich_2005_2024.R`: Statischer Vorher/Nachher-Vergleich der Dichte.
* `07_binnenmigration_sankey.R`: Flussvisualisierung der Binnenmigration.
