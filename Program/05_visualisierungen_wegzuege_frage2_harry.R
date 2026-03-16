source("env_setup.R")

library(ggplot2)
library(dplyr)
library(tidyr)
library(sf)

# 3. ZEITREIHEN: WEGZÜGE (Facet nach Bewegungsart)

indikatoren_mobilitaet_long <- indikatoren_mobilitaet %>%
  pivot_longer(
    cols = c(wegzuege_innen_insgesamt, wegzuege_aussen_insgesamt),
    names_to = "bewegungsart",
    values_to = "anzahl_personen"
  )

plot_wegzuege <- ggplot(
  indikatoren_mobilitaet_long,
  aes(x = jahr, y = anzahl_personen)
) +
  
  geom_line(aes(group = von_bezirk), color = "grey80", alpha = 0.5, linewidth = 0.5) +
  
  stat_summary(aes(color = bezirk_typ), fun = mean, geom = "line", linewidth = 1.2) +
  
  facet_wrap(
    ~bewegungsart,
    labeller = labeller(
      bewegungsart = c(
        wegzuege_innen_insgesamt = "Innerhalb München",
        wegzuege_aussen_insgesamt = "Außerhalb München"
      )
    )
  ) +
  
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  
  labs(
    title = "Entwicklung der Wegzüge aus den Münchner Stadtbezirken (2005–2024)",
    subtitle = "Graue Linien: Einzelne Bezirke | Farbige Linien: Durchschnitt nach Bezirkstyp",
    x = "Jahr",
    y = "Anzahl Personen",
    color = "Bezirkstyp"
  ) +
  
  theme(legend.position = "bottom")

print(plot_wegzuege)

