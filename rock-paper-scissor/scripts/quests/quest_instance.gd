class_name PreviewQuestInstance
extends RefCounted
const Definition = preload("res://scripts/quests/quest_definition.gd")
## Session-only assignment. Definition identity is never the instance ID.
var instance_id: String
var owner_id: String
var definition: Definition
var period_kind: String
var period_start: int
var expires_at: int
var activated_at: int
var activated_after_event: int
var progress: int = 0
var completed_at: int = -1
var paid_at: int = -1
var expired: bool = false
var contributions: Dictionary = {}

func advance(event_id: String, sequence: int, actor: Dictionary, outcome: String, now: int) -> void:
	if expired or completed_at >= 0 or sequence <= activated_after_event or contributions.has(event_id):
		return
	if not definition.qualifies(actor, outcome):
		return
	contributions[event_id] = true
	progress = mini(definition.target, progress + 1)
	if progress == definition.target:
		completed_at = now

func expire(now: int) -> void:
	if now >= expires_at and paid_at < 0:
		expired = true

func snapshot() -> Dictionary:
	var state := "active"
	if expired:
		state = "expired"
	elif paid_at >= 0:
		state = "paid"
	elif completed_at >= 0:
		state = "completed"
	return {"questInstanceId": instance_id, "ownerId": owner_id, "definitionId": definition.definition_id, "title": definition.title, "periodKind": period_kind, "periodStart": period_start, "expiresAt": expires_at, "activationBoundary": {"activatedAt": activated_at, "afterEventSequence": activated_after_event}, "target": definition.target, "progress": progress, "completedAt": completed_at, "rewardPoints": definition.reward_points, "paidAt": paid_at, "expired": expired, "state": state, "contributionIds": contributions.keys()}
