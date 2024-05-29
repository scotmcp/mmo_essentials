extends Node
const DEBUG : int = 2

var file = FileAccess.open("res://log/server-logs_" + str(Time.get_datetime_string_from_system()) + ".log", FileAccess.WRITE)
var console : bool = true

func _ready() -> void:
	file.store_string("**************  Start Log  **************")
	file.flush()

func error(text: String) -> void:
	file.store_string(str(Time.get_datetime_string_from_system()) + " : ERROR : " + text + "
")
	file.flush()
	if console: print(str(Time.get_datetime_string_from_system()) + " : ERROR : " + text)
	
func warning(text: String) -> void:
	file.store_string(str(Time.get_datetime_string_from_system()) + " : WARNING : " + text + "
")
	file.flush()
	if console: print(str(Time.get_datetime_string_from_system()) + " : WARNING : " + text + "
")
	
func info(text: String) -> void:
	file.store_string(str(Time.get_datetime_string_from_system()) + " : INFO : " + text + "
")
	file.flush()
	if console: print(str(Time.get_datetime_string_from_system()) + " : INFO : " + text)
	
func debug(text: String) -> void:
	file.store_string(str(Time.get_datetime_string_from_system()) + " : DEBUG : " + text + "
")
	file.flush()
	if console: print(str(Time.get_datetime_string_from_system()) + " : DEBUG : " + text)

