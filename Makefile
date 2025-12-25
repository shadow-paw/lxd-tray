.PHONY: run install

run:
	@mkdir -p ~/.local/share/plasma/plasmoids/org.shadow-paw.lxd-tray
	@rsync -avr --delete package/ ~/.local/share/plasma/plasmoids/org.shadow-paw.lxd-tray/
	@plasmashell --replace

install:
	@mkdir -p ~/.local/share/plasma/plasmoids/org.shadow-paw.lxd-tray
	@rsync -avr --delete package/ ~/.local/share/plasma/plasmoids/org.shadow-paw.lxd-tray/
	@plasmashell --replace > /dev/null 2>&1 &
