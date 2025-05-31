extends VBoxContainer

const ITEM_FONT_SIZE = 45
const ROW_MIN_HEIGHT = 45
const ICON_BUTTON_SIZE = 15
const CONTAINER_SEPARATION = 60

const TRASH_CAN_ICON_PATH = "res://assets/trash-can-10411.svg"

var trash_can_icon_texture: Texture2D

func _init():
	if ResourceLoader.exists(TRASH_CAN_ICON_PATH):
		trash_can_icon_texture = load(TRASH_CAN_ICON_PATH)

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

func _on_label_info_received(meta_data, label_name):
	print("Received signal from VBoxContainer!")
	print("Meta Data: ", meta_data)
	print("Label Name: ", label_name)
	
	
	
	match label_name:
		"RichTextLabel1":
			create_item_row("Ventilador")
		"RichTextLabel2":
			create_item_row("Organizador Tipo Lapicero")
		"RichTextLabel3":
			create_item_row("Llavero")
		"RichTextLabel4":
			create_item_row("Pantalla de Lámpara")
		"RichTextLabel5":
			create_item_row("Organizador de Cepillos de Dientes")
		"RichTextLabel6":
			create_item_row("Portavasos")
		_:
			print("Unrecognized option.")

func create_item_row(label_text: String):
	var style = preload("res://paginas/rich_text_label_style.tres")

	var panel = PanelContainer.new()
	panel.name = "ItemPanel_" + label_text.replace(" ", "_").substr(0, 20)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = ROW_MIN_HEIGHT
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", style)

	var row_container = HBoxContainer.new()
	row_container.name = "Row_" + label_text.replace(" ", "_").substr(0, 20)
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
	if trash_can_icon_texture:
		delete_button_icon.texture_normal = trash_can_icon_texture
	else:
		delete_button_icon.text = "X"

	delete_button_icon.custom_minimum_size = Vector2(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE)
	delete_button_icon.ignore_texture_size = false
	delete_button_icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	delete_button_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	delete_button_icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	delete_button_icon.pressed.connect(_on_delete_button_pressed.bind(panel))

	row_container.add_child(delete_button_icon)

	panel.add_child(row_container)
	add_child(panel)

	return panel

func _on_delete_button_pressed(row_to_delete: PanelContainer):
	row_to_delete.queue_free()
