# Godot und Git – Teamregeln

1. Alle nutzen dieselbe stabile Godot-Haupt- und Patch-Version, z.B. 4.7.2.
2. Die Gruppe bestimmt **ein** gemeinsames GitHub-Repository. Keine neuen konkurrierenden Main-Projekte erstellen.
3. `main` bleibt spielbar. Jede Person arbeitet auf Feature-Branches, z.B. `feature/forest-puzzle`.
4. Szenen aufteilen: eine Person bearbeitet Island.tscn, eine Forest.tscn etc. Nicht gleichzeitig dieselbe große `.tscn` ändern.
5. `.gitignore` ignoriert `.godot/`, **nicht** aber `project.godot`, `.tscn`, `.tres`, `.gd` oder wichtige Asset-Dateien.
6. Externe Grafiken, Musik und Sounds inkl. Lizenzen und Ursprungslinks dokumentieren.
7. Pull Request: neueste main integrieren; dann Szene starten und Funktion testen, bevor gemergt wird.
8. Alle legen kleine, verständliche Commits an, z.B. "Implement crystal pickup" statt "stuff".
9. Für macOS und Windows auf Groß-/Kleinschreibung der Datei- und Node-Namen achten.
10. Keine großen Engine-Updates während des Projekts ohne Teamsitzung.

Ein Git-Plugin in Godot ist optional. GitHub Desktop, Rider oder die Kommandozeile reichen zunächst aus.
