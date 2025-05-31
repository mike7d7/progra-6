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
		var error_code = emitter_node.connect("label_meta_info_emitted", Callable(self, "_on_erase_received"))
		if error_code == OK:
			print("Emitter signal connected successfully.")
		else:
			print("Failed to connect emitter signal. Code: ", error_code)
	else:
		print("Error: Could not find the emitter node")

	var number_of_labels = 6

	for i in range(1, number_of_labels + 1):
		var label_node_name = "RichTextLabel" + str(i)
		var current_label = get_node_or_null(label_node_name)
		if current_label is RichTextLabel: # Verify that the node exists and is a RichTextLabel
			current_label.bbcode_enabled = true
			var error_code = current_label.meta_clicked.connect(_on_any_label_meta_clicked.bind(current_label))
			#if error_code == OK:
				#print("meta_clicked signal connected successfully for: ", current_label.name)
			#else:
				#print("Error connecting meta_clicked for ", current_label.name, ". Code: ", error_code)
		else:
			print("Error: Node '", label_node_name, "' not found or not a RichTextLabel.")

func _on_erase_received(meta_data, label_name):
	print("Received signal from VBoxContainer!")
	print("Meta Data: ", meta_data)
	print("Label Name: ", label_name)
	var meta_data_como_string: String = str(meta_data)
	if label_name == "ItemPanel_Prod_1_" + meta_data_como_string:
		num_product_1 = meta_data
	elif label_name == "ItemPanel_Prod_2_" + meta_data_como_string:
		num_product_2 = meta_data
	elif label_name == "ItemPanel_Prod_3_" + meta_data_como_string:
		num_product_3 = meta_data
	elif label_name == "ItemPanel_Prod_4_" + meta_data_como_string:
		num_product_4 = meta_data
	elif label_name == "ItemPanel_Prod_5_" + meta_data_como_string:
		num_product_5 = meta_data
	elif label_name == "ItemPanel_Prod_6_" + meta_data_como_string:
		num_product_6 = meta_data
	else:
			print("Unrecognized option.")


func _on_any_label_meta_clicked(url_action, label : RichTextLabel):
	var meta_payload = null
	print("Meta clicked: '", url_action, "' in Label: '", label.name, "'")
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
