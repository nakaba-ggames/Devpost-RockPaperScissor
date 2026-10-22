class_name ArenaFixture
extends Resource
## Controlled development input, never production arena distribution/bot policy.
@export_enum("Devil's Seduction", "Angel's Confession", "No modifier") var condition: int = 0
@export var opponent_decision_seconds: float = 3.0
@export var opponent_revision_seconds: float = 7.0
@export_enum("Rock", "Paper", "Scissor") var opponent_initial: String = "Rock"
@export_enum("Rock", "Paper", "Scissor") var opponent_revised: String = "Paper"
