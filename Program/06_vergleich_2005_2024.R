# Skript 06: Vorher-Nachher-Vergleich (2000 vs 2024) - Sicherer Plan B

source("env_setup.R")
library(sf)
library(ggplot2)
library(dplyr)

# 1. Geometrien (Die saubere Karte) ISOLIERT vorbereiten (mit "_temp" Endung)
karte_muenchen_temp <- st_read("Data/muenchen_bezirke.json", quiet = TRUE)

karte_sauber_temp <- karte_muenchen_temp %>%
  mutate(bezirk_nr = as.numeric(sb_nummer)) %>%
  group_by(bezirk_nr, sb_name) %>%
  summarise(geometry = st_union(geometry), .groups = "drop")

# 2. DEN RICHTIGEN DATENSATZ BAUEN: Geometrien + ALLE Jahre der Dichte
karte_alle_jahre_temp <- karte_sauber_temp %>%
  left_join(indikatoren_dichte, by = c("bezirk_nr" = "von_bezirk"))

# 3. DATEN FILTERN: Nur Startjahr (2000) und Endjahr (2024)
karte_vergleich_daten <- karte_alle_jahre_temp %>% 
  filter(jahr %in% c(2000, 2024))

# 4. PLOT ERSTELLEN
plot_vergleich <- ggplot(karte_vergleich_daten) +
  geom_sf(aes(fill = as.numeric(dichte)), color = "white", linewidth = 0.2) + # <-- LA CORRECCIÓN ESTÁ AQUÍ
  facet_wrap(~jahr) + 
  scale_fill_viridis_c(
    option = "magma", 
    direction = -1,
    limits = c(0, 16000),
    breaks = c(0, 4000, 8000, 12000, 16000), 
    guide = guide_colorbar(barwidth = 20)    
  ) +
  theme_void() +
  labs(
    title = "Verdichtung der Stadt München (2000 vs. 2024)",
    subtitle = "Vergleich der Bevölkerungsdichte (Einw./km²)",
    fill = "Dichte"
  ) +
  theme(
    legend.position = "bottom",
    strip.text = element_text(size = 14, face = "bold")
  )

print(plot_vergleich)

# 5. SICHER SPEICHERN
ggsave("Output/07_karte_vergleich_2000_2024.png", plot = plot_vergleich, 
       width = 12, height = 6, dpi = 300, bg = "white")

message("Der statische Vergleich 2000 vs 2024 liegt im Output-Ordner. Deine 04_Variablen blieben unangetastet!")


# 8. CHOROPLETH-KARTE: BEZIRKSTYPEN (Zentrum, Innenstadt-Rand, Peripherie)

# 1. Wir laden die fertige Karte (die bereits 'bezirk_typ' enthält)
karte_mit_daten_temp2 <- readRDS("Data/muenchen_karte_fertig.rds")

# 2. WICHTIG: Wir machen 'bezirk_typ' zu einem Faktor und sortieren ihn logisch.
# So taucht die Legende nicht alphabetisch auf, sondern von innen nach außen!
karte_mit_daten_temp2 <- karte_mit_daten_temp2 %>%
  mutate(bezirk_typ = factor(bezirk_typ, levels = c("Zentrum", "Innenstadt-Rand", "Peripherie")))

# 3. Den Plot erstellen
plot_bezirkstypen <- ggplot(karte_mit_daten_temp2) +
  geom_sf(aes(fill = bezirk_typ), color = "white", linewidth = 0.5) +
  
  scale_fill_viridis_d(option = "D", end = 0.8) +
  
  theme_void() +
  labs(
    title = "Strukturelle Gliederung der Münchner Stadtbezirke",
    subtitle = "Räumliche Kategorisierung für die Mobilitäts- und Dichteanalyse",
    fill = "Bezirkstyp"
  ) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 16)
  )

print(plot_bezirkstypen)

# 4. Speichern
ggsave("Output/08_karte_bezirkstypen.png", plot = plot_bezirkstypen, 
       width = 10, height = 6, dpi = 300, bg = "white")

message("Die Karte der Bezirkstypen wurde erfolgreich gespeichert!")
