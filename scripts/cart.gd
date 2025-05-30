# carrito.gd
extends VBoxContainer

const CHECKBOX_FONT_SIZE = 50
const CHECKBOX_MIN_HEIGHT = 35 # La altura total del control

# Rutas a tus nuevos iconos de checkbox más grandes
const UNCHECKED_ICON_PATH = "res://assets/shopping-cart-01-svgrepo-com.svg" # CAMBIA ESTA RUTA
const CHECKED_ICON_PATH = "res://assets/home-svgrepo-com.svg"     # CAMBIA ESTA RUTA

# Variables para cargar los iconos una sola vez (opcional, para eficiencia)
var unchecked_icon_large: Texture2D
var checked_icon_large: Texture2D

func _init(): # Se llama una vez cuando se crea el objeto
	# Precargar los iconos para no cargarlos cada vez que se crea un checkbox
	# Manejar errores si los archivos no existen
	if ResourceLoader.exists(UNCHECKED_ICON_PATH):
		unchecked_icon_large = load(UNCHECKED_ICON_PATH)
	else:
		print("ERROR: No se encontró el icono en ", UNCHECKED_ICON_PATH)
		
	if ResourceLoader.exists(CHECKED_ICON_PATH):
		checked_icon_large = load(CHECKED_ICON_PATH)
	else:
		print("ERROR: No se encontró el icono en ", CHECKED_ICON_PATH)

func _ready():
	print("[%s] _ready() se está ejecutando." % name)
	add_theme_constant_override("separation", 10)

	crear_checkbox("Opción A - Con Icono Grande")
	crear_checkbox("Opción B - Marcada", true)
	crear_checkbox("Opción C - Otra Más")

func crear_checkbox(texto_label: String, estado_inicial: bool = false):
	print("[%s] creando checkbox: '%s'" % [name, texto_label])
	var checkbox = CheckBox.new()
	checkbox.text = texto_label
	checkbox.button_pressed = estado_inicial

	checkbox.add_theme_font_size_override("font_size", CHECKBOX_FONT_SIZE)
	checkbox.add_theme_color_override("font_color", Color.BLACK)
	checkbox.add_theme_color_override("font_hover_color", Color.BLACK)
	checkbox.add_theme_color_override("font_pressed_color", Color.BLACK)
	checkbox.add_theme_color_override("font_focus_color", Color.BLACK)
	checkbox.custom_minimum_size.y = CHECKBOX_MIN_HEIGHT

	# --- Sobrescribir los iconos del checkbox ---
	# Asegúrate de que los iconos se hayan cargado correctamente en _init()
	if unchecked_icon_large:
		checkbox.add_theme_icon_override("unchecked", unchecked_icon_large)
	if checked_icon_large:
		checkbox.add_theme_icon_override("checked", checked_icon_large)
	
	# (Opcional) También puedes querer sobrescribir los iconos para el estado deshabilitado
	# checkbox.add_theme_icon_override("checked_disabled", load("res://path/to/checked_disabled_large.png"))
	# checkbox.add_theme_icon_override("unchecked_disabled", load("res://path/to/unchecked_disabled_large.png"))

	checkbox.toggled.connect(_on_checkbox_toggled.bind(checkbox))
	add_child(checkbox)
	return checkbox

func _on_checkbox_toggled(is_now_pressed: bool, checkbox_node: CheckBox):
	print("ACCIÓN: El checkbox '%s' ahora está: %s" % [checkbox_node.text, "Marcado" if is_now_pressed else "Desmarcado"])
	# Tu lógica de acción aquí...
