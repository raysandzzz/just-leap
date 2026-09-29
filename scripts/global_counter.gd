extends Node

signal update_death_counter

var deaths: int = 0

func add_death():
	deaths += 1
	update_death_counter.emit()
