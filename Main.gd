extends Control

const CARD_NAMES := ["獵手射擊", "拾荒補給", "戰地繃帶"]
const CARD_COSTS := [1, 0, 1]
const CARD_VALUES := [12, 10, 18]
const HEX_RADIUS := 42.0

var time_of_day := 6.0
var health := 78
var hunger := 74
var water := 68
var infection := 12
var action_points := 3
var supplies := 4
var enemy_health := 46
var turn := 1
var message := "你在第 7 號安全屋醒來。選擇一格開始探索。"
var selected_card := -1
var game_over := false
var hexes: Array[Vector2i] = []

func _ready() -> void:
	for row in range(3):
		for column in range(4):
			hexes.append(Vector2i(column, row))
	queue_redraw()

func _process(delta: float) -> void:
	if not game_over:
		time_of_day = fmod(time_of_day + delta * 0.08, 24.0)
	queue_redraw()

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0b1015"))
	draw_rect(Rect2(0, 0, size.x, 82), Color("#18232d"))
	draw_string(ThemeDB.fallback_font, Vector2(34, 43), "WASTELAND: LAST HORIZON", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#f6c453"))
	draw_string(ThemeDB.fallback_font, Vector2(35, 67), "廢土生存 · 六角探索 · Roguelike 卡牌", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#91a4af"))
	_draw_status_panel()
	_draw_map()
	_draw_battle_panel()
	_draw_cards()
	if game_over:
		_draw_overlay()

func _draw_status_panel() -> void:
	var panel := Rect2(28, 105, 265, 530)
	draw_rect(panel, Color("#151e25"), true)
	draw_rect(panel, Color("#334653"), false, 2)
	draw_string(ThemeDB.fallback_font, Vector2(48, 143), "生存狀態", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#f6c453"))
	var hour := int(floor(time_of_day))
	var phase := "白晝" if hour >= 6 and hour < 18 else "夜晚"
	draw_string(ThemeDB.fallback_font, Vector2(48, 178), "第 %02d 天 · %02d:00 · %s" % [turn, hour, phase], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#d7e0e5"))
	_draw_meter("生命", health, Color("#e26d5a"), 218)
	_draw_meter("飽食", hunger, Color("#e4a853"), 273)
	_draw_meter("水分", water, Color("#55a8c8"), 328)
	_draw_meter("感染", infection, Color("#ae6fc1"), 383)
	draw_string(ThemeDB.fallback_font, Vector2(48, 445), "行動點數  %d / 3" % action_points, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#d7e0e5"))
	draw_string(ThemeDB.fallback_font, Vector2(48, 477), "補給品      %d" % supplies, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#d7e0e5"))
	_draw_button(Rect2(48, 515, 210, 45), "返回安全屋並存檔", Color("#3b6655"))
	_draw_button(Rect2(48, 572, 210, 45), "休息治療", Color("#405878"))

func _draw_meter(label: String, value: int, color: Color, y: float) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(48, y), "%s  %d%%" % [label, value], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#d7e0e5"))
	draw_rect(Rect2(48, y + 10, 210, 12), Color("#26343d"), true)
	draw_rect(Rect2(48, y + 10, 210.0 * clampf(value / 100.0, 0.0, 1.0), 12), color, true)

func _draw_map() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(330, 130), "六角廢土地圖", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#f6c453"))
	draw_string(ThemeDB.fallback_font, Vector2(330, 157), "點擊相鄰節點移動，每次移動消耗 1 小時", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#91a4af"))
	for index in hexes.size():
		var cell := hexes[index]
		var center := Vector2(400 + cell.x * 104 + (52 if cell.y % 2 else 0), 225 + cell.y * 92)
		var color := Color("#2d5960") if index == 0 else Color("#263a43")
		if index == 5:
			color = Color("#6c4d2f")
		if index == 9:
			color = Color("#593e58")
		_draw_hex(center, HEX_RADIUS, color, index)

func _draw_hex(center: Vector2, radius: float, color: Color, index: int) -> void:
	var points := PackedVector2Array()
	for corner in 6:
		var angle := deg_to_rad(60 * corner - 30)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[4], points[5], points[0]]), Color("#6b818b"), 2.0)
	var marker := "安全屋" if index == 0 else ("廢墟" if index == 5 else ("感染區" if index == 9 else "探索"))
	draw_string(ThemeDB.fallback_font, center + Vector2(-27, 5), marker, HORIZONTAL_ALIGNMENT_LEFT, 55, 13, Color("#e7edf0"))

func _draw_battle_panel() -> void:
	var panel := Rect2(820, 105, 430, 255)
	draw_rect(panel, Color("#151e25"), true)
	draw_rect(panel, Color("#334653"), false, 2)
	draw_string(ThemeDB.fallback_font, Vector2(848, 143), "遭遇：變異獵犬", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#ef8a67"))
	draw_string(ThemeDB.fallback_font, Vector2(848, 177), "敵方生命 %d / 60" % enemy_health, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#d7e0e5"))
	draw_rect(Rect2(848, 190, 370, 16), Color("#3b2527"), true)
	draw_rect(Rect2(848, 190, 370.0 * enemy_health / 60.0, 16), Color("#d35d54"), true)
	draw_string(ThemeDB.fallback_font, Vector2(848, 245), "目前回合：%d    AP：%d" % [turn, action_points], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f6c453"))
	draw_string(ThemeDB.fallback_font, Vector2(848, 278), "先消耗卡牌，再點擊地圖探索。", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#91a4af"))
	_draw_button(Rect2(848, 295, 160, 42), "結束回合", Color("#6c4d2f"))

func _draw_cards() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(330, 510), "手牌（點擊使用）", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#f6c453"))
	for index in 3:
		var rect := Rect2(330 + index * 165, 530, 150, 130)
		var color := Color("#324b58") if selected_card != index else Color("#8b6330")
		draw_rect(rect, color, true)
		draw_rect(rect, Color("#91a4af"), false, 2)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(14, 30), CARD_NAMES[index], HORIZONTAL_ALIGNMENT_LEFT, 125, 18, Color("#f3f4f6"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(14, 60), "消耗 AP %d" % CARD_COSTS[index], HORIZONTAL_ALIGNMENT_LEFT, 125, 15, Color("#f6c453"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(14, 91), "效果 %d" % CARD_VALUES[index], HORIZONTAL_ALIGNMENT_LEFT, 125, 15, Color("#d7e0e5"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(14, 115), "點擊出牌", HORIZONTAL_ALIGNMENT_LEFT, 125, 13, Color("#91a4af"))
	draw_string(ThemeDB.fallback_font, Vector2(330, 695), message, HORIZONTAL_ALIGNMENT_LEFT, 850, 16, Color("#c4d2d8"))

func _draw_button(rect: Rect2, text: String, color: Color) -> void:
	draw_rect(rect, color, true)
	draw_rect(rect, Color("#91a4af"), false, 1)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 29), text, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24, 16, Color("#f3f4f6"))

func _draw_overlay() -> void:
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.02, 0.03, 0.04, 0.86), true)
	draw_string(ThemeDB.fallback_font, Vector2(420, 300), "探險結束", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color("#f6c453"))
	draw_string(ThemeDB.fallback_font, Vector2(420, 350), message, HORIZONTAL_ALIGNMENT_LEFT, 500, 20, Color("#d7e0e5"))
	_draw_button(Rect2(420, 390, 220, 50), "重新開始", Color("#3b6655"))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)

func _handle_click(position: Vector2) -> void:
	if game_over:
		if Rect2(420, 390, 220, 50).has_point(position):
			_restart()
		return
	for index in 3:
		if Rect2(330 + index * 165, 530, 150, 130).has_point(position):
			_play_card(index)
			return
	if Rect2(848, 295, 160, 42).has_point(position):
		_end_turn()
		return
	if Rect2(48, 515, 210, 45).has_point(position):
		_return_to_shelter()
		return
	if Rect2(48, 572, 210, 45).has_point(position):
		_rest()
		return
	for index in hexes.size():
		var cell := hexes[index]
		var center := Vector2(400 + cell.x * 104 + (52 if cell.y % 2 else 0), 225 + cell.y * 92)
		if position.distance_to(center) <= HEX_RADIUS:
			_explore(index)
			return

func _play_card(index: int) -> void:
	if CARD_COSTS[index] > action_points:
		message = "AP 不足，請先結束回合。"
		return
	action_points -= CARD_COSTS[index]
	selected_card = index
	if index == 0:
		enemy_health = maxi(0, enemy_health - CARD_VALUES[index])
		message = "獵手射擊命中，對變異獵犬造成 %d 傷害。" % CARD_VALUES[index]
	elif index == 1:
		supplies += 1
		hunger = mini(100, hunger + CARD_VALUES[index])
		water = mini(100, water + 5)
		message = "你拆開補給包，恢復飽食與水分。"
	else:
		health = mini(100, health + CARD_VALUES[index])
		infection = maxi(0, infection - 5)
		message = "繃帶止住傷口，生命值恢復。"
	if enemy_health == 0:
		message = "變異獵犬已被擊倒，拾得 2 份補給。"
		supplies += 2
	queue_redraw()

func _explore(index: int) -> void:
	if index == 0:
		message = "安全屋：這裡可以休息、整理卡組並安全存檔。"
		return
	if action_points <= 0:
		message = "沒有行動點數了，請結束回合。"
		return
	action_points -= 1
	hunger = maxi(0, hunger - 4)
	water = maxi(0, water - 6)
	infection = mini(100, infection + (3 if time_of_day >= 18 else 1))
	message = "你探索了 %s，時間推進 1 小時。" % ("廢墟並找到零件" if index == 5 else "一處未知節點")
	if index == 5:
		supplies += 1
	if hunger == 0 or water == 0:
		health = maxi(0, health - 8)
	if health == 0:
		game_over = true
		message = "你因傷勢與資源耗盡倒下，探險所得全部遺失。"
	queue_redraw()

func _end_turn() -> void:
	turn += 1
	action_points = 3
	health = maxi(0, health - (4 if enemy_health > 0 else 0))
	message = "敵人反擊後，你重新整理手牌。獲得 3 點 AP。"
	if health == 0:
		game_over = true
		message = "你在廢土中倒下了。"

func _return_to_shelter() -> void:
	message = "你帶著 %d 份補給返回安全屋，探險成果已安全存檔。" % supplies
	action_points = 3
	turn = 1

func _rest() -> void:
	health = 100
	infection = 0
	time_of_day = 6.0
	message = "你在安全屋休息完成：生命全滿、感染清除、時間回到清晨。"

func _restart() -> void:
	time_of_day = 6.0
	health = 78
	hunger = 74
	water = 68
	infection = 12
	action_points = 3
	supplies = 4
	enemy_health = 46
	turn = 1
	selected_card = -1
	game_over = false
	message = "你在第 7 號安全屋醒來。選擇一格開始探索。"
