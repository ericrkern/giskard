#!/usr/bin/env python3
"""
OpenClaw-facing entrypoint for Network Pulse (network-scan-agent).

Runs upstream scripts in external/network-scan-agent and prints one JSON object on stdout
for agent/orchestrator ingestion.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_workspace() -> Path:
    return repo_root() / "external" / "network-scan-agent"


def load_seen_count(workspace: Path) -> int | None:
    cache = workspace / ".seen_devices.json"
    if not cache.is_file():
        return None
    try:
        data = json.loads(cache.read_text(encoding="utf-8"))
        if isinstance(data, dict):
            return len(data)
    except (json.JSONDecodeError, OSError):
        return None
    return None


def run_pulse(workspace: Path, timeout: int) -> subprocess.CompletedProcess[str]:
    script = workspace / "network_scan_agent.py"
    if not script.is_file():
        raise FileNotFoundError(f"Missing network_scan_agent.py under {workspace}")
    return subprocess.run(
        [sys.executable, str(script)],
        cwd=str(workspace),
        capture_output=True,
        text=True,
        timeout=timeout,
    )


def run_deep(workspace: Path, timeout: int) -> subprocess.CompletedProcess[str]:
    script = workspace / "deep_scan.py"
    if not script.is_file():
        raise FileNotFoundError(f"Missing deep_scan.py under {workspace}")
    return subprocess.run(
        [sys.executable, str(script)],
        cwd=str(workspace),
        capture_output=True,
        text=True,
        timeout=timeout,
    )


def artifact_paths(workspace: Path, mode: str) -> Dict[str, str]:
    paths: Dict[str, str] = {
        "devices_md": str(workspace / "devices.md"),
        "seen_devices_json": str(workspace / ".seen_devices.json"),
        "scan_snapshots_json": str(workspace / ".scan_snapshots.json"),
        "deep_scan_results_json": str(workspace / "deep_scan_results.json"),
    }
    _ = mode  # reserved if mode-specific artifacts diverge later
    return paths


def main() -> int:
    parser = argparse.ArgumentParser(description="OpenClaw wrapper for Network Pulse")
    parser.add_argument(
        "--mode",
        choices=("pulse", "deep"),
        default="pulse",
        help="pulse: network_scan_agent.py; deep: deep_scan.py",
    )
    parser.add_argument(
        "--workspace",
        type=Path,
        default=None,
        help="network-scan-agent root (default: <repo>/external/network-scan-agent)",
    )
    parser.add_argument(
        "--timeout-seconds",
        type=int,
        default=900,
        help="Subprocess timeout (default 900)",
    )
    args = parser.parse_args()
    workspace = args.workspace.expanduser().resolve() if args.workspace else default_workspace()
    timeout = max(60, args.timeout_seconds)

    result: Dict[str, Any] = {
        "tool_id": "zerothguard.network_pulse",
        "mode": args.mode,
        "workspace": str(workspace),
        "artifacts": artifact_paths(workspace, args.mode),
        "status": "error",
        "exit_code": None,
        "known_devices_from_cache": load_seen_count(workspace),
        "stdout_tail": "",
        "stderr_tail": "",
        "error": None,
    }

    if not workspace.is_dir():
        result["error"] = f"workspace does not exist: {workspace}"
        print(json.dumps(result, indent=2))
        return 1

    try:
        proc = run_pulse(workspace, timeout) if args.mode == "pulse" else run_deep(workspace, timeout)
    except FileNotFoundError as e:
        result["error"] = str(e)
        print(json.dumps(result, indent=2))
        return 1
    except subprocess.TimeoutExpired:
        result["error"] = f"timeout after {timeout}s"
        print(json.dumps(result, indent=2))
        return 124

    tail = 4000
    result["exit_code"] = proc.returncode
    result["stdout_tail"] = (proc.stdout or "")[-tail:]
    result["stderr_tail"] = (proc.stderr or "")[-tail:]
    result["status"] = "ok" if proc.returncode == 0 else "failed"
    result["known_devices_from_cache"] = load_seen_count(workspace)

    print(json.dumps(result, indent=2))
    return 0 if proc.returncode == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
