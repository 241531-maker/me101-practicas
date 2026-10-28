library(dplyr)

# 1. Carga de datos multivariados (calidad ambiental, 5 estaciones)
df <- read.csv('datos_ambiental_evaluacion_tema9.csv', row.names = 1,
               stringsAsFactors = FALSE, fileEncoding = 'UTF-8')
num_cols <- c('pm10_ugm3', 'no2_ppb', 'ruido_db')
str(df)
colSums(is.na(df))   # PM10 tiene 1 valor faltante (Poroy)

# 2. Imputación de valores faltantes con la mediana
df_clean <- df[, num_cols]
for (col in num_cols) {
  df_clean[is.na(df_clean[, col]), col] <- median(df_clean[, col], na.rm = TRUE)
}
print(df_clean)

# 3. Estandarización Z-Score nativa con scale()
df_z <- as.data.frame(scale(df_clean))

# 4. Escalamiento Min-Max personalizado [0, 1]
min_max_scale <- function(x) { (x - min(x)) / (max(x) - min(x)) }
df_minmax <- as.data.frame(lapply(df_clean, min_max_scale))
rownames(df_minmax) <- rownames(df_clean)

cat("--- Matriz Estandarizada Z-Score en R ---\n")
print(round(df_z, 3))
cat("--- Matriz Min-Max en R ---\n")
print(round(df_minmax, 3))

library(pheatmap)
library(RColorBrewer)

# Paleta divergente azul-blanco-rojo
palette_div <- colorRampPalette(c("navy", "white", "firebrick3"))(100)

# Cortes simétricos para que el blanco quede centrado en 0
lim <- max(abs(df_z))
brks <- seq(-lim, lim, length.out = 101)

pheatmap(as.matrix(df_z),
         color = palette_div,
         breaks = brks,
         cluster_rows = FALSE,      # Sin clustering en esta hora
         cluster_cols = FALSE,
         display_numbers = TRUE,    # Mostrar valores en celdas
         number_format = "%.2f",
         fontsize_number = 9,
         border_color = "gray80",
         main = "Mapa de Calor de Indicadores Ambientales (Z-Score)")

# Pheatmap con Clustering Jerárquico Automático (Distancia Euclidiana y Método Ward.D2)
pheatmap(as.matrix(df_z),
         clustering_distance_rows = "euclidean",
         clustering_distance_cols = "euclidean",
         clustering_method = "ward.D2",
         color = colorRampPalette(c("purple", "black", "yellow"))(100),
         display_numbers = TRUE,
         number_format = "%.1f",
         main = "Heatmap con Clustering Jerárquico en R (Ward.D2)")

# Crear DataFrame de anotación para las filas (tipo_zona del CSV)
annotation_df <- data.frame(Zona = factor(df$tipo_zona))
rownames(annotation_df) <- rownames(df)

# Colores personalizados para las anotaciones
ann_colors <- list(
  Zona = c(Urbana = "#DC143C", Valle = "forestgreen", Altoandina = "royalblue")
)

lim <- max(abs(df_z))

pheatmap(as.matrix(df_z),
         annotation_row = annotation_df,
         annotation_colors = ann_colors,
         color = colorRampPalette(c("blue", "white", "red"))(100),
         breaks = seq(-lim, lim, length.out = 101),
         main = "Heatmap con Anotaciones de Filas en R")

# Matriz de correlación de Pearson entre los 3 indicadores
corr_matrix <- cor(df_clean)

# Exportación a PNG de alta resolución (300 DPI)
png("mapa_calor_correlacion_hd.png", width = 7, height = 6, units = "in", res = 300)
pheatmap(corr_matrix,
         display_numbers = TRUE,
         number_format = "%.3f",
         color = colorRampPalette(c("darkblue", "white", "darkred"))(100),
         breaks = seq(-1, 1, length.out = 101),
         main = "Matriz de Correlación Ambiental de Pearson")
dev.off()

cat("Imagen R exportada exitosamente como 'mapa_calor_correlacion_hd.png'.\n")


