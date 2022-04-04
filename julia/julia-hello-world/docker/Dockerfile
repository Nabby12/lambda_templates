FROM public.ecr.aws/lambda/provided:al2 as runtime

ENV julia=julia-1.7.2

WORKDIR /usr/local

RUN yum install -y tar gzip

RUN curl -LO https://julialang-s3.julialang.org/bin/linux/aarch64/1.7/${julia}-linux-aarch64.tar.gz && \
    tar xf ${julia}-linux-aarch64.tar.gz && \
    rm ${julia}-linux-aarch64.tar.gz && \
    ln -s ${julia} julia

WORKDIR /var/task

ENV JULIA_DEPOT_PATH=/var/task/.julia

COPY app/ .
# RUN /usr/local/julia/bin/julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.API.precompile()"

WORKDIR /var/runtime
COPY bootstrap .

WORKDIR /opt/extensions

CMD ["App.main"]

# FROM public.ecr.aws/sam/build-provided.al2:latest-x86_64 as runner

# ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie

# RUN chmod 755 /usr/bin/aws-lambda-rie

# COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/bootstrap .

# ENTRYPOINT [ "/usr/bin/aws-lambda-rie" ]
