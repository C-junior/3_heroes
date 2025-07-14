# wave_manager.gd
extends Node

var wave_data: Dictionary

func _ready():
    load_wave_data()

func load_wave_data():
    var file = FileAccess.open("res://wave_data.json", FileAccess.READ)
    if file:
        var content = file.get_as_text()
        var json = JSON.new()
        var error = json.parse(content)
        if error == OK:
            wave_data = json.get_data()
        else:
            print("Error parsing wave data JSON: " + json.get_error_message())
    else:
        print("Error loading wave data file.")

func get_wave_enemies(wave_number: int) -> Array:
    if wave_data and "waves" in wave_data:
        for wave in wave_data["waves"]:
            if wave["wave"] == wave_number:
                return wave["enemies"]
    return []
