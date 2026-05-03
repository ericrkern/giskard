---
name: elevenlabs-agents
description: Voice agent integration for outbound calls or spoken summaries—optional break-glass escalation when asynchronous channels fail (policy-gated).
metadata: {"openclaw": {}}
---

# ElevenLabs agents

## Use in Zeroth Guard

- **Optional** high-urgency channel for operators—not a substitute for **Zeroth Guard Mobile** customer UX.
- Requires explicit **policy**, **rate limits**, and **consent** framing; block autonomous dialing without human-approved playbooks.

## Install

Registry listing: [ClawHub — ElevenLabs agents](https://clawhub.ai/PennyroyalTea/elevenlabs-agents).

```bash
openclaw skills install PennyroyalTea/elevenlabs-agents
```

Supply ElevenLabs credentials only via secure config ([skills.entries](https://docs.openclaw.ai/tools/skills)).

## Notes

- Voice adds **social engineering** risk if misused; keep allowlists tight and log all call attempts to audit.
