---
name: home-assistant
description: Natural-language and API access to a local Home Assistant deployment for IoT state and automation context (optional).
metadata: {"openclaw": {}}
---

# Home Assistant

## Use in Zeroth Guard

- Improves **IoT Watcher** context: device presence, unusual states, and routines—**correlate** with Network Pulse and gateway telemetry.
- Any **containment** or **segmentation** decisions still go through **Zeroth Guard policy**, not ad-hoc HA scripts invoked by the model without guardrails.

## Install

Registry listing: [ClawHub — Home Assistant](https://clawhub.ai/iAhmadZain/home-assistant).

```bash
openclaw skills install iAhmadZain/home-assistant
```

Confirm current slug and security scan on ClawHub before install.

## Notes

- Runs best **fully local** with HA on the home subnet; align credentials with your secrets management practice.
