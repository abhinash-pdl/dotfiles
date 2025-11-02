#!/usr/bin/env python3
import json
import subprocess
import sys

def get_media_info():
    try:
        # Get all active players
        players_result = subprocess.run(['playerctl', '--list-all'], 
                                      capture_output=True, text=True, timeout=1)
        
        if players_result.returncode != 0 or not players_result.stdout.strip():
            return {"text": "No media", "class": "stopped"}
        
        players = [p for p in players_result.stdout.strip().split('\n') if p.strip()]

        # Build play_check_order to prefer the most recently listed player
        # (playerctl's list order is used as a proxy for recency). This makes
        # the last-played device win when deciding which player to show.
        play_check_order = list(reversed(players))

        def fetch_metadata(player):
            m = subprocess.run([
                'playerctl', '-p', player, 'metadata',
                '--format', '{{artist}} - {{title}}'
            ], capture_output=True, text=True, timeout=1)
            if m.returncode == 0 and m.stdout.strip():
                text = m.stdout.strip()
                # Remove odd quoting artifacts if present
                text = text.replace("['", "").replace("]'", "").replace("'", "")
                if len(text) > 35:
                    text = text[:32] + "..."
                return text
            return None

        # 1) Prefer any player that is currently playing (check Spotify first)
        for player in play_check_order:
            status_result = subprocess.run(['playerctl', '-p', player, 'status'],
                                           capture_output=True, text=True, timeout=1)
            if status_result.returncode != 0:
                continue
            status = status_result.stdout.strip()
            if status == 'Playing':
                text = fetch_metadata(player)
                if text:
                    icon = "" if 'spotify' in player.lower() else "🎜"
                    return {"text": text, "icon": icon, "class": "playing", "player": player, "status": "Playing"}

        # 2) If nothing is playing, prefer the most recently listed paused player
        # but prefer Spotify if it appears among paused players.
        first_paused = None
        spotify_paused = None
        for player in reversed(players):
            status_result = subprocess.run(['playerctl', '-p', player, 'status'],
                                           capture_output=True, text=True, timeout=1)
            if status_result.returncode != 0:
                continue
            status = status_result.stdout.strip()
            if status == 'Paused':
                text = fetch_metadata(player)
                if not text:
                    continue
                entry = {"text": text, "icon": ("" if 'spotify' in player.lower() else "🎜"), "class": "paused", "player": player, "status": "Paused"}
                if 'spotify' in player.lower():
                    spotify_paused = entry
                    break
                if first_paused is None:
                    first_paused = entry

        if spotify_paused:
            return spotify_paused
        if first_paused:
            return first_paused

        # 3) Final fallback: prefer Spotify metadata if available, otherwise
        # return the most recently listed player that has metadata.
        spotify_entry = None
        first_entry = None
        for player in reversed(players):
            text = fetch_metadata(player)
            if not text:
                continue
            entry = {"text": text, "icon": ("" if 'spotify' in player.lower() else "🎜"), "class": "stopped", "player": player, "status": "Stopped"}
            if 'spotify' in player.lower():
                spotify_entry = entry
                break
            if first_entry is None:
                first_entry = entry

        if spotify_entry:
            return spotify_entry
        if first_entry:
            return first_entry
        
        return {"text": "No media", "class": "stopped"}
        
    except Exception as e:
        return {"text": "No media", "class": "stopped"}

if __name__ == "__main__":
    output = get_media_info()
    print(json.dumps(output))
    sys.stdout.flush()