# Skript + Anhang 07: Binnenmigration - Sankey Diagramm

source("env_setup.R")
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggalluvial)
library(scales) 

# 1. Daten laden
umzuege_clean <- readRDS("Data/umzuege_clean.rds")
indikatoren_mobilitaet <- readRDS("Data/indikatoren_mobilitaet.rds") 

# 2. Wörterbuch
bezirk_dict <- indikatoren_mobilitaet %>%
  select(bezirk_nr = von_bezirk, bezirk_typ) %>%
  distinct()

# 3. Daten umbauen und Prozent pro Herkunft berechnen
fluesse_typ <- umzuege_clean %>%
  rename(von_typ = bezirk_typ) %>%
  pivot_longer(
    cols = starts_with("nach_bezirk_"),
    names_to = "nach_bezirk",
    values_to = "anzahl_personen"
  ) %>%
  mutate(nach_bezirk = as.numeric(gsub("nach_bezirk_", "", nach_bezirk))) %>%
  left_join(bezirk_dict, by = c("nach_bezirk" = "bezirk_nr")) %>%
  rename(nach_typ = bezirk_typ) %>%
  filter(!is.na(von_typ) & !is.na(nach_typ)) %>%
  group_by(von_typ, nach_typ) %>%
  summarise(total_personen = sum(anzahl_personen, na.rm = TRUE), .groups = "drop") %>%
  group_by(von_typ) %>%
  mutate(
    prozent_von_herkunft = total_personen / sum(total_personen) * 100,
    label_text = ifelse(prozent_von_herkunft >= 4, 
                        sprintf("%1.1f%%", prozent_von_herkunft), 
                        "")
  ) %>%
  ungroup() %>%
  
  mutate(
    von_typ = factor(von_typ, levels = c("Zentrum", "Innenstadt-Rand", "Peripherie")),
    nach_typ = factor(nach_typ, levels = c("Zentrum", "Innenstadt-Rand", "Peripherie"))
  )

# 4. SANKEY-DIAGRAMM PLOT
plot_sankey_final <- ggplot(data = fluesse_typ,
                            aes(axis1 = von_typ, axis2 = nach_typ, y = total_personen)) +
  
  # a) Flüsse
  geom_alluvium(aes(fill = von_typ), width = 1/12, alpha = 0.8, color = "white", linewidth = 0.5) +
  
  # b) Blöcke
  geom_stratum(width = 1/4, fill = "grey20", color = "white") +
  
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), 
            color = "white", fontface = "bold", size = 3) +
  
  scale_x_discrete(limits = c("Herkunft (Von)", "Ziel (Nach)"), expand = c(0.15, 0.05)) +
  scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ",")) +
  scale_fill_viridis_d(option = "D", end = 0.8) +
  
  theme_minimal() +
  labs(
    title = "Binnenmigration in München (2005-2024)",
    subtitle = "Aggregierte Flüsse zwischen Stadtstrukturtypen",
    y = "Anzahl der Umzüge (Gesamt)",
    fill = "Herkunftsregion"
  ) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )

print(plot_sankey_final)

ggsave("Output/10_sankey_binnenmigration_final.png", plot = plot_sankey_final, 
       width = 12, height = 8, dpi = 300, bg = "white")

fluesse_typ %>%
  select(Herkunft = von_typ, Ziel = nach_typ, Prozent = prozent_von_herkunft) %>%
  mutate(Prozent = sprintf("%1.1f%%", Prozent)) %>%
  arrange(Herkunft, desc(Prozent)) %>%
  print()


# 8. RELATIVE BALKENDIAGRAMME

plot_bar_relativ <- ggplot(fluesse_typ, aes(x = von_typ, y = prozent_von_herkunft, fill = nach_typ)) +
  geom_col(color = "white", width = 0.6) +
  
  geom_text(aes(label = sprintf("%1.1f%%", prozent_von_herkunft)), 
            position = position_stack(vjust = 0.5),
            color = "white", fontface = "bold", size = 4.5) +

  scale_fill_viridis_d(option = "D", end = 0.8) +
  
  theme_minimal() +
  labs(
    title = "Wohin ziehen die Münchner? (Relative Verteilung)",
    subtitle = "Prozentualer Anteil der Zielgebiete für jede Herkunftsregion (2005-2024)",
    x = "Herkunftsregion (Von)",
    y = "Anteil in Prozent (%)",
    fill = "Zielregion (Nach)"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 16),
    panel.grid.major.x = element_blank()
  )

print(plot_bar_relativ)

ggsave("Output/11_bar_binnenmigration_relativ.png", plot = plot_bar_relativ, 
       width = 10, height = 7, dpi = 300, bg = "white")
