# Supertonic 3 TTS (Deutsch)

Lokale deutsche Sprachausgabe mit [Supertonic 3](https://huggingface.co/Supertone/supertonic-3) über das
Wyoming-Protokoll. Alles läuft auf der CPU dieses Rechners, ohne Cloud.

## Erster Start

Beim ersten Start werden Modell und Stimmen von Hugging Face geladen (ca. 380 MB). Das dauert je nach
Leitung ein paar Minuten. Fertig ist das Add-on, wenn im **Protokoll** `server ready` steht. Danach
läuft alles offline.

## In Home Assistant einbinden

1. **Einstellungen → Geräte & Dienste → Integration hinzufügen → Wyoming-Protokoll**
2. Host: der **Hostname** dieses Add-ons (steht oben auf der Info-Seite des Add-ons, z. B.
   `e8223149-supertonic3-de`), Port: `10200`
3. Die Sprachausgabe erscheint danach als `tts.…` (z. B. `tts.supertonic3`) und kann in
   Assist-Pipelines, mit `tts.speak` oder über `media-source://tts/tts.supertonic3?message=...`
   benutzt werden.

Von einem anderen Rechner aus ist der Dienst unter der IP von Home Assistant und Port `10210` erreichbar
(änderbar unter **Netzwerk**).

## Optionen

| Option | Standard | Bereich | Beschreibung |
|---|---|---|---|
| `voice` | `F2` | `F1`–`F5`, `M1`–`M5` | Standardstimme (F = weiblich, M = männlich). Pro Anfrage über die Stimmenauswahl änderbar. |
| `speed` | `1.0` | `0.8`–`1.2` | Sprechgeschwindigkeit |
| `steps` | `5` | `5`–`12` | Rechenschritte. Mehr = etwas bessere Qualität, aber langsamer. |
| `threads` | `4` | `1`–`4` | CPU-Threads für die Synthese |
| `streaming` | `false` | | `true`: Ausgabe beginnt, bevor der ganze Text fertig ist. `false`: erst komplett erzeugen, dann am Stück abspielen. |
| `prefill_ms` | `3500` | `0`–`5000` | Nur bei `streaming: true`: so viel Audio wird vorab erzeugt, bevor die Wiedergabe beginnt. |
| `german_normalization` | `true` | | Zahlen, Einheiten, Uhrzeiten usw. ausschreiben |

Nach einer Änderung das Add-on neu starten.

### Schwache Hardware

Auf langsamen CPUs (Thin Clients, ältere Mini-PCs) kann die Ausgabe mit Streaming stocken, weil die
Synthese nicht schnell genug nachkommt. Deshalb ist `streaming: false` voreingestellt: Die Ansage
beginnt etwas später, läuft dann aber ohne Lücken. Für lange Texte ist `streaming: true` mit
`prefill_ms: 5000` ein Mittelweg. `steps` auf `5` lassen.

### Cache

Home Assistant speichert erzeugte Ansagen (bei `cache: true`) unter `/config/tts` und spielt gleiche
Texte danach sofort ab. Der Cache kennt die Add-on-Optionen nicht: Nach einer Änderung von `voice`,
`speed` oder `steps` den Cache leeren, sonst kommen weiter die alten Aufnahmen:

```yaml
action: tts.clear_cache
```

## Daten

Modell und Stimmen liegen unter `/data` des Add-ons. Sie bleiben bei Updates erhalten und sind Teil der
Backups.
