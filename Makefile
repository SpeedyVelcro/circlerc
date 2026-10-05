GODOT_PATH := godot
GAME_SLUG := circlerc


# All does not include encrypted newgrounds and gamejolt exports as these require special setup with custom export templates.
all: linux-x86_64 linux-x86_32 linux-arm64 windows-x86_64 windows-x86_32 windows-arm64 macos-universal web

linux-x86_64:
	$(GODOT_PATH) --headless --export-release linux-x86_64 "build/linux-x86_64/$(GAME_SLUG).x86_64"

linux-x86_32:
	$(GODOT_PATH) --headless --export-release linux-x86_32 "build/linux-x86_32/$(GAME_SLUG).x86_32"

linux-arm64:
	$(GODOT_PATH) --headless --export-release linux-arm64 "build/linux-arm64/$(GAME_SLUG).arm64"

windows-x86_64:
	$(GODOT_PATH) --headless --export-release windows-x86_64 "build/windows-x86_64/$(GAME_SLUG).exe"

windows-x86_32:
	$(GODOT_PATH) --headless --export-release windows-x86_32 "build/windows-x86_32/$(GAME_SLUG).exe"

windows-arm64:
	$(GODOT_PATH) --headless --export-release windows-arm64 "build/windows-arm64/$(GAME_SLUG).exe"

macos-universal:
	$(GODOT_PATH) --headless --export-release macos-universal "build/macos-universal/$(GAME_SLUG).app"

web:
	$(GODOT_PATH) --headless --export-release web "build/web/index.html"

# NB: You must set encryption keys on the relevant export templates before
# making encrypted builds, otherwise PCKs will not be protected. Additionally,
# you must replace your installed export templates with custom templates built
# using the encryption key. This is best done in a CI pipeline so you don't
# interfere with your installed export templates.
encrypted: encrypted-except-macos encrypted-macos

# Separate recipe without macOS is provided for CI pipelines that compile export
# templates in the same job as build, because these will likely do macOS on a
# separate runner running macOS itself.
encrypted-except-macos: newgrounds game_jolt-except-macos

encrypted-macos: game_jolt-macos-universal

newgrounds:
	$(GODOT_PATH) --headless --export-release newgrounds "build/newgrounds/index.html"

game_jolt: game_jolt-except-macos game_jolt-macos-universal

game_jolt-except-macos: game_jolt-linux-x86_64 game_jolt-linux-x86_32 game_jolt-linux-arm64 game_jolt-windows-x86_64 game_jolt-windows-x86_32 game_jolt-windows-arm64 game_jolt-macos-universal game_jolt-web

game_jolt-linux-x86_64:
	$(GODOT_PATH) --headless --export-release game_jolt-linux-x86_64 "build/game_jolt/linux-x86_64/$(GAME_SLUG).x86_64"

game_jolt-linux-x86_32:
	$(GODOT_PATH) --headless --export-release game_jolt-linux-x86_32 "build/game_jolt/linux-x86_32/$(GAME_SLUG).x86_32"

game_jolt-linux-arm64:
	$(GODOT_PATH) --headless --export-release game_jolt-linux-arm64 "build/game_jolt/linux-arm64/$(GAME_SLUG).arm64"

game_jolt-windows-x86_64:
	$(GODOT_PATH) --headless --export-release game_jolt-windows-x86_64 "build/game_jolt/windows-x86_64/$(GAME_SLUG).exe"

game_jolt-windows-x86_32:
	$(GODOT_PATH) --headless --export-release game_jolt-windows-x86_32 "build/game_jolt/windows-x86_32/$(GAME_SLUG).exe"

game_jolt-windows-arm64:
	$(GODOT_PATH) --headless --export-release game_jolt-windows-arm64 "build/game_jolt/windows-arm64/$(GAME_SLUG).exe"

game_jolt-macos-universal:
	$(GODOT_PATH) --headless --export-release game_jolt-macos-universal "build/game_jolt/macos-universal/$(GAME_SLUG).app"

game_jolt-web:
	$(GODOT_PATH) --headless --export-release game_jolt-web "build/game_jolt/web/index.html"
