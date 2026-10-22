class_name InitialChoiceHistory
extends Resource
## RoundLog actor fragment. Hidden authoritative data, never a UI position.
@export var actor_id: String = ""
@export var starting_order: Array[String] = []
@export var initial_card: String = ""
@export var identity_claim: String = ""
@export var switch_claim: String = ""
@export var final_card: String = ""
@export var final_state: Dictionary = {}
# Per-phase defaults/locks never overwrite the Option fields below.
@export var claim_phases: Dictionary = {}
@export var events: Array[Dictionary] = []
@export var defaulted: bool = false
@export var locked: bool = false
@export var locked_elapsed_msec: int = -1
