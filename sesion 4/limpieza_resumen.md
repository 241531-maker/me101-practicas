# Resumen de limpieza de datos — Tema 4

## 1. Dataset original

El conjunto de datos original contenía 8 estudiantes y 4 columnas: nombre, curso, nota y asistencia_pct. Se creó utilizando Python y las bibliotecas pandas y NumPy, y se guardó en el archivo `estudiantes.csv`.

## 2. Filas después de la limpieza

Después de la limpieza quedaron 6 estudiantes. Se eliminaron las 2 filas que tenían valores faltantes en la columna `nota`. Por lo tanto, el conjunto de datos final contiene 6 filas y 4 columnas.

## 3. Tratamiento de valores faltantes

La columna `nota` tenía 2 valores faltantes, por lo que se eliminaron las filas correspondientes. La columna `asistencia_pct` tenía 1 valor faltante entre las filas conservadas, que se reemplazó por el promedio de asistencia de los estudiantes restantes, equivalente a 77 %. Las columnas `nombre` y `curso` no tenían valores faltantes.

Finalmente, se verificó que el conjunto de datos limpio no tuviera valores faltantes y se exportó a un archivo CSV.
