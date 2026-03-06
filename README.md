# GrundPrak2526_wohnungsmigration

# 📊 Migration in München - Datenanalyse

## 🛠️ Nutzung (How to run)
Bevor Analysen oder Grafiken erstellt werden, muss immer das Skript `env_setup.R` im Hauptverzeichnis ausgeführt werden. (oder source("env_setup.R") aufrufen!)
Dieses Skript:
1. Installiert und lädt alle benötigten Pakete (tidyverse, readr, etc.).
2. Lädt automatisch die sauberen, aufbereiteten Datensätze (`.rds`) aus dem `Data/`-Ordner in das R-Environment.

## 📂 Ordnerstruktur
* **`Data/`**: Enthält die rohen Excel-/CSV-Dateien des Rathauses sowie die sauberen `.rds`-Dateien (Tidy Data).
* **`env_setup.R`**: Das Herzstück für den Datenimport. (s.o.)
* **`01_datenbereinigung.R`**: Skript zur Bereinigung der 22 Rohdateien (NAs behandeln, fehlerhafte Summen korrigieren, Pivotierung).
* **`02_feature_engineering.R`**: Skript zur Kategorisierung der 25 Stadtbezirke (Zentrum, Innenstadt-Rand, Peripherie).

## 📖 Daten-Wörterbuch (Data Dictionary)
Um Missverständnisse bei der Analyse zu vermeiden, hier die Definition der wichtigsten Variablen in unseren sauberen Datensätzen:
* `zuzuege_aussen`: Personen, die von außerhalb Münchens in einen Bezirk gezogen sind.
* `umzuege_innen`: Personen, die von einem anderen Münchner Bezirk in diesen Bezirk gezogen sind.
* `wegzuege_aussen`: Personen, die den Bezirk verlassen haben und ganz aus München weggezogen sind.
* `wegzuege_innen`: Personen, die den Bezirk verlassen haben, aber innerhalb Münchens geblieben sind.
* `dichte`: Bevölkerungsdichte (Einwohner pro Quadratkilometer).
* `bezirk_typ`: Geografische/Strukturelle Klassifizierung des Bezirks (Zentrum, Innenstadt-Rand, Peripherie).

---

## 🚀 Projektrollen & Verantwortlichkeiten
### Grundlegendes Praxisprojekt: Migration in München

🛠️ 1. Data Wrangler (Daten-Aufbereiter)
**Mission**: Die Rohdaten bändigen. Das ist die Person, die sich mit NAs und Datumsformaten herumschlägt und dafür sorgt, dass die Struktur stimmt.

**Verantwortung**: Das Skript schreiben, das die Originaldaten einliest und einen sauberen Data Frame ausspuckt. Dieses Skript muss mit einem Klick durchlaufen. Falls die 25 Stadtbezirke in Kategorien eingeteilt werden müssen, erstellt diese Person die entsprechenden Variablen.

🎨 2. Lead Data Visualization (Visueller Architekt)
**Mission**: Die sauberen Daten in visuelle Geschichten übersetzen. Diese Person sollte von Tuftes Prinzipien besessen sein (Maximierung der Data-Ink-Ratio).

**Verantwortung**: Grafiken entwerfen, die keine Defaults verwenden. Achsen anpassen, barrierefreie Farbpaletten wählen und sicherstellen, dass der Code die Grafiken exakt so generiert, wie sie in die finale Präsentation kommen.

⚖️ 3. Quality Assurance & Methodology (Statistik-Prüfer)
**Mission**: Den Advocatus Diaboli spielen. Stellt sicher, dass wir aus rein beobachtenden Daten keine kausalen Schlüsse ziehen.

**Verantwortung**: Überprüft die Korrektheit der statistischen Berechnungen, achtet auf konsistente Definitionen (z. B. "Zu- und Umzüge") und ist hauptverantwortlich für das Verfassen des Executive Summarys.

🗣️ 4. Project Manager & Storyteller (Sprecher:in)
**Mission**: Das Schiff pünktlich in den Hafen bringen und dafür sorgen, dass die Story Sinn ergibt.

**Verantwortung**: Offizieller Kontakt zu den Betreuern. Pflegt das GitHub-Repository und den Zeitplan. Orchestriert die Präsentation, wählt die finalen Grafiken aus und verhindert überladene Folien (Wimmelbilder).

⚠️ Wichtiger Hinweis: Auch wenn wir die Hauptaufgaben so aufteilen, müssen wir alle vier den gesamten Prozess kennen und mündlich präsentieren. Diese Aufteilung dient nur dazu, dass wir uns beim Code nicht in die Quere kommen und klare Verantwortlichkeiten haben.

---

# 🛤️ Kritischer Pfad & Paralleles Arbeiten (Migration in München)
## Phase 1: Die parallele Basisarbeit (Tag 1–4)
**Ziel: Niemand wartet auf den anderen. Alle bereiten ihre Baustellen vor.**

🧹 Heinz (Data Wrangling): * Dateien: Die 22 Rohdateien + env_setup.R

Bändigt die 22 Rohdateien in R. Startet mit dem env_setup.R, um die Pakete zu laden.

Baut das Skript, das alles einliest, NAs behandelt und das fertige Tidy-Dataframe ausspuckt. (Wichtig: .RData und .Rhistory sofort löschen oder ins .gitignore packen!)

🧮 Harry (Methodik & QA): * Dateien: Codebook / Metadaten der Stadt München.

Arbeitet sich in das Codebook der Stadt ein.

Legt mathematisch fest: Wie definieren wir einen „Ausreißer“ bei den Zu- und Umzügen? (z.B. Interquartilsabstand, Standardabweichung?).

Formuliert den theoretischen Ansatz für die 3 Fragestellungen (ohne Kausalität!).

🎨 Christian (Data Viz): * Dateien: customstyle.css + presentation.html (als Vorschau).

Öffnet RStudio und programmiert theme_munich() mit Dummy-Daten (z.B. iris oder mtcars).

Passt die customstyle.css an und legt Farben (barrierefrei), Schriftgrößen und Achsen-Stile nach Tufte fest. Wenn die echten Daten kommen, müssen wir sie nur noch in dieses fertige Theme einstecken.

🗣️ Dennis (Team Lead & Orga): * Dateien: presentation.qmd + Executive Summary - KoCo19 Kinder.pdf (als Vorlage).

Recherchiert den inhaltlichen Hintergrund: Zeitungsartikel/Reports zum Münchner Mietmarkt (Warum ziehen die Leute nicht mehr um?).

Baut die Grundstruktur in der presentation.qmd auf und nutzt das PDF-Beispiel, um das Layout für das Executive Summary vorzubereiten.

🚩 MEILENSTEIN 1: Der "Clean Dataframe" steht. Heinz übergibt die sauberen Daten an das Team.

## Phase 2: Analyse & Visualisierung (Tag 5–8)
**Ziel: Die echten Daten werden durch die vorbereiteten Schablonen gejagt.**

🧮 Harry & 🧹 Heinz: * Wenden Harrys Formeln auf Heinz' Daten an. Identifizieren die tatsächlichen Ausreißer und checken die Plausibilität (Können diese Zahlen stimmen?).

🎨 Christian & 🗣️ Dennis: * Dateien: presentation.qmd

Tauschen die Dummy-Daten gegen die echten Daten aus.

Erstellen die 3-4 Hauptgrafiken für die Präsentation (ohne Defaults, absolut clean).

Dennis beginnt, die Ergebnisse in die Story der .qmd-Präsentation (max. 15 Folien) einzubauen.

🚩 MEILENSTEIN 2: Alle Grafiken und statistischen Berechnungen sind final und fehlerfrei.

## Phase 3: Storytelling & Dokumentation (Tag 9–13)
**Ziel: Das Produkt wird abgabefertig gemacht.**

🎨 Christian: Schreibt den Text für das 1-seitige Executive Summary (orientiert sich strikt an der Executive Summary - KoCo19 Kinder.pdf Vorlage).

🗣️ Dennis: Baut die finalen Folien in Quarto zusammen und glättet die Übergänge.

🧮 Harry: Macht den "Bullshit-Check" auf den Folien (Haben wir irgendwo "signifikant" geschrieben, wo es nicht stimmt? Behaupten wir Kausalität?).

🧹 Heinz: Der ultimative Reproduzierbarkeits-Check. Environment leeren, auf "Run All" klicken und schauen, ob der Code von den 22 Rohdaten über die env_setup.R bis zur fertigen presentation.qmd durchläuft.

🚩 MEILENSTEIN 3: Slides und Summary sind fertig. Keine Änderungen mehr am Code.

## Phase 4: Proben (Tag 14–15)
**Ziel: Präsentationstechnik optimieren.**

Alle (Heinz, Harry, Christian, Dennis):

Generalprobe 1 (Fokus: Inhalt und Übergänge).

Generalprobe 2 (Fokus: Zeitlimit von 15–20 Minuten exakt treffen).

Frei sprechen ohne Notizen!
