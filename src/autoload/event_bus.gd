extends Node
## Global event bus for decoupled communication between systems.

# Player events
signal player_moved(position: Vector2i)
signal player_attacked(target: Node)
signal player_died

# Turn events
signal turn_started(turn_number: int)
signal turn_ended(turn_number: int)

# Dungeon events
signal floor_entered(floor_number: int)
signal room_entered(room_id: int)

# Combat events
signal entity_damaged(entity: Node, amount: int)
signal entity_killed(entity: Node)

# UI events
signal inventory_updated
signal stats_updated
