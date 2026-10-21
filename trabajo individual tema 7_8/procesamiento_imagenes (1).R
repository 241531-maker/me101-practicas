# ==============================================================
# Tema 8 - Procesamiento de imágenes digitales como matrices numéricas (R)
# Guía de Evaluación (Examen Práctico, 20 puntos)
# Imagen satelital: UNSAAC, Cusco (imagen_unsaac.png)
#
# Paquetes: imager, magick
# Uso: colocar imagen_unsaac.png en el directorio de trabajo (getwd())
#      y ejecutar el script completo en RStudio.
# ==============================================================
library(imager)
library(magick)

archivo <- "imagen_unsaac.png"

# --------------------------------------------------------------
# PARTE B - B1: traducción a R del bloque de Python
#   gray = rgb2gray(img); crop = gray[10:150, 20:200]
#   Python usa índices 0-based [filas, columnas]; R usa 1-based [x, y]
#   filas 10..149 -> y = 11..150 ; columnas 20..199 -> x = 21..200
# --------------------------------------------------------------
img_b <- load.image(archivo)
if (spectrum(img_b) == 4) img_b <- imsub(img_b, cc <= 3)   # descartar alfa
gray_b <- grayscale(img_b)
crop_b <- imsub(gray_b, x %inrange% c(21, 200), y %inrange% c(11, 150))
dim(crop_b)   # 180 x 140 x 1 x 1  (ancho x alto)

# --------------------------------------------------------------
# PARTE C - Caso práctico espectral y metadatos
# --------------------------------------------------------------
# 1. Carga y metadatos
img <- load.image(archivo)
cat("Clase    :", class(img), "\n")
cat("Dim [X,Y,Z,C]:", dim(img), "\n")
cat("Canales  :", spectrum(img), "\n")
print(image_info(image_read(archivo)))      # metadatos con magick

# La imagen trae canal alfa (4 canales): se conservan solo R, G, B
if (spectrum(img) == 4) img <- imsub(img, cc <= 3)

# 2. Matrices numéricas de los canales Rojo y Azul
R <- img[, , 1, 1]
G <- img[, , 1, 2]
B <- img[, , 1, 3]
cat("Media R:", mean(R), "| Media B:", mean(B), "\n")

# 3. Luminancia ITU-R BT.601 y su promedio
Y <- 0.299 * R + 0.587 * G + 0.114 * B
cat("Luminancia media Y (BT.601):", mean(Y), "\n")

# 4. ROI central de 150 x 150 píxeles -> PNG
cx <- width(img)  %/% 2
cy <- height(img) %/% 2
roi <- imsub(img, x %inrange% c(cx - 74, cx + 75),
                  y %inrange% c(cy - 74, cy + 75))
dim(roi)   # 150 x 150 x 1 x 3
save.image(roi, "roi_central_R.png")

# --------------------------------------------------------------
# PARTE D - Binarización e histograma compuesto a 300 DPI
# --------------------------------------------------------------
# 1. Escala de grises + suavizado Gaussiano (sigma = 2)
gris <- grayscale(img)
blur <- isoblur(gris, sigma = 2)

# 2. Umbralización automática ('auto' de imager = 2-medias, análogo a Otsu)
bin <- threshold(blur, "auto")

# Valor numérico del umbral: punto medio de los dos centros de kmeans
set.seed(123)
km <- kmeans(as.vector(blur), centers = 2)
umbral <- mean(km$centers)
cat("Umbral óptimo (2-medias):", umbral, "\n")
cat("Proporción de primer plano:", mean(bin) * 100, "%\n")

# 3-4. Histograma del canal Rojo + umbral, guardado a 300 DPI (8 x 6 pulgadas)
png("histograma_compuesto_R.png", width = 8, height = 6, units = "in", res = 300)
hist(as.vector(R), breaks = 50, col = "tomato", border = "white",
     main = "Histograma del canal Rojo con umbral óptimo",
     xlab = "Intensidad (0-1)", ylab = "Frecuencia")
abline(v = umbral, col = "blue", lwd = 2, lty = 2)
legend("topright", legend = sprintf("Umbral = %.3f", umbral),
       col = "blue", lty = 2, lwd = 2, bty = "n")
dev.off()

# Máscara binaria a 300 DPI
png("mascara_binaria_R.png", width = 8, height = 6, units = "in", res = 300)
plot(bin, main = "Segmentación por umbral")
dev.off()

cat("Archivos generados: roi_central_R.png, histograma_compuesto_R.png, mascara_binaria_R.png\n")
