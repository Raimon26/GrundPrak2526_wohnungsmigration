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


# NEU
# ==============================================================================
# 6. DATEN BEREINIGEN UND ZUSAMMENFÜHREN (2000-2024)
# ==============================================================================

# --- 6.1. Mobilität und Nationalität (Jetzt ab dem Jahr 2000!) ---

# Wir laden die Rohdaten und retten die Einwohnerzahl (Basiswert.5)
mobilitaet_roh <- mobilitaetsziffer %>%
  mutate(
    jahr = Jahr,
    von_bezirk = as.numeric(str_extract(Raumbezug, "^\\d{2}"))
  ) %>%
  # ÄNDERUNG 1: Wir öffnen das Zeitfenster bis 2000
  filter(!is.na(von_bezirk), jahr >= 2000) %>%
  rename(
    zuzuege_aussen = Basiswert.1,  
    umzuege_innen = Basiswert.2,   
    wegzuege_aussen = Basiswert.3, 
    wegzuege_innen = Basiswert.4,
    einwohner_mob = Basiswert.5    # ÄNDERUNG 2: Wir retten die Bevölkerung!
  ) %>%
  select(jahr, von_bezirk, Ausprägung, zuzuege_aussen, umzuege_innen, wegzuege_aussen, wegzuege_innen, einwohner_mob)

# Einwohner für die verlorenen Jahre 2000-2004 isolieren (Für den Dichte-Trick)
pop_2000_2004 <- mobilitaet_roh %>%
  filter(Ausprägung == "insgesamt", jahr >= 2000, jahr <= 2004) %>%
  select(jahr, von_bezirk, einwohner = einwohner_mob)

# Den originalen mobilitaet_clean für deinen Pivot vorbereiten 
# (Wir werfen einwohner_mob hier weg, damit dein restlicher Code 1:1 funktioniert)
mobilitaet_clean <- mobilitaet_roh %>%
  select(-einwohner_mob)

# DIE MAGIE: Daten vom Long- ins Wide-Format transformieren (Pivot)
indikatoren_mobilitaet <- mobilitaet_clean %>%
  pivot_wider(
    names_from = Ausprägung, 
    values_from = c(zuzuege_aussen, umzuege_innen, wegzuege_aussen, wegzuege_innen)
  )

# --- 6.2. Bevölkerungsdichte (Der Flächen-Trick für 2000-2004) ---

# 1. Die sicheren Dichte-Daten ab 2005 (wie in deinem originalen Code)
dichte_ab_2005 <- bevoelkerungsdichte %>%
  mutate(
    jahr = Jahr,
    von_bezirk = as.numeric(str_extract(Raumbezug, "^\\d{2}")),
    dichte = Indikatorwert,
    einwohner = Basiswert.1
  ) %>%
  filter(Ausprägung == "insgesamt", !is.na(von_bezirk), jahr >= 2005) %>%
  select(jahr, von_bezirk, dichte, einwohner)

# 2. Konstante Fläche berechnen (Fläche = Einwohner / Dichte, basierend auf dem Jahr 2005)
flaeche_konstant <- dichte_ab_2005 %>%
  filter(jahr == 2005) %>%
  mutate(flaeche = einwohner / dichte) %>%
  select(von_bezirk, flaeche)

# 3. Dichte für 2000-2004 berechnen (Dichte = Einwohner aus Mobilität / Konstante Fläche)
dichte_2000_2004 <- pop_2000_2004 %>%
  left_join(flaeche_konstant, by = "von_bezirk") %>%
  mutate(dichte = einwohner / flaeche) %>%
  select(jahr, von_bezirk, dichte, einwohner)

# 4. Die rekonstruierten Jahre (2000-2004) mit den ab 2005er Daten verschmelzen
indikatoren_dichte <- bind_rows(dichte_2000_2004, dichte_ab_2005) %>%
  arrange(von_bezirk, jahr)


# Umzugsmatrix (Von-Nach-Beziehungen der 25 Bezirke)
write_rds(umzuege_clean, "Data/umzuege_clean.rds")

# Bevölkerungsdichte und Einwohnerentwicklung (Für Forschungsfrage 3)
write_rds(indikatoren_dichte, "Data/indikatoren_dichte.rds")

# Mobilität nach Nationalität (Für Forschungsfragen 1 und 2)
write_rds(indikatoren_mobilitaet, "Data/indikatoren_mobilitaet.rds")

# probe <- umzuege_clean |> select(-jahr, -von_bezirk,-muenchen_gesamt) |> mutate(hola = rowSums(across(everything())))
