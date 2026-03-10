# Godot MCP Configuration Setup

## Configuration Files Created

This project includes pre-configured MCP settings for the Godot MCP server.

## For Claude Desktop (Windows)

**Copy to:** `%APPDATA%\Claude\claude_desktop_config.json`
- Or: `C:\Users\<YourUsername>\AppData\Roaming\Claude\claude_desktop_config.json`

**Source file:** `claude_desktop_config.json`

## For Cline (VS Code Extension)

**Copy to:** `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json`
- Or: `C:\Users\<YourUsername>\AppData\Roaming\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json`

**Source file:** `cline_mcp_settings.json`

## For Cursor (Project-specific)

Already configured in: `.cursor/mcp.json`

## Quick Setup Commands

### Claude Desktop (PowerShell)
```powershell
Copy-Item claude_desktop_config.json $env:APPDATA\Claude\claude_desktop_config.json
```

### Cline (PowerShell)
```powershell
$clinePath = "$env:APPDATA\Code\User\globalStorage\saoudrizwan.claude-dev\settings"
New-Item -ItemType Directory -Force -Path $clinePath
Copy-Item cline_mcp_settings.json "$clinePath\cline_mcp_settings.json"
```

## After Configuration

1. Restart your AI assistant (Claude Desktop, Cline, or Cursor)
2. The Godot MCP tools will be available automatically

## Available Tools

- `launch_editor` - Open Godot editor for a project
- `run_project` - Execute Godot project in debug mode
- `get_debug_output` - Retrieve console output and errors
- `stop_project` - Stop running project
- `get_godot_version` - Get installed Godot version
- `list_projects` - Find Godot projects in a directory
- `get_project_info` - Get project structure details
- `create_scene` - Create new scenes
- `add_node` - Add nodes to scenes
- `load_sprite` - Load textures into Sprite2D nodes
- `export_mesh_library` - Export 3D scenes as MeshLibrary
- `save_scene` - Save scenes
- `get_uid` - Get UID for files (Godot 4.4+)
- `update_project_uids` - Update UID references (Godot 4.4+)

## Optional: Set Godot Path

If Godot isn't auto-detected, add to the `env` section:
```json
"env": {
  "DEBUG": "true",
  "GODOT_PATH": "C:/Path/To/Your/Godot_v4.x.x.exe"
}
```
