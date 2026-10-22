# LeafReader: primera prueba

## Cambios

- Icono de una hoja marfil sobre fondo verde, en `icon.jpg`.
- Nombre en Homebrew Menu y en la ventana: LeafReader.
- Salida de Switch fija: `LeafReader.nro`.
- Se conserva `/switch/ebookViewerNX/` para libros, cache y progreso.
- Se conservan los creditos del proyecto original.

## Estado del entorno

Codigo y submodulos descargados. Icono verificado como JPEG de 256 x 256.
Compilacion de Switch completada en GitHub Actions; pendiente la prueba en consola.
Este equipo Windows aun no tiene devkitPro ni WSL instalados.
El cambio del icono requiere reconstruir el NRO;
copiar `icon.jpg` a la SD no cambia el icono de un ejecutable existente.

## Compilacion

La ruta principal es GitHub Actions: abrir **Actions > Build LeafReader for Switch**,
ejecutar el workflow y descargar el artifact de una ejecucion exitosa. Incluye el
NRO, su checksum y las versiones del entorno.

Primera compilacion verificada: [Actions run 39717521100](https://github.com/ConspiraciXn/LeafReader/actions/runs/39717521100),
commit `a4667820d0c9e76241f853ec44112320479113ad`. Se comprobo el checksum SHA256,
la cabecera NRO0, el nombre LeafReader en NACP y que el JPEG incrustado coincide
con `icon.jpg`. El ejecutable ocupa 46,978,293 bytes. Estas comprobaciones no
sustituyen la prueba de arranque y lectura en la Switch.

### Alternativa local

Preparar un entorno Linux con devkitPro, libnx, las bibliotecas SDL2 y las
dependencias de MuPDF. Revisar los scripts heredados en `ubuntu/` antes de
instalar: contienen opciones que omiten la verificacion de firmas de paquetes.
Con las dependencias instaladas, compilar MuPDF con `ubuntu/build-mupdf.sh`
y la aplicacion con `ubuntu/build.sh`.

## Prueba en Switch cuando exista el ejecutable

1. Copiar `LeafReader.nro` a `/switch/LeafReader/` en la SD.
2. Abrir Homebrew Menu y comprobar el nombre LeafReader y el icono de hoja.
3. Iniciar la app y abrir un libro de `/switch/ebookViewerNX/`.
4. Pasar paginas, volver a la biblioteca y reabrir el libro para comprobar el progreso.

## Fuente del icono

Original: `assets/leafreader-icon-source.png`. Generado con la herramienta
integrada image_gen y reducido a JPEG RGB de 256 x 256 para el NRO.

Prompt: A single elegant botanical leaf as the entire icon symbol. One large
ivory-white leaf silhouette with a gently curving stem and one restrained central
vein, pointing diagonally upward, on a full-bleed forest green background with a
subtle emerald gradient. Calm refined minimal reading-app aesthetic. Original
clean silhouette, legible at 64 pixels, balanced padding. No book, extra leaves,
lettering, logos, border, rounded outer corners, mockup or watermark.
