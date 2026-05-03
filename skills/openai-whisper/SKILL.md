---
name: openai-whisper
description: Local or API-assisted transcription for incident verbal notes and briefings (optional); assess privacy vs upstream Whisper packaging on ClawHub.
metadata: {"openclaw": {}}
---

# OpenAI Whisper (transcription)

## Use in Zeroth Guard

- Convert **operator voice notes** or meeting summary audio into text for incident timelines (especially on **local-first** prototype laptops).
- Do not transcribe content that includes **secrets**, **session tokens**, or **classified** customer data unless policy allows.

## Install

Registry listing: [ClawHub — openai-whisper](https://clawhub.ai/steipete/openai-whisper).

```bash
openclaw skills install steipete/openai-whisper
```

Read the published **SKILL.md** and scripts for whether execution is **local**, **API**, or hybrid—your privacy posture may require pure offline models instead.

## Notes

- Prefer disk encryption and short retention for audio artifacts on the Ubuntu prototype host (`docs/hardware.md`).
