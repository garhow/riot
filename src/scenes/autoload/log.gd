extends Node

enum Name {
	Networking
}

enum Type {
	Error,
	Info,
	Warning
}

const name_prefix = {
	"Networking": "network"
}

func get_prefix(name : String, type : String):
	return str("[", name_prefix.get(name), " : ", type.to_upper(), "]", " ")
