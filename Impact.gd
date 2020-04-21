class_name Impact
extends Node2D

export var particle_direction = Vector2() setget olar
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func olar(direction):
	$Particles2D.process_material.direction.x = direction.x
	$Particles2D.process_material.direction.y = direction.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
