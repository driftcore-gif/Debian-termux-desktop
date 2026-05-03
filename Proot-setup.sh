#!/bin/bash
# Run ONCE inside your proot distro:
# proot-distro login debian --shared-tmp
# bash setup/debian-setup.sh

# ─────────────────────────────────────────────
# USER CONFIG — Edit before running
# ─────────────────────────────────────────────
DE="xfce"              # xfce | kde | gnome | mate | lxqt | openbox | i3wm | cinnamon
INSTALL_WINE=true      # true | false (experimental)
INSTALL_MEDIA=true     # true | false — VLC + MPV
INSTALL_PHOTO=true     # true | false — GIMP + Darktable
INSTALL_GAMES=true     # true | false — 3D Linux games
INSTALL_STEAM=false    # true | false — Steam + Proton (experimental, needs 4GB+ free)
# ─────────────────────────────────────────────

echo "📦 Updating system..."
apt update -y && apt upgrade -y

echo "🔧 Installing base tools..."
apt install -y \
  dbus dbus-x11 wget curl git nano \
  mesa-utils libgl1-mesa-dri libvulkan1 \
  gtk2-engines-murrine gtk2-engines-pixbuf \
  greybird-gtk-theme

# ─────────────────────────────────────────────
# Desktop Environment
# ─────────────────────────────────────────────
echo "🖥️ Installing DE: $DE..."
case "$DE" in
  "xfce")
    apt install -y xfce4 xfce4-goodies xfce4-terminal \
      xfce4-whiskermenu-plugin thunar
    ;;
  "kde")
    echo "⚠️ KDE is heavy — may be slow on low-end devices"
    apt install -y kde-plasma-desktop plasma-nm konsole dolphin kwrite
    ;;
  "gnome")
    echo "⚠️ GNOME is heavy — may be slow on low-end devices"
    apt install -y gnome-shell gnome-terminal gnome-tweaks nautilus
    ;;
  "mate")
    apt install -y mate-desktop-environment mate-terminal caja
    ;;
  "lxqt")
    apt install -y lxqt lxqt-config lxterminal pcmanfm-qt
    ;;
  "openbox")
    apt install -y openbox obconf tint2 lxterminal pcmanfm
    ;;
  "i3wm")
    apt install -y i3 i3status i3lock dmenu lxterminal
    ;;
  "cinnamon")
    apt install -y cinnamon cinnamon-core gnome-terminal nemo
    ;;
  *)
    echo "Unknown DE — installing XFCE as fallback"
    apt install -y xfce4 xfce4-goodies xfce4-terminal
    ;;
esac

# ─────────────────────────────────────────────
# Media Players
# ─────────────────────────────────────────────
if [[ "$INSTALL_MEDIA" == true ]]; then
  echo "🎬 Installing Media Players (VLC + MPV)..."
  apt install -y vlc mpv
  echo "✅ Media players installed"
fi

# ─────────────────────────────────────────────
# Photo Editors
# ─────────────────────────────────────────────
if [[ "$INSTALL_PHOTO" == true ]]; then
  echo "🖼️ Installing Photo Editors (GIMP + Darktable)..."
  apt install -y gimp darktable
  echo "✅ Photo editors installed"
fi

# ─────────────────────────────────────────────
# 3D Linux Games
# ─────────────────────────────────────────────
if [[ "$INSTALL_GAMES" == true ]]; then
  echo "🎮 Installing 3D Linux Games..."
  apt install -y \
    supertuxkart \
    xonotic \
    openarena \
    freedoom \
    extremetuxracer \
    neverball \
    pingus \
    chromium-bsu || echo "⚠️ Some games may not be available"
  echo "✅ 3D games installed"
  echo "   • supertuxkart    — 3D kart racing"
  echo "   • xonotic         — fast-paced FPS"
  echo "   • openarena       — Quake-like FPS"
  echo "   • freedoom        — Doom engine game"
  echo "   • extremetuxracer — downhill racing"
  echo "   • neverball       — 3D ball game"
fi

# ─────────────────────────────────────────────
# Steam + Proton (Experimental)
# ─────────────────────────────────────────────
if [[ "$INSTALL_STEAM" == true ]]; then
  echo "🎮 Installing Steam + Proton (Experimental)..."
  dpkg --add-architecture i386
  apt update
  apt install -y \
    libgl1-mesa-dri:i386 libgl1:i386 libc6:i386 \
    libstdc++6:i386 libglib2.0-0:i386 libgtk2.0-0:i386 \
    libsdl2-2.0-0 libsdl2-2.0-0:i386 zenity xterm python3 || echo "⚠️ Some deps failed"
  wget -O /tmp/steam.deb "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
  dpkg -i /tmp/steam.deb 2>/dev/null || apt --fix-broken install -y
  rm -f /tmp/steam.deb
  echo "✅ Steam installed — run: steam"
  echo "⚠️ Enable Proton: Steam > Settings > Compatibility > Enable Steam Play"
fi

# ─────────────────────────────────────────────
# Wine (Experimental)
# ─────────────────────────────────────────────
if [[ "$INSTALL_WINE" == true ]]; then
  echo "🍷 Installing Wine (Experimental)..."
  dpkg --add-architecture i386
  apt update
  apt install -y wine wine64 wine32 winetricks || \
    echo "⚠️ Wine install failed — try manually"
fi

# ─────────────────────────────────────────────
# Write ~/.bashrc
# ─────────────────────────────────────────────
echo "⚙️ Writing ~/.bashrc..."
cat >> ~/.bashrc << 'EOF'

# === Proot Desktop ENV ===
export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1
export WINEDEBUG=-all
export WINEPREFIX=~/.wine
export mesa_glthread=true
export MESA_NO_ERROR=1

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval $(dbus-launch --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
fi
echo "🎮 Proot env loaded"
EOF

source ~/.bashrc

# ─────────────────────────────────────────────
# Apply Theme
# ─────────────────────────────────────────────
echo "🎨 Applying theme..."
eval $(dbus-launch --sh-syntax) 2>/dev/null

if [[ "$DE" == "xfce" ]]; then
  xfconf-query -c xsettings -p /Net/ThemeName -s "Greybird" 2>/dev/null
  xfconf-query -c xsettings -p /Net/IconThemeName -s "hicolor" 2>/dev/null
  xfconf-query -c xfwm4 -p /general/theme -s "Greybird" 2>/dev/null
  xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
  xfconf-query -c xfce4-keyboard-shortcuts \
    -p "/commands/custom/Super_L" \
    -n -t string \
    -s "xfce4-popup-whiskermenu" 2>/dev/null
fi

echo ""
echo "✅ Setup complete!"
echo "👉 Exit proot and run: tx11start"
