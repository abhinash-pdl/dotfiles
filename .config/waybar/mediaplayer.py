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
        
        players = players_result.stdout.strip().split('\n')
        
        # Prioritize players: Spotify first, then others
        prioritized_players = []
        for player in players:
            if 'spotify' in player.lower():
                prioritized_players.insert(0, player)  # Spotify at front
            else:
                prioritized_players.append(player)  # Others at end
        
        # Check each player in priority order
        for player in prioritized_players:
            # Get status for this specific player
            status_result = subprocess.run(['playerctl', '-p', player, 'status'],
                                         capture_output=True, text=True, timeout=1)
            
            if status_result.returncode == 0:
                status = status_result.stdout.strip()
                
                if status == "Playing":
                    # This player is active, use it
                    metadata_result = subprocess.run([
                        'playerctl', '-p', player, 'metadata',
                        '--format', '{{artist}} - {{title}}'
                    ], capture_output=True, text=True, timeout=1)
                    
                    if metadata_result.returncode == 0 and metadata_result.stdout.strip():
                        text = metadata_result.stdout.strip()
                        # Clean up formatting
                        text = text.replace("['", "").replace("']", "").replace("'", "")
                        
                        if len(text) > 35:
                            text = text[:32] + "..."
                        
                        # Determine icon based on player name
                        icon = "" if 'spotify' in player.lower() else "🎜"
                        
                        return {
                            "text": text,
                            "icon": icon,
                            "class": "playing"
                        }
                
                elif status == "Paused":
                    # Player exists but is paused, check if others are playing
                    continue
        
        # If we get here, no players are actively playing
        # Check if any players exist but are paused
        for player in prioritized_players:
            status_result = subprocess.run(['playerctl', '-p', player, 'status'],
                                         capture_output=True, text=True, timeout=1)
            if status_result.returncode == 0 and status_result.stdout.strip() == "Paused":
                metadata_result = subprocess.run([
                    'playerctl', '-p', player, 'metadata',
                    '--format', '{{artist}} - {{title}}'
                ], capture_output=True, text=True, timeout=1)
                
                if metadata_result.returncode == 0 and metadata_result.stdout.strip():
                    text = metadata_result.stdout.strip()
                    text = text.replace("['", "").replace("']", "").replace("'", "")
                    
                    if len(text) > 35:
                        text = text[:32] + "..."
                    
                    icon = "" if 'spotify' in player.lower() else "🎜"
                    
                    return {
                        "text": text,
                        "icon": icon,
                        "class": "paused"
                    }
        
        return {"text": "No media", "class": "stopped"}
        
    except Exception as e:
        return {"text": "No media", "class": "stopped"}

if __name__ == "__main__":
    output = get_media_info()
    print(json.dumps(output))
    sys.stdout.flush()
