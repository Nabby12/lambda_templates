FROM rust:latest as builder

ENV ARCH=aarch64-unknown-linux-musl
WORKDIR /app

RUN apt-get update -y && \
    apt-get install -y gcc-aarch64-linux-gnu && \
    rustup target add ${ARCH}

COPY ./app/ /app/

RUN RUSTFLAGS="-C linker=aarch64-linux-gnu-gcc" cargo build --release --target ${ARCH} && \
    mkdir bin && \
    cp ./target/${ARCH}/release/main ./bin/main

CMD ["cargo", "run", "./bin/main"]

FROM gcr.io/distroless/static as runner

COPY --from=builder /app/bin/main ./main

CMD ["./main"]
