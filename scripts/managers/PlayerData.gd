extends Node

enum Gender {
	MALE,
	FEMALE
}

var player_name: String = "Alex"

var gender: Gender = Gender.MALE

var talent: String = "music"

var stats := {
	"eloquence": 1,
	"culture": 1,
	"empathy": 1,
	"composure": 1,
	"perception": 1
}

func has_talent(required_talent: String) -> bool:
	return talent == required_talent

func get_stat(stat_name: String) -> int:
	return int(stats.get(stat_name, 0))