# 03_eda_tabellen.R
# Ziel: Explorative Datenanalyse (EDA) und Vorbereitung der Ausreißer-Erkennung
# Verantwortlich: Heinz (Infrastruktur) & Harry (Methodik)

# --- A. Arbeitsumgebung laden ---
source("env_setup.R")

message("📊 Basis-Statistiken der Umzüge (zur Orientierung für Ausreißer):")
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

# --- C. Visuelle Ausreißer-Erkennung (Für Harrys "Bullshit-Check") ---
# TEAM-INFO: Hier testen wir die drei verschiedenen Gruppierungen, 
# um zu sehen, welche die Ausreißer und Trends am besten erklärt.

# 1. Boxplot nach Zentrum/Peripherie (Unser Original)
boxplot_typ <- ggplot(indikatoren_mobilitaet, aes(x = bezirk_typ, y = zuzuege_aussen_insgesamt, fill = bezirk_typ)) +
  geom_boxplot(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Option 1: Zuzüge nach Bezirkstyp (Zentrum vs. Peripherie)", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# 2. Boxplot nach Dichte-Kategorie (Vorschlag der Betreuerin)
boxplot_dichte <- ggplot(indikatoren_mobilitaet, aes(x = dichte_kategorie, y = zuzuege_aussen_insgesamt, fill = dichte_kategorie)) +
  geom_boxplot(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Option 2: Zuzüge nach Bevölkerungsdichte", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# 3. Boxplot nach Himmelsrichtung (Nord/Süd/Ost/West/Mitte)
boxplot_himmel <- ggplot(indikatoren_mobilitaet, aes(x = himmelsrichtung, y = zuzuege_aussen_insgesamt, fill = himmelsrichtung)) +
  geom_boxplot(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Option 3: Zuzüge nach Himmelsrichtung", y = "Zuzüge", x = "") +
  theme(legend.position = "none")

# Zeige alle drei an (Harry kann sie im 'Plots' Fenster von RStudio durchblättern)
print(boxplot_typ)
print(boxplot_dichte)
print(boxplot_himmel)

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

