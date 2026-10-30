extends TileMapLayer
## Schritt 7: Kollisionsregeln für unsere Insel (Godot 4.7).
## Die TileMapLayer bleibt editierbar. Kein Eingriff in Spieler, Tor oder Kamera.
## Atlas 0..2 = Wasser, 3..5 = Sand, 6..8 = Gras, 9..11 = Weg.

const WATER_TILE_COUNT: int = 3
const TREE_TRUNK_RADIUS: float = 12.0
const TREE_TRUNK_OFFSET: Vector2 = Vector2(0, 10)


func _ready() -> void:
    _enable_water_collision()
    _enable_tree_collision()


func _enable_water_collision() -> void:
    if tile_set == null:
        push_error("Insel-Kollision: Kein TileSet an IslandGround vorhanden.")
        return

    # Das TileSet zur Laufzeit kopieren, damit die Quelldatei unverändert bleibt.
    var collision_tileset: TileSet = tile_set.duplicate(true) as TileSet
    if collision_tileset.get_physics_layers_count() == 0:
        collision_tileset.add_physics_layer()
    collision_tileset.set_physics_layer_collision_layer(0, 1)
    collision_tileset.set_physics_layer_collision_mask(0, 1)

    var terrain_atlas: TileSetAtlasSource = collision_tileset.get_source(0) as TileSetAtlasSource
    if terrain_atlas == null:
        push_error("Insel-Kollision: Das Terrain-Atlas-Set (ID 0) fehlt.")
        return

    # Volle 16x16-Kollision für die drei Wasser-Varianten im Terrain-Atlas.
    # Sand, Gras und Wege bleiben begehbar.
    var water_shape := PackedVector2Array([
        Vector2(-8, -8), Vector2(8, -8),
        Vector2(8, 8), Vector2(-8, 8)
    ])
    for atlas_x in range(WATER_TILE_COUNT):
        var data: TileData = terrain_atlas.get_tile_data(Vector2i(atlas_x, 0), 0)
        if data == null:
            push_warning("Insel-Kollision: Wasser-Tile %d fehlt." % atlas_x)
            continue
        data.set_collision_polygons_count(0, 1)
        data.set_collision_polygon_points(0, 0, water_shape)

    tile_set = collision_tileset


func _enable_tree_collision() -> void:
    # Die bestehenden Baum-Sprites erhalten nur am Stamm eine Kollision.
    # Baumkronen sollen in der Top-Down-Ansicht keine großen Hindernisse sein.
    for child in get_children():
        if not (child is Sprite2D and String(child.name).begins_with("Tree")):
            continue
        if child.has_node("TrunkCollision"):
            continue

        var trunk := StaticBody2D.new()
        trunk.name = "TrunkCollision"
        trunk.position = TREE_TRUNK_OFFSET
        trunk.collision_layer = 1
        trunk.collision_mask = 1

        var shape_node := CollisionShape2D.new()
        shape_node.name = "CollisionShape2D"
        var circle := CircleShape2D.new()
        circle.radius = TREE_TRUNK_RADIUS
        shape_node.shape = circle

        trunk.add_child(shape_node)
        child.add_child(trunk)
