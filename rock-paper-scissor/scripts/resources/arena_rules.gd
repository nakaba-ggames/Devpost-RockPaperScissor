class_name ArenaRules
extends Resource
## Production weights stay unset until authored. M03 uses an explicit fixture.
@export var revision: String = "m04-claims-v1"
@export var option_seconds: float = 15.0
@export var identity_claim_seconds: float = 15.0
@export var switch_claim_seconds: float = 15.0
@export var production_weights_configured: bool = false
@export var devil_weight: float = -1.0
@export var angel_weight: float = -1.0
@export var no_modifier_weight: float = -1.0
