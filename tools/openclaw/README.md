# OpenClaw runtime tools (reference registry)

This folder documents **OpenClaw gateway tools** relevant to Zeroth Guard. These are **not** Python wrappers in this repo—they are built into OpenClaw or loaded via plugins. Use [`zeroth-guard-openclaw-tools.yaml`](./zeroth-guard-openclaw-tools.yaml) as the canonical inventory for allowlisting, onboarding, and architecture alignment.

| Artifact | Purpose |
|----------|---------|
| [`zeroth-guard-openclaw-tools.yaml`](./zeroth-guard-openclaw-tools.yaml) | Machine-readable list: built-ins, session/memory tools, documented search extensions, workflow helpers |

**Sources**

- [Tools and plugins](https://docs.openclaw.ai/tools) (built-in table and tool groups)
- [Tools docs index](https://docs.openclaw.ai/llms.txt) (individual tool pages such as Exec, Browser, Exa search)

**Policy**

- Prefer `tools.allow` / `tools.deny` and [exec approvals](https://docs.openclaw.ai/tools/exec-approvals) on defense agents.
- **Zeroth Guard Mobile** remains the customer-facing surface; `message` and chat channels are operator glue only.

Executable wrappers maintained in this monorepo stay under [`../network_pulse/`](../network_pulse/) (and similar future folders).
