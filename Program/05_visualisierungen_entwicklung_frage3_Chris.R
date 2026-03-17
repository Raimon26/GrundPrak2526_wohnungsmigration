# Frage 3

# Zeitreihenplot zur Bevölkerungsentwicklung

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
  
  # Manuelle Farbwahl 
  scale_color_manual(values = c(
    "Zentrum" = "#005a94", 
    "Innenstadt-Rand" = "#5dade2", 
    "Peripherie" = "#e67e22"
  )) +
  
  # Beschriftung
  labs(
    title = "Bevölkerungsentwicklung in München (2005-2024)",
    subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Einwohner",
    color = "Bezirkstyp:"
  )
print(bev_entw_plot)


# Zeitreihenplot zur Dichtenentwicklung

# 1. Daten laden 
data_dichte <- indikatoren_dichte

# 2. Daten aggregieren für die Durchschnittslinien der Dichte

typ_dichte_summary <- data_dichte %>%
  group_by(jahr, bezirk_typ) %>%
  summarise(DICHTE_AVG = mean(dichte, na.rm = TRUE), .groups = "drop")

# 2. Der Plot
dichte_entw_plot <- ggplot() +
  # Hintergrund: Alle Bezirke (Cloud)
  geom_line(data = data_dichte, 
            aes(x = jahr, y = dichte, group = von_bezirk), 
            color = "grey85", size = 0.4, alpha = 0.5) +
  
  # Vordergrund: Durchschnittliche Dichte pro Typ
  geom_line(data = typ_dichte_summary, 
            aes(x = jahr, y = DICHTE_AVG, color = bezirk_typ), 
            size = 1.5) +
  
  # Manuelle Farbwahl (vermeidet den Brewer-Error)
  scale_color_manual(values = c(
    "Zentrum" = "#005a94", 
    "Innenstadt-Rand" = "#5dade2", 
    "Peripherie" = "#e67e22"
  )) +
  
  theme_lockin() +
  labs(
    title = "Entwicklung der Siedlungsdichte in München",
    subtitle = "Einwohner pro km²(: Zentrum verdichtet sich am stärksten)",
    x = "Jahr",
    y = "Einwohner / km²",
    color = "Lage:"
  )

print(dichte_entw_plot)


