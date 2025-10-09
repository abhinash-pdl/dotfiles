#!/usr/bin/env python3
"""Toggle OBS recording via obs-websocket.

Usage: obs_ws_toggle.py [--host HOST] [--port PORT]

Environment:
  OBS_WEBSOCKET_PASSWORD - optional password for obs-websocket authentication
"""
import os
import sys
import argparse
from obswebsocket import obsws
from obswebsocket import requests as obs_requests


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--host', default=os.environ.get('OBS_WEBSOCKET_HOST', 'localhost'))
    p.add_argument('--port', type=int, default=int(os.environ.get('OBS_WEBSOCKET_PORT', '4444')))
    args = p.parse_args()

    password = os.environ.get('OBS_WEBSOCKET_PASSWORD', None)

    try:
        client = obsws(args.host, args.port, password)
        client.connect()
    except Exception as e:
        print('failed to connect to obs-websocket:', e, file=sys.stderr)
        sys.exit(2)

    try:
        # Get recording status
        resp = client.call(obs_requests.GetRecordStatus())
        is_recording = getattr(resp, 'isRecording', None)
        # fallback: try attribute access for older versions
        if is_recording is None:
            is_recording = getattr(resp, 'getRecording', False)
        # Toggle
        if is_recording:
            client.call(obs_requests.StopRecord())
            print('stopped')
        else:
            client.call(obs_requests.StartRecord())
            print('started')
    except Exception as e:
        print('obs-websocket call failed:', e, file=sys.stderr)
        client.disconnect()
        sys.exit(3)

    client.disconnect()


if __name__ == '__main__':
    main()
