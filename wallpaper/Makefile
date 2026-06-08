APP     = GradientWallpaper.app
BINARY  = $(APP)/Contents/MacOS/GradientWallpaper
SDK     = $(shell xcrun --sdk macosx --show-sdk-path)
ARCH    = $(shell uname -m)
TARGET  = $(ARCH)-apple-macosx12.0

.PHONY: build run stop install install-login clean

build:
	mkdir -p $(APP)/Contents/MacOS
	swiftc \
		-target $(TARGET) \
		-sdk "$(SDK)" \
		-framework AppKit \
		-framework WebKit \
		-framework CoreGraphics \
		-o $(BINARY) \
		GradientWallpaper.swift
	cp Info.plist $(APP)/Contents/Info.plist
	codesign --force --deep --sign - $(APP)
	@echo "✓ Build complete"

run: build
	pkill -f GradientWallpaper 2>/dev/null || true
	open $(APP)
	@echo "✓ Running (menu bar icon active)"

stop:
	pkill -f GradientWallpaper 2>/dev/null && echo "✓ Stopped" || echo "Not running"

install: build
	cp -r $(APP) /Applications/
	@echo "✓ Installed to /Applications/GradientWallpaper.app"

install-login: install
	osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/GradientWallpaper.app", hidden:true}'
	@echo "✓ Added to login items (System Settings → General → Login Items)"

clean:
	rm -rf $(APP)
