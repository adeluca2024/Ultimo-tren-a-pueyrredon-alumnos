# Último tren a Pueyrredón

Aventura educativa para practicar comandos básicos de GNU/Linux y Bash en
Debian 11 y Debian 12.

## Capítulos disponibles

Esta entrega corresponde al **módulo 2** de Computación Aplicada e incluye los
capítulos 1, 2 y 3.

Los próximos capítulos se publicarán a medida que avance la cursada. Para
recibirlos sin perder la partida, ejecutá `git pull` dentro del repositorio.

El lanzador `jugar.sh` carga automáticamente los archivos disponibles en
`capitulos/`. No es necesario modificarlo al recibir una nueva entrega.

## Requisitos

- Bash 5 o posterior.
- Herramientas estándar de Debian: `coreutils` y `util-linux`.
- Terminal con soporte ANSI opcional.

## Descargar y jugar

```bash
git clone https://github.com/adeluca2024/Ultimo-tren-a-pueyrredon-alumnos.git
cd Ultimo-tren-a-pueyrredon-alumnos
./jugar.sh
```

Comandos propios del juego:

- `ayuda`: muestra los comandos habilitados.
- `objetivo`: repite la misión actual.
- `pista`: ofrece ayuda gradual.
- `salir`: guarda el avance y termina.

Para reiniciar completamente la partida:

```bash
./jugar.sh --reiniciar
```

## Actualizar el juego

Desde el directorio del repositorio:

```bash
git pull
./jugar.sh
```

El progreso se guarda fuera del repositorio, en:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/la-terminal-perdida/
```

Por eso, ejecutar `git pull` no borra la partida.

## Seguridad

El juego interpreta solamente una lista limitada de comandos y restringe las
rutas al mundo ficticio creado para la actividad. No ejecuta los comandos que
todavía no fueron habilitados por la historia.

Autor: Lic. Adolfo Deluca.
