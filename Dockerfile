FROM ghcr.io/apollographql/rover@sha256:267e1150fc69e6b0e4db9a3d0b6af591a482358f3f7a3fbdf8eaace1f285e92a AS compose
WORKDIR /home/rover
COPY supergraph-config.yaml ./
# subgraph_url introspection means the subgraph must be reachable at build
# time — the schema this bakes in is whatever hdmi-switch is actually
# serving right now, not a checked-in copy that can drift out of sync.
RUN rover supergraph compose --config supergraph-config.yaml --elv2-license accept > supergraph.graphql

FROM ghcr.io/apollographql/router@sha256:2cfe0d94971eacecd16c70a81ac3515f08df5d2e590a26dceb6ee93bce50c403 AS release
# The base image only defaults APOLLO_ROUTER_CONFIG_PATH — without this,
# the router refuses to start at all, since it has no way to know where
# to find a supergraph schema.
ENV APOLLO_ROUTER_SUPERGRAPH_PATH=/dist/config/supergraph.graphql
COPY router.yaml /dist/config/router.yaml
COPY --from=compose /home/rover/supergraph.graphql /dist/config/supergraph.graphql
