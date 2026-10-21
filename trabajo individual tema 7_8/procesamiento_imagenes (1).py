# -*- coding: utf-8 -*-
"""
Tema 8 - Procesamiento de imágenes digitales como matrices numéricas (Python)
Guía de Evaluación (Examen Práctico, 20 puntos)
Imagen satelital: UNSAAC, Cusco (imagen_unsaac.png)

Requisitos: numpy, matplotlib, scikit-image
Uso: colocar imagen_unsaac.png en la carpeta de trabajo y ejecutar
     python procesamiento_imagenes.py
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")                      # guardar figuras sin ventana
import matplotlib.pyplot as plt
from skimage.io import imread, imsave
from skimage.color import rgb2gray
from skimage.filters import gaussian, threshold_otsu, threshold_isodata

ARCHIVO = "imagen_unsaac.png"

# ---------------------------------------------------------------
# PARTE B (B1 y B2): bloques de conversión sintáctica
# ---------------------------------------------------------------
# B1 (bloque original en Python). Indexación 0-based: [filas, columnas]
img_b = imread(ARCHIVO)[..., :3]           # se descarta el canal alfa
gray_b = rgb2gray(img_b)
crop_b = gray_b[10:150, 20:200]            # filas 10..149, columnas 20..199
print("B1 -> recorte:", crop_b.shape)

# B2 (traducción del bloque de R: isoblur + threshold 'auto')
img_b2 = imread(ARCHIVO)[..., :3] / 255.0
blur_b2 = gaussian(img_b2, sigma=2.5, channel_axis=-1)
bin_b2 = blur_b2 > threshold_otsu(blur_b2.ravel())  # umbral global sobre todos los valores
print("B2 -> píxeles en 1:", int(bin_b2.sum()))

# ---------------------------------------------------------------
# PARTE C: caso práctico espectral y metadatos
# ---------------------------------------------------------------
# 1. Carga y metadatos
img_raw = imread(ARCHIVO)
print("\n--- Metadatos ---")
print("Tipo de objeto :", type(img_raw).__name__, "| dtype:", img_raw.dtype)
print("Dimensiones    : alto =", img_raw.shape[0], "| ancho =", img_raw.shape[1],
      "| canales =", img_raw.shape[2])

img = img_raw[..., :3] / 255.0             # RGB en [0, 1] (como imager)

# 2. Matrices de los canales Rojo y Azul
R = img[:, :, 0]
G = img[:, :, 1]
B = img[:, :, 2]
print("Matriz R:", R.shape, "| media =", round(float(R.mean()), 4))
print("Matriz B:", B.shape, "| media =", round(float(B.mean()), 4))

# 3. Luminancia ITU-R BT.601 y su promedio
Y = 0.299 * R + 0.587 * G + 0.114 * B
print("Luminancia media Y (BT.601) =", round(float(Y.mean()), 4))

# 4. ROI central de 150 x 150 píxeles -> PNG
alto, ancho = img.shape[:2]
cy, cx = alto // 2, ancho // 2
roi = img[cy - 75:cy + 75, cx - 75:cx + 75, :]
print("ROI:", roi.shape)
imsave("roi_central_py.png", (roi * 255).round().astype(np.uint8))

# ---------------------------------------------------------------
# PARTE D: binarización e histograma compuesto a 300 DPI
# ---------------------------------------------------------------
# 1. Escala de grises + suavizado Gaussiano (sigma = 2)
gris = rgb2gray(img)
blur = gaussian(gris, sigma=2)

# 2. Umbralización automática
umbral_otsu = threshold_otsu(blur)         # Otsu
umbral_auto = threshold_isodata(blur)      # equivalente al 'auto' (2-medias) de imager
mascara = blur > umbral_otsu
print("\nUmbral Otsu            =", round(float(umbral_otsu), 4))
print("Umbral auto (isodata)  =", round(float(umbral_auto), 4))
print("Proporción de primer plano =", round(float(mascara.mean()) * 100, 2), "%")

# 3-4. Histograma del canal Rojo + umbral, guardado a 300 DPI
fig, ax = plt.subplots(figsize=(8, 6))
ax.hist(R.ravel(), bins=50, color="tomato", edgecolor="white")
ax.axvline(umbral_otsu, color="blue", linestyle="--", linewidth=2,
           label=f"Umbral Otsu = {umbral_otsu:.3f}")
ax.set_title("Histograma del canal Rojo con umbral óptimo")
ax.set_xlabel("Intensidad (0-1)")
ax.set_ylabel("Frecuencia")
ax.legend()
fig.savefig("histograma_compuesto_py.png", dpi=300, bbox_inches="tight")
plt.close(fig)

# Máscara binaria a 300 DPI
fig, ax = plt.subplots(figsize=(8, 6))
ax.imshow(mascara, cmap="gray")
ax.set_title("Segmentación por umbral (Otsu)")
ax.axis("off")
fig.savefig("mascara_binaria_py.png", dpi=300, bbox_inches="tight")
plt.close(fig)

print("\nArchivos generados: roi_central_py.png, histograma_compuesto_py.png, mascara_binaria_py.png")
