extends VBoxContainer
signal label_meta_info_emitted(meta_data, label_name)

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
		label_meta_info_emitted.emit(meta_payload, label.name)
