extends CanvasLayer

class_name HUD

@onready var main_menu = $VBoxContainer/MainMenu
@onready var fight_menu = $VBoxContainer/FightMenu
@onready var dialog_menu = $VBoxContainer/DialogMenu

@onready var active_menu = dialog_menu

@onready var message_node: RichTextLabel = $VBoxContainer/DialogMenu/MarginContainer/Message

signal finish_read

func _ready():
	Global.hud = self

func _unhandled_input(event):
	if event.is_action("ui_accept") or event.is_action("click"):
		emit_signal("finish_read")

func select_menu(menu):
	if active_menu == menu:
		return
	active_menu.hide()
	active_menu = menu
	menu.show()

func _on_fight_button_pressed():
	select_menu(fight_menu)

func show_message(msg):
	select_menu(dialog_menu)
	
	message_node.text = ''
	for character in msg:
		message_node.text += character
		await get_tree().create_timer(0.02).timeout 
	
	await get_tree().create_timer(0.1).timeout 
	await finish_read
	
	return
