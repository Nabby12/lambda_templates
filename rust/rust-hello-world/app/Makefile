ARCH = aarch64-unknown-linux-musl

build:
	RUSTFLAGS="-C linker=aarch64-linux-gnu-gcc" cargo build --release --target ${ARCH}

copy:
	cp ./target/${ARCH}/release/bootstrap $(ARTIFACTS_DIR)

build-RustHelloWorld: build copy
