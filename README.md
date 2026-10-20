# Supertonic 3 TTS (Deutsch) – Home Assistant Add-on

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

- Home Assistant OS oder Supervised
- `amd64` mit AVX2 (prüfen im Terminal-Add-on: `grep -o -m1 avx2 /proc/cpuinfo`)
- Einmalig Internet: beim Installieren (Image-Build) und beim ersten Start (ca. 380 MB Modell und
  Stimmen von Hugging Face). Danach läuft alles offline.

Im Einsatz auf einem HP T630 Thin Client (AMD GX-420GI, 4 Kerne, 12 GB RAM).

## Installation

1. Dieses Repository als Ordner `supertonic3_de` in die Freigabe `addons` von Home Assistant kopieren
   (z. B. über das Samba-Add-on), sodass `/addons/supertonic3_de/config.yaml` existiert.
2. **Einstellungen → Add-ons → Add-on Store → ⋮ → Nach Updates suchen**. Das Add-on erscheint unter
   „Lokale Add-ons".
3. Installieren und starten. Der erste Start lädt das Modell herunter; fertig ist es, wenn im Protokoll
   `server ready` steht.
4. **Einstellungen → Geräte & Dienste → Integration hinzufügen → Wyoming-Protokoll**
   - Host: `local-supertonic3-de`
   - Port: `10200`

   Alternativ von außerhalb: IP von Home Assistant und Port `10210`.
5. Die Sprachausgabe heißt danach z. B. `tts.supertonic3` und kann in Assist-Pipelines, mit `tts.speak`
   oder über `media-source://tts/tts.supertonic3?message=...` benutzt werden.

## Konfiguration

| Option | Standard | Bereich | Beschreibung |
|---|---|---|---|
| `voice` | `F2` | `F1`–`F5`, `M1`–`M5` | Standardstimme (F = weiblich, M = männlich). Pro Anfrage über die Wyoming-Stimmenauswahl änderbar. |
| `speed` | `1.0` | `0.8`–`1.2` | Sprechgeschwindigkeit |
| `steps` | `5` | `5`–`12` | Rechenschritte. Mehr = etwas bessere Qualität, aber langsamer. |
| `threads` | `4` | `1`–`4` | CPU-Threads für die Synthese |
| `streaming` | `false` | | `true`: Ausgabe beginnt, bevor der ganze Text fertig ist. `false`: erst komplett erzeugen, dann am Stück abspielen. |
| `prefill_ms` | `3500` | `0`–`5000` | Nur bei `streaming: true`: so viel Audio wird vorab erzeugt, bevor die Wiedergabe beginnt. |
| `german_normalization` | `true` | | Zahlen, Einheiten, Uhrzeiten usw. ausschreiben |

### Schwache Hardware

Auf langsamen CPUs (Thin Clients, ältere Mini-PCs) kann die Ausgabe mit Streaming stocken, weil die
Synthese nicht schnell genug nachkommt. Deshalb ist `streaming: false` voreingestellt: Die Ansage
beginnt etwas später, läuft dann aber ohne Lücken. Für lange Texte ist `streaming: true` mit
`prefill_ms: 5000` ein Mittelweg.

### Cache

Home Assistant speichert erzeugte Ansagen (bei `cache: true`) unter `/config/tts` und spielt gleiche
Texte danach sofort ab. Der Cache kennt die Add-on-Einstellungen nicht: Nach einer Änderung von Stimme,
`speed` oder `steps` den Cache leeren, sonst kommen weiter die alten Aufnahmen:

```yaml
action: tts.clear_cache
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
