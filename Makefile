all: build

build:
	godot --path ./src/ --export Windows Riot-Win64.exe --no-window	
	godot --path ./src/ --export Windows\ 32-bit Riot-Win32.exe --no-window
	godot --path ./src/ --export macOS Riot-Mac.zip --no-window	
	godot --path ./src/ --export macOS\ 32-bit Riot-Mac-32.zip --no-window
	godot --path ./src/ --export Linux Riot-Linux.x86_64 --no-window	
	godot --path ./src/ --export Linux\ 32-bit Riot-Linux.i386 --no-window
	[ ! -d dist ] && mkdir dist
	mv src/Riot* dist/

clean:
	rm -rf dist/
