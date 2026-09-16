# Audio Sink Selector

Kleines FreePascal-Tool zur schnellen Auswahl des Standard-Audio-Sinks unter Linux.

Das Tool liest die verfügbaren Audio-Sinks über `wpctl status -k` aus und erstellt für jeden gefundenen Sink einen Button. Durch einen Klick wird der entsprechende Sink mit `wpctl set-default <id>` als Standard gesetzt. Anschließend beendet sich das Tool.

## Voraussetzungen

- Linux mit PipeWire/WirePlumber
- `wpctl`
- FreePascal/Lazarus

