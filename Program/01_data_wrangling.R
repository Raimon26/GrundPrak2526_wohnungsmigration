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
  select(1:28) %>%
  set_names(c("datei_pfad", saubere_namen)) %>%
  filter(von_bezirk %in% as.character(1:25)) %>%
  mutate(
    jahr = as.numeric(str_extract(datei_pfad, "(?<=jt)\\d{2}")) + 1999,
    across(von_bezirk:muenchen_gesamt, as.numeric)
  ) %>%
  mutate(muenchen_gesamt = rowSums(pick(starts_with("nach")))) %>% # 6. Spalten sinnvoll anordnen
  select(jahr, von_bezirk, starts_with("nach"), muenchen_gesamt)

# Das finale, saubere Meisterwerk betrachten!
glimpse(umzuege_clean) 


# 6. Datensätze von Dichte und Mobilität bereinigen

glimpse(bevoelkerungsdichte)
glimpse(mobilitaetsziffer)


# --- 6.1. Bevölkerungsdichte und Einwohnerzahl (Forschungsfrage 3) ---
dichte_clean <- bevoelkerungsdichte %>%
  mutate(
    jahr = Jahr,
    von_bezirk = as.numeric(str_extract(Raumbezug, "^\\d{2}")),
    dichte = Indikatorwert,
    einwohner = Basiswert.1 # Gesamtbevölkerung (Hauptwohnsitz)
  ) %>%
  filter(Ausprägung == "insgesamt", !is.na(von_bezirk), jahr >= 2005) %>%
  select(jahr, von_bezirk, dichte, einwohner)

# --- 6.2. Mobilität und Nationalität (Forschungsfragen 1 und 2) ---
mobilitaet_clean <- mobilitaetsziffer %>%
  mutate(
    jahr = Jahr,
    von_bezirk = as.numeric(str_extract(Raumbezug, "^\\d{2}"))
  ) %>%
  filter(!is.na(von_bezirk), jahr >= 2005) %>%
  rename(
    zuzuege_aussen = Basiswert.1,  # Zuzüge von außerhalb Münchens
    umzuege_innen = Basiswert.2,   # Umzüge innerhalb Münchens
    wegzuege_aussen = Basiswert.3, # Wegzüge nach außerhalb Münchens
    wegzuege_innen = Basiswert.4   # Wegzüge in einen anderen Stadtbezirk
  ) %>%
  select(jahr, von_bezirk, Ausprägung, zuzuege_aussen, umzuege_innen, wegzuege_aussen, wegzuege_innen) %>%
  # DIE MAGIE: Daten vom Long- ins Wide-Format transformieren (Pivot)
  pivot_wider(
    names_from = Ausprägung, 
    values_from = c(zuzuege_aussen, umzuege_innen, wegzuege_aussen, wegzuege_innen),
    names_sep = "_"
  )


# Umzugsmatrix (Von-Nach-Beziehungen der 25 Bezirke)
write_rds(umzuege_clean, "Data/umzuege_clean.rds")

# Bevölkerungsdichte und Einwohnerentwicklung (Für Forschungsfrage 3)
write_rds(dichte_clean, "Data/indikatoren_dichte.rds")

# Mobilität nach Nationalität (Für Forschungsfragen 1 und 2)
write_rds(mobilitaet_clean, "Data/indikatoren_mobilitaet.rds")

# probe <- umzuege_clean |> select(-jahr, -von_bezirk,-muenchen_gesamt) |> mutate(hola = rowSums(across(everything())))
