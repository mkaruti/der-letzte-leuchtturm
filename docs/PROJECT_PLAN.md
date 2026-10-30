# Projektplan – Der letzte Leuchtturm

## Ursprung
Die Gruppenpräsentation beschreibt ein 2D-Top-Down-Adventure in Unity mit dem Wächter Lio, Mara, Leuchtturm, drei Kristallen, Sturm, Wald, Höhle und Ruine. Geplant sind Erkundung, Rätsel (Schalter, Steinblöcke, Fackeln), einfache Sturmwesen, Sammeln und freier Dungeon-Reihenfolge. Die präsentierten 1–2 Stunden Spielzeit sind für ein Anfängerteam bis Januar sehr ambitioniert.

## Vorschlag: Minimum Viable Game
- Hauptinsel als zentrale Hub-Szene
- Drei **kleine** Dungeons, pro Dungeon 1–2 Rätsel
- 1 wiederverwendbarer einfacher Gegnertyp, sofern Zeit reicht
- 3 einsammelbare Kristalle, Rückkehr zum Leuchtturm
- NPC Mara mit ein paar Textdialogen
- Sturm verändert sich in 3–4 Story-Phasen, **kein echter Countdown**
- Finale mit Licht, kurzer Endszene und Neustart
- 20–40 Minuten Zielspielzeit, nicht 1–2 Stunden versprechen

## Meilensteine (ab 30.10.2026; Abgabedatum im Januar noch klären)
**Bis 06.11.** Version/Repository/Rollen festlegen, Spielerbewegung, Interaktion und Testszene.
**Bis 15.11.** Vertikaler Schnitt: 1 Mini-Dungeon, 1 Rätsel, Kristall aufnehmen, zum Hub zurückkehren.
**Bis 29.11.** Hauptinsel, Dialog, Inventar/Kristallfortschritt, erster Dungeon komplett.
**Bis 13.12.** Zwei weitere kurze Dungeons integriert; alle Kristalle erreichbar.
**Bis 20.12.** Leuchtturm-Finale, UI, Sound, vorläufiger Build.
**Danach** Tests, Bugs, Dokumentation, Präsentation und Abgabe – keine neuen Hauptmechaniken mehr.

## Technische Architektur
- Player.tscn / Player.gd: Steuerung und einfache Interaktion
- GameState.gd: Kristalle und Sturmphase (Autoload)
- Island.tscn: Hub und Leuchtturm
- Forest.tscn, Cave.tscn, Ruins.tscn: separate Dungeons
- Interactable.gd: Interaktionsbasis
- PuzzleSwitch.gd, Door.gd, Crystal.gd: wiederverwendbare Rätsel-Bausteine
- Enemy.tscn: ein wiederverwendbarer Gegner (später)
- UI: Dialog, Inventar, Hauptmenü

## Definition of Done
- Windows-Build startet auf einem echten Windows-PC.
- Neues Spiel bis Ende durchspielbar ohne manuelle Editor-Eingriffe.
- Keine offensichtlichen Sackgassen, alle Kristalle funktionieren.
- Mindestens zwei fremde Testpersonen haben einen Durchlauf gemacht.
- Git main wird ohne Merge-Konflikt geöffnet und gestartet.
- Code, Assets und KI-Einsatz sind dokumentiert.

## Rollen (erst nach Gruppengröße festlegen)
1. Systems: Player, Interaktion, Kristallfortschritt, Gegner
2. Levels: Insel/Wald/Höhle/Ruine; pro Person andere Szene
3. Content: Pixel-Art, Dialoge, UI, Audio, Tests, Dokumentation

**Priorität:** Zuerst eine komplette Spielschleife, danach Levelinhalt. Keine vierte Dungeon-Idee vor dem stabilen Finale.
