extends VBoxContainer
signal label_meta_info_emitted(meta_data, label_name, modified)

const ITEM_FONT_SIZE = 45

var notification_layer: CanvasLayer
var popup: Panel

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
	notification_layer = CanvasLayer.new()
	notification_layer.layer = 100
	get_tree().root.add_child.call_deferred(notification_layer)

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

func _on_modify_received(meta_data, label_name, modified):
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
		label_meta_info_emitted.emit(meta_data, label, modified)

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
			show_notification("Producto añadido al \ncarrito exitosamente")
		else:
			show_notification(str(meta_payload)+" Productos añadidos \nal carrito exitosamente")
		label_meta_info_emitted.emit(meta_payload, label.name, false)
		

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
	container.add_theme_constant_override("margin_left", 190)
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
	tween.tween_callback(Callable(popup, "queue_free"))
