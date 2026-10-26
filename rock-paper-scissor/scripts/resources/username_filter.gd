extends Resource
## Local courtesy filter. Whole words avoid rejecting innocent substrings.
@export var banned_words: PackedStringArray = []
@export var warning_text: String = "Please choose a different name."
@export var invalid_color: Color = Color("#ef6464")
@export var normal_color: Color = Color.WHITE
@export var warning_font_size: int = 20

func blocks(value: String) -> bool:
	var normalized := value.to_lower()
	for pair in [["0", "o"], ["1", "i"], ["3", "e"], ["4", "a"], ["5", "s"], ["7", "t"], ["@", "a"], ["$", "s"]]:
		normalized = normalized.replace(pair[0], pair[1])
	var separators := RegEx.new()
	separators.compile("[^a-z]+")
	var spaced := separators.sub(normalized, " ", true).strip_edges()
	var tokens := spaced.split(" ", false)
	var compact := spaced.replace(" ", "")
	for word in banned_words:
		if word in tokens or compact == word:
			return true
	return false
