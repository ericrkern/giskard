# Zeroth Guard

**Zeroth Guard** is an autonomous, policy-driven security platform for **home and small-office networks**: a multi-agent swarm under local orchestration, **guarded automatic response**, and **Zeroth Guard Mobile** (iPhone) for alerts, audit-friendly visibility, and sensitive confirmations.

The name cites Asimov’s **Zeroth Law** framing (*humanity-scale harm avoidance precedes narrower robot directives*) as a narrative fit for **policy-bound autonomy**—not as a claim on unrelated third-party trademarks or confusingly similar product names. See **`docs/zerothguard.md`** for literary background.

Operating philosophy:

- vigilant observation without unnecessary disruption  
- intelligent response guided by explicit constraints  
- proactive protection of people and the devices they rely on  

---

## Network pulse (network-scan-agent)

The [network-scan-agent](https://github.com/ericrkern/network-scan-agent) repo (“network pulse”) is included as a **Git submodule** at `external/network-scan-agent`. It remains its own GitHub project; this repo only records **which commit** of that repo you depend on.

Clone this repository with submodules:

```bash
git clone --recurse-submodules https://github.com/ericrkern/zerothguard.git
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

If recursive init fails (for example an unset nested submodule URL inside `network-scan-agent`), initialize Network Pulse only:

```bash
git submodule update --init external/network-scan-agent
```

To move the submodule to a newer commit on `network-scan-agent`, check out the desired revision inside `external/network-scan-agent`, then commit the submodule pointer update in this repo.
