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
        from gi.repository import Gtk, Gdk, GLib
        return gi, Gtk, Gdk, GLib
    except Exception:
        return None, None, None, None


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

    # Header: title, pin and close buttons to emulate Windows-like behaviour
    header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
    title = Gtk.Label(label="Network")
    title.set_halign(Gtk.Align.START)
    header.pack_start(title, True, True, 0)

    pin_btn = Gtk.ToggleButton(label="Pin")
    header.pack_start(pin_btn, False, False, 0)

    close_btn = Gtk.Button(label="✕")
    close_btn.connect("clicked", lambda *_: Gtk.main_quit())
    header.pack_start(close_btn, False, False, 0)

    box.pack_start(header, False, False, 0)

    # Try to show available Wi‑Fi networks via nmcli. If nmcli isn't present
    # or listing fails, fall back to an entry that opens nm-connection-editor.
    try:
        out = subprocess.check_output(["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL", "device", "wifi", "list"], stderr=subprocess.DEVNULL)
        lines = out.decode(errors="ignore").splitlines()
        if not lines:
            raise RuntimeError("no networks")

        listbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        for ln in lines:
            # Use rsplit to allow colons in SSID
            parts = ln.rsplit(":", 2)
            if len(parts) == 3:
                ssid, security, signal = parts
            else:
                ssid = parts[0]
                security = ""
                signal = "0"

            ssid = ssid.strip()
            if not ssid:
                continue

            row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            lbl = Gtk.Label(label=f"{ssid} ({signal}%)")
            lbl.set_halign(Gtk.Align.START)
            row.pack_start(lbl, True, True, 0)

            sec_icon = "🔒" if security and security != "--" else "🔓"
            sec_lbl = Gtk.Label(label=sec_icon)
            row.pack_start(sec_lbl, False, False, 0)

            btn = Gtk.Button(label="Connect")
            def make_connect_cb(ss):
                def cb(*args):
                    # Attempt a direct nmcli connect; if it fails, open editor
                    try:
                        r = subprocess.run(["nmcli", "device", "wifi", "connect", ss], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                        if r.returncode == 0:
                            subprocess.run(["notify-send", "Network", f"Connected to {ss}"])
                            Gtk.main_quit()
                            return
                    except Exception:
                        pass
                    # fallback
                    run_detached(["nm-connection-editor"])
                    Gtk.main_quit()
                return cb
            btn.connect("clicked", make_connect_cb(ssid))
            row.pack_start(btn, False, False, 0)

            listbox.pack_start(row, False, False, 0)

        sc = Gtk.ScrolledWindow()
        sc.set_min_content_height(200)
        sc.add(listbox)
        box.pack_start(sc, True, True, 0)

    except Exception:
        # fallback UI: open the full editor
        btn1 = Gtk.Button(label="Open full Network settings")
        btn1.connect("clicked", lambda *_: (run_detached(["nm-connection-editor"]), Gtk.main_quit()))
        box.pack_start(btn1, False, False, 0)

    # general actions
    btn_restart = Gtk.Button(label="Network restart")
    btn_restart.connect("clicked", lambda *_: (run_detached(["nmcli", "networking", "off"]), run_detached(["nmcli", "networking", "on"]), Gtk.main_quit()))
    box.pack_start(btn_restart, False, False, 0)

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

    # Try to list sinks with pactl; allow quick switching of default sink.
    try:
        out = subprocess.check_output(["pactl", "list", "short", "sinks"], stderr=subprocess.DEVNULL)
        lines = out.decode(errors="ignore").splitlines()
        if lines:
            listbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
            for ln in lines:
                # expected: index\tname\t... we'll take the name
                parts = ln.split('\t')
                if len(parts) < 2:
                    continue
                name = parts[1]
                row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
                lbl = Gtk.Label(label=name)
                lbl.set_halign(Gtk.Align.START)
                row.pack_start(lbl, True, True, 0)

                btn = Gtk.Button(label="Set")
                def make_set_cb(nm):
                    def cb(*args):
                        try:
                            subprocess.run(["pactl", "set-default-sink", nm], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                            # move existing inputs
                            try:
                                ins = subprocess.check_output(["pactl", "list", "short", "sink-inputs"]).decode().splitlines()
                                for it in ins:
                                    idx = it.split('\t',1)[0]
                                    subprocess.run(["pactl", "move-sink-input", idx, nm], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                            except Exception:
                                pass
                            subprocess.run(["notify-send", "Audio", f"Default sink set to {nm}"])
                        except Exception:
                            run_detached(["pavucontrol"])
                        Gtk.main_quit()
                    return cb
                btn.connect("clicked", make_set_cb(name))
                row.pack_start(btn, False, False, 0)
                listbox.pack_start(row, False, False, 0)

            sc = Gtk.ScrolledWindow()
            sc.set_min_content_height(200)
            sc.add(listbox)
            box.pack_start(sc, True, True, 0)
        else:
            raise RuntimeError("no sinks")
    except Exception:
        btn1 = Gtk.Button(label="Open volume control")
        btn1.connect("clicked", lambda *_: (run_detached(["pavucontrol"]), Gtk.main_quit()))
        box.pack_start(btn1, False, False, 0)

    btn_toggle = Gtk.Button(label="Toggle mute")
    btn_toggle.connect("clicked", lambda *_: (run_detached(["pamixer", "-t"]), Gtk.main_quit()))
    box.pack_start(btn_toggle, False, False, 0)

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
    gi, Gtk, Gdk, GLib = try_import_gi()
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
    # Some compositors/Wayland setups don't reliably emit focus-out for
    # POPUP windows. Add a short periodic check to quit when the window
    # is no longer active.
    try:
        def _check_active():
            try:
                # If pinned, keep the popup open even when not active.
                if pin_btn.get_active():
                    return True
                if not win.is_active():
                    Gtk.main_quit()
                    return False
            except Exception:
                pass
            return True

        GLib.timeout_add(150, _check_active)
    except Exception:
        pass

    Gtk.main()


if __name__ == "__main__":
    main()
