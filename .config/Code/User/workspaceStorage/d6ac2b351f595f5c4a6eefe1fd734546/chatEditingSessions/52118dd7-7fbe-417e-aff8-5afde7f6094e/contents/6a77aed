#!/usr/bin/env python3
"""Small popup for Waybar to open network/audio settings.

Usage: waybar-mini-control.py network|audio

Creates a tiny undecorated window placed near the top-right of the screen
so it appears under a top-positioned Waybar. Buttons launch GUI tools and
the popup closes after an action or on focus-out.
"""
import sys
import subprocess

MODE = sys.argv[1] if len(sys.argv) > 1 else "network"

def run_detached(cmd):
    try:
        # Use setsid so the launched GUI doesn't get tied to this process
        subprocess.Popen(["/usr/bin/setsid"] + cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        try:
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass


def fallback_launch_network():
    run_detached(["nm-connection-editor"])


def fallback_launch_audio():
    run_detached(["pavucontrol"])


def try_import_gi():
    try:
        import gi
        gi.require_version("Gtk", "3.0")
        from gi.repository import Gtk, Gdk
        return gi, Gtk, Gdk
    except Exception:
        return None, None, None


def make_network_ui(Gtk, Gdk):
    # Use a POPUP window type and popup-menu hint so compositor treats
    # this as a small transient popup rather than a regular toplevel.
    win = Gtk.Window(type=Gtk.WindowType.POPUP)
    try:
        win.set_type_hint(Gdk.WindowTypeHint.POPUP_MENU)
    except Exception:
        pass
    win.set_decorated(False)
    win.set_keep_above(True)
    win.set_default_size(220, -1)
    win.set_resizable(False)
    win.set_border_width(6)

    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)

    btn1 = Gtk.Button(label="Network settings")
    btn1.connect("clicked", lambda *_: (run_detached(["nm-connection-editor"]), Gtk.main_quit()))
    box.pack_start(btn1, False, False, 0)

    btn2 = Gtk.Button(label="Wi‑Fi networks (list)")
    btn2.connect("clicked", lambda *_: (run_detached(["alacritty", "-e", "nmcli", "d", "wifi", "list"]), Gtk.main_quit()))
    box.pack_start(btn2, False, False, 0)

    btn3 = Gtk.Button(label="Network restart")
    btn3.connect("clicked", lambda *_: (run_detached(["nmcli", "networking", "off"]), run_detached(["nmcli", "networking", "on"]), Gtk.main_quit()))
    box.pack_start(btn3, False, False, 0)

    win.add(box)
    win.connect("focus-out-event", lambda *_: Gtk.main_quit())
    win.connect("key-press-event", lambda w, e: (Gtk.main_quit() if e.keyval == 65307 else None))

    # place near top-right under the bar
    screen = Gdk.Screen.get_default()
    sw = screen.get_width()
    # give small top margin where Waybar sits
    top_margin = 36
    win.show_all()
    # Positioning on Wayland is limited; don't try to move the window
    # aggressively. Using POPUP_MENU type helps the compositor present it
    # as a small menu near the pointer or parent surface.
    return win


def make_audio_ui(Gtk, Gdk):
    win = Gtk.Window(type=Gtk.WindowType.POPUP)
    try:
        win.set_type_hint(Gdk.WindowTypeHint.POPUP_MENU)
    except Exception:
        pass
    win.set_decorated(False)
    win.set_keep_above(True)
    win.set_default_size(220, -1)
    win.set_resizable(False)
    win.set_border_width(6)

    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)

    btn1 = Gtk.Button(label="Open volume control")
    btn1.connect("clicked", lambda *_: (run_detached(["pavucontrol"]), Gtk.main_quit()))
    box.pack_start(btn1, False, False, 0)

    btn2 = Gtk.Button(label="Toggle mute")
    btn2.connect("clicked", lambda *_: (run_detached(["pamixer", "-t"]), Gtk.main_quit()))
    box.pack_start(btn2, False, False, 0)

    btn3 = Gtk.Button(label="Show sources/sinks")
    btn3.connect("clicked", lambda *_: (run_detached(["alacritty", "-e", "pactl", "list", "short", "sinks"]), Gtk.main_quit()))
    box.pack_start(btn3, False, False, 0)

    win.add(box)
    win.connect("focus-out-event", lambda *_: Gtk.main_quit())
    win.connect("key-press-event", lambda w, e: (Gtk.main_quit() if e.keyval == 65307 else None))

    screen = Gdk.Screen.get_default()
    sw = screen.get_width()
    top_margin = 36
    win.show_all()
    # As above: avoid move(); let the compositor place this small popup.
    return win


def main():
    gi, Gtk, Gdk = try_import_gi()
    if gi is None:
        # fallback: try to just launch the requested tool
        if MODE == "audio":
            fallback_launch_audio()
        else:
            fallback_launch_network()
        return

    if MODE == "audio":
        win = make_audio_ui(Gtk, Gdk)
    else:
        win = make_network_ui(Gtk, Gdk)

    win.present()
    Gtk.main()


if __name__ == "__main__":
    main()
