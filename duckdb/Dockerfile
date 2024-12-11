FROM buildpack-deps:bookworm AS base0
FROM base0 AS base0-amd64
ARG DUCKDB_ARCH=amd64
FROM base0 AS base0-arm64
ARG DUCKDB_ARCH=aarch64

FROM base0-$TARGETARCH AS downloader
RUN curl -L -o duckdb_cli.zip "https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-${DUCKDB_ARCH}.zip" \
    && unzip duckdb_cli.zip && rm duckdb_cli.zip

FROM debian:bookworm
COPY --from=downloader duckdb .
ENTRYPOINT [ "./duckdb" ]