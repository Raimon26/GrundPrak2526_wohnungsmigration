# 03_eda_tabellen.R
# Ziel: Explorative Datenanalyse (EDA) und Vorbereitung der Ausreißer-Erkennung
# Verantwortlich: Heinz (Infrastruktur) & Harry (Methodik)

# --- A. Arbeitsumgebung laden ---
source("env_setup.R")

message("Basis-Statistiken der Umzüge (zur Orientierung für Ausreißer):")
summary(umzuege_clean)

# --- B. (Zentrum vs. Peripherie) ---
# Schauen wir uns an, wo die meiste Bewegung stattfindet
tab_bewegung_typ <- indikatoren_mobilitaet %>%
  group_by(bezirk_typ) %>%
  summarise(
    avg_zuzuege_aussen = mean(zuzuege_aussen_insgesamt, na.rm = TRUE),
    avg_wegzuege_aussen = mean(wegzuege_aussen_insgesamt, na.rm = TRUE),
    max_zuzuege = max(zuzuege_aussen_insgesamt, na.rm = TRUE)
  ) %>%
  arrange(desc(avg_zuzuege_aussen))

print(tab_bewegung_typ)

# --- C. Visuelle Ausreißer-Erkennung (Für Methodik & Anhang) ---

# Die Reihenfolge der Faktor-Level definiert die Reihenfolge in der Legende
indikatoren_mobilitaet <- indikatoren_mobilitaet %>%
  mutate(bezirk_typ = factor(bezirk_typ, 
                             levels = c("Zentrum", "Innenstadt-Rand", "Peripherie")))

# 1. Boxplot nach Zentrum/Peripherie (Unser Original)
boxplot_typ <- ggplot(indikatoren_mobilitaet, aes(x = bezirk_typ, y = zuzuege_aussen_insgesamt, fill = bezirk_typ)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d(option = "D", end = 0.8) +
  theme_minimal() +
  labs(title = "Zuzüge nach Bezirkstyp (Zentrum vs. Peripherie)", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# 2. Boxplot nach Dichte-Kategorie (Vorschlag der Betreuerin)
boxplot_dichte <- ggplot(indikatoren_mobilitaet, aes(x = dichte_kategorie, y = zuzuege_aussen_insgesamt, fill = dichte_kategorie)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d(option = "D") +
  theme_minimal() +
  labs(title = "Zuzüge nach Bevölkerungsdichte", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# 3. Boxplot nach Himmelsrichtung (Nord/Süd/Ost/West/Mitte)
boxplot_himmel <- ggplot(indikatoren_mobilitaet, aes(x = himmelsrichtung, y = zuzuege_aussen_insgesamt, fill = himmelsrichtung)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d(option = "D") +
  theme_minimal() +
  labs(title = "Zuzüge nach Himmelsrichtung", y = "Zuzüge", x = "") +
  theme(legend.position = "none")



# Zeige alle drei an
print(boxplot_typ)
print(boxplot_dichte)
print(boxplot_himmel)

# Umzüge
# 1. Boxplot nach Zentrum/Peripherie (Unser Original)
boxplot_typ_um <- ggplot(indikatoren_mobilitaet, aes(x = bezirk_typ, y = umzuege_innen_insgesamt, fill = bezirk_typ)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d(option = "D") +
  theme_minimal() +
  labs(title = "Umzüge nach Bezirkstyp (Zentrum vs. Peripherie)", y = "Umzüge", x = "") +
  theme(legend.position = "none")

# 2. Boxplot nach Dichte-Kategorie (Vorschlag der Betreuerin)
boxplot_dichte_um <- ggplot(indikatoren_mobilitaet, aes(x = dichte_kategorie, y = umzuege_innen_insgesamt, fill = dichte_kategorie)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d(option = "D") +
  theme_minimal() +
  labs(title = "Umzüge nach Bevölkerungsdichte", y = "Umzüge", x = "") +
  theme(legend.position = "none")

# 3. Boxplot nach Himmelsrichtung (Nord/Süd/Ost/West/Mitte)
boxplot_himmel_um <- ggplot(indikatoren_mobilitaet, aes(x = himmelsrichtung, y = umzuege_innen_insgesamt, fill = himmelsrichtung)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d(option = "D") +
  theme_minimal() +
  labs(title = "Umzüge nach Himmelsrichtung", y = "Umzüge", x = "") +
  theme(legend.position = "none")

# Zeige alle drei an
print(boxplot_typ_um)
print(boxplot_dichte_um)
print(boxplot_himmel_um)



# --- BILDER EXPORTIEREN (FÜR DEN ANHANG / DOKUMENTATION) ---
ggsave("Output/EDA_boxplot_bezirkstyp.png", plot = boxplot_typ, width = 8, height = 5, dpi = 300, bg = "white")
ggsave("Output/EDA_boxplot_dichte.png", plot = boxplot_dichte, width = 8, height = 5, dpi = 300, bg = "white")
ggsave("Output/EDA_boxplot_himmelsrichtung.png", plot = boxplot_himmel, width = 8, height = 5, dpi = 300, bg = "white")

# NEU: Interne Umzüge
ggsave("Output/EDA_boxplot_bezirkstyp_um.png", plot = boxplot_typ_um, width = 8, height = 5, dpi = 300, bg = "white")
ggsave("Output/EDA_boxplot_dichte_um.png", plot = boxplot_dichte_um, width = 8, height = 5, dpi = 300, bg = "white")
ggsave("Output/EDA_boxplot_himmelsrichtung_um.png", plot = boxplot_himmel_um, width = 8, height = 5, dpi = 300, bg = "white")
# --- D. PLATZHALTER FÜR HARRY FILTER-LOGIK ---
# TODO für Harry: Schau dir die 3 Boxplots an. Welche Gruppierung erklärt die Daten am besten?
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

# Wenn du dich entschieden hast, schreibe deine Filter-Formel hier rein (z.B. Mean + 2*SD).
# Definition der Ausreißer:
# Ausreißer werden anhand der IQR-Regel definiert (wie im Boxplot).
# Werte größer als Q3 + 1.5 * IQR gelten als Ausreißer.
Q1 <- quantile(indikatoren_mobilitaet$zuzuege_aussen_insgesamt, 0.25, na.rm = TRUE)
Q3 <- quantile(indikatoren_mobilitaet$zuzuege_aussen_insgesamt, 0.75, na.rm = TRUE)
IQR_value <- Q3 - Q1

threshold <- Q3 + 1.5 * IQR_value

ausreisser_tabelle <- indikatoren_mobilitaet %>%
  filter(zuzuege_aussen_insgesamt > threshold)

