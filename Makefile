GDB ?= arm-none-eabi-gdb

all:
	$(MAKE) dfu

build-semihosting:
	rustup component add llvm-tools-preview
	rustup target add thumbv7m-none-eabi
	cargo build --release --features use_semihosting

dfu:
	cargo objcopy --release --bin anne-key -- -O binary anne-key.bin
	./scripts/dfu-convert.py -b 0x08004000:anne-key.bin anne-key.dfu
	ls -l anne-key.dfu

debug: build-semihosting
	$(GDB) -x openocd.gdb target/thumbv7m-none-eabi/release/anne-key

gui-debug: build-semihosting
	gdbgui --gdb $(GDB) --gdb-args "-x openocd.gdb" target/thumbv7m-none-eabi/release/anne-key

bloat:
	cargo bloat --release $(BLOAT_ARGS) -n 50

fmt:
	rustup component add rustfmt
	cargo fmt

clippy:
	rustup component add clippy
	cargo clippy

clean:
	cargo clean
	rm -f anne-key.bin
	rm -f anne-key.dfu
	rm -rf _book/

.PHONY: all build clean debug openocd bloat fmt clippy
