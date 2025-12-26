.PHONY: run install run restart-plasma

install:
	@mkdir -p ~/.local/share/plasma/plasmoids/org.shadow-paw.lxd-tray
	@rsync -avr --delete package/ ~/.local/share/plasma/plasmoids/org.shadow-paw.lxd-tray/

run: install
	@plasmashell --replace

restart-plasma:
	@plasmashell --replace > /dev/null 2>&1 &
