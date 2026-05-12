# Network Pulse — OpenClaw tool wrapper

Wraps the **[network-scan-agent](https://github.com/ericrkern/network-scan-agent)** codebase pinned at `external/network-scan-agent` so OpenClaw agents can invoke **Network Pulse** as a bounded skill.

## Contract

- **Tool ID:** `zerothguard.network_pulse` (see `openclaw_tool.yaml`)
- **Entrypoint:** `wrapper.py` — runs the upstream scanner with a configurable workspace root and returns JSON on stdout
- **Upstream scripts:** `network_scan_agent.py` (pulse), `deep_scan.py` (deep inspection pass)

Upstream behavior matches the submodule at `external/network-scan-agent` (see `docs/architecture.md` §Network scan agent). Notable **environment variables** read by `network_scan_agent.py` when you run pulse directly (the wrapper does not set these unless your shell exports them):

- **`NETWORK_SCAN_AGENT_NETWORKS`** — comma-separated CIDRs to scan (defaults are defined in `network_scan_agent.py` and in `scripts/cron-quick-scan.sh`).
- **`NETWORK_SCAN_AGENT_SKIP_DEEP`** — when truthy, pulse skips inline deep-scan triggers (the stock quick-cron wrapper sets this for lightweight 15-minute runs).

## Usage

From the Zeroth Guard repo root:

```bash
python3 tools/network_pulse/wrapper.py --mode pulse
python3 tools/network_pulse/wrapper.py --mode deep --timeout-seconds 3600
```

Default workspace is `external/network-scan-agent` relative to the repo root. Override if your deployment copies the agent elsewhere:

```bash
python3 tools/network_pulse/wrapper.py --workspace /usr/local/zeroth-guard/network-scan-agent --mode pulse
```

## OpenClaw integration notes

- Register this tool with OpenClaw using the manifest (`openclaw_tool.yaml`) so agents receive schema-backed arguments and timeouts.
- Map wrapper JSON output into your shared finding schema (`trace_id`, `asset_id`, evidence refs to artifact paths, confidence).
- Prefer **`pulse`** on a schedule; reserve **`deep`** for on-demand investigations (longer runtime, heavier `nmap` usage).
- Ensure the process identity running OpenClaw has permission to execute `nmap` and write upstream artifacts (`devices.md`, `.seen_devices.json`, etc.) under the workspace.
