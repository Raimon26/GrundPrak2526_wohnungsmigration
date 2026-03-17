# eigenes theme

theme_lockin <- function() {
  theme_minimal(base_size = 14) %+replace% 
    theme(
      # Alle unnötigen Hintergrundelemente entfernen
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_line(color = "#eeeeee", size = 0.5), 
      panel.grid.major.y = element_line(color = "#eeeeee", size = 0.5), # Sehr dezente Orientierungslinien
      
      # Achsen definieren (Tufte-Prinzip: nur zeigen, was nötig ist)
      axis.line.x = element_line(color = "#333333", size = 0.8),
      axis.ticks.x = element_line(color = "#333333"),
      axis.title = element_text(face = "bold", size = 12),
      
      # Überschriften-Design (München-Blau aus dem CSS)
      plot.title = element_text(face = "bold", size = 16, color = "#005a94", hjust = 0, margin = margin(b = 10)),
      plot.subtitle = element_text(size = 12, color = "#666666", hjust = 0, margin = margin(b = 20)),
      
      # Facet-Styling 
      strip.background = element_blank(),
      strip.text = element_text(face = "bold", size = 10, color = "#333333"),
      
      # Legende nach unten, falls vorhanden
      legend.position = "bottom",
      legend.title = element_text(face = "bold")
    )
}


# Plot zur Bevölkerungsentwicklung
# Frage 3

# --- Arbeitsumgebung laden ---
source("env_setup.R")
library(ggplot2)
library(tidyverse)
library(scales)

data_bev<- indikatoren_dichte

einwohner_entwicklung <- ggplot(data_bev, aes(x = jahr, y = einwohner, group = von_bezirk, colour = bezirk_typ)) +
  geom_line() +
  labs
  theme_lockin()
   #theme_bw()

print(einwohner_entwicklung)


dichte_entwicklung <- ggplot(data_bev, aes(x = jahr, y = dichte ,group = von_bezirk, colour = bezirk_typ)) +
  geom_line() +
  theme_bw()

print(dichte_entwicklung)


  
# Plot: Alle Bezirke als Linien
plot_bev_entwicklung <- ggplot(data_bev, aes(x = jahr, y = einwohner, group = von_bezirk)) +
  # Alle Bezirke als dünne, hellgraue Linien (die 'Cloud')
  geom_line(color = "grey80", size = 0.5, alpha = 0.6) +
  # Option: Den städtischen Durchschnitt oder ein Highlight hinzufügen
  # Hier berechnen wir den Mittelwert pro Jahr für eine markante Linie
  stat_summary(aes(group = 1), fun = mean, geom = "line", 
               color = "#005a94", size = 1.5) +
  # Punkte nur für die markante Durchschnittslinie
  stat_summary(aes(group = 1), fun = mean, geom = "point", 
               color = "#005a94", size = 3) +
  # Die Durchschnittswerte pro Bezirkstyp als dicke farbige Linien
  stat_summary(aes(color = bezirk_typ), fun = mean, geom = "line", linewidth = 1.2) +
  #theme
  theme_lockin() +
  labs(
    title = "Bevölkerungsentwicklung nach Stadtbezirken",
    subtitle = "Graue Linien: Einzelne Bezirke | Blaue Linie: Durchschnitt München",
    x = "Jahr",
    y = "Einwohner (absolut)"
  )
print(plot_bev_entwicklung)











# Plot zur Bevölkerungsentwicklung
# Frage 3

# --- Arbeitsumgebung laden ---
source("env_setup.R")
library(ggplot2)
library(tidyverse)
library(scales)


#1. Daten laden
data_bev<- indikatoren_dichte

# 2. Durchschnittswerte pro Jahr und Bezirkstyp berechnen
typ_summary <- data_bev %>%
  group_by(jahr, bezirk_typ) %>%
  summarise(BEV_AVG = mean(einwohner, na.rm = TRUE), .groups = "drop")

# 3. Der kombinierte Plot
 bev_entw_plot <- ggplot() +
  # Hintergrund: Alle 25 Bezirke als dezente graue Linien
  geom_line(data = data_bev, 
            aes(x = jahr, y = einwohner, group = von_bezirk), 
            color = "grey85", size = 0.5, alpha = 0.5) +
  
  # Vordergrund: Die 3 Durchschnittslinien für die Bezirkstypen
  geom_line(data = typ_summary, 
            aes(x = jahr, y = BEV_AVG, color = bezirk_typ), 
            size = 1.5) +
  
  # Achsen-Formatierung (Tausender-Punkte)
  scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ",")) +
  
  # Unser Projekt-Theme
  theme_lockin() +
  
  scale_color_brewer(palette = "Set1") +
  
  # Beschriftung
  labs(
    title = "Bevölkerungsentwicklung in München (2005-2024)",
    subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Einwohner",
    color = "Bezirkstyp:"
  )
print(bev_entw_plot)
