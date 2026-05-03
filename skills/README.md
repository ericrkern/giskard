# Skills

Zeroth Guard-related **OpenClaw skill recommendations** live in subfolders below. Each folder contains a `SKILL.md` in [AgentSkills](https://agentskills.io/)-compatible form so OpenClaw can load guidance from the workspace ([OpenClaw skills paths](https://docs.openclaw.ai/tools/skills)).

These entries are **curated stubs**: they document *when* to use a capability for autonomous defense work and *how* to install the upstream skill from [ClawHub](https://clawhub.ai/) or linked sources. They **do not** vendor third-party skill code—install separately after reviewing `SKILL.md` and scripts on the registry ([security](https://docs.openclaw.ai/tools/skills)).

| Folder | Role |
|--------|------|
| [`composio/`](./composio/SKILL.md) | Broad integrations (GitHub, Slack, ticketing, many SaaS APIs). |
| [`n8n-workflow-automation/`](./n8n-workflow-automation/SKILL.md) | Local workflow automation and playbook glue. |
| [`home-assistant/`](./home-assistant/SKILL.md) | IoT / smart-home context aligned with subnet device posture. |
| [`exa-search/`](./exa-search/SKILL.md) | Doc- and repo-grounded technical search (TI / CVE research). |
| [`self-improving-agent/`](./self-improving-agent/SKILL.md) | Structured operational memory and tuning feedback. |
| [`elevenlabs-agents/`](./elevenlabs-agents/SKILL.md) | Optional voice escalation path (policy-gated). |
| [`openai-whisper/`](./openai-whisper/SKILL.md) | Local speech-to-text for analyst notes (privacy-sensitive). |
| [`protocol-reverse-engineering/`](./protocol-reverse-engineering/SKILL.md) | Traffic / protocol analysis posture (high caution). |

**Customer-facing rule:** only **Zeroth Guard Mobile** is the end-user surface; these skills support operators and automation behind the orchestrator.

Install workflow (after review on ClawHub):

```bash
openclaw skills search "<keyword>"
openclaw skills install <slug>
```

Verify registry security scan summaries before enabling in production.
