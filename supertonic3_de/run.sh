#!/bin/sh
set -eu

OPTIONS=/data/options.json

# Einfacher Leser für flache Werte aus options.json (das Image hat weder jq noch Python).
opt() {
    sed -n "s/.*\"$1\": *\"\{0,1\}\([^\",}]*\)\"\{0,1\}.*/\1/p" "$OPTIONS" | head -n 1
}

export TTS_VOICE="$(opt voice)"
export TTS_SPEED="$(opt speed)"
export TTS_STEPS="$(opt steps)"
export TTS_THREADS="$(opt threads)"
export TTS_STREAMING="$(opt streaming)"
export TTS_STREAM_PREFILL_MS="$(opt prefill_ms)"
export TTS_GERMAN_NORMALIZATION="$(opt german_normalization)"

mkdir -p "$MODEL_DIR" "$VOICE_DIR"

echo "Supertonic 3: voice=$TTS_VOICE speed=$TTS_SPEED steps=$TTS_STEPS threads=$TTS_THREADS streaming=$TTS_STREAMING prefill=${TTS_STREAM_PREFILL_MS}ms"

supertonic3-tts-german-wyoming &
SERVER=$!
trap 'kill -TERM "$SERVER" 2>/dev/null' TERM INT

# Discovery: Sobald das Modell geladen ist, dem Supervisor melden, wo der Wyoming-Server läuft.
# Home Assistant zeigt den Dienst dann unter Geräte & Dienste als "Entdeckt" an.
# Beim ersten Start kann das wegen des Modell-Downloads einige Minuten dauern.
(
    until supertonic3-tts-german-wyoming --healthcheck >/dev/null 2>&1; do
        kill -0 "$SERVER" 2>/dev/null || exit 0
        sleep 2
    done
    if [ -z "${SUPERVISOR_TOKEN:-}" ]; then
        echo "Discovery übersprungen: kein SUPERVISOR_TOKEN (läuft nicht als Add-on)."
        exit 0
    fi
    HOST="$(cat /proc/sys/kernel/hostname)"
    if curl -fsS -X POST \
        -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{\"service\": \"wyoming\", \"config\": {\"uri\": \"tcp://${HOST}:${WYOMING_PORT}\"}}" \
        http://supervisor/discovery >/dev/null; then
        echo "Discovery an Home Assistant gesendet: tcp://${HOST}:${WYOMING_PORT}"
    else
        echo "Discovery an Home Assistant fehlgeschlagen. Integration manuell hinzufügen (Host ${HOST}, Port ${WYOMING_PORT})."
    fi
) &

# Auf den Server warten (zweimal, weil ein Signal das erste wait unterbricht).
set +e
wait "$SERVER"
STATUS=$?
if kill -0 "$SERVER" 2>/dev/null; then
    wait "$SERVER"
    STATUS=$?
fi
exit "$STATUS"
