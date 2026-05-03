---
name: protocol-reverse-engineering
description: Guidance for traffic capture, protocol reasoning, and structured analysis workflows—use only with explicit authorization and sandboxing.
metadata: {"openclaw": {}}
---

# Protocol reverse engineering (traffic analysis)

## Use in Zeroth Guard

- Deep-dive **unknown protocols**, **C2-like traffic**, or **binary telemetry** when signature-only detection is insufficient—typically under **human-directed** investigations.
- **Do not** run aggressive captures on networks or devices **outside** authorized scope; pair with local law/policy constraints.

## Install

Curated packages move between registries. Prefer discovery:

```bash
openclaw skills search "reverse engineering"
openclaw skills search "pcap"
openclaw skills search "wireshark"
```

Third-party roundups may reference protocol-analysis skill packs (e.g. listings on [skills.sh](https://skills.sh/)); **always** install from a registry page with **security scan** visibility ([ClawHub](https://clawhub.ai/)) and review source before enabling.

## Notes

- High **misuse** potential—restrict to Tier 2/Tier 3 analyst workflows per `docs/hardware.md` isolation model; never let capture tools run unbounded on production subnets without governance.
