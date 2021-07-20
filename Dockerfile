# syntax=docker/dockerfile:1.0-experimental
FROM rust:1-slim-buster as build

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update \
  && apt-get install -yqq --no-install-recommends \
  shared-mime-info

WORKDIR /src
ADD . /src

RUN mkdir /out

RUN --mount=type=cache,target=/src/target \
  --mount=type=cache,target=/usr/local/cargo/registry \
  --mount=type=cache,target=/usr/local/cargo/git \
  cargo build --release \
  && cp /src/target/release/tree_magic_detector /out

RUN mkdir -p /tmp/mime-patch-1/packages
COPY ./data/extra-mime-types.xml /tmp/mime-patch-1/packages/
RUN update-mime-database /tmp/mime-patch-1/

# Now copy it into our base image.
FROM gcr.io/distroless/base-debian10:nonroot
COPY --from=build /out/tree_magic_detector /
COPY --from=build /lib/aarch64-linux-gnu/libgcc_s.so.1 /lib/aarch64-linux-gnu
COPY --from=build /usr/share/mime/magic /usr/share/mime/
COPY --from=build /tmp/mime-patch-1/magic /usr/local/share/mime/

ENTRYPOINT ["/tree_magic_detector"]
