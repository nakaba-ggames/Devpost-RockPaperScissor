extends SceneTree
## Build tool only. Loads native Resources without changing scenes/settings.

func _initialize() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 1:
		push_error("Expected one absolute output path.")
		quit(1)
		return
	var rules := load("res://resources/arena/option_rules.tres") as Resource
	var quests := load("res://resources/quests/release_catalogue.tres") as Resource
	if rules == null or quests == null:
		push_error("Required configuration Resources unavailable.")
		quit(1)
		return
	var rule_fields := ["revision", "option_seconds", "identity_claim_seconds", "switch_claim_seconds", "final_choice_seconds", "production_weights_configured", "devil_weight", "angel_weight", "no_modifier_weight", "win_points", "draw_points", "loss_points", "devil_win_bonus", "devil_draw_bonus", "angel_win_bonus", "angel_draw_bonus"]
	var quest_fields := ["definition_id", "title", "objective", "card", "target", "reward_points"]
	var release := load("res://resources/backend/release_settings.tres") as Resource
	var personality := load("res://resources/bots/ember_personality.tres") as Resource
	var source_files := {}
	for path: String in ["res://scripts/resources/arena_rules.gd", "res://scripts/quests/quest_catalogue.gd", "res://scripts/quests/quest_definition.gd", rules.resource_path, quests.resource_path, release.resource_path, personality.resource_path, "res://scripts/resources/backend_release_settings.gd", "res://scripts/resources/bot_personality.gd"]:
		source_files[path.trim_prefix("res://")] = FileAccess.get_sha256(path)
	var daily: Array = []
	var weekly: Array = []
	for definition: Resource in quests.get("daily_cycle"):
		daily.append(_fields(definition, quest_fields))
		source_files[definition.resource_path.trim_prefix("res://")] = FileAccess.get_sha256(definition.resource_path)
	for definition: Resource in quests.get("weekly_objectives"):
		weekly.append(_fields(definition, quest_fields))
		source_files[definition.resource_path.trim_prefix("res://")] = FileAccess.get_sha256(definition.resource_path)
	var configuration := {
		"rules": _fields(rules, rule_fields),
		"release": _fields(release, ["collection_prefix", "fallback_seed_key", "fallback_personality_id", "intro_bot_names", "regular_bot_names"]),
		"bot": _fields(personality, ["profile_id", "development_fixture", "identity_lie_chance", "intention_lie_chance", "switch_chance", "revision_chance"]),
		"quests": {
			"revision": quests.get("revision"), "development_only": quests.get("development_only"),
			"daily_selection": quests.get("daily_selection"), "daily_cycle": daily, "weekly_objectives": weekly
		},
		"productionReady": rules.get("production_weights_configured") and not quests.get("development_only") and not personality.get("development_fixture") and release.get("fallback_personality_id") == personality.get("profile_id") and rules.get("devil_weight") >= 0 and rules.get("angel_weight") >= 0 and rules.get("no_modifier_weight") >= 0 and rules.get("devil_weight") + rules.get("angel_weight") + rules.get("no_modifier_weight") > 0
	}
	var output := FileAccess.open(arguments[0], FileAccess.WRITE)
	if output == null:
		push_error("Cannot write configuration output.")
		quit(1)
		return
	output.store_string(JSON.stringify({"schemaVersion": 1, "sourceFiles": source_files, "configuration": configuration}, "\t", true))
	output.close()
	quit(0)

func _fields(resource: Resource, names: Array) -> Dictionary:
	var result := {}
	for field: String in names:
		result[field] = resource.get(field)
	return result
