# Agents — OpenClaw × Zeroth Guard workspace bundle

Drop-in descriptions for wiring OpenClaw to operate **Zeroth Guard**: autonomous LAN defense using curated **tools** (`tools/`, OpenClaw built-ins per `tools/openclaw/zeroth-guard-openclaw-tools.yaml`) and **skills** (`skills/`).

## Files

| File | Purpose |
|------|---------|
| [**SOUL.md**](./SOUL.md) | Personality layer injected by OpenClaw ([guide](https://docs.openclaw.ai/concepts/soul)) |
| [**soul.md**](./soul.md) | Lowercase duplicate of `SOUL.md` for tooling that expects this filename |
| [**AGENTS.md**](./AGENTS.md) | Hard operating rules (policy, tools, customer surface) |
| [**swarm-manifest.yaml**](./swarm-manifest.yaml) | Logical agent IDs, missions, suggested tools/skills, handoffs |
| [**roles/**](./roles/) | Narrative specs per tier |

## Wiring hints

1. Point OpenClaw workspace at this directory or merge these files into `/.agents/` per [Agent workspace](https://docs.openclaw.ai/concepts/agent-workspace).
2. Map `swarm-manifest.yaml` `agents[].id` entries to `agents.list[]` in `openclaw.json`; attach **tool allowlists** per tier (`tools.allow` / `tools.deny`).
3. Keep **`SOUL.md` + `soul.md`** synchronized when editing stance.

Canonical taxonomy remains in **`docs/agents.md`** and **`docs/architecture.md`**.
