#!/usr/bin/env python3
import json
import subprocess
import sys
import threading
from collections import deque

# Cache to store recent player activity
player_cache = deque(maxlen=5)

def get_player_status(player):
    """Get status for a specific player without blocking"""
    try:
        result = subprocess.run(['playerctl', '-p', player, 'status'],
                              capture_output=True, text=True, timeout=0.5)
        if result.returncode == 0:
            status = result.stdout.strip()
            if status == "Playing":
                player_cache.appendleft(player)
            elif status == "Paused" and player not in player_cache:
                player_cache.append(player)
            return status
    except (subprocess.TimeoutExpired, subprocess.SubprocessError):
        pass
    return None

def get_media_info():
    try:
        players_result = subprocess.run(['playerctl', '--list-all'], 
                                      capture_output=True, text=True, timeout=0.5)
        
        if players_result.returncode != 0 or not players_result.stdout.strip():
            return {"text": "No media", "class": "stopped"}
        
        current_players = players_result.stdout.strip().split('\n')
        
        # Background status checks
        for player in current_players:
            thread = threading.Thread(target=get_player_status, args=(player,))
            thread.daemon = True
            thread.start()
        
        # Prioritize players
        prioritized_players = []
        for cached_player in list(player_cache):
            if cached_player in current_players:
                prioritized_players.append(cached_player)
        for player in current_players:
            if player not in prioritized_players:
                prioritized_players.append(player)
        
        # Check each player
        for player in prioritized_players:
            try:
                metadata_result = subprocess.run([
                    'playerctl', '-p', player, 'metadata',
                    '--format', '{{artist}} - {{title}}'
                ], capture_output=True, text=True, timeout=0.3)
                
                if metadata_result.returncode == 0 and metadata_result.stdout.strip():
                    text = metadata_result.stdout.strip()
                    text = text.replace("['", "").replace("']", "").replace("'", "")
                    
                    if len(text) > 35:
                        text = text[:32] + "..."
                    
                    status_result = subprocess.run(['playerctl', '-p', player, 'status'],
                                                 capture_output=True, text=True, timeout=0.2)
                    
                    status = "stopped"
                    if status_result.returncode == 0:
                        status = status_result.stdout.strip().lower()
                    
                    # Use simple ASCII/icons that work everywhere
                    if status == "playing":
                        icon = "▶"  # Simple play symbol
                    elif status == "paused":
                        icon = "⏸"  # Simple pause symbol  
                    else:
                        icon = "♫"  # Simple music note
                    
                    if status == "playing":
                        if player in player_cache:
                            player_cache.remove(player)
                        player_cache.appendleft(player)
                        return {
                            "text": text,
                            "icon": icon,
                            "class": "playing"
                        }
                    elif status == "paused":
                        return {
                            "text": text,
                            "icon": icon,
                            "class": "paused"
                        }
            
            except (subprocess.TimeoutExpired, subprocess.SubprocessError):
                continue
        
        return {"text": "No media", "class": "stopped"}
        
    except Exception as e:
        return {"text": "No media", "class": "stopped"}

if __name__ == "__main__":
    output = get_media_info()
    print(json.dumps(output))
    sys.stdout.flush()