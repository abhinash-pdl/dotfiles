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
    p.add_argument('--quit-after-stop', action='store_true', help='Exit OBS after stopping recording')
    args = p.parse_args()

    password = os.environ.get('OBS_WEBSOCKET_PASSWORD', None)

    try:
        client = obsws(args.host, args.port, password)
        client.connect()
    except Exception as e:
        print('failed to connect to obs-websocket:', e, file=sys.stderr)
        sys.exit(2)

    try:
        # Ensure desired scene exists and is active (best-effort)
        desired_scene = os.environ.get('OBS_SCENE', 'AutoRecordingScene')
        try:
            scene_list = client.call(obs_requests.GetSceneList())
            scenes = scene_list.getScenes() if hasattr(scene_list, 'getScenes') else []
            if not any((s.get('sceneName') == desired_scene or s.get('name') == desired_scene) for s in scenes):
                try:
                    client.call(obs_requests.CreateScene(sceneName=desired_scene))
                except Exception:
                    # older/newer APIs may differ; ignore on failure
                    pass
            try:
                client.call(obs_requests.SetCurrentScene(sceneName=desired_scene))
            except Exception:
                try:
                    client.call(obs_requests.SetCurrentProgramScene(sceneName=desired_scene))
                except Exception:
                    # If we can't switch scene, continue; recording may still pick active scene
                    pass
        except Exception:
            # If scene-listing fails, continue without scene setup
            pass

        # Best-effort: ensure there's a video input (monitor/screen/pipewire). If none, try to create one.
        try:
            inputs_resp = client.call(obs_requests.GetInputList())
            inputs = inputs_resp.getInputs() if hasattr(inputs_resp, 'getInputs') else []
            video_input = None
            for inp in inputs:
                kind = inp.get('inputKind') or inp.get('type') or ''
                if kind and any(k in kind.lower() for k in ('monitor', 'screen', 'display', 'pipewire', 'window')):
                    video_input = inp.get('inputName') or inp.get('name') or inp.get('input')
                    break
            if not video_input:
                # try to create a monitor capture input (best-effort; may fail on some setups)
                try:
                    client.call(obs_requests.CreateInput(inputName='AutoScreen', inputKind='monitor_capture', inputSettings={}))
                    video_input = 'AutoScreen'
                    try:
                        client.call(obs_requests.AddSceneItem(sceneName=desired_scene, sourceName=video_input))
                    except Exception:
                        # different request name in some API versions
                        try:
                            client.call(obs_requests.CreateSceneItem(sceneName=desired_scene, sourceName=video_input))
                        except Exception:
                            pass
                except Exception:
                    # creation failed; continue — user may need to add source manually
                    pass
        except Exception:
            pass

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
            if args.quit_after_stop:
                try:
                    client.call(obs_requests.Exit())
                except Exception:
                    # Not fatal if Exit isn't available in this obs-websocket version
                    pass
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
