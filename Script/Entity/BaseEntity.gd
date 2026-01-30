@abstract
class_name BaseEntity

signal entity_left
signal entity_attack(delta: float)

var type: EntityManager.Entity
var attack_meter: float:
	set(val):
		attack_meter = val

@abstract
func process(delta: float)

func leave():
	entity_left.emit()


func attack(delta: float ):
	entity_attack.emit(delta)
