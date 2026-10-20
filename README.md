# Supertonic 3 TTS (Deutsch) – Home Assistant Add-on

[![Repository zu Home Assistant hinzufügen](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fs256%2Fsupertonic3-tts-homeassistant-addon)

Lokale deutsche Sprachausgabe für Home Assistant mit [Supertonic 3](https://huggingface.co/Supertone/supertonic-3),
angebunden über das Wyoming-Protokoll. Klingt deutlich natürlicher als Piper, macht hörbare Pausen an
Kommas und läuft komplett lokal auf der CPU.

Das Add-on ist ein dünner Wrapper um das Docker-Image
[marco-taylor/supertonic3-tts-german-wyoming](https://github.com/marco-taylor/supertonic3-tts-german-wyoming)
(Rust, ONNX Runtime, nativer Wyoming-Server mit deutscher Text-Normalisierung für Zahlen, Uhrzeiten,
Temperaturen, Einheiten usw.). Es ergänzt nur:

- Konfiguration über die Add-on-Oberfläche statt über Umgebungsvariablen
- dauerhafte Ablage von Modell und Stimmen unter `/data` des Add-ons (bleibt bei Updates erhalten,
  ist Teil der Backups)

## Voraussetzungen

- **Home Assistant OS** (oder Supervised). Add-ons gibt es nur dort, nicht bei Home Assistant Container
  oder Core. Dort stattdessen das
  [Upstream-Image](https://github.com/marco-taylor/supertonic3-tts-german-wyoming) direkt mit Docker
  starten.
- `amd64`-CPU mit AVX2 (prüfen im Terminal-Add-on: `grep -o -m1 avx2 /proc/cpuinfo`)
- Einmalig Internet: beim Installieren (das Add-on wird auf dem Gerät gebaut) und beim ersten Start
  (ca. 380 MB Modell und Stimmen von Hugging Face). Danach läuft alles offline.

Im Einsatz auf einem HP T630 Thin Client (AMD GX-420GI, 4 Kerne, 12 GB RAM).

## Installation

1. Repository hinzufügen: Button oben klicken, oder manuell unter
   **Einstellungen → Add-ons → Add-on Store → ⋮ → Repositories** diese URL eintragen:

   ```
   https://github.com/s256/supertonic3-tts-homeassistant-addon
   ```

2. Im Add-on Store **Supertonic 3 TTS (Deutsch)** öffnen und **Installieren**. Das Add-on wird dabei auf
   dem Gerät gebaut, das dauert ein paar Minuten.
3. **Starten** und im **Protokoll** warten, bis `server ready` steht (der erste Start lädt das Modell).
4. Sobald das Modell geladen ist, meldet sich das Add-on selbst bei Home Assistant. Unter
   **Einstellungen → Geräte & Dienste** erscheint **Wyoming-Protokoll** als *Entdeckt* →
   **Konfigurieren** → **Senden**.

   Falls nicht: **Integration hinzufügen → Wyoming-Protokoll** mit dem **Hostname** des Add-ons (steht
   auf der Info-Seite des Add-ons, bei der URL oben `e8223149-supertonic3-de`) und Port `10200`.
5. Die Sprachausgabe ist danach als `tts.…` verfügbar (z. B. `tts.supertonic3`) und kann in
   Assist-Pipelines, mit `tts.speak` oder als `media-source://tts/tts.supertonic3?message=...` benutzt
   werden.

Optionen, Hinweise für schwache Hardware und zum Cache stehen in der
[Dokumentation des Add-ons](supertonic3_de/DOCS.md) (in Home Assistant im Reiter **Dokumentation**).

## Aufbau

```
repository.yaml            Beschreibung des Add-on-Repositorys für den Supervisor
supertonic3_de/
  config.yaml              Add-on-Definition (Optionen, Ports, Architektur)
  Dockerfile               baut auf ghcr.io/marco-taylor/supertonic3-tts-german-wyoming auf
  run.sh                   liest /data/options.json, startet den Server, meldet ihn per Discovery
  DOCS.md                  Dokumentation, wird in Home Assistant angezeigt
```

## Lizenzen

- Dieses Add-on (Konfiguration und Skripte): [MIT](LICENSE)
- [supertonic3-tts-german-wyoming](https://github.com/marco-taylor/supertonic3-tts-german-wyoming)
  (verwendetes Docker-Image): MIT
- ONNX Runtime: MIT
- Das Supertonic-3-Modell und die Stimmen sind **nicht** Teil dieses Repositorys. Sie werden beim ersten
  Start von Hugging Face geladen und stehen unter der
  [OpenRAIL-M-Lizenz](https://huggingface.co/Supertone/supertonic-3/blob/main/LICENSE) von Supertone Inc.
  Mit der Nutzung gelten deren Bedingungen.
