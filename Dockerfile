FROM ghcr.io/marco-taylor/supertonic3-tts-german-wyoming:latest

# Das Upstream-Image läuft als UID 10001; /data des Add-ons gehört root.
USER root
ENV MODEL_DIR=/data/models \
    VOICE_DIR=/data/voices \
    TTS_LANGUAGE=de \
    WYOMING_PORT=10200

COPY run.sh /run.sh
RUN chmod 755 /run.sh

ENTRYPOINT ["/run.sh"]
