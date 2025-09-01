import subprocess
from libqtile import qtile
from libqtile.widget import base
from libqtile.lazy import lazy


class Nordvpn(base.ThreadPoolText):
    """Basic widget showing Norvpn status."""

    defaults = [
        ("update_interval", 5, "Update interval in seconds"),
        ("format_disconneted", "[  no VPN]", "Format when disconnected"),
        ("format_connect", "[ {country}]", "Format when connected"),
        ("format_connecting", "[󱘖 Process...]", "Format during connection"),
        ("rofi_command", "rofi -show nordvpn", "Command for menu"),
    ]

    def __init__(self, **config):
        base.ThreadPoolText.__init__(self, text="", **config)
        self.add_defaults(Nordvpn.defaults)

        self.is_connected = False
        self.country = "N/A"

        self.add_callbacks(
            {
                "Button1": self.toggle_connect,
                "Button3": lazy.spawn(self.rofi_command, shell=True),
            }
        )

    def _run_cmd(self, *args):
        """Helper to run the Nordvpn command."""
        command = ["nordvpn"] + list(args)
        try:
            result = subprocess.run(
                command, capture_output=True, text=True, check=True, timeout=10
            )
            return result.stdout.strip()
        except (
            subprocess.CalledProcessError,
            subprocess.TimeoutExpired,
            FileNotFoundError,
        ) as e:
            print(f"NordVpn command not run: {e}")

    def poll(self):
        """Polls the Nordvpn status and returns the formatted string."""
        status_output = self._run_cmd("status")

        if "Connected" in status_output:
            self.is_connected = True
            for line in status_output.split("\n"):
                if line.startswith("Country:"):
                    self.country = line.split(":", 1)[1].strip()
                    break
            return self.format_connect.format(country=self.country)

        if "Disconnected" in status_output:
            self.is_connected = False
            return self.format_disconneted.format()

        else:
            self.is_connected = False
            return self.format_connecting.format()

    def toggle_connect(self):
        """Checks status and connect/disconnect depending on status."""
        status=self._run_cmd("status")
        self.update(self.format_connecting)
        if "Connected" in status:
            qtile.spawn("nordvpn disconnect", shell=True)
        else:
            qtile.spawn("nordvpn connect", shell=True)
