#!/usr/bin/env bash

set -u

readonly RAIZ_JUEGO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly MOTOR="$RAIZ_JUEGO/motor/motor.sh"

if [[ ! -r "$MOTOR" ]]; then
    printf 'Error: no se encontró el motor del juego.\n' >&2
    exit 1
fi

source "$MOTOR"
ejecutar_juego "$@"
