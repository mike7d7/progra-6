extends VBoxContainer

func _ready():
	var number_of_labels = 6

	for i in range(1, number_of_labels + 1):
		var label_node_name = "RichTextLabel" + str(i)
		var current_label = get_node_or_null(label_node_name)
		if current_label is RichTextLabel: # Verify that the node exists and is a RichTextLabel
			current_label.bbcode_enabled = true
			var error_code = current_label.meta_clicked.connect(_on_any_label_meta_clicked.bind(current_label))
			if error_code == OK:
				print("meta_clicked signal connected successfully for: ", current_label.name)
			else:
				print("Error connecting meta_clicked for ", current_label.name, ". Code: ", error_code)
		else:
			print("Error: Node '", label_node_name, "' not found or not a RichTextLabel.")

func _on_any_label_meta_clicked(meta_payload, label : RichTextLabel):
	print("Meta clicked: '", meta_payload, "' in Label: '", label.name, "'")
