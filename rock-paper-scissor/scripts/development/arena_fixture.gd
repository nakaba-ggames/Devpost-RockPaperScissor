class_name ArenaFixture
extends Resource
## Controlled development input, never production arena distribution/bot policy.
@export_enum("Devil's Seduction", "Angel's Confession", "No modifier") var condition: int = 0
@export var opponent_decision_seconds: float = 3.0
@export var opponent_revision_seconds: float = 7.0
@export_enum("Rock", "Paper", "Scissor") var opponent_initial: String = "Rock"
@export_enum("Rock", "Paper", "Scissor") var opponent_revised: String = "Paper"
@export_enum("Rock", "Paper", "Scissor") var opponent_identity: String = "Rock"
@export_enum("Rock", "Paper", "Scissor") var opponent_identity_revised: String = "Scissor"
@export_enum("keep", "switch") var opponent_switch: String = "keep"
@export_enum("keep", "switch") var opponent_switch_revised: String = "switch"
@export_enum("Rock", "Paper", "Scissor") var opponent_final: String = "Paper"
@export_enum("Rock", "Paper", "Scissor") var opponent_final_revised: String = "Rock"
