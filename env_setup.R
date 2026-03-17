### env_setup.R ###
# WICHTIG: Führe dieses Skript immer als Erstes aus, bevor du an deinen Analysen arbeitest.
# Am besten direkt oben in deinem Skript mit: source("env_setup.R")
# Es installiert fehlende Pakete automatisch, lädt sie und importiert unsere sauberen Datensätze.

# 1. Benötigte Pakete definieren
# TEAM-INFO: Wenn du für deine Grafiken oder Modelle neue Pakete brauchst (z.B. "leaflet", "sf"), 
# füge sie einfach hier in diese Liste ein und mache einen Commit!
packages <- c(
  "tidyverse",  # Datenmanipulation und ggplot2
  "readxl",     # Excel-Import
  "readr",      # RDS- und CSV-Import
  "sf",          # NEU: Für Geodaten und Karten!
  "scales"      # Neu: Für Achsenskalierung bei Plots
)

# 2. Pakete automatisch installieren (falls nötig) und laden
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Dies lädt automatisch alle .rds Dateien aus dem Ordner "Data/" in unser Environment.

folder_path <- "Data/"
rds_files <- list.files(path = folder_path, pattern = "\\.rds$", full.names = TRUE, ignore.case = TRUE)

for (file in rds_files) {
  var_name <- gsub("\\.rds$", "", basename(file), ignore.case = TRUE)
  assign(var_name, read_rds(file))
}


# Dies lädt unser eigenes theme ins Environment 
# Bei Plots +theme_munich() um es zu benutzen
theme_munich <- function() {
  theme_minimal(base_size = 14) %+replace% 
    theme(
      # Alle unnötigen Hintergrundelemente entfernen
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_line(color = "#eeeeee", size = 0.5), 
      panel.grid.major.y = element_line(color = "#eeeeee", size = 0.5), # Sehr dezente Orientierungslinien
      
      # Achsen definieren (Tufte-Prinzip: nur zeigen, was nötig ist)
      axis.line.x = element_line(color = "#333333", size = 0.8),
      axis.ticks.x = element_line(color = "#333333"),
      axis.title = element_text(face = "bold", size = 12),
      
      # Überschriften-Design (München-Blau aus dem CSS)
      plot.title = element_text(face = "bold", size = 16, color = "#005a94", hjust = 0, margin = margin(b = 10)),
      plot.subtitle = element_text(size = 12, color = "#666666", hjust = 0, margin = margin(b = 20)),
      
      # Facet-Styling 
      strip.background = element_blank(),
      strip.text = element_text(face = "bold", size = 10, color = "#333333"),
      
      # Legende nach unten, falls vorhanden
      legend.position = "bottom",
      legend.title = element_text(face = "bold")
    )
}


# Erfolgsmeldung in der Konsole ausgeben
message("✅ Environment erfolgreich eingerichtet! Alle Pakete , das Theme und sauberen Daten sind geladen. Viel Spaß beim Analysieren!")