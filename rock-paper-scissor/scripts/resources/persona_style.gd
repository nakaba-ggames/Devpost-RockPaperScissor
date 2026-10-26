extends Resource
## Cosmetic view data only. No identity, rank or server profile is changed.
@export var angel: Texture2D
@export var devil: Texture2D
@export var angel_titles: Array[String] = []
@export var devil_titles: Array[String] = []

func avatar(lies: int, honest: int) -> Texture2D:
	if lies > honest:
		return devil
	return angel

func titles(lies: int, honest: int) -> Array[String]:
	if lies > honest:
		return devil_titles
	return angel_titles

func avatar_from_public(data: Dictionary) -> Texture2D:
	if data.has("lieCount") and data.has("honestCount"):
		return avatar(int(data.lieCount), int(data.honestCount))
	var lie_rate: Variant = data.get("liePercentage")
	if lie_rate != null and float(lie_rate) > 50.0:
		return devil
	return angel
