# ---08-dichte_boxplots_vergleich ---

source("env_setup.R")
library(dplyr)
library(tidyr)
library(tidyverse)
library(ggplot2)
library(scales)
library(sf)


# Daten Laden

indikatoren_dichte <- readRDS("Data/indikatoren_dichte.rds")

# 1. Daten vorbereiten: Die vier Jahre filtern und Faktor für richtige Anordnung
boxplot_data <- indikatoren_dichte %>%
  filter(jahr %in% c(2000, 2005, 2015, 2024)) %>%
  mutate(
    jahr = factor(jahr), # Jahr als Kategorie für die Facets
    bezirk_typ = factor(bezirk_typ, levels = c("Zentrum", "Innenstadt-Rand", "Peripherie"))
  )

# 2. Den Boxplot erstellen
plot_dichte_boxplot <- ggplot(boxplot_data, aes(x = bezirk_typ, y = dichte, fill = bezirk_typ)) +
  # Boxplot ohne Ausreißer-Punkte (da wir alle Punkte mit jitter zeigen)
  geom_boxplot(alpha = 0.6, outlier.shape = NA, color = "grey30") + 
  
  # Einzelne Bezirke als Punkte (Streuung innerhalb der Gruppe)
  geom_jitter(width = 0.2, alpha = 0.4, size = 1.2, aes(color = bezirk_typ)) +
  
  # Facetting nach den 4 Jahren in einer Reihe
  facet_wrap(~jahr, nrow = 1) +
  
  # Optik & Farben
  scale_fill_viridis_d(option = "D", end = 0.8) +
  scale_color_viridis_d(option = "D", end = 0.8) +
  
  theme_minimal() +
  labs(
    title = "Evolution der Siedlungsdichte (2000–2024)",
    subtitle = "Vergleich über vier markante Zeitpunkte",
    x = NULL,
    y = "Einwohner pro km²"
  ) +
  theme(
    legend.position = "none", 
    axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
    strip.text = element_text(face = "bold", size = 12), # Jahreszahlen dicker
    panel.spacing = unit(1, "lines") # Mehr Platz zwischen den Jahren
  )

print(plot_dichte_boxplot)


# --- Plot in Ordner Output sichern ---

ggsave(
  filename = "Output/06a_dichte_boxplot.png",
  plot = plot_dichte_boxplot,width = 20, height = 12,units = "cm", dpi = 300, bg = "white")


