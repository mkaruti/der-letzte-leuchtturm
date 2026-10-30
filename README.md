# Der letzte Leuchtturm – Godot Starter

**Eigenständiger technischer Prototyp** für die Gruppenentscheidung. Noch **nicht** mit eurem gemeinsamen Git-Projekt zusammenführen, bevor ihr die Rollen und Versionen abgestimmt habt.

## Was bereits enthalten ist
- Einfacher 2D-Top-Down-Spieler (WASD und Pfeiltasten)
- Kollisionsbasierte Begrenzungen, ein Tor mit Kollision
- E-Interaktion mit einem Schalter
- Toröffnung nach Schalterbetätigung
- Einsammelbarer Kristall
- Kristall am Leuchtturm abgeben
- Status-/Zielanzeige
- Einfaches Platzhalter-Design direkt per GDScript gezeichnet (keine Assets nötig)

## Start auf macOS
1. ZIP entpacken.
2. Godot Engine 4.x (empfohlen: im Team exakt gleiche **stabile** Version) öffnen.
3. Im Projektmanager **Importieren** wählen.
4. Datei `project.godot` aus dem entpackten Ordner auswählen.
5. Projekt öffnen, oben rechts **F5** drücken ("Play Project").
6. Steuerung: **WASD/Pfeiltasten**, **E** zum Interagieren.

## Testablauf
1. Links zum runden Schalter laufen; `E` drücken.
2. Durch die jetzt geöffnete Tür auf die rechte Spielfeldhälfte gehen.
3. Türkisen Kristall ansteuern; `E` drücken.
4. Zum runden Leuchtturm rechts laufen; `E` drücken.
5. Status zeigt "Ziel erreicht" und das Leuchtturm-Licht wechselt die Farbe.

## Projektstruktur
- `scenes/main.tscn` und `scripts/main.gd`: Minilevel, Interaktionen, Tor, Kristall, Beacons
- `scenes/player.tscn` und `scripts/player.gd`: Top-Down-Charakter und Kollision
- `docs/PROJECT_PLAN.md`: vorgeschlagene Meilensteine und MVP-Umfang
- `docs/TEAM_GIT.md`: Gruppenregeln und Git-Workflow

## Grenzen
Der Prototyp ersetzt **noch nicht** Insel, drei Dungeons, Inventar, Gegner, Musik, Spielmenü oder Pixel-Art. Es ist der erste funktionale Kernablauf. Der Code wurde statisch erstellt, **nicht in einer lokalen Godot-Engine ausgeführt**. Falls der Editor einen Fehler zeigt, die Fehlermeldung und den Script-Pfad teilen.
