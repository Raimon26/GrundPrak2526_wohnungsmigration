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
# Ein simpler Boxplot für Harry. Dieser soll dir dabei helfen, die extremen Werte 
# zu lokalisieren, 
# BEVOR du die mathematische Formel (z.B. IQR) festlegst.
boxplot_zuzuege <- ggplot(indikatoren_mobilitaet, aes(x = bezirk_typ, y = zuzuege_aussen_insgesamt, fill = bezirk_typ)) +
  geom_boxplot(alpha = 0.7) +
  theme_minimal() +
  labs(
    title = "Verteilung der Zuzüge nach Bezirkstyp",
    subtitle = "Die Punkte außerhalb der 'Antennen' (Whiskers) sind potenzielle Ausreißer",
    y = "Anzahl Zuzüge von außen",
    x = "Bezirkstyp"
  ) +
  theme(legend.position = "none")


print(boxplot_zuzuege)

# --- D. PLATZHALTER FÜR HARRY FILTER-LOGIK ---
# TODO für Harry: Wenn du dich für eine Methode entschieden hast (z.B. Mean + 2*SD), 
# schreibe deinen Code hier rein, um die tatsächlichen Ausreißer zu extrahieren.

# ausreisser_tabelle <- indikatoren_mobilitaet %>%
#   filter(zuzuege_aussen > DEINE_FORMEL_HIER)