# 02_feature_engineering.R
# Ziel: Hinzufügen von geografischen und strukturellen Kategorien zu den Bezirken

# Arbeitsumgebung laden (Lädt Pakete und die 3 sauberen Datensätze)
source("env_setup.R")

# Logik für die Kategorisierung der 25 Münchner Bezirke definieren
# Zentrum: Altstadt, Isarvorstadt, Maxvorstadt, Schwabing-West, Au-Haidhausen, Schwanthalerhöhe
# Innenstadt-Rand: Sendling, Sendling-Westpark, Neuhausen, Giesing, Laim
# Peripherie: Restliche äußere Bezirke (Pasing, Moosach, Trudering, etc.)
kategorisiere_bezirk <- function(bezirk_nummer) {
  case_when(
    bezirk_nummer %in% c(1, 2, 3, 4, 5, 8) ~ "Zentrum",
    bezirk_nummer %in% c(6, 7, 9, 17, 18, 25) ~ "Innenstadt-Rand",
    TRUE ~ "Peripherie"
  )
}

# Die neue Kategorie "bezirk_typ" an alle 3 Datensätze anfügen
umzuege_clean <- umzuege_clean %>%
  mutate(bezirk_typ = kategorisiere_bezirk(von_bezirk))

indikatoren_dichte <- indikatoren_dichte %>%
  mutate(bezirk_typ = kategorisiere_bezirk(von_bezirk))

indikatoren_mobilitaet <- indikatoren_mobilitaet %>%
  mutate(bezirk_typ = kategorisiere_bezirk(von_bezirk))

# Die angereicherten Datensätze speichern (überschreibt die alten Dateien im Data-Ordner)
write_rds(umzuege_clean, "Data/umzuege_clean.rds")
write_rds(indikatoren_dichte, "Data/indikatoren_dichte.rds")
write_rds(indikatoren_mobilitaet, "Data/indikatoren_mobilitaet.rds")

message("✅ Feature Engineering abgeschlossen: Die Kategorie 'bezirk_typ' wurde in alle Datensätze integriert!")



# 1. ¿Hay algún año fuera de lugar? (Debería ser 2005 a 2024)
range(indikatoren_dichte$jahr)

# 2. ¿Hay alguna población o densidad negativa? (Deberían ser todas >= 0)
min(indikatoren_dichte$einwohner)
min(indikatoren_dichte$dichte)

# 3. ¿Alguien ha metido mudanzas negativas por error?
umzuege_clean %>% 
  summarise(across(starts_with("nach"), min)) %>% 
  pivot_longer(everything()) %>% 
  filter(value < 0)

# 4. ¿Hay valores faltantes (NAs) que se nos hayan escapado en la matriz?
sum(is.na(umzuege_clean2))
sum(is.na(indikatoren_mobilitaet))


umzuege_clean |> filter(if_any(everything(), is.na)) |> select(jahr, von_bezirk)

