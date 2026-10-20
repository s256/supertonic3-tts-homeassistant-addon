FROM ghcr.io/marco-taylor/supertonic3-tts-german-wyoming:latest

# Das Upstream-Image läuft als UID 10001; /data des Add-ons gehört root.
USER root

# curl für die Discovery-Meldung an den Supervisor. Das Upstream-Image nutzt einen festen
# Debian-Snapshot, daher Check-Valid-Until=false wie im Upstream-Dockerfile.
RUN apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get -o Acquire::Check-Valid-Until=false install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

ENV MODEL_DIR=/data/models \
    VOICE_DIR=/data/voices \
    TTS_LANGUAGE=de \
    WYOMING_PORT=10200

COPY run.sh /run.sh
RUN chmod 755 /run.sh

ENTRYPOINT ["/run.sh"]
