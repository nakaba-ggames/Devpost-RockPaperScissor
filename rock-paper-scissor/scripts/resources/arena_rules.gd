class_name ArenaRules
extends Resource
## Production weights stay unset until authored. Development uses explicit fixtures.
@export var revision: String = "m05-round-v1"
@export var option_seconds: float = 15.0
@export var identity_claim_seconds: float = 15.0
@export var switch_claim_seconds: float = 15.0
@export var production_weights_configured: bool = false
@export var devil_weight: float = -1.0
@export var angel_weight: float = -1.0
@export var no_modifier_weight: float = -1.0
@export var final_choice_seconds: float = 15.0
@export var win_points: int = 10
@export var draw_points: int = 3
@export var loss_points: int = 0
@export var devil_win_bonus: int = 10
@export var devil_draw_bonus: int = 5
@export var angel_win_bonus: int = 15
@export var angel_draw_bonus: int = 7
