# Skript 04: Geodaten
# Ziel: Karte von München bereinigen und mit unseren Dichte-Daten verknüpfen
source("env_setup.R")
library(sf)

# Karte laden
karte_muenchen <- st_read("Data/muenchen_bezirke.json")

karte_sauber <- karte_muenchen %>%
  mutate(bezirk_nr = as.numeric(sb_nummer)) %>%
  # Fasse geteilte Polygone (die 27 Reihen) zu 25 Bezirken zusammen
  group_by(bezirk_nr, sb_name) %>%
  summarise(geometry = st_union(geometry), .groups = "drop")

# Daten für die Karte filtern (2024) 
dichte_2024 <- indikatoren_dichte %>%
  filter(jahr == 2024)

karte_mit_daten <- karte_sauber %>%
  left_join(dichte_2024, by = c("bezirk_nr" = "von_bezirk"))

saveRDS(karte_mit_daten, "Data/muenchen_karte_fertig.rds")

message("Geodaten erfolgreich bereinigt (25 Bezirke) und gespeichert")

