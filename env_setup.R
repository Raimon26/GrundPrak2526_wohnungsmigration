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
  "readr"       # RDS- und CSV-Import
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

# Erfolgsmeldung in der Konsole ausgeben
message("✅ Environment erfolgreich eingerichtet! Alle Pakete und sauberen Daten sind geladen. Viel Spaß beim Analysieren!")