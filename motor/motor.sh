#!/usr/bin/env bash

readonly JUEGO_ID="la-terminal-perdida"
readonly VERSION_MOTOR="2.0-modular"
readonly DATA_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/${JUEGO_ID}"
readonly MUNDO="${DATA_BASE}/mundo"
readonly PROGRESO="${DATA_BASE}/progreso"
readonly DIRECTORIO_CAPITULOS="$RAIZ_JUEGO/capitulos"

NIVEL=1
ULTIMO_CAPITULO=0
DIRECTORIO_ACTUAL=""
ANCHO_TEXTO=100
SALIR_JUEGO=0

declare -A ESTADO=()

if [[ -t 1 && "${NO_COLOR:-}" == "" ]]; then
    readonly C_TITULO=$'\033[1;36m'
    readonly C_OK=$'\033[1;32m'
    readonly C_ERROR=$'\033[1;31m'
    readonly C_RESET=$'\033[0m'
else
    readonly C_TITULO=""
    readonly C_OK=""
    readonly C_ERROR=""
    readonly C_RESET=""
fi

if [[ -t 1 ]]; then
    columnas_terminal=$(tput cols 2>/dev/null || printf '100')
    if [[ "$columnas_terminal" =~ ^[0-9]+$ ]] && (( columnas_terminal < ANCHO_TEXTO + 2 )); then
        ANCHO_TEXTO=$(( columnas_terminal > 42 ? columnas_terminal - 2 : 40 ))
    fi
fi

decir() { printf '%s\n' "$*" | command fold -s -w "$ANCHO_TEXTO"; }
titulo() { printf '\n%s%s%s\n\n' "$C_TITULO" "$*" "$C_RESET"; }
error() { printf '%sError:%s %s\n' "$C_ERROR" "$C_RESET" "$*" >&2; }

nombre_funcion_capitulo() {
    printf 'capitulo_%02d_%s\n' "$1" "$2"
}

ejecutar_hook() {
    local numero=$1 hook=$2 funcion
    shift 2
    funcion=$(nombre_funcion_capitulo "$numero" "$hook")
    if declare -F "$funcion" >/dev/null; then
        "$funcion" "$@"
    else
        return 1
    fi
}

cargar_capitulos() {
    local archivo base numero funcion
    shopt -s nullglob
    for archivo in "$DIRECTORIO_CAPITULOS"/[0-9][0-9]_*.sh; do
        base=$(basename -- "$archivo")
        numero=${base%%_*}
        source "$archivo"
        if (( 10#$numero > ULTIMO_CAPITULO )); then
            ULTIMO_CAPITULO=$((10#$numero))
        fi
    done
    shopt -u nullglob
    (( ULTIMO_CAPITULO > 0 )) || { error "no hay capítulos instalados."; return 1; }
    for ((numero=1; numero<=ULTIMO_CAPITULO; numero++)); do
        funcion=$(nombre_funcion_capitulo "$numero" iniciar)
        if ! declare -F "$funcion" >/dev/null; then
            error "falta el capítulo $numero; instalá las entregas en orden."
            return 1
        fi
    done
}

guardar_progreso() {
    mkdir -p -- "$DATA_BASE"
    printf '%s\n' "$NIVEL" > "$PROGRESO"
}

cargar_progreso() {
    if [[ -f "$PROGRESO" ]]; then IFS= read -r NIVEL < "$PROGRESO"; fi
    [[ "$NIVEL" =~ ^[1-9][0-9]*$ ]] || NIVEL=1
}

crear_archivo_si_falta() {
    local ruta=$1 contenido=$2
    [[ -e "$ruta" ]] || printf '%s\n' "$contenido" > "$ruta"
}

ruta_canonica_existente() { realpath -e -- "$1" 2>/dev/null; }

ruta_canonica_nueva() {
    local padre nombre padre_real
    padre=$(dirname -- "$1")
    nombre=$(basename -- "$1")
    padre_real=$(realpath -e -- "$padre" 2>/dev/null) || return 1
    printf '%s/%s\n' "$padre_real" "$nombre"
}

esta_en_mundo() { [[ "$1" == "$MUNDO" || "$1" == "$MUNDO/"* ]]; }

resolver_existente_seguro() {
    local base ruta
    [[ "$1" == /* ]] && base=$1 || base="$DIRECTORIO_ACTUAL/$1"
    ruta=$(ruta_canonica_existente "$base") || return 1
    esta_en_mundo "$ruta" || return 1
    printf '%s\n' "$ruta"
}

resolver_nuevo_seguro() {
    local base ruta
    [[ "$1" == /* ]] && base=$1 || base="$DIRECTORIO_ACTUAL/$1"
    ruta=$(ruta_canonica_nueva "$base") || return 1
    esta_en_mundo "$ruta" || return 1
    printf '%s\n' "$ruta"
}

comando_pwd() {
    (( $# == 0 )) || { error "pwd no necesita argumentos."; return; }
    printf '%s\n' "${DIRECTORIO_ACTUAL#"$MUNDO"}"
}

comando_ls() {
    local opcion="" objetivo="." ruta
    (( $# <= 2 )) || { error "uso: ls [opción] [ruta]"; return; }
    if (( $# >= 1 )); then
        if [[ "$1" == -* ]]; then
            case "$1" in -a|-l|-la|-al) opcion=$1 ;; *) error "opción de ls no habilitada: $1"; return ;; esac
            (( $# == 2 )) && objetivo=$2
        else
            (( $# == 1 )) || { error "uso: ls [opción] [ruta]"; return; }
            objetivo=$1
        fi
    fi
    ruta=$(resolver_existente_seguro "$objetivo") || { error "ruta inexistente o fuera del mundo."; return; }
    if [[ -n "$opcion" ]]; then command ls "$opcion" -- "$ruta"; else command ls -- "$ruta"; fi
    ejecutar_hook "$NIVEL" despues_ls "$opcion" "$ruta"
}

comando_cd() {
    local ruta
    (( $# == 1 )) || { error "uso: cd directorio"; return; }
    ruta=$(resolver_existente_seguro "$1") || { error "directorio inexistente o fuera del mundo."; return; }
    [[ -d "$ruta" ]] || { error "no es un directorio: $1"; return; }
    DIRECTORIO_ACTUAL=$ruta
}

comando_cat() {
    local ruta
    (( $# == 1 )) || { error "uso: cat archivo"; return; }
    ruta=$(resolver_existente_seguro "$1") || { error "archivo inexistente o fuera del mundo."; return; }
    [[ -f "$ruta" ]] || { error "no es un archivo regular: $1"; return; }
    command fold -s -w "$ANCHO_TEXTO" -- "$ruta" \
        || { error "no se pudo leer el archivo; revisá sus permisos."; return; }
    ejecutar_hook "$NIVEL" despues_cat "$ruta"
}

comando_mkdir_o_touch() {
    local comando=$1 ruta
    shift
    (( $# == 1 )) || { error "uso: $comando nombre"; return; }
    ruta=$(resolver_nuevo_seguro "$1") || { error "destino inválido o fuera del mundo."; return; }
    command "$comando" -- "$ruta"
}

comando_cp_o_mv() {
    local comando=$1 origen destino
    shift
    (( $# == 2 )) || { error "uso: $comando origen destino"; return; }
    origen=$(resolver_existente_seguro "$1") || { error "origen inexistente o fuera del mundo."; return; }
    [[ ! -d "$origen" ]] || { error "solo se manipulan archivos."; return; }
    if ! destino=$(resolver_existente_seguro "$2"); then
        destino=$(resolver_nuevo_seguro "$2") || { error "destino inválido o fuera del mundo."; return; }
    fi
    command "$comando" -- "$origen" "$destino"
}

mostrar_ayuda() {
    decir "Comandos habilitados:"
    decir "  pwd"
    decir "  ls [opción] [ruta]      opciones: -a, -l, -la, -al"
    decir "  cd [directorio]"
    decir "  cat archivo"
    ejecutar_hook "$NIVEL" ayuda
    decir "  objetivo | pista | ayuda | salir"
}

mostrar_objetivo() { ejecutar_hook "$NIVEL" objetivo; }
mostrar_pista() { ejecutar_hook "$NIVEL" pista; }

iniciar_nivel() {
    if (( NIVEL > ULTIMO_CAPITULO )); then
        if (( NIVEL == 10 )) && declare -F capitulo_09_final >/dev/null; then
            capitulo_09_final
            return
        fi
        titulo "FIN DE LOS CAPÍTULOS DISPONIBLES"
        decir "Tu progreso quedó guardado. Cuando se publique la próxima entrega, ejecutá git pull y volvé a iniciar el juego."
        return
    fi
    ejecutar_hook "$NIVEL" iniciar
    decir ""
    mostrar_objetivo
}

avanzar_nivel() {
    ejecutar_hook "$NIVEL" cierre
    ejecutar_hook "$NIVEL" transicion
    NIVEL=$((NIVEL + 1))
    guardar_progreso
    iniciar_nivel
}

evaluar_nivel() {
    ejecutar_hook "$NIVEL" evaluar || true
}

procesar_comando() {
    local entrada=$1
    local -a partes
    if [[ "$entrada" == *'$('* || "$entrada" == *'`'* || "$entrada" == *';'* || "$entrada" == *'<'* ]]; then
        error "esa sintaxis no está habilitada en este capítulo."
        return
    fi
    if ejecutar_hook "$NIVEL" procesar_entrada "$entrada"; then
        evaluar_nivel
        return
    fi
    read -r -a partes <<< "$entrada"
    (( ${#partes[@]} > 0 )) || return
    case "${partes[0]}" in
        pwd) comando_pwd "${partes[@]:1}" ;;
        ls) comando_ls "${partes[@]:1}" ;;
        cd) comando_cd "${partes[@]:1}" ;;
        cat) comando_cat "${partes[@]:1}" ;;
        mkdir|touch|cp|mv)
            (( NIVEL >= 2 )) || { error "${partes[0]} todavía no está habilitado."; return; }
            case "${partes[0]}" in
                mkdir|touch) comando_mkdir_o_touch "${partes[0]}" "${partes[@]:1}" ;;
                cp|mv) comando_cp_o_mv "${partes[0]}" "${partes[@]:1}" ;;
            esac
            ;;
        ayuda|help) mostrar_ayuda ;;
        objetivo) mostrar_objetivo ;;
        pista) mostrar_pista ;;
        salir|exit) guardar_progreso; decir "Partida guardada."; SALIR_JUEGO=1 ;;
        *)
            if ! ejecutar_hook "$NIVEL" comando "${partes[@]}"; then
                error "comando no habilitado: ${partes[0]}. Escribí ayuda."
            fi
            ;;
    esac
    evaluar_nivel
    return 0
}

reiniciar() {
    case "$DATA_BASE" in
        "${HOME}/.local/share/${JUEGO_ID}"|"${XDG_DATA_HOME:-}/""${JUEGO_ID}")
            for ((numero=1; numero<=ULTIMO_CAPITULO; numero++)); do
                ejecutar_hook "$numero" limpiar
            done
            [[ ! -d "$DATA_BASE" ]] || command rm -rf -- "$DATA_BASE"
            decir "Partida reiniciada."
            ;;
        *) error "ruta de datos inesperada; no se reinició la partida."; return 1 ;;
    esac
}

ejecutar_juego() {
    cargar_capitulos || return 1
    case "${1:-}" in
        --reiniciar) reiniciar; return ;;
        --version) decir "Último tren a Pueyrredón $VERSION_MOTOR"; return ;;
        "") ;;
        *) error "opción desconocida: $1"; decir "Uso: ./jugar.sh [--reiniciar|--version]"; return 2 ;;
    esac

    for ((numero=1; numero<=ULTIMO_CAPITULO; numero++)); do
        ejecutar_hook "$numero" preparar
    done
    cargar_progreso
    titulo "ÚLTIMO TREN A PUEYRREDÓN — versión $VERSION_MOTOR"
    decir "Una aventura de terminal, terror porteño y trámites fuera de horario."
    iniciar_nivel
    (( NIVEL <= ULTIMO_CAPITULO )) || return

    while (( SALIR_JUEGO == 0 && NIVEL <= ULTIMO_CAPITULO )); do
        if ejecutar_hook "$NIVEL" antes_prompt; then
            (( SALIR_JUEGO == 0 && NIVEL <= ULTIMO_CAPITULO )) || break
        fi
        printf '\n%s@microcentro:%s$ ' "${USER:-estudiante}" "${DIRECTORIO_ACTUAL#"$MUNDO"}"
        if ! IFS= read -r entrada; then decir ""; guardar_progreso; break; fi
        decir ""
        procesar_comando "$entrada"
    done
}
