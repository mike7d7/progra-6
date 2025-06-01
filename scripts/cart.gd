extends VBoxContainer
signal label_meta_info_emitted(meta_data, label_name)

const ITEM_FONT_SIZE = 45
const ROW_MIN_HEIGHT = 45
const ICON_BUTTON_SIZE = 15
const CONTAINER_SEPARATION = 60

const TRASH_CAN_ICON_PATH = "res://assets/trash-can-10411.svg"
const EDIT_ICON_PATH = "res://assets/edit-icon.svg"

var trash_can_icon_texture: Texture2D
var edit_icon_texture: Texture2D

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

func _on_label_info_received(meta_data, label_name):
	var label_text = ""
	var label_id = ""
	var subtotal = 15 * meta_data
	
	match label_name:
		"RichTextLabel1":
			label_id = "Prod_1"
			label_text = "Ventilador\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel2":
			label_id = "Prod_2"
			label_text = "Organizador Tipo Lapicero\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel3":
			label_id = "Prod_3"
			label_text = "Llavero\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel4":
			label_id = "Prod_4"
			label_text = "Pantalla de Lámpara\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel5":
			label_id = "Prod_5"
			label_text = "Organizador de Cepillos de Dientes\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		"RichTextLabel6":
			label_id = "Prod_6"
			label_text = "Portavasos\nCantidad: " + str(meta_data) + "\nSubtotal: $" + str(subtotal) + " MXN "
		_:
			print("Unrecognized option.")

	if label_text != "" && meta_data == 1:
		create_item_row(label_id,label_text)
	else:
		modify_item_row(meta_data,label_id,label_text)

func modify_item_row(meta_payload,label_id: String,label_text: String):
	var label = get_node_or_null("ItemPanel_" + label_id).get_node_or_null("Row_" + label_id).get_node_or_null("ItemLabel")
	if label:
		label.text = label_text
	else:
		print("ERROR")

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

	return panel

#func create_pop_up(txt: String):
	#var existente = get_tree().current_scene.get_node_or_null("WindowPopup")
	#if existente:
		#return
	#if txt.is_empty():
		#print("Warning: create_pop_up called with empty text.")
		#txt = "[Default Text for Debug]" # Use a placeholder
	#var ventana = Window.new()
	#ventana.name = "WindowPopup"
	#ventana.title = "Modificar Cantidad" # Correct for Window in Godot 4
	#ventana.size = Vector2i(512, 512) # Use Vector2i for window size; adjust as needed
	#ventana.add_theme_font_size_override("title_font_size", 24)
	#ventana.unresizable = true
	#var margin_container = MarginContainer.new()
	#margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	##margin_container.add_theme_constant_override("margin_right", 10)
	##margin_container.add_theme_constant_override("margin_left", 10)
	##margin_container.add_theme_constant_override("margin_top", 10)
	##margin_container.add_theme_constant_override("margin_bottom", 10)
	#ventana.add_child(margin_container)
	#var vbox = VBoxContainer.new()
	#vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	#margin_container.add_child(vbox)
	#var label = Label.new()
	#label.text = txt
	#label.autowrap_mode = TextServer.AUTOWRAP_WORD 
	#label.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	#label.add_theme_color_override("font_color", Color.BLACK)
	#label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#label.size_flags_vertical = Control.SIZE_EXPAND_FILL # Make label expand vertically
	#label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_TOP
	#vbox.add_child(label)
	#ventana.close_requested.connect(ventana.queue_free)
	#get_tree().current_scene.add_child(ventana)
	#ventana.popup_centered() # This makes the window modal, visible, and centered.

# Asumo que ITEM_FONT_SIZE es una constante definida en alguna parte de tu script o autoload
# const ITEM_FONT_SIZE = 18 # Ejemplo, asegúrate de que esté definida

func create_pop_up(txt: String, callback_on_accept: Callable = Callable()):
	var existente = get_tree().current_scene.get_node_or_null("WindowPopup")
	if existente:
		existente.queue_free() # Opcional: cierra la existente si se llama de nuevo

	if txt.is_empty():
		print("Warning: create_pop_up called with empty text.")
		txt = "[Default Text for Debug]"

	var ventana = Window.new()
	ventana.name = "WindowPopup"
	# ventana.title = "Modificar Cantidad" # Ya no es visible con borderless
	
	# Hacer la ventana sin bordes y sin capacidad de redimensionar
	ventana.borderless = true
	ventana.unresizable = true
	
	# Tamaño ajustado para un pop-up (ejemplo, puedes cambiarlo)
	ventana.size = Vector2i(512, 512) 
	# Si es borderless, popup_centered() la posicionará.
	# Para un control más fino o si no usas popup_centered(), podrías necesitar
	# ajustar su posición manualmente o usar initial_position.
	# ventana.initial_position = Window.INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS # o CENTER_SCREEN

	# Contenedor principal con márgenes para dar espacio interno al contenido
	var root_margin_container = MarginContainer.new()
	root_margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_margin_container.add_theme_constant_override("margin_right", 15)
	root_margin_container.add_theme_constant_override("margin_left", 15)
	root_margin_container.add_theme_constant_override("margin_top", 15)
	root_margin_container.add_theme_constant_override("margin_bottom", 15)
	ventana.add_child(root_margin_container)

	# VBoxContainer para organizar los elementos verticalmente
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_margin_container.add_child(vbox)

	# Etiqueta para el texto informativo
	var label = Label.new()
	label.text = txt
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# label.size_flags_vertical = Control.SIZE_EXPAND_FILL # Quitar para que no expanda tanto si hay poco texto
	vbox.add_child(label)

	# Espaciador
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10) # Pequeño espacio
	vbox.add_child(spacer)

	# LineEdit para la entrada numérica
	var line_edit = LineEdit.new()
	line_edit.placeholder_text = "Ingresa cantidad"
	# Para mostrar el teclado numérico en Android/iOS:
	line_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	line_edit.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	vbox.add_child(line_edit)

	# Espaciador antes de los botones
	var spacer_buttons = Control.new()
	spacer_buttons.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer_buttons)

	# HBoxContainer para los botones
	var button_hbox = HBoxContainer.new()
	button_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER # Centra los botones en el HBox
	vbox.add_child(button_hbox)

	# Botón de Cancelar
	var cancel_button = Button.new()
	cancel_button.text = "Cancelar"
	# Estilo para el botón rojo de cancelar
	var cancel_style = StyleBoxFlat.new()
	cancel_style.bg_color = Color.RED
	cancel_style.set_content_margin_all(8) # Padding interno del botón
	cancel_button.add_theme_stylebox_override("normal", cancel_style)
	cancel_button.add_theme_stylebox_override("hover", cancel_style) # Mismo estilo al pasar el mouse
	cancel_button.add_theme_stylebox_override("pressed", cancel_style) # Mismo estilo al presionar
	cancel_button.add_theme_color_override("font_color", Color.WHITE)
	cancel_button.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)

	cancel_button.pressed.connect(ventana.queue_free) # Cierra la ventana
	button_hbox.add_child(cancel_button)
	
	# Espacio entre botones
	var button_spacer = Control.new()
	button_spacer.custom_minimum_size = Vector2(20,0)
	button_hbox.add_child(button_spacer)

	# Botón de Aceptar
	var accept_button = Button.new()
	accept_button.text = "Aceptar"
	accept_button.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	# Estilo para el botón de aceptar (opcional, puedes hacerlo similar al de cancelar con otro color)
	var accept_style = StyleBoxFlat.new()
	accept_style.bg_color = Color.GREEN.darkened(0.2) # Un verde oscuro
	accept_style.set_content_margin_all(8)
	accept_button.add_theme_stylebox_override("normal", accept_style)
	accept_button.add_theme_color_override("font_color", Color.WHITE)

	accept_button.pressed.connect(func():
		var input_value = line_edit.text
		if input_value.is_valid_float(): # Verifica si es un número válido (entero o decimal)
			print("Valor aceptado: ", input_value)
			if callback_on_accept.is_valid():
				callback_on_accept.call(input_value) # Llama al callback con el valor
		else:
			print("Entrada no válida: ", input_value)
	# Aquí podrías, por ejemplo, hacer que el LineEdit parpadee o mostrar un error
	# Por ahora, no cerramos la ventana si la entrada no es válida.
	# Si quieres cerrar siempre, quita el 'else' y mueve ventana.queue_free() afuera.
			return # No cerramos si no es válido y no hay callback, o dejamos que el callback decida.
	
		ventana.queue_free() # Cierra la ventana después de aceptar y llamar al callback
	)
	button_hbox.add_child(accept_button)

	# Añadir a la escena y mostrar
	get_tree().current_scene.add_child(ventana)
	ventana.popup_centered()
	line_edit.grab_focus() # Poner el foco en el LineEdit para que el teclado aparezca

func _on_modify_button_pressed(panel: PanelContainer):
	var label = panel.get_child(0).get_child(0)
	create_pop_up(label.text)
	#label_meta_info_emitted.emit(5, panel.name)

func _on_delete_button_pressed(row_to_delete: PanelContainer):
	row_to_delete.queue_free()
	var window = get_tree().current_scene.get_node_or_null("WindowPopup")
	if window != null:
		window.queue_free()
	label_meta_info_emitted.emit(row_to_delete.name)
