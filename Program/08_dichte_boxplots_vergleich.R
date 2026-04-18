# Anhang: 08 Boxplotvergleich

source("env_setup.R")
library(dplyr)
library(tidyr)
library(tidyverse)
library(ggplot2)
library(scales)
library(sf)



indikatoren_dichte <- readRDS("Data/indikatoren_dichte.rds")

# 1. Plot
boxplot_data <- indikatoren_dichte %>%
  filter(jahr %in% c(2000, 2005, 2015, 2024)) %>%
  mutate(
    jahr = factor(jahr),
    bezirk_typ = factor(bezirk_typ, levels = c("Zentrum", "Innenstadt-Rand", "Peripherie"))
  )


plot_dichte_boxplot <- ggplot(boxplot_data, aes(x = bezirk_typ, y = dichte, fill = bezirk_typ)) +

  geom_boxplot(alpha = 0.6, outlier.shape = NA, color = "grey30") + 
  

  geom_jitter(width = 0.2, alpha = 0.4, size = 1.2, aes(color = bezirk_typ)) +
  

  facet_wrap(~jahr, nrow = 1) +
  

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
    strip.text = element_text(face = "bold", size = 12),
    panel.spacing = unit(1, "lines") 
  )

print(plot_dichte_boxplot)


ggsave(
  filename = "Output/06a_dichte_boxplot.png",
  plot = plot_dichte_boxplot,width = 20, height = 12,units = "cm", dpi = 300, bg = "white")


