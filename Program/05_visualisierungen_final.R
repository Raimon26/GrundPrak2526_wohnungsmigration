# --- 05_visualisierungen_final.R ---
source("env_setup.R")
library(dplyr)
library(tidyr)
library(tidyverse)
library(ggplot2)
library(scales)
library(sf)


# 1 & 2. ZEITREIHEN: ZU- UND UMZÜGE (Facet nach Nationalität)
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
  scale_color_viridis_d(option = "D", end = 0.8) +
  
  # Anfangs- und Endjahr, sonst 5er Jahres-Schritte auf der Skala 
  scale_x_continuous(breaks = c(seq(2005, 2024, by = 5), 2024), limits = c(2005, 2024)) +
  
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
  scale_color_viridis_d(option = "D", end = 0.8) +
  
  # Anfangs- und Endjahr, sonst 5er Jahres-Schritte auf der Skala 
  scale_x_continuous(breaks = c(seq(2005, 2024, by = 5), 2024), limits = c(2005, 2024)) +
  
  labs(
    title = "Entwicklung der Umzüge innerhalb München (2005-2024)",
    subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Anzahl Personen",
    color = "Bezirkstyp"
  ) +
  theme(legend.position = "bottom")

print(plot_umzuege)

# --- HIGHLIGHT-VERSION MIT DIREKTEN LABELS (Der "Direct Labeling" Trick) ---

plot_zuzuege_highlight <- plot_zuzuege +
  # Bezirk 12 (Schwabing-Freimann / Bayernkaserne) in Dunkelrot
  geom_line(data = mobilitaet_long_plot %>% 
              filter(bewegungsart == "zuzuege_aussen", von_bezirk == 12), 
            aes(group = von_bezirk), color = "darkred", linewidth = 0.5) +
  
  # Bezirk 19 (Obersendling / Alte EAE) in Schwarz
  geom_line(data = mobilitaet_long_plot %>% 
              filter(bewegungsart == "zuzuege_aussen", von_bezirk == 19), 
            aes(group = von_bezirk), color = "black", linewidth = 0.5) +
  
  geom_text(data = data.frame(jahr = 2010, anzahl_personen = 13000, nationalitaet = "Nichtdeutsch"),
            label = "Obersendling", color = "black", fontface = "bold", vjust = 7, 
            hjust = 0.75, size = 3) +
  
  geom_text(data = data.frame(jahr = 2016, anzahl_personen = 12500, nationalitaet = "Nichtdeutsch"),
            label = "Schwabing-\nFreimann", color = "darkred", fontface = "bold", vjust = 1.75, 
            hjust = 0.2, size = 3) +
  labs(
    title = "Zuzüge nach München (2005-2024)",
    subtitle = "Grau: Einzelne Bezirke | Farbige Linien: Durchschnitt | Hervorgehoben: Erstaufnahmeeinrichtung (EAE)"
  )

print(plot_zuzuege_highlight)

# --- HIGHLIGHT-VERSION FÜR UMZÜGE (Der "Direct Labeling" Trick) ---

plot_umzuege_highlight <- plot_umzuege +
  # Bezirk 12 (Schwabing-Freimann / Bayernkaserne) in Dunkelrot
  geom_line(data = mobilitaet_long_plot %>% 
              filter(bewegungsart == "umzuege_innen", von_bezirk == 12), 
            aes(group = von_bezirk), color = "darkred", linewidth = 0.5) +
  
  # Bezirk 19 (Obersendling / Alte EAE) in Schwarz
  geom_line(data = mobilitaet_long_plot %>% 
              filter(bewegungsart == "umzuege_innen", von_bezirk == 19), 
            aes(group = von_bezirk), color = "black", linewidth = 0.5) +
  
  # Achtung: Y-Koordinaten an die Umzüge-Skala (max ~8000) angepasst!
  geom_text(data = data.frame(jahr = 2011, anzahl_personen = 5000, nationalitaet = "Nichtdeutsch"),
            label = "Obersendling", color = "black", fontface = "bold", vjust = 0, 
            hjust = 0, size = 3) +
  
  geom_text(data = data.frame(jahr = 2016, anzahl_personen = 7500, nationalitaet = "Nichtdeutsch"),
            label = "Schwabing-\nFreimann", color = "darkred", fontface = "bold", vjust = 0,
            hjust = 0, size = 3) +
  labs(
    title = "Umzüge innerhalb Münchens (2005-2024)",
    subtitle = "Grau: Einzelne Bezirke | Farbige Linien: Durchschnitt | Hervorgehoben: Erstaufnahmeeinrichtung (EAE)"
  )

print(plot_umzuege_highlight)


# --- FREE_Y VERSIONEN ERSTELLEN (Der "Zoom-In" Effekt) ---
# Wir nehmen den fertigen Plot und überschreiben nur den Facet-Wrap!

plot_zuzuege_free <- plot_zuzuege + 
  facet_wrap(~nationalitaet, scales = "free_y") +
  labs(subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt (Zoom / Free Y-Achse)") 
 
plot_umzuege_free <- plot_umzuege + 
  facet_wrap(~nationalitaet, scales = "free_y") +
  labs(subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt (Zoom / Free Y-Achse)") 

  
# 3. BOXPLOT: Verteilung der Zuzüge (Zentrum vs. Peripherie)
plot_zuzuege_typ <- ggplot(indikatoren_mobilitaet, aes(x = bezirk_typ, y = zuzuege_aussen_insgesamt, fill = bezirk_typ)) +
  geom_boxplot(alpha = 0.8, outlier.color = "red", outlier.size = 2) +
  theme_minimal() +
  scale_fill_viridis_d(option = "D") + # Paleta accesible (Viridis)
  labs(
    title = "Verteilung der Zuzüge nach Bezirkstyp",
    subtitle = "Zentrum, Innenstadtrand und Peripherie im Vergleich",
    x = "Bezirkstyp",
    y = "Anzahl der Zuzüge (von außerhalb)"
  ) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold")
  )

print(plot_zuzuege_typ)

# Berechnung der Ausreißer (IQR-Methode) für den Bericht
Q1 <- quantile(indikatoren_mobilitaet$zuzuege_aussen_insgesamt, 0.25, na.rm = TRUE)
Q3 <- quantile(indikatoren_mobilitaet$zuzuege_aussen_insgesamt, 0.75, na.rm = TRUE)
IQR_value <- Q3 - Q1
threshold <- Q3 + 1.5 * IQR_value

ausreisser_tabelle <- indikatoren_mobilitaet %>%
  filter(zuzuege_aussen_insgesamt > threshold) %>%
  select(jahr, von_bezirk, bezirk_typ, zuzuege_aussen_insgesamt) %>%
  arrange(desc(zuzuege_aussen_insgesamt))

# Print der Tabelle zur Kontrolle
print(ausreisser_tabelle)


# 4. ZEITREIHEN: WEGZÜGE (Facet nach Bewegungsart)

indikatoren_mobilitaet_long <- indikatoren_mobilitaet %>%
  pivot_longer(
    cols = c(wegzuege_innen_insgesamt, wegzuege_aussen_insgesamt),
    names_to = "bewegungsart",
    values_to = "anzahl_personen"
  )

plot_wegzuege <- ggplot(
  indikatoren_mobilitaet_long,
  aes(x = jahr, y = anzahl_personen)
) +
  
  geom_line(aes(group = von_bezirk), color = "grey80", alpha = 0.5, linewidth = 0.5) +
  
  stat_summary(aes(color = bezirk_typ), fun = mean, geom = "line", linewidth = 1.2) +
  
  facet_wrap(
    ~bewegungsart,
    labeller = labeller(
      bewegungsart = c(
        wegzuege_innen_insgesamt = "Innerhalb München",
        wegzuege_aussen_insgesamt = "Außerhalb München"
      )
    )
  ) +
  
  theme_minimal() +
  scale_color_viridis_d(option = "D", end = 0.8) +
  
  # Anfangs- und Endjahr, sonst 5er Jahres-Schritte auf der Skala 
  scale_x_continuous(breaks = c(seq(2005, 2024, by = 5), 2024), limits = c(2005, 2024)) +
  
  labs(
    title = "Entwicklung der Wegzüge aus den Münchner Stadtbezirken (2005–2024)",
    subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Anzahl Personen",
    color = "Bezirkstyp"
  ) +
  
  theme(legend.position = "bottom")

print(plot_wegzuege)



# NEU!!
# 5. Relative BEVÖLKERUNGSENTWICKLUNG über die ZEIT (Chris)

# Index berechnen: Jeder Bezirk startet bei 100 im Jahr 2005
indikatoren_index <- indikatoren_dichte %>%
  group_by(von_bezirk) %>%
  mutate(
    einwohner_index = (einwohner / einwohner[jahr == min(jahr)]) * 100,
    dichte_index = (dichte / dichte[jahr == min(jahr)]) * 100
  ) %>%
  ungroup()

# Durchschnittswerte der Indizes pro Bezirkstyp berechnen
typ_summary_index <- indikatoren_index %>%
  group_by(jahr, bezirk_typ) %>%
  summarise(
    BEV_INDEX_AVG = mean(einwohner_index, na.rm = TRUE),
    DICHTE_INDEX_AVG = mean(dichte_index, na.rm = TRUE),
    .groups = "drop"
  )

plot_entwicklung_index <- ggplot() +
  # Hintergrund: Alle Bezirke als Index-Linien
  geom_line(data = indikatoren_index, 
            aes(x = jahr, y = einwohner_index, group = von_bezirk), 
            color = "grey85", linewidth = 0.5, alpha = 0.5) +
  
  # Vordergrund: Durchschnittlicher Index nach Typ
  geom_line(data = typ_summary_index, 
            aes(x = jahr, y = BEV_INDEX_AVG, color = bezirk_typ), 
            linewidth = 1.2) +
  
  # Anfangs- und Endjahr, sonst 5er Jahres-Schritte auf der Skala 
  scale_x_continuous(breaks = c(seq(2005, 2024, by = 5), 2024), limits = c(2005, 2024)) +
  
  # Y-Achse: Start bei 100 (Basisjahr)
  scale_y_continuous(labels = label_number(suffix =  "%")) +
  
  theme_minimal() +
  scale_color_viridis_d(option = "D", end = 0.8) + 
  labs(
    title = "Relatives Bevölkerungswachstum München (2005-2024) (Basis 2005 = 100%)",
    subtitle =  "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Wachstum in %",
    color = "Bezirkstyp"
  ) +
  theme(legend.position = "bottom")

print(plot_entwicklung_index)


# NEU!! 
# 6. BEVÖLKERUNGSDICHTE über die Zeit(Chris)
# 
# Daten aggregieren für die Durchschnittslinien der Dichte
typ_dichte_summary <- indikatoren_dichte %>%
  group_by(jahr, bezirk_typ) %>%
  summarise(DICHTE_AVG = mean(dichte, na.rm = TRUE), .groups = "drop")

plot_dichte <- ggplot() +
  # Hintergrund: Alle Bezirke
  geom_line(data = indikatoren_dichte, 
            aes(x = jahr, y = dichte, group = von_bezirk, 
            color = bezirk_typ), linewidth = 0.5, alpha = 0.2) +
  # Vordergrund: Durchschnittliche Dichte pro Typ
  geom_line(data = typ_dichte_summary, 
            aes(x = jahr, y = DICHTE_AVG, color = bezirk_typ), 
            linewidth = 1.2) +
  theme_minimal() +
  
  # Anfangs- und Endjahr, sonst 5er Jahres-Schritte auf der Skala 
  scale_x_continuous(breaks = c(seq(2005, 2024, by = 5), 2024), limits = c(2005, 2024)) +
  
  scale_color_viridis_d(option = "D", end = 0.8) +
  labs(
    title = "Entwicklung der Siedlungsdichte in München (2005-2024)",
    subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Einwohner / km²",
    color = "Bezirkstyp"
  ) +
  theme(legend.position = "bottom")

print(plot_dichte)

# 7. CHOROPLETH-KARTE (Dichte 2024)
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




# --- BILDER EXPORTIEREN ---

# ==============================================================================
# 8. PLOTS SPEICHERN (In der von Harry gewünschten Reihenfolge)
# ==============================================================================

dir.create("Output", showWarnings = FALSE)

# 1. Zuzüge
ggsave("Output/01a_zeitreihe_zuzuege.png", plot = plot_zuzuege, width = 12, height = 6, dpi = 300, bg = "white")
ggsave("Output/01b_zeitreihe_zuzuege_free_y.png", plot = plot_zuzuege_free, width = 12, height = 6, dpi = 300, bg = "white")

# Highlight-Plot exportieren
ggsave("Output/01c_zeitreihe_zuzuege_HIGHLIGHT.png", plot = plot_zuzuege_highlight, 
       width = 12, height = 6, dpi = 300, bg = "white")
ggsave("Output/02c_zeitreihe_umzuege_HIGHLIGHT.png", plot = plot_umzuege_highlight, 
       width = 12, height = 6, dpi = 300, bg = "white")

# 2. Umzüge
ggsave("Output/02a_zeitreihe_umzuege.png", plot = plot_umzuege, width = 12, height = 6, dpi = 300, bg = "white")
ggsave("Output/02b_zeitreihe_umzuege_free_y.png", plot = plot_umzuege_free, width = 12, height = 6, dpi = 300, bg = "white")

# 3. Boxplots
ggsave("Output/03_boxplot_zuzuege_typ.png", plot = plot_zuzuege_typ, width = 8, height = 5, dpi = 300, bg = "white")

# 4. Wegzüge
ggsave("Output/04_zeitreihe_wegzuege.png", plot = plot_wegzuege, width = 12, height = 6, dpi = 300, bg = "white")

# 5. Relative Bevölkerungsentwicklung über die Zeit (Chris - Vorübergehend deaktiviert)
ggsave("Output/05_bevoelkerungsentwicklung.png", plot = plot_entwicklung_index, width = 10, height = 6, dpi = 300, bg = "white")

# 6. Bevölkerungsdichte (Chris - Vorübergehend deaktiviert)
ggsave("Output/06_bevoelkerungsdichte.png", plot = plot_dichte, width = 10, height = 6, dpi = 300, bg = "white")

# 7. Choropleth Map
ggsave("Output/07_karte_dichte_2024.png", plot = plot_karte, width = 10, height = 6, dpi = 300, bg = "white")

message("Alle bereiten Plots wurden im Ordner 'Output' gespeichert.")

