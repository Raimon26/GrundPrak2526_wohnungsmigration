# --- 05_visualisierungen_final.R ---
source("env_setup.R")
library(ggplot2)
library(sf)

# 1. CHOROPLETH-KARTE (Dichte 2024)
karte_mit_daten <- readRDS("Data/muenchen_karte_fertig.rds")

plot_karte <- ggplot(karte_mit_daten) +
  geom_sf(aes(fill = dichte), color = "white", linewidth = 0.3) +
  # Eine schöne Farbpalette wählen (viridis ist perfekt für Dichte)
  scale_fill_viridis_c(option = "magma", direction = -1) + 
  theme_void() +
  labs(
    title = "Bevölkerungsdichte in München (2024)",
    subtitle = "Je dunkler, desto dichter besiedelt",
    fill = "Einw. pro km²"
  )

print(plot_karte)

# 2. ZEITREIHEN: ZU- UND UMZÜGE (Facet nach Nationalität)
# Wir nutzen unser erstelltes Long-Format!
mobilitaet_long_plot <- readRDS("Data/indikatoren_mobilitaet_long_plot.rds")

plot_zuzuege <- ggplot(mobilitaet_long_plot %>% filter(bewegungsart == "zuzuege_aussen"), 
                       aes(x = jahr, y = anzahl_personen)) +
  # Die 25 Bezirke als graue, leicht transparente Linien im Hintergrund
  geom_line(aes(group = von_bezirk), color = "grey80", alpha = 0.5, linewidth = 0.5) +
  # Die Durchschnittswerte pro Bezirkstyp als dicke farbige Linien
  stat_summary(aes(color = bezirk_typ), fun = mean, geom = "line", linewidth = 1.2) +
  facet_wrap(~nationalitaet) + # scales = "free_y" (zum Einzoomen) setzen!
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Entwicklung der Zuzüge nach München (2005-2024)",
    subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Anzahl Personen",
    color = "Bezirkstyp"
  ) +
  theme(legend.position = "bottom")

print(plot_zuzuege)

plot_umzuege <- ggplot(mobilitaet_long_plot %>% filter(bewegungsart == "umzuege_innen"), 
                       aes(x = jahr, y = anzahl_personen)) +
  # Die 25 Bezirke als graue, leicht transparente Linien im Hintergrund
  geom_line(aes(group = von_bezirk), color = "grey80", alpha = 0.5, linewidth = 0.5) +
  # Die Durchschnittswerte pro Bezirkstyp als dicke farbige Linien
  stat_summary(aes(color = bezirk_typ), fun = mean, geom = "line", linewidth = 1.2) +
  facet_wrap(~nationalitaet) + # scales = "free_y" (zum Einzoomen) setzen!
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Entwicklung der Umzüge innerhalb München (2005-2024)",
    subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Anzahl Personen",
    color = "Bezirkstyp"
  ) +
  theme(legend.position = "bottom")

print(plot_umzuege)

# --- FREE_Y VERSIONEN ERSTELLEN (Der "Zoom-In" Effekt) ---
# Wir nehmen den fertigen Plot und überschreiben nur den Facet-Wrap!

plot_zuzuege_free <- plot_zuzuege + 
  facet_wrap(~nationalitaet, scales = "free_y") +
  labs(subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt (Zoom / Free Y-Achse)")

plot_umzuege_free <- plot_umzuege + 
  facet_wrap(~nationalitaet, scales = "free_y") +
  labs(subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt (Zoom / Free Y-Achse)")

# (Für die Wegzüge / Plot 2 kannst du, Harry, exakt denselben Code-Block kopieren 
# und einfach den Filter auf bewegungsart == "wegzuege_aussen" ändern!)


# --- BILDER EXPORTIEREN ---

dir.create("Output", showWarnings = FALSE)

# 1. Choropleth-Karte
ggsave("Output/01_karte_dichte_2024.png", plot = plot_karte, 
       width = 10, height = 6, dpi = 300, bg = "white")

# 2. Zeitreihen (Feste Skala für den Vergleich der Magnitude)
ggsave("Output/02_zeitreihe_zuzuege.png", plot = plot_zuzuege, 
       width = 12, height = 6, dpi = 300, bg = "white")
ggsave("Output/03_zeitreihe_umzuege.png", plot = plot_umzuege, 
       width = 12, height = 6, dpi = 300, bg = "white")

# 3. Zeitreihen ("Free Y" für den "Zoom" auf interne Trends)
ggsave("Output/04_zeitreihe_zuzuege_free_y.png", plot = plot_zuzuege_free, 
       width = 12, height = 6, dpi = 300, bg = "white")
ggsave("Output/05_zeitreihe_umzuege_free_y.png", plot = plot_umzuege_free, 
       width = 12, height = 6, dpi = 300, bg = "white")

message("📸 BÄM! Alle 5 Plots (inklusive Free-Y Zoom) wurden im Ordner 'Output' gespeichert.")
