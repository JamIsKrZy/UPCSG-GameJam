extends Control

signal left_screen_hovered;
signal right_screen_hovered;
signal screen_hovered_out;

func left_hovered() -> void:
	left_screen_hovered.emit()

func hovered_out() -> void:
	screen_hovered_out.emit()

func right_hovered() -> void:
	right_screen_hovered.emit()
