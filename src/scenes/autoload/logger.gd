extends Node

enum Name {
	Game,
	Networking
}

enum Type {
	Error,
	Info,
	Warning
}

func get_prefix(name : String, type : String):
	return str("[", name.to_lower(), " : ", type.to_upper(), "]", " ")

func out(args : Array):
	var string : String
	for arg in args:
		string = string.insert(string.length(), arg)
	print(string)
	Game.console.get_node("Margin/Output").text += (string+"\n")
