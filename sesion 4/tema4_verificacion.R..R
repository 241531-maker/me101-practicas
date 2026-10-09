#----script 1 -------------------------------------------------------------------
library(tidyverse)

# Completa: lee el CSV
df <- read_csv("estudiantes.csv")

# Completa: muestra la estructura y los NA por columna
glimpse(df)
colSums(is.na(df))

#----script 2 -------------------------------------------------------------------
# Completa: aplica drop_na() y replace_na() encadenados con el pipe
df_limpio <- df %>%
  drop_na(nota) %>%
  mutate(asistencia_pct = replace_na(asistencia_pct, mean(asistencia_pct, na.rm = TRUE)))

# Completa: verifica que no queden NA
colSums(is.na(df_limpio))
sum(is.na(df_limpio))   # debe dar 0

#----script 3 -------------------------------------------------------------------
# Completa: promedio de nota agrupado por curso, estilo dplyr
promedio_por_curso <- df_limpio %>%
  group_by(curso) %>%
  summarise(promedio_nota = mean(nota))

print(promedio_por_curso)

##----script 4 -------------------------------------------------------------------
write_csv(df_limpio, "estudiantes_limpio_R.csv")
