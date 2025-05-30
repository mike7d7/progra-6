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
	var path_al_emisor_desde_better_tab_c = "catalogo/VBoxContainer"
	var nodo_emisor = get_parent().get_parent().get_node_or_null(path_al_emisor_desde_better_tab_c)

	if nodo_emisor:
		print("Nodo emisor encontrado: ", nodo_emisor.get_path())
		var error_code = nodo_emisor.connect("label_meta_info_emitted", Callable(self, "_on_label_info_received"))
		if error_code == OK:
			print("Señal del emisor conectada exitosamente.")
		else:
			print("Error al conectar la señal del emisor. Código: ", error_code)
	else:
		print("Error: No se pudo encontrar el nodo emisor")
		print("Verifica que 'catalogo' tenga un hijo llamado 'VBoxContainer' (o como se llame realmente) y que este sea el nodo correcto.")


func _on_label_info_received(meta_data, label_name):
	print("Received signal from VBoxContainer!")
	print("Meta Data: ", meta_data)
	print("Label Name: ", label_name)
	#add_theme_constant_override("separation", CONTAINER_SEPARATION)
	
	match label_name:
		"RichTextLabel1":
			crear_fila_de_elemento("Ventilador")
		"RichTextLabel2":
			crear_fila_de_elemento("Organizador Tipo Lapicero")
		"RichTextLabel3":
			crear_fila_de_elemento("Llavero")
		"RichTextLabel4":
			crear_fila_de_elemento("Pantalla de Lámpara")
		"RichTextLabel5":
			crear_fila_de_elemento("Organizador de Cepillos de Dientes")
		"RichTextLabel6":
			crear_fila_de_elemento("Portavasos")
		_:
			print("Opción no reconocida.")


func crear_fila_de_elemento(texto_del_label: String):
	var style = preload("res://paginas/rich_text_label_style.tres")

	var panel = PanelContainer.new()
	panel.name = "PanelFila_" + texto_del_label.replace(" ", "_").substr(0, 20)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = ROW_MIN_HEIGHT
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", style)

	var fila_container = HBoxContainer.new()
	fila_container.name = "Fila_" + texto_del_label.replace(" ", "_").substr(0, 20)
	fila_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var label_item = Label.new()
	label_item.name = "TextoLabel"
	label_item.text = texto_del_label
	label_item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_item.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label_item.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_item.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label_item.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	label_item.add_theme_color_override("font_color", Color.BLACK)
	fila_container.add_child(label_item)

	var boton_eliminar_icono = TextureButton.new()
	boton_eliminar_icono.name = "BotonEliminar"
	if trash_can_icon_texture:
		boton_eliminar_icono.texture_normal = trash_can_icon_texture
	else:
		boton_eliminar_icono.text = "X"

	boton_eliminar_icono.custom_minimum_size = Vector2(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE)
	boton_eliminar_icono.ignore_texture_size = false
	boton_eliminar_icono.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	boton_eliminar_icono.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	boton_eliminar_icono.size_flags_vertical = Control.SIZE_EXPAND_FILL
	boton_eliminar_icono.pressed.connect(_on_boton_eliminar_presionado.bind(panel))

	fila_container.add_child(boton_eliminar_icono)

	panel.add_child(fila_container)
	add_child(panel)

	return panel

func _on_boton_eliminar_presionado(fila_a_eliminar: PanelContainer):
	fila_a_eliminar.queue_free()
