# This node is not expected to be inherited by any node, this is just a
# node extension to manipulate the values according to its given behaviour

@abstract
class_name BaseBehavior extends Node

@abstract
func call_trigger()

@abstract
func enable_trigger()

@abstract
func disable_trigger()

@abstract
func hovered_reference()
