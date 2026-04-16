# 03_eda_tabellen.R
# Ziel: Explorative Datenanalyse (EDA) und Vorbereitung der Ausreißer-Erkennung

#  1. Arbeitsumgebung laden 
source("env_setup.R")

message("Basis-Statistiken der Umzüge:")
summary(umzuege_clean)

#  2. Bezirkstyp (Zentrum/Innenstadt-Rand/Peripherie) 

tab_bewegung_typ <- indikatoren_mobilitaet %>%
  group_by(bezirk_typ) %>%
  summarise(
    avg_zuzuege_aussen = mean(zuzuege_aussen_insgesamt, na.rm = TRUE),
    avg_wegzuege_aussen = mean(wegzuege_aussen_insgesamt, na.rm = TRUE),
    max_zuzuege = max(zuzuege_aussen_insgesamt, na.rm = TRUE)
  ) %>%
  arrange(desc(avg_zuzuege_aussen))

print(tab_bewegung_typ)

# Faktorisierung der Bezirktypen

indikatoren_mobilitaet <- indikatoren_mobilitaet %>%
  mutate(bezirk_typ = factor(bezirk_typ, 
                             levels = c("Zentrum", "Innenstadt-Rand", "Peripherie")))

#  3. Visuelle Ausreißer-Erkennung 

# 3.1 Boxplot nach Berzirktyp
boxplot_typ <- ggplot(indikatoren_mobilitaet, aes(x = bezirk_typ, y = zuzuege_aussen_insgesamt, fill = bezirk_typ)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d(option = "D", end = 0.8) +
  theme_minimal() +
  labs(title = "Zuzüge (von außen) nach Bezirkstyp", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# 3.2 Boxplot nach Dichte-Kategorie
indikatoren_mobilitaet <- indikatoren_mobilitaet %>% 
  mutate(dichte_kategorie = fct_relevel(dichte_kategorie, 
                                        "Hohe Dichte", 
                                        "Mittlere Dichte", 
                                        "Niedrige Dichte"))

boxplot_dichte <- ggplot(indikatoren_mobilitaet, aes(x = dichte_kategorie, y = zuzuege_aussen_insgesamt)) +
  geom_boxplot(fill = "lightgrey", alpha = 0.7) +
  theme_minimal() +
  labs(title = "Zuzüge (von außen) nach Bevölkerungsdichte", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# 3.3 Boxplot nach Himmelsrichtung (Nord/Süd/Ost/West/Mitte)
boxplot_himmel <- ggplot(indikatoren_mobilitaet, aes(x = himmelsrichtung, y = zuzuege_aussen_insgesamt)) +
  geom_boxplot(fill = "lightgrey", alpha = 0.7) +
  theme_minimal() +
  labs(title = "Zuzüge (von außen) nach Himmelsrichtung", y = "Zuzüge", x = "") +
  theme(legend.position = "none")


print(boxplot_typ)
print(boxplot_dichte)
print(boxplot_himmel)

# Umzüge

# 1. Boxplot nach Bezirkstyp
boxplot_typ_um <- ggplot(indikatoren_mobilitaet, aes(x = bezirk_typ, y = umzuege_innen_insgesamt, fill = bezirk_typ)) +
  geom_boxplot(alpha = 0.7,) +
  scale_fill_viridis_d(option = "D", end = 0.8) +
  theme_minimal() +
  labs(title = "Zuzüge (von innen) nach Bezirkstyp", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# 2. Boxplot nach Dichte-Kategorie
boxplot_dichte_um <- ggplot(indikatoren_mobilitaet, aes(x = dichte_kategorie, y = umzuege_innen_insgesamt)) +
  geom_boxplot(fill = "lightgrey", alpha = 0.7) +
  theme_minimal() +
  labs(title = "Zuzüge (von innen) nach Bevölkerungsdichte", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# 3. Boxplot nach Himmelsrichtung 
boxplot_himmel_um <- ggplot(indikatoren_mobilitaet, aes(x = himmelsrichtung, y = umzuege_innen_insgesamt)) +
  geom_boxplot(fill = "lightgrey", alpha = 0.7) +
  theme_minimal() +
  labs(title = "Zuzüge (von innen) nach Himmelsrichtung", y = "Zuzüge", x = "") +
  theme(legend.position = "none")


print(boxplot_typ_um)
print(boxplot_dichte_um)
print(boxplot_himmel_um)

# Plots im Ordner 'Output' gespeichert

ggsave("Output/EDA_boxplot_bezirkstyp.png", plot = boxplot_typ, width = 8, height = 5, dpi = 300, bg = "white")
ggsave("Output/EDA_boxplot_dichte.png", plot = boxplot_dichte, width = 8, height = 5, dpi = 300, bg = "white")
ggsave("Output/EDA_boxplot_himmelsrichtung.png", plot = boxplot_himmel, width = 8, height = 5, dpi = 300, bg = "white")

ggsave("Output/EDA_boxplot_bezirkstyp_um.png", plot = boxplot_typ_um, width = 8, height = 5, dpi = 300, bg = "white")
ggsave("Output/EDA_boxplot_dichte_um.png", plot = boxplot_dichte_um, width = 8, height = 5, dpi = 300, bg = "white")
ggsave("Output/EDA_boxplot_himmelsrichtung_um.png", plot = boxplot_himmel_um, width = 8, height = 5, dpi = 300, bg = "white")
#  4. FILTER-LOGIK 
# Entscheidung zur Gruppierung:
# Die Gruppierung nach Bezirkstyp (Zentrum / Peripherie / Innenstadt-Rand)
# erscheint am sinnvollsten für die weitere Analyse.
# In den Boxplots zeigen sich hier die klarsten Unterschiede in der Verteilung
# der Zuzüge, und die Ergebnisse lassen sich auch inhaltlich gut interpretieren
# (z.B. Unterschiede zwischen zentralen und peripheren Stadtlagen).
#
# Die Gruppierung nach Bevölkerungsdichte zeigt teilweise ein ähnliches Muster,
# überschneidet sich jedoch stark mit der Peripherie.
# Bei den Himmelsrichtungen sind dagegen keine klaren Unterschiede erkennbar.
#
# Daher verwenden wir den Bezirkstyp als Hauptstruktur für die weitere Analyse.

Q1 <- quantile(indikatoren_mobilitaet$zuzuege_aussen_insgesamt, 0.25, na.rm = TRUE)
Q3 <- quantile(indikatoren_mobilitaet$zuzuege_aussen_insgesamt, 0.75, na.rm = TRUE)
IQR_value <- Q3 - Q1

threshold <- Q3 + 1.5 * IQR_value

ausreisser_tabelle <- indikatoren_mobilitaet %>%
  filter(zuzuege_aussen_insgesamt > threshold)

