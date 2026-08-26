#!/usr/bin/env bash

capitulo_02_preparar() {
    mkdir -p -- "$MUNDO/nivel2/piso_17/archivo" "$MUNDO/nivel2/piso_17/ascensor"
    crear_archivo_si_falta "$MUNDO/nivel2/piso_17/archivo/credencial_antigua" \
        "Credencial provisoria. Vencimiento: 14/08/2526. Sector autorizado: planta baja. Foto: ilegible."
    crear_archivo_si_falta "$MUNDO/nivel2/piso_17/archivo/instrucciones" \
        "El lector acepta un objeto llamado credencial dentro de ascensor. Administración lamenta cualquier eternidad ocasionada."
}

capitulo_02_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel2/piso_17"
    titulo "CAPÍTULO 2 — El ascensor conoce tu nombre"
    decir "Terminás de leer el aviso de evacuación. El papel está amarillento y cubierto de manchas, pero la indicación todavía puede distinguirse."
    decir "Levantás la vista hacia el final del pasillo. Allí está el ascensor."
    decir "Las puertas metálicas se encuentran cerradas y cubiertas de óxido. Sobre ellas, el indicador continúa encendido. Marca el piso 17, aunque la luz parpadea con la insistencia de algo que lleva demasiado tiempo esperando."
    decir "Te acercás. El ascensor responde con una campanada. No recordás haber presionado ningún botón."
    decir "Un pequeño lector se ilumina junto a la puerta: 'BUENAS TARDES. CREDENCIAL, POR FAVOR'. Durante unos segundos no ocurre nada. Entonces la pantalla cambia y muestra tu nombre."
    decir "Retrocedés instintivamente. El pasillo sigue vacío y las luces parpadean. Por momentos todo queda a oscuras y, cada vez que eso sucede, escuchás algo parecido a uñas arrastrándose sobre la cara interna de las puertas."
    decir "En una pared cercana, un cartel informa: 'Reclamos por fallas, encierros o desplazamientos temporales se reciben únicamente de 9:00 a 11:00. La administración no se responsabiliza por usuarios entregados en pisos inexistentes'."
    decir "Necesitás encontrar una credencial y preparar algo donde llevar los objetos que encuentres."
}

capitulo_02_ayuda() {
    decir "  mkdir directorio"
    decir "  touch archivo"
    decir "  cp origen destino"
    decir "  mv origen destino"
}

capitulo_02_objetivo() {
    decir "Creá mochila/, guardá allí la credencial, presentá una copia en ascensor/credencial y tocá el botón."
}

capitulo_02_pista() {
    if [[ ! -d "$MUNDO/nivel2/piso_17/mochila" ]]; then
        decir "Paso 1: desde piso_17 ejecutá: mkdir mochila"
    elif [[ ! -f "$MUNDO/nivel2/piso_17/mochila/credencial" ]]; then
        if [[ -f "$MUNDO/nivel2/piso_17/mochila/credencial_antigua" ]]; then
            if [[ "$DIRECTORIO_ACTUAL" == "$MUNDO/nivel2/piso_17/mochila" ]]; then
                decir "Guardaste la credencial con su nombre antiguo. Renombrala desde acá:"
                decir "mv credencial_antigua credencial"
            else
                decir "Guardaste la credencial con su nombre antiguo. Renombrala:"
                decir "mv mochila/credencial_antigua mochila/credencial"
            fi
        elif [[ -f "$MUNDO/nivel2/piso_17/archivo/credencial_antigua" ]]; then
            decir "Paso 2: guardá y renombrá la credencial: mv archivo/credencial_antigua mochila/credencial"
        elif [[ -f "$MUNDO/nivel2/piso_17/ascensor/credencial" ]]; then
            decir "Moviste la única credencial al ascensor y la mochila quedó vacía. Recuperá una copia: cp ascensor/credencial mochila/credencial"
        else
            decir "No encuentro ninguna credencial. Escribí salir y volvé a iniciar el juego para que el escenario la reponga."
        fi
    elif [[ ! -f "$MUNDO/nivel2/piso_17/ascensor/credencial" ]]; then
        decir "Paso 3: presentá una copia al lector: cp mochila/credencial ascensor/credencial"
    elif [[ ! -f "$MUNDO/nivel2/piso_17/ascensor/boton" ]]; then
        decir "Paso 4: tocá el botón para llamar al ascensor: touch ascensor/boton"
    elif [[ -f "$MUNDO/nivel2/piso_17/ascensor/credencial" ]]; then
        decir "La credencial está colocada y el botón fue activado."
    else
        decir "Revisá el objetivo; todavía falta un elemento."
    fi
}

capitulo_02_evaluar() {
    if [[ -d "$MUNDO/nivel2/piso_17/mochila" \
        && -f "$MUNDO/nivel2/piso_17/mochila/credencial" \
        && -f "$MUNDO/nivel2/piso_17/ascensor/credencial" \
        && -f "$MUNDO/nivel2/piso_17/ascensor/boton" ]]; then
        avanzar_nivel
    fi
}

capitulo_02_cierre() {
    printf '%sCapítulo superado.%s El ascensor acepta la credencial. La pantalla marca PB... y luego -12.\n' "$C_OK" "$C_RESET"
    decir "El lector emite un sonido agudo. La luz cambia de rojo a verde y las puertas se abren con un gemido metálico."
    decir "Dentro no hay nadie. El ascensor está cubierto de polvo, excepto por una mancha de sangre reciente en el suelo, como si algo —o alguien— hubiera sido arrastrado hacia afuera en algún otro piso."
    decir "Entrás con la mochila y la credencial original. La copia queda colocada en el lector. Las puertas se cierran detrás de vos."
    decir "El indicador desciende: 16... 15... 14... Las luces parpadean. 3... 2... 1... PB... pero el ascensor no se detiene."
    decir "Continúa bajando: -1... -2... -3... Finalmente queda clavado en -12."
    decir "Desde algún lugar detrás de la pared, una voz infantil pregunta: '¿Vos también te quedaste dormido?'."
    decir "Antes de que puedas responder, las puertas comienzan a abrirse."
}

capitulo_02_transicion() {
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
             ___________
            |  PB  | -12|
            |------|----|
            |      |    |
            |______|____|
                 ||
                 \/
ASCII
    printf '%s' "$C_RESET"
}
