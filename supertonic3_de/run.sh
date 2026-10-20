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
exec supertonic3-tts-german-wyoming
