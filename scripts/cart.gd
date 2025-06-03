extends VBoxContainer
signal label_meta_info_emitted(label_name)
signal label_meta_info_emitted_modify(meta_data, label_name, modified)

const ITEM_FONT_SIZE = 45
const ROW_MIN_HEIGHT = 45
const ICON_BUTTON_SIZE = 15
const CONTAINER_SEPARATION = 60

const TRASH_CAN_ICON_PATH = "res://assets/trash-can-10411.svg"
const EDIT_ICON_PATH = "res://assets/edit-icon.svg"

var trash_can_icon_texture: Texture2D
var edit_icon_texture: Texture2D

var notification_layer: CanvasLayer
var popup: Panel

var buy_label_text = ""
var buy_label_sum = 0
var buy_label_count: Array[int] = [0,0,0,0,0,0]
var total_richtext = null


func _init():
	if ResourceLoader.exists(TRASH_CAN_ICON_PATH):
		trash_can_icon_texture = load(TRASH_CAN_ICON_PATH)
	if ResourceLoader.exists(EDIT_ICON_PATH):
		edit_icon_texture = load(EDIT_ICON_PATH)

func _ready():
	var path_to_emitter_from_tab = "catalogo/VBoxContainer"
	var emitter_node = get_parent().get_parent().get_node_or_null(path_to_emitter_from_tab)

	if emitter_node:
		print("Emitter node found: ", emitter_node.get_path())
		var error_code = emitter_node.connect("label_meta_info_emitted", Callable(self, "_on_label_info_received"))
		if error_code == OK:
			print("Emitter signal connected successfully.")
		else:
			print("Failed to connect emitter signal. Code: ", error_code)
	else:
		print("Error: Could not find the emitter node")
		print("Check that 'catalogo' has a child called 'VBoxContainer' (or whatever its real name is) and that it is the correct node.")
	var vbox2 = get_parent().get_child(0)
	if vbox2:
		total_richtext=vbox2.get_child(1).get_child(0)
	if total_richtext is RichTextLabel:
		total_richtext.bbcode_enabled = true
		total_richtext.meta_clicked.connect(_on_buy_meta_clicked.bind(total_richtext))
	else:
		print("Error.")
	notification_layer = CanvasLayer.new()
	notification_layer.layer = 100
	get_tree().root.add_child.call_deferred(notification_layer)

func _on_buy_meta_clicked(url_action, label : RichTextLabel):
	var txt = "¿Desea confirmar la compra?\nTotal: $" + str(buy_label_sum) + "MXN"
	if url_action == "buy":
		create_pop_up(txt, null, 2)

func _on_label_info_received(meta_data, label_name, modified):
	var subtotal = int(15 * meta_data)
	var label_text = ""
	var label_id = ""
	
	match label_name:
		"RichTextLabel1":
			buy_label_count[0] = subtotal
			label_id = "Prod_1"
			label_text = "Ventilador\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel2":
			buy_label_count[1] = subtotal
			label_id = "Prod_2"
			label_text = "Organizador Tipo Lapicero\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel3":
			buy_label_count[2] = subtotal
			label_id = "Prod_3"
			label_text = "Llavero\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel4":
			buy_label_count[3] = subtotal
			label_id = "Prod_4"
			label_text = "Pantalla de Lámpara\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel5":
			buy_label_count[4] = subtotal
			label_id = "Prod_5"
			label_text = "Organizador de Cepillos de Dientes\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel6":
			buy_label_count[5] = subtotal
			label_id = "Prod_6"
			label_text = "Portavasos\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		_:
			print("Unrecognized option.")

	if label_text != "" && meta_data == 1 && modified == false:
		create_item_row(label_id,label_text)
	else:
		modify_item_row(meta_data,label_id,label_text)
	
	buy_label_sum = buy_label_count[0] +buy_label_count[1] +buy_label_count[2] +buy_label_count[3]+buy_label_count[4]+buy_label_count[5]
	buy_label_text = "[left][font_size=70]Total: $" +str(buy_label_sum)+ " MXN	[url=buy][color=green][b]Comprar[/b][/color][/url][/font_size][/left]"
	#buy_label_sum = 0
	if total_richtext:
		total_richtext.text = buy_label_text

func modify_item_row(meta_payload,label_id: String,label_text: String):
	var item_panel = get_node_or_null("ItemPanel_" + label_id)
	if item_panel != null:
		var row_label = item_panel.get_node_or_null("Row_" + label_id)
		if row_label != null:
			var label = row_label.get_node_or_null("ItemLabel")
			if label != null:
				label.text = label_text

func create_item_row(label_id: String,label_text: String):
	var style = preload("res://paginas/rich_text_label_style.tres")

	var panel = PanelContainer.new()
	panel.name = "ItemPanel_" + label_id
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = ROW_MIN_HEIGHT
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", style)

	var row_container = HBoxContainer.new()
	row_container.name = "Row_" + label_id
	row_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var item_label = Label.new()
	item_label.name = "ItemLabel"
	item_label.text = label_text
	item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	item_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_label.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	item_label.add_theme_color_override("font_color", Color.BLACK)
	row_container.add_child(item_label)

	var delete_button_icon = TextureButton.new()
	delete_button_icon.name = "DeleteButton"
	delete_button_icon.texture_normal = trash_can_icon_texture
	delete_button_icon.custom_minimum_size = Vector2(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE)
	delete_button_icon.ignore_texture_size = false
	delete_button_icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	delete_button_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	delete_button_icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	delete_button_icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	delete_button_icon.pressed.connect(_on_delete_button_pressed.bind(panel))

	var modify_button_icon = TextureButton.new()
	modify_button_icon.name = "ModifyButton"
	modify_button_icon.texture_normal = edit_icon_texture
	modify_button_icon.custom_minimum_size = Vector2(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE)
	modify_button_icon.ignore_texture_size = false
	modify_button_icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	modify_button_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	modify_button_icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modify_button_icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	modify_button_icon.pressed.connect(_on_modify_button_pressed.bind(panel))

	row_container.add_child(modify_button_icon)
	row_container.add_child(delete_button_icon)

	panel.add_child(row_container)
	add_child(panel)

func create_pop_up(txt: String, panel, action):
	var existente = get_tree().current_scene.get_node_or_null("WindowPopup")
	if existente:
		return

	if txt.is_empty():
		print("Warning: create_pop_up called with empty text.")
		txt = "[Sin Productos Seleccionados para modificar]"

	var ventana = Window.new()
	ventana.name = "WindowPopup"
	ventana.borderless = true
	ventana.unresizable = true
	ventana.size = Vector2i(512, 512) 

	var root_margin_container = MarginContainer.new()
	root_margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_margin_container.add_theme_constant_override("margin_right", 5)
	root_margin_container.add_theme_constant_override("margin_left", 50)
	root_margin_container.add_theme_constant_override("margin_top", 15)
	root_margin_container.add_theme_constant_override("margin_bottom", 15)
	ventana.add_child(root_margin_container)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_margin_container.add_child(vbox)

	var label = Label.new()
	label.text = txt
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)
	var line_edit = null
	if action == 1: 
		line_edit =LineEdit.new()
		line_edit.placeholder_text = "Ingresa cantidad"
		line_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
		line_edit.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
		vbox.add_child(line_edit)

	var spacer_buttons = Control.new()
	spacer_buttons.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer_buttons)

	var button_hbox = HBoxContainer.new()
	button_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(button_hbox)

	var cancel_button = Button.new()
	cancel_button.text = "Cancelar"

	var cancel_style = StyleBoxFlat.new()
	cancel_style.bg_color = Color.RED
	cancel_style.set_content_margin_all(8)
	cancel_button.add_theme_stylebox_override("normal", cancel_style)
	cancel_button.add_theme_stylebox_override("hover", cancel_style)
	cancel_button.add_theme_stylebox_override("pressed", cancel_style)
	cancel_button.add_theme_color_override("font_color", Color.WHITE)
	cancel_button.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	cancel_button.pressed.connect(ventana.queue_free)
	button_hbox.add_child(cancel_button)
	
	var button_spacer = Control.new()
	button_spacer.custom_minimum_size = Vector2(20,0)
	button_hbox.add_child(button_spacer)

	var accept_button = Button.new()
	accept_button.text = "Aceptar"
	accept_button.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)

	var accept_style = StyleBoxFlat.new()
	accept_style.bg_color = Color.GREEN.darkened(0.2)
	accept_style.set_content_margin_all(8)
	accept_button.add_theme_stylebox_override("normal", accept_style)
	accept_button.add_theme_color_override("font_color", Color.WHITE)

	if action == 1:
		accept_button.pressed.connect(_btn_accept_modify.bind(line_edit, panel, ventana))
	elif action == 2:
		accept_button.pressed.connect(_btn_accept_buy.bind(ventana))
	button_hbox.add_child(accept_button)

	get_tree().current_scene.add_child(ventana)
	ventana.popup_centered()
	if action == 1:
		line_edit.grab_focus()

func _btn_accept_buy(ventana):
	show_notification("¡Compra Realizada Correctamente!")	
	ventana.queue_free()
	

func _on_popup_hidden_then_change_scene():
	if is_instance_valid(popup):
		popup.queue_free()
		var err = get_tree().change_scene_to_file("res://control.tscn")
		if err != OK:
			print("Error al intentar reiniciar la escena: ", err)

func _btn_accept_modify(line_edit, panel, ventana):
		var input_value = line_edit.text
		if input_value.is_valid_float():
			label_meta_info_emitted_modify.emit(int(input_value), panel.name, true)
		else:
			return
	
		ventana.queue_free()

func _on_modify_button_pressed(panel: PanelContainer):
	var label = panel.get_child(0).get_child(0)
	create_pop_up(label.text, panel, 1)

func _on_delete_button_pressed(row_to_delete: PanelContainer):
	var label_name = row_to_delete.name
	print(label_name)
	if label_name == "ItemPanel_Prod_1":
		buy_label_count[0] = 0
	elif label_name == "ItemPanel_Prod_2":
		buy_label_count[1] = 0
	elif label_name == "ItemPanel_Prod_3":
		buy_label_count[2] = 0
	elif label_name == "ItemPanel_Prod_4":
		buy_label_count[3] = 0
	elif label_name == "ItemPanel_Prod_5":
		buy_label_count[4] = 0
	elif label_name == "ItemPanel_Prod_6":
		buy_label_count[5] = 0
	else:
		print("Unrecognized option.")
	buy_label_sum = buy_label_count[0] +buy_label_count[1] +buy_label_count[2] +buy_label_count[3]+buy_label_count[4]+buy_label_count[5]
	buy_label_text = "[left][font_size=70]Total: $" +str(buy_label_sum)+ " MXN	[url=buy][color=green][b]Comprar[/b][/color][/url][/font_size][/left]"
	#buy_label_sum = 0
	if total_richtext:
		total_richtext.text = buy_label_text
	row_to_delete.queue_free()
	var window = get_tree().current_scene.get_node_or_null("WindowPopup")
	if window != null:
		window.queue_free()
	label_meta_info_emitted.emit(row_to_delete.name)

func show_notification(message: String):
	if is_instance_valid(popup):
		popup.queue_free()
	
	popup = Panel.new()

	var style = StyleBoxFlat.new()
	style.bg_color = Color.GREEN.darkened(0.2)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	popup.add_theme_stylebox_override("panel", style)
	
	popup.anchor_left = 0.1
	popup.anchor_right = 0.9
	popup.anchor_top = 0.05
	popup.anchor_bottom = 0.0
	popup.offset_top = 5
	popup.custom_minimum_size = Vector2(0, 160)
	
	var container = MarginContainer.new()
	container.add_theme_constant_override("margin_left", 64)
	container.add_theme_constant_override("margin_top", 12)
	container.add_theme_constant_override("margin_bottom", 12)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var label = Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL

	container.add_child(label)
	popup.add_child(container)

	notification_layer.add_child(popup)
	
	popup.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(popup, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.0)
	tween.tween_property(popup, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_on_popup_hidden_then_change_scene)
