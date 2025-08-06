import os
import subprocess
import os
import subprocess
import re

from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.backend.wayland.inputs import InputConfig
from libqtile.widget import backlight
from qtile_extras import widget as extra_widget
from qtile_extras.layout.decorations.borders import RoundedCorners

from widgets.nordvpn import Nordvpn

mod = "mod4"
terminal = guess_terminal()
file_explorer = "thunar"

colors_macchiato = {
    "text": "#cad3f5",
    "subtext1": "#b8c0e0",
    "subtext0": "#a5adcb",
    "lavender": "#b7bdf8",
    "overlay0": "#6e738d",
    "overlay1": "#8087a2",
    "overlay2": "#939ab7",
    "yellow": "#eed49f",
    "red": "#ed8796",
    "teal": "#8bd5ca",
    "surface0": "#363a4f",
    "mauve": "#c6a0f6",
    "flamingo": "#f0c6c6",
    "pink": "#f5bde6",
    "maroon": "#ee99a0",
    "peach": "#f5a97f",
    "green": "#a6da95",
    "sky": "#91d7e3",
    "sapphire": "#7dc4e4",
    "blue": "#8aadf4",
    "rosewater": "#f4dbd6",
}

colors = colors_macchiato
myfont = "Fira Code Nerd Font Bold"

keys = [
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "tab", lazy.layout.next(), desc="Move window focus to other window"),
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.growdown(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod, "Shift"], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod, "shift"], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [mod],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod, "control"], "Return", lazy.group["scratchpad"].dropdown_toggle("term"), desc="Launch dropdown terminal"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="reload config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "e", lazy.spawn(file_explorer), desc="Open file_explorer"),
    Key([mod], "space", lazy.spawn("rofi -show combi"), desc="Show launcher menu"),
    Key([mod], "Escape", lazy.spawn("rofi -show power"), desc="Show power menu"),
    Key([mod], "n", lazy.spawn("rofi -show notes"), desc="Show notes menu"),
    Key(
        [mod],
        "i",
        lazy.spawn("rofi -show firefox-bookmarks"),
        desc="Show bookmarks menu",
    ),
    Key(
        [],
        "XF86MonBrightnessUp",
        lazy.widget["backlight"].change_backlight(backlight.ChangeDirection.UP),
        desc="Increase screen backlight",
    ),
    Key(
        [],
        "XF86MonBrightnessDown",
        lazy.widget["backlight"].change_backlight(backlight.ChangeDirection.DOWN),
        desc="Lower screen backlight",
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.widget["volume"].increase_vol(),
        desc="Raise volume",
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.widget["volume"].decrease_vol(),
        desc="Lower volume",
    ),
    Key([], "XF86AudioMute", lazy.widget["volume"].mute(), desc="Toggle mute"),
]

wl_input_rules = {
    "type:touchpad": InputConfig(tap=True, dwt=True),
    "type:keyboard": InputConfig(kb_layout="gb", kb_options="caps:escape"),
}

groups = [
    ScratchPad("scratchpad", [DropDown("term", "foot")]),
    Group(
        "1",
        label="\uf4f6",
        spawn="foot nvim git/gitjournal/ +:Neotree",
        init=True,
    ),
    Group(
        "2",
        label="\uf120",
        spawn="foot",
        init=True,
    ),
    Group(
        "3",
        label="\uf269",
        matches=[Match(wm_class=re.compile("firefox"))],
        init=True,
        exclusive=True,
        spawn="firefox",
        layout="max",
    ),
    Group("4", label="\U000f06a9", spawn="foot -e gemini"),
    Group("5", label="\uf52c")
]


for grp in groups:
    keys.extend(
        [
            Key(
                [mod],
                grp.name,
                lazy.group[grp.name].toscreen(),
                desc=f"Switch to group {grp.name}",
            ),
            Key(
                [mod, "shift"],
                grp.name,
                lazy.window.togroup(grp.name, switch_group=True),
                desc=f"Switch to & move focused window to group {grp.name}",
            ),
        ]
    )

layout_defaults = dict(
    border_focus_stack=[colors["lavender"], colors["overlay0"]],
    border_normal=RoundedCorners(colour=colors["overlay2"]),
    border_focus=RoundedCorners(colour=colors["lavender"]),
    border_width=2,
    margin=12,
    margin_on_single=8,
    single_border_width=2,
)

layouts = [
    layout.MonadTall(
        **layout_defaults,
        ratio=0.66,
    ),
    layout.Max(
        **layout_defaults,
    ),
    layout.TreeTab(
        font=myfont,
        active_bg=colors["surface0"],
        active_fg=colors["lavender"],
        bg_color=colors["surface0"],
        inactive_bg=colors["surface0"],
        inactive_fg=colors["text"],
        panel_width=200,
        margin_y=8,
    ),
    # layout.Columns(
    #   border_focus_stack = [colors["lavender"], colors["overlay0"]],
    #   border_normal = colors["overlay0"],
    #   border_focus = colors["lavender"],
    #   border_width = 2,
    #   margin = 8,
    #   margin_on_single = 8,
    #   single_border_width = 2,
    # ),
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]


widget_defaults = dict(
    font=myfont,
    foreground=colors["text"],
    fontsize=14,
    padding_x=6,
)
extension_defaults = widget_defaults.copy()


def sep():
    return widget.TextBox("|")


# def get_volume():
#     try:
#         output = subprocess.run(
#             ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
#             text=True,
#             capture_output=True,
#         )
#         volume = str(int(float(output.stdout.split()[1]) * 100)) + "%"
#     except:
#         volume = "999%"
#     (
#         str(
#             int(
#                 float(
#                     subprocess.run(
#                         ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
#                         text=True,
#                         capture_output=True,
#                     ).stdout.split()[1]
#                 )
#                 * 100
#             )
#         )
#         + "%"
#     )
#     return volume
#



def create_bar():
    return bar.Bar(
        [
            widget.GroupBox(
                hide_unused=True,
                disable_drag=True,
                highlight_method="line",
                highlight_color=[colors["surface0"], colors["surface0"]],
                active=colors["text"],
                inactive=colors["overlay0"],
                this_current_screen_border=colors["lavender"],
                this_screen_border=colors["overlay1"],
                other_current_screen_border=colors["subtext0"],
                other_screen_border=colors["overlay0"],
                margin_x=6,
            ),
            sep(),
            widget.Prompt(),
            widget.WindowName(),
            widget.CurrentLayout(fmt="[{}]"),
            sep(),
            widget.StatusNotifier(),
            Nordvpn(),
            widget.Wlan(fmt="\uf1eb  {}", format="{essid}", foreground=colors["mauve"]),
            widget.Battery(
                fmt="{}",
                full_char="\U000f17e2",
                charge_char="\U000f1901",
                discharge_char="\U000f007d",
                low_percentage=0.15,
                format="{char} {percent:2.0%}",
                foreground=colors["yellow"],
                charging_foreground=colors["green"],
                low_foreground=colors["red"],
            ),
            widget.Backlight(
                name="backlight",
                backlight_name="intel_backlight",
                fmt="\uf522 {}",
                brightness_file="/sys/class/backlight/intel_backlight/brightness",
                max_brightness_file="/sys/class/backlight/intel_backlight/max_brightness",
                foreground=colors["sky"],
                change_command="light -S {0}",
                mouse_callbacks={
                    "Button4": lazy.widget["backlight"].change_backlight(
                        backlight.ChangeDirection.UP
                    ),
                    "Button5": lazy.widget["backlight"].change_backlight(
                        backlight.ChangeDirection.DOWN
                    ),
                },
            ),
            widget.Volume(
                name="volume",
                foreground=colors["rosewater"],
                fmt="\uf028 {}",
                mute_format="Mute",
                unmute_format="{volume}%",
                get_volume_command="get_volume.sh",
                # get_volume_command=str(
                #     int(
                #         float(
                #             subprocess.run(
                #                 ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
                #                 text=True,
                #                 capture_output=True,
                #             ).stdout.split()[1]
                #         )
                #         * 100
                #     )
                # )
                # + "%",
                volume_app="wpctl",
                volume_down_command="wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-",
                volume_up_command="wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+",
                check_mute_command="wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo Muted || echo Unmuted",
                check_mute_string="Muted",
                mute_command="wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
                update_interval=0.2,
            ),
            sep(),
            widget.Clock(
                format="%a %d %b %H:%M",
            ),
        ],
        size=36,
        background=colors["surface0"],
        margin=8,
        border_width=1,
        # TODO: RoundedBorders for bar?
        border_color=colors["overlay0"],
    )


screen_params = dict(
    wallpaper="/home/farangoth/.config/qtile/wallpaper.png",
    wallpaper_mode="fill",
)

screens = [
    Screen(
        top=create_bar(),
        **screen_params,
    ),
    Screen(
        top=create_bar(),
        **screen_params,
    ),
]

mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ],
    border_width=2,
    border_normal=RoundedCorners(colour=colors["overlay0"]),
    border_focus=RoundedCorners(colour=colors["lavender"]),
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24


@hook.subscribe.startup_once
def autostart():
    """Run autostart applications."""
    home = os.path.expanduser("~")
    autostart_script = os.path.join(home, ".config", "qtile", "autostart.sh")
    if os.path.exists(autostart_script):
        subprocess.call([autostart_script])
    else:
        print(f"Autostart script not found: {autostart_script}")
