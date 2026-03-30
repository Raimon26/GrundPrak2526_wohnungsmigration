# ==============================================================================
# Skript 07: Binnenmigration - Sankey Diagramm (Perfektioniert mit Tuben-Prozenten)
# ==============================================================================
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

# 3. Daten umbauen und Prozent pro Herkunft (Tubo) berechnen
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
  
  # --- NEU: Mathematik für die Tuben ---
  # Wir berechnen, wie viel Prozent jeder Fluss ausmacht (bezogen auf die Herkunft)
  group_by(von_typ) %>%
  mutate(
    prozent_von_herkunft = total_personen / sum(total_personen) * 100,
    # Verstecke Labels, die zu klein sind (unter 4%), damit es sauber bleibt
    label_text = ifelse(prozent_von_herkunft >= 4, 
                        sprintf("%1.1f%%", prozent_von_herkunft), 
                        "")
  ) %>%
  ungroup() %>%
  
  mutate(
    von_typ = factor(von_typ, levels = c("Zentrum", "Innenstadt-Rand", "Peripherie")),
    nach_typ = factor(nach_typ, levels = c("Zentrum", "Innenstadt-Rand", "Peripherie"))
  )

# 4. DAS SANKEY-DIAGRAMM PLOTTEN 
plot_sankey_final <- ggplot(data = fluesse_typ,
                            aes(axis1 = von_typ, axis2 = nach_typ, y = total_personen)) +
  
  # a) Flüsse (Alluvium)
  geom_alluvium(aes(fill = von_typ), width = 1/12, alpha = 0.8, color = "white", linewidth = 0.5) +
  
  # b) Blöcke (Stratum)
  geom_stratum(width = 1/4, fill = "grey20", color = "white") +
  
  # Text für die Blöcke (Wieder nur die sauberen Namen, ohne Fake-Prozente)
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), 
            color = "white", fontface = "bold", size = 4) +
  
  # Achsenbeschriftungen
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
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 16),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )

print(plot_sankey_final)

# 5. SICHER SPEICHERN
ggsave("Output/10_sankey_binnenmigration_final.png", plot = plot_sankey_final, 
       width = 12, height = 8, dpi = 300, bg = "white")

# Die "Spickzettel" für die Präsentation
fluesse_typ %>%
  select(Herkunft = von_typ, Ziel = nach_typ, Prozent = prozent_von_herkunft) %>%
  mutate(Prozent = sprintf("%1.1f%%", Prozent)) %>%
  arrange(Herkunft, desc(Prozent)) %>%
  print()


# ==============================================================================
# 8. RELATIVE BALKENDIAGRAMME (100% Stacked Bar Chart mit Prozenten)
# ==============================================================================

plot_bar_relativ <- ggplot(fluesse_typ, aes(x = von_typ, y = prozent_von_herkunft, fill = nach_typ)) +
  # geom_col stapelt automatisch, wenn wir 'y' vorgeben
  geom_col(color = "white", width = 0.6) +
  
  # Hier kommen die ersehnten Prozente direkt IN die Balken!
  geom_text(aes(label = sprintf("%1.1f%%", prozent_von_herkunft)), 
            position = position_stack(vjust = 0.5), # Zentriert den Text im Farbblock
            color = "white", fontface = "bold", size = 4.5) +
  
  # Gleiche Farbpalette für absolute Konsistenz
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
    panel.grid.major.x = element_blank() # Macht den Hintergrund sauberer
  )

print(plot_bar_relativ)

ggsave("Output/11_bar_binnenmigration_relativ.png", plot = plot_bar_relativ, 
       width = 10, height = 7, dpi = 300, bg = "white")
