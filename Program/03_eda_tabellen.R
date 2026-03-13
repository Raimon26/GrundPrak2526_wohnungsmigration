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
# Wenn du dich entschieden hast, schreibe deine Filter-Formel hier rein (z.B. Mean + 2*SD).

# ausreisser_tabelle <- indikatoren_mobilitaet %>%
#   filter(zuzuege_aussen > DEINE_FORMEL_HIER)