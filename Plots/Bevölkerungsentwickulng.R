# Plot zur Bevölkerungsentwicklung
# Frage 3

# --- Arbeitsumgebung laden ---
source("env_setup.R")



einwohner_entwicklung <- ggplot(indikatoren_dichte, aes(x = jahr, y = einwohner, group = von_bezirk, colour = bezirk_typ)) +
  geom_line() +
   theme_bw()

print(einwohner_entwicklung)


dichte_entwicklung <- ggplot(indikatoren_dichte, aes(x = jahr, y = dichte ,group = von_bezirk, colour = bezirk_typ)) +
  geom_line() +
  theme_bw()

print(dichte_entwicklung)

dichte_entwicklung_grouped <- ggplot(indikatoren_dichte, aes(x = jahr, y = dichte, group = bezirk_typ)) +
  geom_col()

print(dichte_entwicklung_grouped)

  
