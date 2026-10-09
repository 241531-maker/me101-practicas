# Resumen de imágenes sintéticas (Tema 6)

## (a) Dimensiones (shape)
- Imagen en escala de grises: `(5, 5)`, un degradado horizontal de 0 a 255, dtype `float64`.
- Imagen RGB: `(4, 4, 3)`, dtype `uint8`, dividida en dos mitades verticales.

## (b) Colores elegidos y luminosidad
| Mitad | Color (R, G, B) | Luminosidad ponderada |
|---|---|---|
| Izquierda | Rojo (200, 50, 50) | 94.85 |
| Derecha | Azul (50, 100, 200) | 96.45 |

La luminosidad se calculó con 0.299·R + 0.587·G + 0.114·B. En R salió igual que en Python.

## (c) Umbral de binarización
Usé umbral = 95. Con 128 toda la imagen quedaba en 0, porque ambos valores de luminosidad están por debajo. El 95 queda entre 94.85 y 96.45, así que separa las dos mitades.
