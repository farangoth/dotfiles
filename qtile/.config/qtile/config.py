from libqtile import bar, layout, qtile, widget 
from libqtile.widget import backlight
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.backend.wayland.inputs import InputConfig
from qtile_extras import widget as extra_widget
from qtile_extras.layout.decorations import RoundedCorners

mod = "mod4"
terminal = guess_terminal()

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
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
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
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "space", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key(
        [],
        "XF86MonBrightnessUp",
        lazy.widget["backlight"].change_backlight(backlight.ChangeDirection.UP),
    ),
    Key(
        [],
        "XF86MonBrightnessDown",
        lazy.widget["backlight"].change_backlight(
            widget.backlight.ChangeDirection.DOWN
        ),
    ),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume 58 5%+")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume 58 5%-")),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute 58 toggle")),
    Key([mod, "control"], "l", lazy.spawn("physlock -m")),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

wl_input_rules = {
    "type:touchpad": InputConfig(tap=True, dwt=True),
    "type:keyboard": InputConfig(kb_layout="gb", kb_options="caps:escape"),
}

groups = [
    Group("1", label="\uf120"),
    Group("2", label="\uf269", matches=[Match(wm_class="firefox_firefox")]),
]

groups.extend([Group(i, label=i + " | \ueaae") for i in "3456"])

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.MonadTall(
        border_focus_stack=[colors["lavender"], colors["overlay0"]],
        border_normal=RoundedCorners(colour=colors["overlay0"]),
        border_focus=RoundedCorners(colour=colors["lavender"]),
        border_width=2,
        margin=8,
        margin_on_single=8,
        single_border_width=2,
        ratio=0.66,
    ),
    layout.Max(
        margin=8,
        border_width=2,
        border_normal=RoundedCorners(colour=colors["overlay0"]),
        border_focus=RoundedCorners(colour=colors["lavender"]),
    ),
    # layout.TreeTab(
    # font=myfont,
    # active_bg=colors["surface0"],
    # active_fg=colors["lavender"],
    # bg_color=colors["surface0"],
    # inactive_bg=colors["surface0"],
    # inactive_fg=colors["text"],
    # panel_width=200,
    # margin=8,
    # ),
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
    padding=5,
)
extension_defaults = widget_defaults.copy()


def create_bar():
    return bar.Bar(
        [
            widget.CurrentLayout(foreground=colors["text"]),
            widget.GroupBox(
                hide_unused=True,
                highlight_method="line",
                highlight_color=[colors["surface0"], colors["surface0"]],
                active=colors["text"],
                inactive=colors["overlay0"],
                this_current_screen_border=colors["lavender"],
                this_screen_border=colors["overlay1"],
                other_current_screen_border=colors["subtext0"],
                other_screen_border=colors["overlay0"],
            ),
            widget.Prompt(),
            widget.WindowName(),
            widget.StatusNotifier(),
            widget.Wlan(fmt="\uf1eb  {}", format="{essid}", foreground=colors["mauve"]),
            widget.Battery(
                fmt="{}",
                charge_char="󰂄",
                discharge_char="󰁽",
                low_percentage=0.15,
                format="{char} {percent:2.0%}",
                foreground=colors["yellow"],
                charging_foreground=colors["green"],
                low_foreground=colors["red"],
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
            )
        ]


# @hook.subscribe.screens_reconfigured
# def setup_screens():
#     qtile.screens = []
#     outputs = wl_core.get_enabled_outputs()
# 
#     for _ in outputs:
#         qtile.screens.append(
#             Screen(
#                 top=create_bar(),
#                 wallpaper="/home/farangoth/.config/qtile/wallpaper.png",
#             )
#         )



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

# When using the Wayland backend, this can be used to configure input devices.
# wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24
