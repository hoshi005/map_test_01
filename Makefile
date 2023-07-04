generate_icon_files:
	fvm flutter pub run flutter_launcher_icons:main

build_runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs