# Giskard

`Giskard` is named after **R. Giskard Reventlov**, a pivotal robot character in Isaac Asimov's *Robot* series.

In Asimov's universe, Giskard is known for advanced insight, subtle intervention, and a deep commitment to protecting humanity while operating within strict ethical boundaries. Those themes map directly to this project's purpose: autonomous defense, policy-guided action, and responsible use of intelligence to reduce harm.

The name reflects the system's core philosophy:

- vigilant observation without unnecessary disruption
- intelligent response guided by constraints
- proactive protection of people and critical systems

Like its namesake, Giskard is built to detect risk early, act with precision, and prioritize safety.

---

## Network pulse (network-scan-agent)

The [network-scan-agent](https://github.com/ericrkern/network-scan-agent) repo (“network pulse”) is included as a **Git submodule** at `external/network-scan-agent`. It remains its own GitHub project; this repo only records **which commit** of that repo you depend on.

Clone Giskard with submodules:

```bash
git clone --recurse-submodules https://github.com/ericrkern/giskard.git
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

To move the submodule to a newer commit on `network-scan-agent`, check out the desired revision inside `external/network-scan-agent`, then commit the submodule pointer update in Giskard.
