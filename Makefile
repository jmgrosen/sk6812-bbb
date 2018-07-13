PRU_TOOLS_BIN=
PRU_ASM=$(PRU_TOOLS_BIN)clpru
PRU_HEX=$(PRU_TOOLS_BIN)hexpru
PRU_ASM_FLAGS=--silicon_version=3

PRU_LINKER_CMD=pru/am335x_pru_imem.cmd

.PHONY: all deploy
all: pru/sk6812rgbw.bin leds/target/armv7-unknown-linux-gnueabihf/release/examples/main

deploy: leds/target/armv7-unknown-linux-gnueabihf/debug/examples/main
	scp leds/target/armv7-unknown-linux-gnueabihf/debug/examples/main "mark@192.167.7.2:"

leds/target/armv7-unknown-linux-gnueabihf/release/examples/main: pru/sk6812rgbw.bin leds/src/lib.rs leds/examples/main.rs
	cargo build --manifest-path leds/Cargo.toml --target=armv7-unknown-linux-gnueabihf --example=main --release

leds/target/armv7-unknown-linux-gnueabihf/debug/examples/main: pru/sk6812rgbw.bin leds/src/lib.rs leds/examples/main.rs
	cargo build --manifest-path leds/Cargo.toml --target=armv7-unknown-linux-gnueabihf --example=main

pru/%.bin: pru/%.elf
	$(PRU_HEX) -b -o $@ $< --quiet

pru/%.elf: pru/%.obj $(PRU_LINKER_CMD)
	$(PRU_ASM) -z $(PRU_LINKER_CMD) -o $@ $<

pru/%.obj: pru/%.asm
	$(PRU_ASM) $(PRU_ASM_FLAGS) --output_file $@ -c $<
