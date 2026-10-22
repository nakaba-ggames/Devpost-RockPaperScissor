extends Resource
## Creator authoring stays explicit; disabled until presentation direction is agreed.
@export var authoring_agreed: bool = false
@export var dim_alpha: float = 0.3
@export var final_dim_alpha: float = 1.0
@export var black_hold_seconds: float = 0.35
@export var close_existing_chat: bool = true
@export var temporary_outcome_agreed: bool = false
@export var outcome_animation: StringName = &""
@export var allow_skip_narration: bool = false
@export var retreat_seconds: float = 0.55
@export var fade_seconds: float = 0.4
@export var curtain_seconds: float = 0.8
@export var text_hold_seconds: float = 2.2
@export var outcome_seconds: float = 0.7
@export var outcome_hold_seconds: float = 1.0
@export var continue_seconds: float = 0.35
@export var receipt_timeout_seconds: float = 10.0
@export var retry_seconds: float = 1.0
@export var status_pulse_seconds: float = 0.65
@export var projector_cycle_seconds: float = 0.16
@export var projector_min_alpha: float = 0.04
@export var projector_max_alpha: float = 0.10
@export var outcome_start_scale: Vector2 = Vector2(0.86, 0.86)
@export var transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease: Tween.EaseType = Tween.EASE_IN_OUT
@export_group("Narration copy")
@export_multiline var initial_copy: String = "{name} began with {initial}.{default}"
@export_multiline var identity_copy: String = "{name} claimed {claim}.\n{truth} about the initial {initial}.{default}"
@export_multiline var intention_copy: String = "{name} promised to {intention}.\n{truth} about the final action.{default}"
@export_multiline var action_copy: String = "{name} chose to {action}.\n{initial} → {final}.{default}"
@export var truth_copy: String = "Truthful"
@export var lie_copy: String = "Deceptive"
@export var keep_copy: String = "keep"
@export var switch_copy: String = "switch"
@export var default_copy: String = "\nNo input: the phase default applied."
@export_group("Delivery and result copy")
@export var pending_copy: String = "Waiting for result acknowledgement…"
@export var uncertain_copy: String = "Acknowledgement is uncertain. Query / retry the same result."
@export var preview_copy: String = "Simulated acknowledgement • session preview only\nNo server commitment or saved points"
@export var committed_copy: String = "Result acknowledged"
@export var ineligible_copy: String = "Not eligible for credit"
@export var win_copy: String = "YOU WIN"
@export var loss_copy: String = "YOU LOSE"
@export var draw_copy: String = "DRAW"
