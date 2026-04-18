# Skript 06: Vorher-Nachher-Vergleich (2000 vs 2024)

source("env_setup.R")
library(sf)
library(ggplot2)
library(dplyr)

# 1. Karte optimieren
karte_muenchen_temp <- st_read("Data/muenchen_bezirke.json", quiet = TRUE)

karte_sauber_temp <- karte_muenchen_temp %>%
  mutate(bezirk_nr = as.numeric(sb_nummer)) %>%
  group_by(bezirk_nr, sb_name) %>%
  summarise(geometry = st_union(geometry), .groups = "drop")

karte_alle_jahre_temp <- karte_sauber_temp %>%
  left_join(indikatoren_dichte, by = c("bezirk_nr" = "von_bezirk"))

karte_vergleich_daten <- karte_alle_jahre_temp %>% 
  filter(jahr %in% c(2000, 2024))

# Berechnung der Differenz 
differenz_daten <- indikatoren_dichte %>%
  filter(jahr %in% c(2000, 2024)) %>%
  select(von_bezirk, jahr, dichte) %>%
  tidyr::pivot_wider(names_from = jahr, names_prefix = "d", values_from = dichte) %>%
  mutate(
    diff_wert = d2024 - d2000,
    label_text = paste0(ifelse(diff_wert > 0, "+", ""), round(diff_wert, 0))
  )

# 4. Plot
plot_vergleich <- ggplot(karte_vergleich_daten) +
  geom_sf(aes(fill = as.numeric(dichte)), color = "white", linewidth = 0.2) +
  geom_sf_text(
    data = karte_vergleich_daten %>% 
      dplyr::filter(jahr == 2024) %>% 
      dplyr::left_join(differenz_daten, by = c("bezirk_nr" = "von_bezirk")), 
    aes(label = label_text), 
    size = 2.0,
    color = "cyan",
    fontface = "bold",
    check_overlap = FALSE
  ) +
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
    title = "Vergleich der Bevölkerungsdichte (Einw./km²)",
    fill = "Dichte"
  ) +
  theme(
    plot.title = element_text(
      size = 16, 
      face = "bold", 
      hjust = 0.5,
      margin = margin(b = 10)
    ),
    legend.position = "bottom",
    strip.text = element_text(size = 14, face = "bold")
  )

print(plot_vergleich)

ggsave("Output/07_karte_vergleich_2000_2024.png", plot = plot_vergleich, 
       width = 12, height = 6, dpi = 300, bg = "white")

message("Der statische Vergleich 2000 vs 2024 liegt im Output-Ordner. Deine 04_Variablen blieben unangetastet!")


# 2. CHOROPLETH-KARTE: Bezirkstypen (Zentrum, Innenstadt-Rand, Peripherie)

karte_mit_daten_temp2 <- readRDS("Data/muenchen_karte_fertig.rds")

karte_mit_daten_temp2 <- karte_mit_daten_temp2 %>%
  mutate(bezirk_typ = factor(bezirk_typ, levels = c("Zentrum", "Innenstadt-Rand", "Peripherie")))

# Plot
plot_bezirkstypen <- ggplot(karte_mit_daten_temp2) +
  geom_sf(aes(fill = bezirk_typ), color = "white", linewidth = 0.5) +
  
  scale_fill_viridis_d(option = "D", end = 0.8) +
  
  theme_void() +
  labs(
    title = "Räumliche Kategorisierung für die Mobilitäts- und Dichteanalyse",
    fill = "Bezirkstyp"
  ) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

print(plot_bezirkstypen)

ggsave("Output/08_karte_bezirkstypen.png", plot = plot_bezirkstypen, 
       width = 10, height = 6, dpi = 300, bg = "white")

message("Die Karte der Bezirkstypen wurde gespeichert")
