# Resumen del procesamiento de imágenes (Tema 7)

## a) Figuras dibujadas y colores

Creé una imagen de 120×120 píxeles con fondo crema (255, 244, 200) y dibujé tres figuras:

- Un **rectángulo rojo** (220, 50, 50) en la esquina superior izquierda.
- Un **círculo azul** (40, 90, 200) en la esquina inferior derecha.
- Una **línea verde** (30, 140, 60) en la parte inferior izquierda.

## b) Comparación de escala de grises: `.convert('L')` vs. `rgb2gray()`

Usé el píxel de fondo en la posición (100, 20).

- Pillow con `.convert('L')` dio **242**.
- scikit-image con `color.rgb2gray()` (multiplicado por 255) dio **243.165**.

No son iguales, pero la diferencia es muy pequeña. Se debe a que cada librería usa pesos distintos para rojo, verde y azul, y a que Pillow redondea a un número entero mientras que scikit-image deja decimales.

## c) Umbral de Otsu

El umbral de Otsu que obtuve fue **0.435** (en escala de 0 a 1). Al binarizar la imagen con ese umbral, el **66.5 %** de los píxeles quedó por encima de él (valor `True`), y el resto quedó por debajo.
