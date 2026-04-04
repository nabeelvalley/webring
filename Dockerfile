FROM erlang:28.0.1.0-alpine AS build
COPY --from=ghcr.io/gleam-lang/gleam:v1.14.0-erlang-alpine /bin/gleam /bin/gleam
COPY . /app/
RUN cd /app && gleam export erlang-shipment

FROM erlang:28.0.1.0-alpine
RUN \
  addgroup --system webapp && \
  adduser --system webapp -g webapp
COPY --from=build /app/build/erlang-shipment /app
WORKDIR /app

HEALTHCHECK --interval=60s --timeout=10s --retries=5 \
  CMD wget --no-verbose --tries=1 --spider http://0.0.0.0:8000/ || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
