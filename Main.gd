extends Control

@onready var title_label: Label = $Title
@onready var subtitle_label: Label = $Subtitle
@onready var tick_label: Label = $Tick

var time_of_day := 6.0
var stage_name := "安全屋"

func _ready() -> void:
	_update_hud()

func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + delta * 0.35, 24.0)
	_update_hud()

func _update_hud() -> void:
	var hour := int(floor(time_of_day))
	var phase := "晨"
	if hour >= 6 and hour < 18:
		phase = "日"
	elif hour >= 18:
		phase = "夜"
	
	title_label.text = "Wasteland: Last Horizon"
	subtitle_label.text = "廢土探索 • 六角地圖 • 卡牌戰鬥 • 安全屋撤離"
	tick_label.text = "時間: %02d:00 %s | 狀態: %s" % [hour, phase, stage_name]
