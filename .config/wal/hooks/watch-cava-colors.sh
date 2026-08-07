#!/usr/bin/env python3
"""
Watch pywal colors and update cava theme live
Polls colors.json for changes and updates cava theme
No external dependencies required
"""

import json
import time
import subprocess
from pathlib import Path

WATCH_FILE = Path.home() / ".cache/wal/colors.json"
HOOK_SCRIPT = Path.home() / ".config/wal/hooks/cava-colors"
POLL_INTERVAL = 2  # Check every 2 seconds

last_mtime = None

print(f"Watching {WATCH_FILE} for changes...")
print("Will update cava theme whenever pywal colors change")

# Initial run
subprocess.run(["python3", str(HOOK_SCRIPT)], capture_output=True)

while True:
    try:
        if WATCH_FILE.exists():
            current_mtime = WATCH_FILE.stat().st_mtime
            
            if last_mtime is not None and current_mtime != last_mtime:
                print(f"Colors changed at {time.strftime('%H:%M:%S')}")
                result = subprocess.run(
                    ["python3", str(HOOK_SCRIPT)],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    print("✓ Cava theme updated")
                else:
                    print(f"✗ Error updating theme: {result.stderr}")
            
            last_mtime = current_mtime
        
        time.sleep(POLL_INTERVAL)
    
    except KeyboardInterrupt:
        print("\nStopped watching for color changes")
        break
    except Exception as e:
        print(f"Error: {e}")
        time.sleep(POLL_INTERVAL)

