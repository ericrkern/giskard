# Domain monitoring agents

Autonomous **sense** tier: parallel watchers over surfaces defined in `docs/agents.md` §3. All findings normalize to the orchestrator with `confidence`, `evidence_refs[]`, `trace_id`.

## Network Sentinel Agent (`network-sentinel`)

- **Watches:** gateway/firewall logs, DNS, east-west flows, unusual egress.
- **OpenClaw tools:** `read` (logs/rules workspace), `web_search` / `web_fetch` (sanitized TI), `exec` for adapters and **`tools/network_pulse/wrapper.py`** when inventory refresh is needed, `cron` for periodic pulls, `nodes` if paired-device context applies.
- **Skills:** optional grounded search (`skills/exa-search`); integrations via `skills/composio/` when ticketing/chat enrichment is wired.
- **Outputs:** flow anomalies, block/quarantine **recommendations** until policy binds actions.

## Endpoint Guard Agent (`endpoint-guard`)

- **Watches:** process trees, priv escalation, file drift, host auth trails.
- **Tools:** `read`, constrained `exec` / host probes, `code_execution` for log-derived analytics where sandbox helps.
- **Outputs:** kill/isolate/revoke **recommendations** with severity.

## Mobile Shield Agent (`mobile-shield`)

- **Watches:** posture signals when MDM/UEM exists; DNS/outbound from handhelds on LAN segments.
- **Tools:** `read`, `web_fetch`, optional `exec` for captive integrations.
- **Outputs:** segment-quarantine requests, risky-domain blocks aligned with Mobile identities.

## IoT Watcher Agent (`iot-watcher`)

- **Watches:** device fingerprint drift, LAN scanning noise, odd protocols—cross-reference Network Pulse snapshots for inventory truth.
- **Tools:** `read`, `exec` → **`tools/network_pulse/wrapper.py`** (`pulse`/`deep`) under schedule/policy; `cron`, `nodes`.
- **Skills:** **`skills/home-assistant`** for local smart-home state correlation when deployed.

## Identity Defender Agent (`identity-defender`)

- **Watches:** brute-force transitions to success, impossible-travel patterns (when clocks/geo trusted), token/session misuse indicators.
- **Tools:** `read`, selective `web_fetch` for IdP docs/integration stubs.
- **Outputs:** revoke/step-up/lock **recommendations**.

## Deception Agent (`deception`)

- **Watches:** honeytokens, decoys, planted lure interactions.
- **Tools:** `read`, light `exec`, `sessions_send` to escalate hot correlations immediately.

---

**Handoff:** all emit structured findings to **Correlation Agent**; none bypass Policy or Response Coordinator for containment execution.
