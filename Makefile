GODOT_PATH := godot
GAME_SLUG := circlerc


# All does not include encrypted newgrounds and gamejolt exports as these require special setup with custom export templates.
all: linux-x86_64 linux-x86_32 linux-arm64 windows-x86_64 windows-x86_32 windows-arm64 macos-universal web

# Godot can throw a bunch of compile errors when importing scripts if it is the
# first time opening the project due to depending on other scripts (usually
# autoloads) that haven't been imported yet.
#
# Opening and closing the project once (as this command does) avoids this
# problem.
#
# This problem was initially discovered when using this Makefile for CircleRC.
# To see if this problem still exists for the current project, you can try
# deleting the .godot folder and then running godot --headless --export-release <template> <path>
# to see if it produces any errors. If it doesn't, this step might not be needed.
import:
	$(GODOT_PATH) --headless --import

linux-x86_64: import
	$(GODOT_PATH) --headless --export-release linux-x86_64 "build/linux-x86_64/$(GAME_SLUG).x86_64"

linux-x86_32: import
	$(GODOT_PATH) --headless --export-release linux-x86_32 "build/linux-x86_32/$(GAME_SLUG).x86_32"

linux-arm64: import
	$(GODOT_PATH) --headless --export-release linux-arm64 "build/linux-arm64/$(GAME_SLUG).arm64"

windows-x86_64: import
	$(GODOT_PATH) --headless --export-release windows-x86_64 "build/windows-x86_64/$(GAME_SLUG).exe"

windows-x86_32: import
	$(GODOT_PATH) --headless --export-release windows-x86_32 "build/windows-x86_32/$(GAME_SLUG).exe"

windows-arm64: import
	$(GODOT_PATH) --headless --export-release windows-arm64 "build/windows-arm64/$(GAME_SLUG).exe"

macos-universal: import
	$(GODOT_PATH) --headless --export-release macos-universal "build/macos-universal/$(GAME_SLUG).app"

web: import
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

newgrounds: import
	$(GODOT_PATH) --headless --export-release newgrounds "build/newgrounds/index.html"

game_jolt: game_jolt-except-macos game_jolt-macos-universal

game_jolt-except-macos: game_jolt-linux-x86_64 game_jolt-linux-x86_32 game_jolt-linux-arm64 game_jolt-windows-x86_64 game_jolt-windows-x86_32 game_jolt-windows-arm64 game_jolt-macos-universal game_jolt-web

game_jolt-linux-x86_64: import
	$(GODOT_PATH) --headless --export-release game_jolt-linux-x86_64 "build/game_jolt/linux-x86_64/$(GAME_SLUG).x86_64"

game_jolt-linux-x86_32: import
	$(GODOT_PATH) --headless --export-release game_jolt-linux-x86_32 "build/game_jolt/linux-x86_32/$(GAME_SLUG).x86_32"

game_jolt-linux-arm64: import
	$(GODOT_PATH) --headless --export-release game_jolt-linux-arm64 "build/game_jolt/linux-arm64/$(GAME_SLUG).arm64"

game_jolt-windows-x86_64: import
	$(GODOT_PATH) --headless --export-release game_jolt-windows-x86_64 "build/game_jolt/windows-x86_64/$(GAME_SLUG).exe"

game_jolt-windows-x86_32: import
	$(GODOT_PATH) --headless --export-release game_jolt-windows-x86_32 "build/game_jolt/windows-x86_32/$(GAME_SLUG).exe"

game_jolt-windows-arm64: import
	$(GODOT_PATH) --headless --export-release game_jolt-windows-arm64 "build/game_jolt/windows-arm64/$(GAME_SLUG).exe"

game_jolt-macos-universal: import
	$(GODOT_PATH) --headless --export-release game_jolt-macos-universal "build/game_jolt/macos-universal/$(GAME_SLUG).app"

game_jolt-web: import
	$(GODOT_PATH) --headless --export-release game_jolt-web "build/game_jolt/web/index.html"
