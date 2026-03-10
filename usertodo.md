# User Todo - 3 Heroes Roguelike Autobattler

These are tasks that need your input or action to complete.

---

## Required from You

### 1. Add Knight to the Scene
- Open `main_game.tscn` in Godot Editor
- Add a Knight node as a child of `PlayerCharacters` (similar to Cleric, Valkyrie, Wizard)
- Use the `knight.tscn` scene

### 2. Add Knight UI Button
- Open `ui.tscn` in Godot Editor  
- Duplicate one of the existing character buttons (e.g., `valkyrie_button`)
- Rename it to `knight_button`
- Connect the `pressed` signal to a new function `_on_knight_button_pressed`

### 3. Add Skill Selection for Knight
- In `ui.tscn`, duplicate one of the `SkillPopup*` HBoxContainers
- Rename it to `SkillPopupKnight`

### 4. Test the Game
- Run the game in Godot
- Verify waves spawn correctly
- Verify skill selection works for all 4 characters
- Report any errors you encounter

---

## Optional Improvements You Can Add Later

- [ ] Add more enemy types with unique abilities
- [ ] Add item drops from enemies
- [ ] Add a shop between waves
- [ ] Add visual effects for skills (particles, animations)
- [ ] Add sound effects and music
- [ ] Add a main menu / pause menu
