# Skript 02: Features
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

# Die angereicherten Datensätze speichern
write_rds(umzuege_clean, "Data/umzuege_clean.rds")
write_rds(indikatoren_mobilitaet, "Data/indikatoren_mobilitaet.rds")
write_rds(indikatoren_dichte, "Data/indikatoren_dichte.rds")

message("Feature Engineering abgeschlossen: Die Kategorie 'bezirk_typ' wurde in alle Datensätze integriert!")


# Kleine Checks zur Überprüfung der Funktionalität unserer Datensätze
# 1. Irgendein Jahr ausserhalb unseres Ranges? (Sollte zw. 2000 und 2024)
range(indikatoren_dichte$jahr)

# 2. Negative Bevölkerung oder Dichte? (Alle sollten >= 0)
min(indikatoren_dichte$einwohner)
min(indikatoren_dichte$dichte)

# 3. Hat irgendjemand negative Umzüge hinzugefügt? 
umzuege_clean %>% 
  summarise(across(starts_with("nach"), min)) %>% 
  pivot_longer(everything()) %>% 
  filter(value < 0)

# 4. Sind irgendwelche NAs vorhanden?
sum(is.na(umzuege_clean))
sum(is.na(indikatoren_mobilitaet))


umzuege_clean |> filter(if_any(everything(), is.na)) |> select(jahr, von_bezirk)



# Filterung für Nationalität
indikatoren_mobilitaet_long_plot <- indikatoren_mobilitaet %>%
  select(jahr, von_bezirk, bezirk_typ, matches("_(deutsch|nichtdeutsch)$")) %>%
  pivot_longer(
    cols = matches("_(deutsch|nichtdeutsch)$"),
    names_to = c("bewegungsart", "nationalitaet"),
    names_pattern = "(.*)_(deutsch|nichtdeutsch)",
    values_to = "anzahl_personen"
  ) %>%
  mutate(
    nationalitaet = str_to_title(nationalitaet)
  )

saveRDS(indikatoren_mobilitaet_long_plot, "Data/indikatoren_mobilitaet_long_plot.rds")

message("Datensatz facet_wrap erfolgreich als .rds gespeichert")

# Gruppierung der Bezirke nach Dichte

indikatoren_dichte <- indikatoren_dichte %>%
  group_by(jahr) %>%
  mutate(
    # ntile(dichte, 3) teilt die Werte automatisch in 3 Gruppen (1=niedrig, 3=hoch)
    dichte_level = ntile(dichte, 3), 
    dichte_kategorie = case_when(
      dichte_level == 1 ~ "Geringe Dichte",
      dichte_level == 2 ~ "Mittlere Dichte",
      dichte_level == 3 ~ "Hohe Dichte"
    )
  ) %>%
  ungroup() %>% select(-dichte_level)

# Gruppierung der Himmelsrichtungen (Norden, Süden, Osten, Westen, Mitte) ---

indikatoren_dichte <- indikatoren_dichte %>%
  mutate(
    himmelsrichtung = case_when(
      # Mitte (Altstadt, Ludwigsvorstadt, Maxvorstadt, Schwabing-West, Au-Haidhausen, Schwanthalerhöhe)
      von_bezirk %in% c(1, 2, 3, 4, 5, 8) ~ "Mitte",
      # Nord (Moosach, Milbertshofen, Schwabing-Freimann, Feldmoching)
      von_bezirk %in% c(10, 11, 12, 24) ~ "Nord",
      # Ost (Bogenhausen, Berg am Laim, Trudering, Ramersdorf)
      von_bezirk %in% c(13, 14, 15, 16) ~ "Ost",
      # Süd (Sendling, Obergiesing, Untergiesing, Thalkirchen, Hadern)
      von_bezirk %in% c(6, 17, 18, 19, 20) ~ "Süd",
      # West (Sendling-Westpark, Neuhausen, Pasing, Aubing, Allach, Laim)
      von_bezirk %in% c(7, 9, 21, 22, 23, 25) ~ "West",
      TRUE ~ "Unbekannt" 
    )
  )


# Übertragung der neuen Features auf die Mobilitätsdaten

indikatoren_mobilitaet <- indikatoren_mobilitaet %>%
  left_join(
    indikatoren_dichte %>% select(jahr, von_bezirk, dichte_kategorie, himmelsrichtung), 
    by = c("jahr", "von_bezirk")
  )

glimpse(indikatoren_mobilitaet)

# Überschreiben beider Dateien
write_rds(indikatoren_dichte, "Data/indikatoren_dichte.rds")
write_rds(indikatoren_mobilitaet, "Data/indikatoren_mobilitaet.rds")

message("Features wurden auf beide Datensätze angewendet und gespeichert.")
