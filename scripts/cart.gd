# carrito.gd
extends VBoxContainer

# --- Constantes de Configuración ---
const ITEM_FONT_SIZE = 45       # Tamaño de la fuente para el texto del label
const ROW_MIN_HEIGHT = 45       # Altura mínima para cada fila (label + botón)
const ICON_BUTTON_SIZE = 15     # Tamaño deseado para el botón de icono (cuadrado)

const TRASH_CAN_ICON_PATH = "res://assets/trash-can-10411.svg" # Ruta al icono de papelera

# --- Variables de Script ---
var trash_can_icon_texture: Texture2D # Textura del icono precargada

func _init():
	if ResourceLoader.exists(TRASH_CAN_ICON_PATH):
		trash_can_icon_texture = load(TRASH_CAN_ICON_PATH)
		if trash_can_icon_texture == null:
			print("ERROR: No se pudo cargar el icono desde '", TRASH_CAN_ICON_PATH, "'.")
	else:
		print("ERROR: No se encontró el archivo de icono en '", TRASH_CAN_ICON_PATH, "'. Los botones no tendrán icono.")

func _ready():
	print("[%s] _ready() se está ejecutando. Creando elementos..." % name)

	crear_fila_de_elemento("Documento Importante Alpha")
	crear_fila_de_elemento("Tarea Pendiente #001")
	crear_fila_de_elemento("Recordatorio Final")
	crear_fila_de_elemento("Configuración del Sistema X")

# Función para crear una fila completa (Label + Botón de Icono)
func crear_fila_de_elemento(texto_del_label: String):
	print("[%s] Creando fila para: '%s'" % [name, texto_del_label])

	# 1. Contenedor de Fila (HBoxContainer)
	# Este HBoxContainer contendrá el Label y el TextureButton en una línea horizontal.
	var fila_container = HBoxContainer.new()
	var style = preload("res://paginas/rich_text_label_style.tres")
	fila_container.name = "Fila_" + texto_del_label.replace(" ", "_").substr(0, 20) # Nombre único para depuración
	fila_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL # La fila ocupa todo el ancho disponible
	fila_container.custom_minimum_size.y = ROW_MIN_HEIGHT # Asegura altura mínima para la fila
	fila_container.add_theme_stylebox_override("normal",style)

	# 2. Label para el Texto
	var label_item = Label.new()
	label_item.name = "TextoLabel" # Para poder encontrarlo luego si es necesario
	label_item.text = texto_del_label
	label_item.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT # Texto alineado a la izquierda
	label_item.vertical_alignment = VERTICAL_ALIGNMENT_CENTER   # Texto centrado verticalmente en su espacio
	label_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL # El label se expande para ocupar el espacio, empujando el botón a la derecha
	label_item.size_flags_vertical = Control.SIZE_EXPAND_FILL   # El label ocupa la altura de la fila
	
	label_item.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
	label_item.add_theme_color_override("font_color", Color.BLACK)
	# Opcional: para que el texto no se corte si es muy largo
	# label_item.autowrap_mode = TextServer.AUTOWRAP_WORD
	# label_item.clip_text = true 
	fila_container.add_child(label_item)

	# 3. Botón de Icono (TextureButton) para la acción de eliminar
	var boton_eliminar_icono = TextureButton.new()
	boton_eliminar_icono.name = "BotonEliminar"
	
	if trash_can_icon_texture:
		boton_eliminar_icono.texture_normal = trash_can_icon_texture
		# Puedes añadir texturas para otros estados si las tienes (hover, pressed)
		# boton_eliminar_icono.texture_hover = load("res://assets/trash_hover.png")
		# boton_eliminar_icono.texture_pressed = load("res://assets/trash_pressed.png")
	else:
		boton_eliminar_icono.text = "X" # Texto de fallback si el icono no carga
		print("Advertencia: Icono de papelera no cargado para la fila '%s'" % texto_del_label)

	# Configuración del tamaño y apariencia del TextureButton
	boton_eliminar_icono.custom_minimum_size = Vector2(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE)
	boton_eliminar_icono.ignore_texture_size = false # El botón intentará ser del tamaño de custom_minimum_size
	boton_eliminar_icono.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED # Escala el icono manteniendo aspecto y centrado
	
	boton_eliminar_icono.size_flags_horizontal = Control.SIZE_SHRINK_CENTER # No se expande, se centra en su "celda" del HBox
	boton_eliminar_icono.size_flags_vertical = Control.SIZE_EXPAND_FILL   # Ocupa la altura de la fila, icono centrado por stretch_mode

	# Conectar la señal 'pressed' del TextureButton a la función de eliminación
	# Pasamos 'fila_container' para poder eliminar toda la fila.
	boton_eliminar_icono.pressed.connect(_on_boton_eliminar_presionado.bind(fila_container))
	fila_container.add_child(boton_eliminar_icono)

	# 4. (Opcional) Espaciador para el margen derecho fijo
	# Este Control vacío añade un pequeño espacio después del botón, antes del borde derecho del HBoxContainer.
	
	# Añadir la fila completa al VBoxContainer principal
	add_child(fila_container)
	return fila_container

# Función que se ejecuta cuando se presiona el botón de icono (eliminar)
func _on_boton_eliminar_presionado(fila_a_eliminar: HBoxContainer):
	# Intentamos obtener el texto del label dentro de la fila para un mensaje más informativo
	var texto_del_item = "un elemento" # Valor por defecto
	var label_encontrado = fila_a_eliminar.get_node_or_null("TextoLabel")
	if label_encontrado and label_encontrado is Label:
		texto_del_item = label_encontrado.text

	print("ACCIÓN: Botón de eliminar para el item '%s' fue presionado. Eliminando fila..." % texto_del_item)

	# Aquí iría cualquier lógica adicional antes de eliminar (ej. actualizar datos, etc.)

	fila_a_eliminar.queue_free() # Elimina el HBoxContainer y todos sus hijos (Label, TextureButton, Espaciador)
	
	print("Fila para '%s' puesta en cola para eliminación." % texto_del_item)
