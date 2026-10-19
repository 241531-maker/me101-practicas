# ==============================================================================
#  PROCESAMIENTO DE IMÁGENES EN R  (equivalente al tutorial Python + OpenCV)
# ------------------------------------------------------------------------------
#  Cómo usarlo en RStudio:
#   1. Guarda este archivo junto a tu imagen (por ejemplo Ganeshji.webp)
#      o cambia la variable `ruta_imagen` del PASO 0.
#   2. Session > Set Working Directory > To Source File Location
#   3. Ejecuta línea por línea con Ctrl+Enter, o un bloque entero seleccionándolo.
#   4. Cada PASO produce un gráfico en el panel "Plots".
#
#  Librerías:
#   - imager : operaciones sobre píxeles (resize, blur, bordes, morfología...)
#   - magick : lectura de formatos como .webp (usa ImageMagick)
#
#  Equivalencias Python/OpenCV -> R:
#   cv2.imread / cvtColor ..... magick::image_read + imager::magick2cimg
#   cv2.resize ................ imager::imresize
#   cv2.getRotationMatrix2D ... imager::imrotate
#   cv2.warpAffine (traslación) imager::imshift
#   cv2.warpAffine (shear) .... imager::imwarp
#   cv2.normalize ............. min-max manual por canal
#   cv2.GaussianBlur .......... imager::isoblur
#   cv2.medianBlur ............ imager::medianblur
#   cv2.bilateralFilter ....... imager::blur_bilateral
#   cv2.Sobel / cv2.Canny ..... imager::imgradient / imager::cannyEdges
#   cv2.dilate / cv2.erode .... imager::dilate_square / imager::erode_square
# ==============================================================================


# ------------------------------------------------------------------------------
# PASO 0. Instalar/cargar librerías y leer la imagen
# ------------------------------------------------------------------------------
paquetes <- c("imager", "magick")
faltan   <- paquetes[!paquetes %in% rownames(installed.packages())]
if (length(faltan) > 0) install.packages(faltan)

library(imager)
library(magick)

# Cambia esta ruta por la de tu imagen
ruta_imagen <- "gato_de_colores.jpg"

if (file.exists(ruta_imagen)) {
  # magick lee .webp (si tu ImageMagick lo soporta) y lo pasamos a imager
  img <- magick2cimg(image_read(ruta_imagen))
} else {
  message("No se encontró '", ruta_imagen, "'. Se usa una imagen de ejemplo (parrots).")
  img <- load.example("parrots")
}

# Si la imagen trae canal alfa (4 canales), lo quitamos para trabajar en RGB
if (spectrum(img) == 4) img <- imsub(img, cc %in% 1:3)

# Función auxiliar: devuelve (alto, ancho, canales) como en `image.shape` de Python
forma <- function(im) paste0("(", height(im), ", ", width(im), ", ", spectrum(im), ")")

cat("Forma de la imagen original (alto, ancho, canales):", forma(img), "\n")
# Nota: en imager los valores de píxel están en [0, 1], no en [0, 255].


# ------------------------------------------------------------------------------
# PASO 1. Redimensionamiento (zoom x3 con cúbica, reducción a 1/3 con "área")
# ------------------------------------------------------------------------------
# interpolation en imager: 1 = vecino más cercano, 2 = promedio móvil (similar
# a INTER_AREA, recomendado al reducir), 3 = lineal, 5 = cúbica, 6 = Lanczos.
escala_1 <- 3.0
escala_2 <- 1 / 3.0

img_zoom   <- imresize(img, scale = escala_1, interpolation = 5)   # INTER_CUBIC
img_scaled <- imresize(img, scale = escala_2, interpolation = 2)   # INTER_AREA

par(mfrow = c(1, 3), mar = c(1, 1, 3, 1))
plot(img,        axes = FALSE, main = paste("Original\nShape:", forma(img)))
plot(img_zoom,   axes = FALSE, main = paste("Zoomed\nShape:",   forma(img_zoom)))
plot(img_scaled, axes = FALSE, main = paste("Scaled\nShape:",   forma(img_scaled)))


# ------------------------------------------------------------------------------
# PASO 2. Rotación (30 grados respecto al centro, escala 1)
# ------------------------------------------------------------------------------
# imrotate gira alrededor del centro por defecto y rellena con negro (boundary 0).
# Si el sentido te sale al revés de lo que esperas, cambia el signo del ángulo.
angulo <- 30
img_rot <- imrotate(img, angle = angulo, interpolation = 1, boundary = 0)

par(mfrow = c(1, 2), mar = c(1, 1, 3, 1))
plot(img,     axes = FALSE, main = "Original Image")
plot(img_rot, axes = FALSE, main = paste("Image Rotation:", angulo, "°"))


# ------------------------------------------------------------------------------
# PASO 3. Traslación (tx = 100, ty = 70 píxeles)
# ------------------------------------------------------------------------------
# Equivale a la matriz [[1,0,tx],[0,1,ty]] de warpAffine. boundary_conditions = 0
# rellena con negro lo que queda vacío (si fuera 2 sería circular).
tx <- 100
ty <- 70
img_trasl <- imshift(img, delta_x = tx, delta_y = ty, boundary_conditions = 0)

par(mfrow = c(1, 2), mar = c(1, 1, 3, 1))
plot(img,       axes = FALSE, main = "Original Image")
plot(img_trasl, axes = FALSE, main = paste0("Image Translation (", tx, ", ", ty, ")"))


# ------------------------------------------------------------------------------
# PASO 4. Deslizamiento / Shearing (shearX = -0.15, shearY = 0)
# ------------------------------------------------------------------------------
# Matriz de OpenCV:  x' = x + shearX * y ;  y' = shearY * x + y
# imwarp trabaja mejor "hacia atrás": para cada píxel de salida (x', y') busca
# de dónde sale en la entrada. Para shearY = 0 la inversa es x = x' - shearX*y'.
shearX <- -0.15
shearY <- 0

mapa_inverso <- function(x, y) {
  # inversa exacta de la matriz [[1, shearX], [shearY, 1]]
  det <- 1 - shearX * shearY
  list(x = (x - shearX * y) / det,
       y = (y - shearY * x) / det)
}

img_shear <- imwarp(img, map = mapa_inverso, direction = "backward",
                    coordinates = "absolute", interpolation = "linear",
                    boundary = "dirichlet")

par(mfrow = c(1, 2), mar = c(1, 1, 3, 1))
plot(img,       axes = FALSE, main = "Original Image")
plot(img_shear, axes = FALSE, main = "Sheared Image")


# ------------------------------------------------------------------------------
# PASO 5. Normalización min-max por canal (rango 0 a 1)
# ------------------------------------------------------------------------------
# Se normaliza cada canal por separado (como cv2.normalize + cv2.merge).
normalizar_minmax <- function(canal) {
  rango <- range(canal)
  if (diff(rango) == 0) return(canal * 0)
  (canal - rango[1]) / diff(rango)
}

canales      <- imsplit(img, axis = "c")              # lista: R, G, B
canales_norm <- lapply(canales, normalizar_minmax)
img_norm     <- imappend(canales_norm, axis = "c")    # equivale a cv2.merge

# Matriz del primer canal (t() para que filas = alto y columnas = ancho, como NumPy)
matriz_canal1 <- t(as.matrix(canales_norm[[1]]))
print(round(matriz_canal1[1:6, 1:6], 7))              # esquina superior izquierda

# Interpretación: valor * 255 devuelve la intensidad en la escala clásica 0-255
cat("Valor máximo del canal 1 x 255 =", round(max(matriz_canal1) * 255), "\n")
cat("Ejemplo: 0.0745098 * 255 =", round(0.0745098 * 255), " | 0.00392157 * 255 =",
    round(0.00392157 * 255), "\n")

par(mfrow = c(1, 1), mar = c(1, 1, 3, 1))
plot(img_norm, axes = FALSE, main = "Normalized Image")


# ------------------------------------------------------------------------------
# PASO 6. Detección de bordes (suavizado gaussiano -> gradiente Sobel -> Canny)
# ------------------------------------------------------------------------------
gris <- grayscale(img)

# 6.1 Suavizado gaussiano previo (elimina ruido)
gris_suave <- isoblur(gris, sigma = 1.5)

# 6.2 Gradiente (magnitud) tipo Sobel
grad     <- imgradient(gris_suave, "xy")
magnitud <- sqrt(grad$x^2 + grad$y^2)

# 6.3 Canny (supresión de no máximos + histéresis). Los umbrales se calculan
#     automáticamente; puedes fijarlos con t1 y t2, por ejemplo:
#     bordes <- cannyEdges(gris, t1 = 0.1, t2 = 0.3, sigma = 2)
bordes <- cannyEdges(gris, sigma = 2)

par(mfrow = c(1, 3), mar = c(1, 1, 3, 1))
plot(img,      axes = FALSE, main = "Original Image")
plot(magnitud, axes = FALSE, main = "Gradiente (Sobel)")
plot(bordes,   axes = FALSE, main = "Image Edges (Canny)")


# ------------------------------------------------------------------------------
# PASO 7. Desenfoque (Gaussiano, Mediana, Bilateral)
# ------------------------------------------------------------------------------
img_gauss <- isoblur(img, sigma = 1)        # GaussianBlur con núcleo pequeño (~3x3)
img_med   <- medianblur(img, n = 3)         # medianBlur con vecindario 3x3

# Bilateral: suaviza conservando bordes (puede tardar con imágenes grandes)
img_bilat <- tryCatch(
  blur_bilateral(img, guide = img, sigma_s = 3, sigma_r = 0.1),
  error = function(e) { message("blur_bilateral no disponible: ", e$message); img }
)

par(mfrow = c(2, 2), mar = c(1, 1, 3, 1))
plot(img,       axes = FALSE, main = "Original Image")
plot(img_gauss, axes = FALSE, main = "Gaussian Blur")
plot(img_med,   axes = FALSE, main = "Median Blur")
plot(img_bilat, axes = FALSE, main = "Bilateral Filter")


# ------------------------------------------------------------------------------
# PASO 8. Procesamiento morfológico (dilatación, erosión, apertura, cierre)
# ------------------------------------------------------------------------------
# Se trabaja en escala de grises con un núcleo de 3x3 (np.ones((3,3))).
tam <- 3

# iterations = 2 en OpenCV -> aplicar la operación dos veces
dilatada <- dilate_square(dilate_square(gris, tam), tam)
erosionada <- erode_square(erode_square(gris, tam), tam)

# Apertura = erosión seguida de dilatación (quita ruido pequeño)
apertura <- dilate_square(erode_square(gris, tam), tam)
# Cierre = dilatación seguida de erosión (rellena huecos pequeños)
cierre   <- erode_square(dilate_square(gris, tam), tam)

par(mfrow = c(2, 2), mar = c(1, 1, 3, 1))
plot(dilatada,   axes = FALSE, main = "Dilated Image")
plot(erosionada, axes = FALSE, main = "Eroded Image")
plot(apertura,   axes = FALSE, main = "Opening")
plot(cierre,     axes = FALSE, main = "Closing")


# ------------------------------------------------------------------------------
# EXTRA. Guardar resultados en disco (opcional)
# ------------------------------------------------------------------------------
# save.image(img_rot,   "imagen_rotada.png")
# save.image(img_shear, "imagen_shear.png")
# save.image(bordes,    "bordes_canny.png")

# Restablecer la ventana gráfica
par(mfrow = c(1, 1))

