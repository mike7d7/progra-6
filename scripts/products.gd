extends VBoxContainer
signal label_meta_info_emitted(meta_data, label_name)

const ITEM_FONT_SIZE = 45

var num_product_1 = 1
var num_product_2 = 1
var num_product_3 = 1
var num_product_4 = 1
var num_product_5 = 1
var num_product_6 = 1

func _ready():
	var path_to_emitter_from_tab = "carrito/VBoxContainer"
	var emitter_node = get_parent().get_parent().get_node_or_null(path_to_emitter_from_tab)

	if emitter_node:
		print("Emitter node found: ", emitter_node.get_path())
		emitter_node.connect("label_meta_info_emitted", Callable(self, "_on_erase_received"))
		emitter_node.connect("label_meta_info_emitted_modify", Callable(self, "_on_modify_received"))
	else:
		print("Error: Could not find the emitter node")

	var number_of_labels = 6

	for i in range(1, number_of_labels + 1):
		var label_node_name = "RichTextLabel" + str(i)
		var current_label = get_node_or_null(label_node_name)
		if current_label is RichTextLabel: # Verify that the node exists and is a RichTextLabel
			current_label.bbcode_enabled = true
			current_label.meta_clicked.connect(_on_any_label_meta_clicked.bind(current_label))
		else:
			print("Error: Node '", label_node_name, "' not found or not a RichTextLabel.")

func _on_erase_received(label_name):
	if label_name == "ItemPanel_Prod_1":
		num_product_1 = 1
	elif label_name == "ItemPanel_Prod_2":
		num_product_2 = 1
	elif label_name == "ItemPanel_Prod_3":
		num_product_3 = 1
	elif label_name == "ItemPanel_Prod_4":
		num_product_4 = 1
	elif label_name == "ItemPanel_Prod_5":
		num_product_5 = 1
	elif label_name == "ItemPanel_Prod_6":
		num_product_6 = 1
	else:
		print("Unrecognized option.")

func _on_modify_received(meta_data, label_name):
	var label = null
	if label_name == "ItemPanel_Prod_1":
		label = "RichTextLabel1"
		num_product_1 = meta_data
	elif label_name == "ItemPanel_Prod_2":
		label = "RichTextLabel2"
		num_product_2 = meta_data
	elif label_name == "ItemPanel_Prod_3":
		label = "RichTextLabel3"
		num_product_3 = meta_data
	elif label_name == "ItemPanel_Prod_4":
		label = "RichTextLabel4"
		num_product_4 = meta_data
	elif label_name == "ItemPanel_Prod_5":
		label = "RichTextLabel5"
		num_product_5 = meta_data
	elif label_name == "ItemPanel_Prod_6":
		label = "RichTextLabel6"
		num_product_6 = meta_data
	else:
		print("Unrecognized option.")
	if label != null:
		label_meta_info_emitted.emit(meta_data, label)

func _on_any_label_meta_clicked(url_action, label : RichTextLabel):
	var meta_payload = null
	if url_action == "num_prod":
		match label.name:
			"RichTextLabel1":
				meta_payload = num_product_1
				num_product_1+=1
			"RichTextLabel2":
				meta_payload = num_product_2
				num_product_2+=1
			"RichTextLabel3":
				meta_payload = num_product_3
				num_product_3+=1
			"RichTextLabel4":
				meta_payload = num_product_4
				num_product_4+=1
			"RichTextLabel5":
				meta_payload = num_product_5
				num_product_5+=1
			"RichTextLabel6":
				meta_payload = num_product_6
				num_product_6+=1
			_:
				print("Unrecognized option.")
	if meta_payload:
		if meta_payload == 1:
			create_temporal_top_popup("Producto añadido al \ncarrito exitosamente")
		else:
			create_temporal_top_popup(str(meta_payload)+" Productos añadidos\nal carrito exitosamente")
		label_meta_info_emitted.emit(meta_payload, label.name)
		

func create_temporal_top_popup(txt: String):
	var existente = get_tree().current_scene.get_node_or_null("WindowPopup")
	if existente:
		existente.queue_free()

	if txt.is_empty():
		print("Warning: create_pop_up called with empty text.")
		txt = "No se pudo añadir tu \nproducto al carrito"

	var ventana = Window.new()
	ventana.name = "WindowPopup"
	ventana.borderless = true
	ventana.unresizable = true
	#ventana.transparent_bg = true 
	ventana.size = Vector2i(512, 128) 

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.set_alignment(VBoxContainer.ALIGNMENT_CENTER)
	ventana.add_child(vbox)

	var label = Label.new()
	label.text = txt
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(label)
	
	get_tree().current_scene.add_child(ventana)
	
	var screen_size = get_viewport().size
	var window_size = ventana.size
	var top_offset = 0 # Pequeño margen desde la parte superior
	
	ventana.position = Vector2i(
		((screen_size.x - window_size.x) + 85) / 2,
		top_offset
	)
	
	ventana.show()

	var timer = get_tree().create_timer(2.0) # 2.0 segundos
	timer.timeout.connect(func():
		if is_instance_valid(ventana): # Asegurarse de que la ventana aún exista
			ventana.queue_free()
	)
	
