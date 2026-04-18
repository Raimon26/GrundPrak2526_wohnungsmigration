### env_setup.R ###
# WICHTIG: Führe dieses Skript immer als Erstes aus

# 1. Benötigte Pakete 

packages <- c(
  "tidyverse",  
  "readxl",
  "readr",
  "sf",        
  "dplyr",
  "tidyr",
  "scales",
  "ggalluvial"
)

# 2. Pakete automatisch installieren
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Dies lädt automatisch alle .rds Dateien aus dem Ordner "Data/" in Environment.

folder_path <- "Data/"
rds_files <- list.files(path = folder_path, pattern = "\\.rds$", full.names = TRUE, ignore.case = TRUE)

for (file in rds_files) {
  var_name <- gsub("\\.rds$", "", basename(file), ignore.case = TRUE)
  assign(var_name, read_rds(file))
}

 



# Erfolgsmeldung in der Konsole ausgeben
message("Environment erfolgreich eingerichtet! Alle Pakete und sauberen Daten sind geladen.")