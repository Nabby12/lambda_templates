FROM rust:latest as builder

ENV ARCH=aarch64-unknown-linux-musl
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
        gcc-aarch64-linux-gnu

RUN rustup target add ${ARCH}

COPY ./app/ /app/

RUN RUSTFLAGS="-C linker=aarch64-linux-gnu-gcc" \
    cargo build \
        --release \
        --target ${ARCH}

CMD ["./target/aarch64-unknown-linux-musl/release/bootstrap"]
