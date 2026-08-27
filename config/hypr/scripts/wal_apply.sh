#!/usr/bin/env bash
# Runs pywal on an image and propagates colors to Quickshell, Hyprland, and Rofi.
# Usage: wal_apply.sh [image_path]
# Defaults to the Steam Workshop wallpaper preview.jpg if no argument given.

WORKSHOP_DIR="$HOME/.steam/steam/steamapps/workshop/content/431960"
WALLPAPER_SH="$(dirname "$0")/wallpaper.sh"
WALLPAPER_ID=$(grep -oP '(?<=WALLPAPER_ID=")[^"]+' "$WALLPAPER_SH" 2>/dev/null)
DEFAULT_IMAGE=$(find "$WORKSHOP_DIR/$WALLPAPER_ID" -maxdepth 1 -name "preview.*" \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) \
    | head -1)

IMAGE="${1:-$DEFAULT_IMAGE}"

if [[ ! -f "$IMAGE" ]]; then
    echo "wal_apply: image not found: $IMAGE" >&2
    exit 1
fi

# Generate colors with pywal (no wallpaper setting, colors only)
wal -i "$IMAGE" -n -s -q --backend wal

python3 - "$HOME" <<'PYEOF'
import json, sys, os, colorsys

home = sys.argv[1]
wal_json = f"{home}/.cache/wal/colors.json"

with open(wal_json) as f:
    wal = json.load(f)

c = wal["colors"]
s = wal["special"]

def hex_no_hash(h):
    return h.lstrip("#")

def parse_hex(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) / 255.0 for i in (0, 2, 4))

def to_hex(r, g, b):
    return "#{:02x}{:02x}{:02x}".format(
        max(0, min(255, int(r * 255))),
        max(0, min(255, int(g * 255))),
        max(0, min(255, int(b * 255))),
    )

def lighten(hex_color, amount):
    r, g, b = parse_hex(hex_color)
    h, l, sv = colorsys.rgb_to_hls(r, g, b)
    l = min(1.0, l + amount)
    return to_hex(*colorsys.hls_to_rgb(h, l, sv))

def blend(hex_a, hex_b, t):
    ra, ga, ba = parse_hex(hex_a)
    rb, gb, bb = parse_hex(hex_b)
    return to_hex(ra + (rb - ra) * t, ga + (gb - ga) * t, ba + (bb - ba) * t)

bg  = s["background"]
fg  = s["foreground"]

# ── Quickshell color JSON (/tmp/qs_colors.json) ──────────────────────────────
qs = {
    # Dark backgrounds — derived by progressively lightening the base
    "base":     bg,
    "mantle":   lighten(bg, 0.03),
    "crust":    lighten(bg, 0.01),
    # Surfaces — lifted off the background
    "surface0": lighten(bg, 0.07),
    "surface1": lighten(bg, 0.11),
    "surface2": lighten(bg, 0.15),
    # Overlays — halfway between surface and text
    "overlay0": blend(bg, fg, 0.25),
    "overlay1": blend(bg, fg, 0.35),
    "overlay2": blend(bg, fg, 0.45),
    # Text hierarchy
    "text":     fg,
    "subtext1": blend(bg, fg, 0.80),
    "subtext0": blend(bg, fg, 0.65),
    # Accent colors straight from pywal palette
    "blue":     c["color4"],
    "sapphire": c["color12"],
    "peach":    c["color3"],
    "green":    c["color2"],
    "red":      c["color1"],
    "mauve":    c["color5"],
    "pink":     c["color13"],
    "yellow":   c["color11"],
    "maroon":   c["color9"],
    "teal":     c["color6"],
}
with open("/tmp/qs_colors.json", "w") as f:
    json.dump(qs, f, indent=2)

# ── Hyprland colors.conf ──────────────────────────────────────────────────────
accent  = hex_no_hash(c["color1"])
surface = hex_no_hash(c["color8"])
hypr_conf = f"""$active_border = rgba({accent}ee)
$inactive_border = rgba({surface}aa)
"""
hypr_path = f"{home}/.config/hypr/colors.conf"
with open(hypr_path, "w") as f:
    f.write(hypr_conf)

# ── Rofi theme ────────────────────────────────────────────────────────────────
bg      = s["background"]
fg      = s["foreground"]
col0    = c["color0"]
col1    = c["color1"]
col4    = c["color4"]
col5    = c["color5"]
col7    = c["color7"]
col8    = c["color8"]
col9    = c["color9"]
col11   = c["color11"]

bg_alpha   = bg + "f2"
surf_alpha = col8 + "80"

rofi_theme = f"""* {{
    bg-col:          {bg};
    bg-col-light:    {col0};
    border-col:      {col8};
    selected-col:    {col8};
    blue:            {col4};
    fg-col:          {fg};
    fg-col2:         {col9};
    grey:            {col7};
    surface0:        {col0};
    surface1:        {col8};
    mauve:           {col5};
    rosewater:       {col11};
    bg-alpha:        {bg_alpha};
    surface-alpha:   {surf_alpha};

    background-color:   @bg-col;
    text-color:         @fg-col;
    border-color:       @border-col;
    separatorcolor:     @border-col;
    width:              600;
}}

window {{
    background-color:   @bg-alpha;
    border:             2px;
    border-color:       @border-col;
    border-radius:      8px;
    padding:            0;
}}

mainbox {{
    background-color:   transparent;
    padding:            12px;
    spacing:            8px;
}}

inputbar {{
    background-color:   @surface-alpha;
    border-radius:      6px;
    padding:            8px 12px;
    text-color:         @fg-col;
    children:           [prompt, entry];
}}

prompt {{
    background-color:   transparent;
    text-color:         @mauve;
    padding:            0 6px 0 0;
}}

entry {{
    background-color:   transparent;
    text-color:         @fg-col;
    placeholder-color:  @grey;
    placeholder:        "Search...";
}}

listview {{
    background-color:   transparent;
    lines:              8;
    columns:            1;
    spacing:            4px;
    scrollbar:          false;
}}

element {{
    background-color:   transparent;
    border-radius:      6px;
    padding:            8px 10px;
    text-color:         @fg-col;
    orientation:        horizontal;
    spacing:            8px;
}}

element selected.normal {{
    background-color:   @selected-col;
    text-color:         @fg-col;
}}

element-icon {{
    background-color:   transparent;
    size:               24px;
}}

element-text {{
    background-color:   transparent;
    text-color:         inherit;
    vertical-align:     0.5;
}}
"""
rofi_path = f"{home}/.config/rofi/theme.rasi"
with open(rofi_path, "w") as f:
    f.write(rofi_theme)

# ── GTK 3 / GTK 4 colors ──────────────────────────────────────────────────────
# Only the @define-color block is generated. The rules that give menus their
# shape live in gtk.css, which imports this file.
def luminance(hex_color):
    r, g, b = parse_hex(hex_color)
    def lin(v):
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)

def on(hex_color):
    """Whichever of the wallpaper's fg/bg stays readable on `hex_color`."""
    return bg if luminance(hex_color) > 0.4 else fg

ui_accent = c["color4"]
on_accent = on(ui_accent)
danger = c["color1"]

gtk_colors = f"""/* Generated by wal_apply.sh -- do not edit.
   Shape and layout rules belong in gtk.css, which imports this file. */

/* GTK3 */
@define-color theme_bg_color {qs['base']};
@define-color theme_fg_color {qs['text']};
@define-color theme_base_color {qs['base']};
@define-color theme_text_color {qs['text']};
@define-color theme_selected_bg_color {ui_accent};
@define-color theme_selected_fg_color {on_accent};
@define-color insensitive_bg_color {qs['mantle']};
@define-color insensitive_fg_color {qs['subtext0']};
@define-color insensitive_base_color {qs['base']};
@define-color borders {qs['surface2']};
@define-color unfocused_borders {qs['surface1']};
@define-color menu_color {qs['surface0']};

/* GTK4 / libadwaita */
@define-color window_bg_color {qs['base']};
@define-color window_fg_color {qs['text']};
@define-color view_bg_color {qs['base']};
@define-color view_fg_color {qs['text']};
@define-color headerbar_bg_color {qs['surface0']};
@define-color headerbar_fg_color {qs['text']};
@define-color headerbar_border_color {qs['surface2']};
@define-color headerbar_backdrop_color {qs['mantle']};
@define-color popover_bg_color {qs['surface0']};
@define-color popover_fg_color {qs['text']};
@define-color dialog_bg_color {qs['surface0']};
@define-color dialog_fg_color {qs['text']};
@define-color sidebar_bg_color {qs['mantle']};
@define-color sidebar_fg_color {qs['text']};
@define-color sidebar_backdrop_color {qs['mantle']};
@define-color sidebar_border_color {qs['surface2']};
@define-color card_bg_color {qs['surface1']};
@define-color card_fg_color {qs['text']};
@define-color accent_color {ui_accent};
@define-color accent_bg_color {ui_accent};
@define-color accent_fg_color {on_accent};
@define-color destructive_color {danger};
@define-color destructive_bg_color {danger};
@define-color destructive_fg_color {on(danger)};
@define-color success_color {c['color2']};
@define-color warning_color {c['color3']};
@define-color error_color {danger};
"""

for gtk_dir in ("gtk-3.0", "gtk-4.0"):
    target_dir = f"{home}/.config/{gtk_dir}"
    os.makedirs(target_dir, exist_ok=True)
    with open(f"{target_dir}/colors.css", "w") as f:
        f.write(gtk_colors)

# ── Qt (qt5ct / qt6ct) ────────────────────────────────────────────────────────
# Qt palette roles, in the order qt6ct's ColorScheme expects.
qt_active = [
    qs["text"],      # WindowText
    qs["surface1"],  # Button
    qs["surface2"],  # Light
    qs["surface1"],  # Midlight
    qs["mantle"],    # Dark
    qs["surface0"],  # Mid
    qs["text"],      # Text
    qs["text"],      # BrightText
    qs["text"],      # ButtonText
    qs["base"],      # Base
    qs["base"],      # Window
    "#000000",       # Shadow
    ui_accent,       # Highlight
    on_accent,       # HighlightedText
    c["color6"],     # Link
    c["color5"],     # LinkVisited
    qs["surface0"],  # AlternateBase
    qs["text"],      # NoRole
    qs["surface2"],  # ToolTipBase
    qs["text"],      # ToolTipText
    qs["subtext0"],  # PlaceholderText
]
qt_disabled = [
    qs["subtext0"], qs["surface0"], qs["surface2"], qs["surface1"], qs["base"],
    qs["surface0"], qs["subtext0"], qs["subtext0"], qs["subtext0"], qs["base"],
    qs["base"], "#000000", qs["surface1"], qs["subtext0"], c["color6"],
    c["color5"], qs["surface0"], qs["subtext0"], qs["surface2"], qs["subtext0"],
    qs["subtext0"],
]
qt_scheme = (
    "[ColorScheme]\n"
    f"active_colors={', '.join(qt_active)}\n"
    f"inactive_colors={', '.join(qt_active)}\n"
    f"disabled_colors={', '.join(qt_disabled)}\n"
)

# Qt draws menus as plain grey boxes unless a stylesheet says otherwise; this is
# what actually gives Qt context menus rounded corners and a hover pill.
qt_qss = f"""/* Generated by wal_apply.sh -- do not edit. */

QMenu {{
    background-color: {qs['surface0']};
    color: {qs['text']};
    border: 1px solid {qs['surface2']};
    border-radius: 12px;
    padding: 6px;
}}

QMenu::item {{
    background-color: transparent;
    padding: 7px 24px 7px 12px;
    margin: 1px 2px;
    border-radius: 8px;
}}

QMenu::item:selected {{
    background-color: {ui_accent};
    color: {on_accent};
}}

QMenu::item:disabled {{
    color: {qs['subtext0']};
}}

QMenu::separator {{
    height: 1px;
    background-color: {qs['surface2']};
    margin: 5px 10px;
}}

QMenu::indicator {{
    width: 14px;
    height: 14px;
    margin-left: 8px;
}}

QMenuBar {{
    background-color: {qs['base']};
    color: {qs['text']};
}}

QMenuBar::item {{
    background-color: transparent;
    padding: 5px 10px;
    border-radius: 7px;
}}

QMenuBar::item:selected {{
    background-color: {qs['surface1']};
}}

QToolTip {{
    background-color: {qs['surface1']};
    color: {qs['text']};
    border: 1px solid {qs['surface2']};
    border-radius: 8px;
    padding: 5px 8px;
}}
"""

for qt_dir in ("qt5ct", "qt6ct"):
    base_dir = f"{home}/.config/{qt_dir}"
    os.makedirs(f"{base_dir}/colors", exist_ok=True)
    os.makedirs(f"{base_dir}/qss", exist_ok=True)
    with open(f"{base_dir}/colors/pywal.conf", "w") as f:
        f.write(qt_scheme)
    with open(f"{base_dir}/qss/pywal.qss", "w") as f:
        f.write(qt_qss)

print("wal_apply: colors written")
print(f"  Quickshell: /tmp/qs_colors.json  (base={qs['base']}, text={qs['text']})")
print(f"  Hyprland:   {hypr_path}  (accent=#{accent})")
print(f"  Rofi:       {rofi_path}")
print(f"  GTK:        {home}/.config/gtk-[34].0/colors.css  (accent={ui_accent})")
print(f"  Qt:         {home}/.config/qt[56]ct/{{colors,qss}}/pywal.*")
PYEOF

# Reload Hyprland border colors without a full restart
hyprctl reload >/dev/null 2>&1
