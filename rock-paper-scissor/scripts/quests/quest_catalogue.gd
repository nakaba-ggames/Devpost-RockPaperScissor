class_name QuestCatalogue
extends Resource
const Definition = preload("res://scripts/quests/quest_definition.gd")
## Selection is explicit: daily ordered cycle repeats; weekly list is concurrent.
@export var revision: String = ""
@export var development_only: bool = true
@export_enum("ordered_cycle") var daily_selection: String = "ordered_cycle"
@export var daily_cycle: Array[Definition] = []
@export var weekly_objectives: Array[Definition] = []
