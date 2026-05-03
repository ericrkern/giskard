# Tools

## Executable wrappers (this repo)

Stable **entrypoints** the swarm can shell out to via OpenClaw `exec` (with approvals). Each folder has a manifest + runner where applicable.

| Tool | Role |
|------|------|
| [`network_pulse/`](./network_pulse/README.md) | LAN discovery pulse and optional deep host inspection ([network-scan-agent](../../external/network-scan-agent)) |

Wrappers do **not** replace Zeroth Guard policy: they return structured output and artifact paths for orchestrator ingestion.

## OpenClaw runtime tools (reference only)

OpenClaw **built-in and documented extension tools** (browser, web_search, sessions, plugins, etc.) are catalogued here for allowlisting and architecture—not reimplemented in Python:

| Registry | Role |
|----------|------|
| [`openclaw/README.md`](./openclaw/README.md) | How this relates to the gateway |
| [`openclaw/zeroth-guard-openclaw-tools.yaml`](./openclaw/zeroth-guard-openclaw-tools.yaml) | Full inventory with doc links and Zeroth Guard tiers |

Authoritative behavior and groups: [OpenClaw — Tools and plugins](https://docs.openclaw.ai/tools).
