# graph-router

Builds the Apollo Router image for this homelab's federated GraphQL gateway.
Composes the supergraph schema at build time (via `rover supergraph compose`,
introspecting each live subgraph — no checked-in copy of subgraph schemas to
keep in sync by hand) and bakes the result plus `router.yaml` into the
image. Deploys to `k8s-graphql-router`.

## Files

- `router.yaml` — Apollo Router runtime config (CORS, error visibility,
  health check, etc.)
- `supergraph-config.yaml` — tells `rover` which subgraphs to compose and
  where to fetch each one's schema from
- `Dockerfile` — composes the schema, then bakes it + `router.yaml` into
  the official `apollographql/router` image

## Adding a subgraph

Add an entry to `supergraph-config.yaml` under `subgraphs:`, pointing
`routing_url` and `schema.subgraph_url` at the new service's live GraphQL
endpoint. The next build will compose it in — no other changes needed here.
