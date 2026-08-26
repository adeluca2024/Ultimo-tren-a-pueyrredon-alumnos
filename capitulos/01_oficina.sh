#!/usr/bin/env bash

capitulo_01_preparar() {
    mkdir -p -- "$MUNDO/nivel1/piso_17/oficina" "$MUNDO/nivel1/piso_17/pasillo"
    crear_archivo_si_falta "$MUNDO/nivel1/piso_17/oficina/reloj" \
        "17:42. El segundero está quieto. Debajo del vidrio alguien escribió: NO MIRES LA TORRE."
    crear_archivo_si_falta "$MUNDO/nivel1/piso_17/oficina/foto" \
        "Es una selfie que te sacaste en Plaza San Martín, con la Torre Monumental de fondo. Estás en el centro de la imagen, pero alguien rayó tu cara con tinta negra."
    printf '%s\n' \
        "EVACUACIÓN: ascensor habilitado únicamente con credencial." \
        "Escalera clausurada: Luis vomitó desde el piso 17 hasta la planta baja sin parar, mientras huía con los pantalones bajos después de pasar cuarenta minutos en el baño." \
        > "$MUNDO/nivel1/piso_17/pasillo/aviso"
}

capitulo_01_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel1/piso_17/oficina"
    titulo "PRÓLOGO"
    decir "Es un jueves cualquiera. Son las 17:30 y salís del trabajo como todos los días, rumbo a Retiro. Solo falta tomar el tren que te llevará de vuelta a casa, con tu familia y hacia un merecido descanso. Al menos hasta mañana."
    decir "Recorrés Florida hacia el norte. Mirás distraídamente los negocios, las vidrieras y el kiosco de la esquina donde alguna vez compraste alfajores para acompañar el viaje."
    decir "Cruzás Plaza San Martín. Cuando estás por llegar al Monumento a los Caídos en Malvinas, levantás la vista hacia la Torre Monumental. El reloj marca las 17:42. Todavía podés llegar al tren."
    decir "Entonces sentís un dolor punzante en un costado de la cabeza, como si alguien intentara atravesarte el cráneo con un destornillador."
    decir "El dolor te obliga a detenerte."
    decir "Algo no está bien."
    decir "Lo sabés antes de que todo se vuelva oscuro."
    titulo "CAPÍTULO 1 — Otra vez en la oficina"
    decir "Abrís los ojos con esfuerzo, como después de una noche de resaca combinada con la patada de un caballo en el pecho y un piano cayéndote encima."
    decir "Sin siquiera levantarte, girás la cabeza y reconocés el lugar. O, al menos, creés reconocerlo."
    decir "Es tu oficina: el mismo lugar que abandonaste hace apenas unos minutos para volver a casa. Sin embargo, no recordás haber regresado."
    decir "Cuando conseguís ponerte de pie, comprendés que tampoco es exactamente la misma oficina."
    decir "Las paredes están agrietadas. Los escritorios aparecen destrozados y cubiertos por una gruesa capa de polvo. Entre los muebles se abren rincones oscuros que no recordás haber visto nunca. Todo resulta familiar y, al mismo tiempo, completamente ajeno."
    decir "Lo último que recordás es haber cruzado Plaza San Martín camino a Retiro. Miraste el reloj de la Torre Monumental para comprobar si llegarías a tiempo. Después vino el dolor. Después, la oscuridad."
    decir "Te acercás a una ventana. Afuera, la ciudad permanece inmóvil bajo un cielo amarillo. Hay plantas creciendo sobre los edificios, autos abandonados y calles completamente desiertas."
    decir "Parece que el fin del mundo llegó antes de tiempo. Y nadie se molestó en avisarte."
}

capitulo_01_objetivo() {
    decir "Salí de la oficina, llegá al pasillo y leé el aviso de evacuación."
}

capitulo_01_pista() {
    decir "Probá: pwd, ls, cat reloj, cd .., ls, cd pasillo y cat aviso."
}

capitulo_01_despues_cat() {
    [[ "$1" == "$MUNDO/nivel1/piso_17/pasillo/aviso" ]] && ESTADO[VIO_AVISO]=1
}

capitulo_01_evaluar() {
    if [[ "$DIRECTORIO_ACTUAL" == "$MUNDO/nivel1/piso_17/pasillo" && "${ESTADO[VIO_AVISO]:-0}" == 1 ]]; then
        avanzar_nivel
    fi
}

capitulo_01_cierre() {
    printf '%sCapítulo superado.%s Desde el ascensor llega una campanada. No recordás haberlo llamado.\n' "$C_OK" "$C_RESET"
}

capitulo_01_transicion() {
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
       ______________________________________
      | PISO 17                ___________   |
      | Oficina               |           |  |
      |_______                |           |  |
      |_______|_______________| ASCENSOR  |  |
                              |           |  |
                              |_____  ____|  |
                                    \/
ASCII
    printf '%s' "$C_RESET"
}
