extends RichTextLabel

func _richtextlabel_on_meta_clicked(meta):
	var phone_number: String = "tel:" + str(meta).replace(' ', '')
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at runtime.
	OS.shell_open(phone_number)
