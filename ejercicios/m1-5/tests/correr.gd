extends SceneTree
## Corrector automático del ejercicio m1-5 (NONA Studio Academy).
## No lo modifiques: GitHub lo ejecuta en cada push y escribe el resultado.
## Uso: godot --headless --path <carpeta> --script res://tests/correr.gd -- --salida <archivo.json> --commit <sha>

const VENTANA := 0.5
var pruebas: Array = []
var salida := ""
var commit := ""


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--salida" and i + 1 < args.size():
			salida = args[i + 1]
		if args[i] == "--commit" and i + 1 < args.size():
			commit = args[i + 1]
	_correr.call_deferred()


func _correr() -> void:
	var script: Script = load("res://jugador.gd")
	if script == null or not script.can_instantiate():
		_anotar("El script se carga", false, "jugador.gd tiene un error de sintaxis o no existe. Ábrelo en Godot: el editor marca la línea.")
		_terminar()
		return
	await _prueba_un_golpe(script)
	await _prueba_aviso(script)
	await _prueba_ventana(script)
	await _prueba_sostenido(script)
	await _prueba_duracion(script)
	await _prueba_colision(script)
	_terminar()


# ---------- utilidades ----------

func _anotar(nombre: String, ok: bool, mensaje: String) -> void:
	pruebas.append({"nombre": nombre, "ok": ok, "mensaje": "" if ok else mensaje})


func _jugador(script: Script) -> Area2D:
	var j := Area2D.new()
	j.set_script(script)
	var forma := CollisionShape2D.new()
	forma.name = "CollisionShape2D"
	var circulo := CircleShape2D.new()
	circulo.radius = 16
	forma.shape = circulo
	j.add_child(forma)
	j.name = "Jugador"
	root.add_child(j)
	if j.has_method("_on_body_entered") and not j.body_entered.is_connected(j._on_body_entered):
		j.body_entered.connect(j._on_body_entered)
	return j


func _enemigo(pos: Vector2) -> CharacterBody2D:
	var e := CharacterBody2D.new()
	var forma := CollisionShape2D.new()
	var circulo := CircleShape2D.new()
	circulo.radius = 18
	forma.shape = circulo
	e.add_child(forma)
	e.position = pos
	root.add_child(e)
	return e


func _cuadros(n: int) -> void:
	for i in n:
		await physics_frame


func _esperar(segundos: float) -> void:
	await create_timer(segundos).timeout


func _limpiar() -> void:
	for n in root.get_children():
		n.queue_free()
	await _cuadros(2)


func _n(x: float) -> String:
	return ("%.2f" % x).replace(".", ",")


func _vidas(j: Node) -> int:
	var v = j.get("vidas")
	return v if v is int else -999


# ---------- pruebas ----------

func _prueba_un_golpe(script: Script) -> void:
	var j := _jugador(script)
	await _cuadros(2)
	_enemigo(Vector2.ZERO)
	await _cuadros(4)
	var v := _vidas(j)
	_anotar("Un enemigo resta una vida", v == 2, "Después del primer contacto, vidas debería valer 2 y vale %d." % v)
	await _limpiar()


func _prueba_aviso(script: Script) -> void:
	var j := _jugador(script)
	var recibidos: Array = []
	if not j.has_signal("golpeado"):
		_anotar("La señal golpeado avisa el valor nuevo", false, "jugador.gd no declara la señal golpeado.")
		await _limpiar()
		return
	j.golpeado.connect(func(x): recibidos.append(x))
	await _cuadros(2)
	_enemigo(Vector2.ZERO)
	await _cuadros(4)
	var ok: bool = recibidos.size() >= 1 and recibidos[0] == 2
	var visto := "nada" if recibidos.is_empty() else str(recibidos[0])
	_anotar("La señal golpeado avisa el valor nuevo", ok, "Con el primer golpe, la señal tendría que llevar 2 y llevó %s. ¿Se emite antes o después de restar?" % visto)
	await _limpiar()


func _prueba_ventana(script: Script) -> void:
	var j := _jugador(script)
	await _cuadros(2)
	_enemigo(Vector2.ZERO)
	await _esperar(0.15)
	_enemigo(Vector2.ZERO)
	await _esperar(0.15)
	var v := _vidas(j)
	_anotar("Durante la ventana no hay más daño", v == 2, "Un segundo enemigo llegó a los 0,15 s del primero y vidas quedó en %d. Durante la invulnerabilidad los golpes nuevos no cuentan." % v)
	await _limpiar()


func _prueba_sostenido(script: Script) -> void:
	var j := _jugador(script)
	await _cuadros(2)
	_enemigo(Vector2.ZERO)
	await _esperar(VENTANA + 0.25)
	var v := _vidas(j)
	_anotar("El contacto sostenido vuelve a doler", v == 1, "Un enemigo quedó encima %s s y vidas vale %d; debería valer 1. Al terminar la ventana nadie vuelve a avisar: hay que preguntar qué toca al jugador." % [_n(VENTANA + 0.25), v])
	await _limpiar()


func _prueba_duracion(script: Script) -> void:
	var j := _jugador(script)
	var tiempos: Array = []
	if j.has_signal("golpeado"):
		j.golpeado.connect(func(_x): tiempos.append(Time.get_ticks_msec()))
	await _cuadros(2)
	_enemigo(Vector2.ZERO)
	await _esperar(1.2)
	if tiempos.size() < 2:
		_anotar("La ventana dura medio segundo", false, "No hubo un segundo golpe con el enemigo encima, así que no se pudo medir la ventana. Resuelve primero la prueba del contacto sostenido.")
	else:
		var dt: float = (tiempos[1] - tiempos[0]) / 1000.0
		_anotar("La ventana dura medio segundo", dt >= 0.45 and dt <= 0.75, "Entre el primer y el segundo golpe pasaron %s s; deberían ser unos 0,5 s. Si depende de los cuadros por segundo, mídela en segundos." % _n(dt))
	await _limpiar()


func _prueba_colision(script: Script) -> void:
	var j := _jugador(script)
	var forma := j.get_node("CollisionShape2D") as CollisionShape2D
	await _cuadros(2)
	_enemigo(Vector2.ZERO)
	await _esperar(VENTANA + 0.2)
	var ok: bool = j.monitoring and not forma.disabled
	_anotar("La detección sigue encendida", ok, "Después de un golpe, el área quedó sin detectar choques (forma desactivada o monitoring apagado). Es el error del caso 1 de Investigar.")
	await _limpiar()


# ---------- salida ----------

func _terminar() -> void:
	var aprobadas: int = pruebas.filter(func(p): return p.ok).size()
	var datos := {
		"clase": "m1-5",
		"fecha": Time.get_datetime_string_from_system(true) + "Z",
		"commit": commit,
		"godot": Engine.get_version_info().string,
		"aprobado": aprobadas == pruebas.size() and pruebas.size() > 0,
		"aprobadas": aprobadas,
		"total": pruebas.size(),
		"pruebas": pruebas,
	}
	var texto := JSON.stringify(datos, "  ")
	print(texto)
	if salida != "":
		DirAccess.make_dir_recursive_absolute(salida.get_base_dir())
		var f := FileAccess.open(salida, FileAccess.WRITE)
		if f:
			f.store_string(texto)
			f.close()
	quit(0 if datos.aprobado else 1)
