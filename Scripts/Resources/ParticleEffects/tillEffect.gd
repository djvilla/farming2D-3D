extends Spatial

onready var effect = $TillParticle
onready var timer = $Timer

var effect_time = 100#0.05

#func _ready():
#	effect.one_shot = true
#	effect.emitting = true
#	timer.set_wait_time(effect_time)
#	timer.connect("timeout", self, "_remove_effect")
#	timer.start()
#
#func _remove_effect():
#	queue_free()
