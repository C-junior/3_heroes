# Todo - Refactoring for Scalability and Maintainability

This document outlines the recommended refactoring tasks to improve the codebase of the game. The goal is to make the project more scalable, maintainable, and easier to work on in the long term.

## 1. Global State Management

**Problem:** The `global.gd` script is used as a singleton to manage game-wide state like currency. While convenient for small projects, extensive use of singletons can lead to tightly coupled code that is hard to test and debug.

**Recommendation:**

*   **Introduce a centralized game state manager:** Create a dedicated `GameStateManager` node that holds all the global data (e.g., currency, player progression, current level).
*   **Use dependency injection:** Instead of accessing the global singleton directly, pass the `GameStateManager` instance to the nodes that need it. This can be done through the scene tree or by using signals.
*   **Avoid direct UI updates from the global script:** The `global.gd` script directly updates the UI. It's better to use signals to notify the UI of changes and let the UI update itself.

## 2. Decouple Game Logic from UI

**Problem:** The `main_game.gd` script has direct references to UI elements like `wave_label` and `shop_ui`. This creates a tight coupling between the game logic and the UI, making it difficult to change one without affecting the other.

**Recommendation:**

*   **Use signals for communication:** The `main_game.gd` script should emit signals when the game state changes (e.g., `wave_started`, `wave_completed`, `open_shop`).
*   **Create a dedicated UI manager:** A `UIManager` script should listen for these signals and update the UI accordingly. This will keep the game logic and UI separate.

## 3. Improve Character and Item Management

**Problem:** The `character.gd` script is a `GridContainer`, which suggests it's a UI element. The logic for equipping items is also very specific to the "knight" character. The `item_manager.gd` is a good start, but it can be improved.

**Recommendation:**

*   **Separate character logic from UI:** The `character.gd` script should be a pure logic script (`Node` or `Node2D`) and not a UI element. The UI for displaying characters should be a separate scene.
*   **Create a generic `Character` class:** Instead of having specific logic for the "knight", create a base `Character` class with common properties and methods. Different character types can then inherit from this base class.
*   **Centralize item management:** The `ItemManager` should be responsible for all item-related operations, including equipping, unequipping, and managing the item database.

## 4. Wave Manager Improvements

**Problem:** The `wave_manager.gd` script has the wave configurations hardcoded in a dictionary. This is not very scalable and makes it difficult to add new waves or modify existing ones without changing the code.

**Recommendation:**

*   **Use data-driven design:** Store the wave configurations in a separate data file (e.g., a JSON or a custom resource file).
*   **Load wave data at runtime:** The `WaveManager` should load the wave data from the file at runtime. This will make it easy to add new waves or modify existing ones without changing the code.

## 5. Scene and Asset Organization

**Problem:** The project structure has many assets and scenes in the root directory. This can become messy as the project grows.

**Recommendation:**

*   **Create a clear folder structure:** Organize the assets and scenes into logical folders (e.g., `Scenes`, `Scripts`, `Assets/Characters`, `Assets/Enemies`, `Assets/UI`).
*   **Use sub-folders for better organization:** Within the main folders, use sub-folders to further organize the assets (e.g., `Assets/Characters/Knight`, `Assets/Characters/Wizard`).

By implementing these changes, the codebase will be more robust, scalable, and easier to maintain in the long run.
