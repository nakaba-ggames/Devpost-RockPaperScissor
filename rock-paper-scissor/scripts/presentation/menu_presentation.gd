class_name MenuPresentation
extends Control
## Read-only menu view. Cosmetic titles last for this UI/login session only.
@export var persona: Resource
@export var icons: Resource
var titles_by_player: Dictionary = {}
var records_generation: int = 0
var empty_recent_texture: Texture2D

func _ready() -> void:
	get_viewport().size_changed.connect(_fit_canvas)
	_fit_canvas()
	%Leaderboard.icon = icons.leaderboard
	%Record.icon = icons.records
	%Stats.icon = icons.stats
	%Quests.icon = icons.quests
	$Trophy.texture = icons.trophy
	$QuestCrown.texture = icons.crown
	empty_recent_texture = $Recent.get_child(0).get_node("Disc").texture
	_clear_recent()

func present_profile(profile: PlayerProfile, source: ProfileProvider) -> void:
	%PlayerName.text = profile.display_name
	%Points.text = str(profile.overall_points)
	var portrait: Texture2D = persona.avatar(profile.lie_count, profile.honest_count)
	$TopAvatar.texture = portrait
	$Summary/Center/AllegianceIcon.texture = portrait
	var side := "angel"
	if profile.lie_count > profile.honest_count:
		side = "devil"
	var key := profile.player_id + "/" + side
	var choices: Array[String] = persona.titles(profile.lie_count, profile.honest_count)
	if not titles_by_player.has(key) and not choices.is_empty():
		titles_by_player[key] = choices.pick_random()
	$Summary/Center/AllegianceLabel.text = "[" + str(titles_by_player.get(key, "")) + "]"
	var win_rate := "N/A"
	if profile.games_played > 0:
		win_rate = "%.0f%%" % (100.0 * profile.wins / profile.games_played)
	var lie_rate := "N/A"
	var classified := profile.lie_count + profile.honest_count
	if classified > 0:
		lie_rate = "%.0f%%" % (100.0 * profile.lie_count / classified)
	%WinRatio.text = "WIN RATE: %s | LIE: %s" % [win_rate, lie_rate]
	%WinStreak.text = "Win streak %d" % profile.win_streak
	_load_recent(source)

func apply_snapshot(snapshot: Dictionary) -> void:
	%Points.text = str(snapshot.profile.overallPoints)
	var daily: Dictionary = snapshot.get("dailyQuest", {})
	%DailyQuest.text = "Daily quest unavailable"
	$QuestCounter.text = "—"
	$QuestReward.text = ""
	$QuestProgress.value = 0.0
	if daily.is_empty():
		return
	%DailyQuest.text = str(daily.title)
	$QuestProgress.max_value = maxf(float(daily.target), 1.0)
	$QuestProgress.value = float(daily.progress)
	$QuestCounter.text = "%d/%d" % [daily.progress, daily.target]
	$QuestReward.text = "×%d" % int(daily.rewardPoints)

func fading_controls() -> Array[Control]:
	return [%PlayerName, %Points, %DailyQuest, $Summary/Center, $TopBar, $TopAvatar,
		$Trophy, $QuestPanel, $QuestProgress, $QuestCounter, $QuestCrown, $QuestReward,
		$RecentLabel, $Recent, %ClearData, %PresentationMode, %ArenaCondition, $FixtureNotice]

func _clear_recent() -> void:
	for item in $Recent.get_children():
		item.get_node("Mark").hide()
		item.get_node("Disc").texture = empty_recent_texture
		item.get_node("Disc").modulate = Color(0.20, 0.26, 0.34, 1)
		item.tooltip_text = "No completed match"

func _load_recent(source: ProfileProvider) -> void:
	records_generation += 1
	var ticket := records_generation
	_clear_recent()
	var response: Dictionary = await source.request_records("", 3)
	if ticket != records_generation or not is_instance_valid(source):
		return
	if response.has("error"):
		$RecentLabel.text = "Recent games unavailable"
		return
	$RecentLabel.text = "Last 3 games"
	var records: Array = response.get("records", [])
	# Provider order is newest first; display the three available results oldest first.
	var recent: Array = records.slice(0, 3)
	recent.reverse()
	for index in recent.size():
		var outcome := str(recent[index].get("outcome", ""))
		var item := $Recent.get_child(index)
		var texture: Texture2D = icons.result_draw
		if outcome == "win":
			texture = icons.result_win
		elif outcome == "loss":
			texture = icons.result_loss
		item.get_node("Mark").hide()
		item.get_node("Disc").texture = texture
		item.get_node("Disc").modulate = Color.WHITE
		item.tooltip_text = outcome.capitalize()

func _fit_canvas() -> void:
	custom_minimum_size = get_viewport_rect().size
