# Notwendige Pakete laden
library(tidyverse)
library(readxl)
library(readr)

# 1. Liste mit den Dateipfaden aller Excel-Dateien im Ordner erstellen
excel_pfade <- list.files(path = "Data/Exceldateien Jahrbuch", 
                          pattern = "\\.xlsx?$", # Sucht nach .xls und .xlsx
                          full.names = TRUE)

# 2. Saubere Spaltennamen definieren
saubere_namen <- c("von_bezirk", paste0("nach_bezirk_", 1:25), "muenchen_gesamt")

# 3. Alle Dateien im "Staubsauger"-Modus einlesen (col_names = FALSE)
umzuege_gesamt <- excel_pfade %>%
  set_names() %>% 
  map_dfr(~ read_excel(.x, 
                       skip = 4,                  
                       col_names = FALSE,         # R vergibt automatisch ...1, ...2
                       col_types = "text"),       
          .id = "datei_pfad")

# Ergebnis der Rohdaten überprüfen
glimpse(umzuege_gesamt)

# 4. Indikatoren einlesen
bevoelkerungsdichte <- read_csv("Data/Indikate/indikat2510_bevoelkerung_bevoelkerungsdichte_28_10_25.csv")
mobilitaetsziffer   <- read_csv("Data/Indikate/indikat2510_bevoelkerung_mobilitaetsziffer_28_10_25.csv")

# 5. Datenbereinigung: Unnötige Spalten entfernen, filtern und Jahr extrahieren
umzuege_clean <- umzuege_gesamt %>%
  # Nur die ersten 28 Spalten behalten (die fehlerhafte 29. Spalte wird verworfen)
  select(1:28) %>%
  
  # Die sauberen deutschen Namen vergeben (inkl. Dateipfad)
  set_names(c("datei_pfad", saubere_namen)) %>%
  
  # Nur Zeilen behalten, in denen 'von_bezirk' eine Zahl von 1 bis 25 ist (löscht leere Zeilen und Summen)
  filter(von_bezirk %in% as.character(1:25)) %>%
  
  # Das Jahr aus dem Dateipfad extrahieren und alle Werte in Zahlen umwandeln
  mutate(
    # Extrahiert die zwei Ziffern nach 'jt' (z.B. '06' aus 'jt06...'), addiert 1999 -> Jahr 2005
    jahr = as.numeric(str_extract(datei_pfad, "(?<=jt)\\d{2}")) + 1999,
    
    # Wandelt alle Spalten von 'von_bezirk' bis 'muenchen_gesamt' in numerische Werte um
    across(von_bezirk:muenchen_gesamt, as.numeric)
  ) %>%
  
  # Spalten sinnvoll anordnen (Jahr zuerst, dann Herkunft, dann Ziele, dann Gesamt)
  select(jahr, von_bezirk, starts_with("nach"), muenchen_gesamt)

# Das finale, saubere Meisterwerk betrachten!
glimpse(umzuege_clean) 

# Das saubere Dataframe für den Rest des Teams speichern
write_rds(umzuege_clean, "Data/umzuege_clean.rds")
