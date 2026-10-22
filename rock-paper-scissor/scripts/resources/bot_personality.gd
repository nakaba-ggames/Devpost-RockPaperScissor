class_name BotPersonality
extends Resource
## Creator-authored production profiles are still pending. Fixture values are explicit.
@export var profile_id: String = ""
@export var development_fixture: bool = true
@export var choice_weights: Vector3 = Vector3.ZERO
@export_range(0.0, 1.0) var identity_lie_chance: float = 0.0
@export_range(0.0, 1.0) var intention_lie_chance: float = 0.0
@export_range(0.0, 1.0) var switch_chance: float = 0.0
@export_range(0.0, 1.0) var revision_chance: float = 0.0
@export var decision_seconds: Vector2 = Vector2.ZERO
@export var revision_seconds: Vector2 = Vector2.ZERO
