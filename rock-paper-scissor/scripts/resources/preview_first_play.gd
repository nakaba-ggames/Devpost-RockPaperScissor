extends Resource
## Offline rehearsal only; never infers or persists live onboarding state.
@export var enabled: bool = true
@export var search_seconds: float = 3.0
@export var decision_seconds: float = 20.0
