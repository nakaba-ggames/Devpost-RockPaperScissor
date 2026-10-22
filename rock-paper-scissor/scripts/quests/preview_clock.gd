class_name PreviewQuestClock
extends RefCounted
## DEVELOPMENT ONLY. M11/M12 must use backend time and reward authority.
var controlled_unix: int = -1

func now_unix() -> int:
	if controlled_unix >= 0:
		return controlled_unix
	return int(Time.get_unix_time_from_system())

func set_development_time(unix_time: int) -> void:
	controlled_unix = unix_time

func reset() -> void:
	controlled_unix = -1
