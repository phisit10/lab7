extends Node3D

@onready var animation_tree = %AnimationTree
#@onready var hurt = $AnimationPlayer2

func hurt():
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
