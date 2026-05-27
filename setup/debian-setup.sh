#!/bin/bash
# Debian setup — Run inside proot
# proot-distro login debian --shared-tmp
# bash ~/desktop/setup/debian-setup.sh

BLUE_BG='\033[44m'
WHITE_TEXT='\033[1;37m'
CYAN_TEXT='\033[1;36m'
RESET='\033[0m'

clear
echo -e "${BLUE_BG}${WHITE_TEXT}                                           ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}    Debian Setup (Inside Proot)             ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}                                           ${RESET}"
echo ""

# Select DE
echo -e "${CYAN_TEXT}🖥️ Select Desktop Environment:${RESET}"
echo ""
echo -e "1) XFCE      Lightweight (recommended)"
echo -e "2) KDE       Heavy (6GB+ RAM)"
echo -e "3) GNOME     Heavy (6GB+ RAM)"
echo -e "4) MATE      Medium"
echo -e "5) LXQt      Lightweight"
echo -e "6) Openbox   Minimal"
echo -e "7) i3wm      Tiling"
echo -e "8) Cinnamon  Modern"
echo ""
read -r -p "$(echo -e ${CYAN_TEXT}Enter [1]:${RESET}) " de_num
de_num="${de_num:-1}"
case "$de_num" in
  1) DE="xfce" ;;
  2) DE="kde" ;;
  3) DE="gnome" ;;
  4) DE="mate" ;;
  5) DE="lxqt" ;;
  6) DE="openbox" ;;
  7) DE="i3wm" ;;
  8) DE="cinnamon" ;;
  *) DE="xfce" ;;
esac
echo "✅ DE: $DE"

# Save DE for tx11start
echo "$DE" > ~/.proot-de

# Select apps
echo ""
echo -e "${CYAN_TEXT}📦 Optional apps:${RESET}"
read -r -p "  Install Wine? [y/N]: " wine_ans
read -r -p "  Install media players (VLC/MPV)? [Y/n]: " media_ans
read -r -p "  Install photo editors (GIMP/Darktable)? [Y/n]: " photo_ans
read -r -p "  Install 3D games? [Y/n]: " games_ans

INSTALL_WINE="false"
INSTALL_MEDIA="true"
INSTALL_PHOTO="true"
INSTALL_GAMES="true"

[[ "${wine_ans,,}" == "y" ]] && INSTALL_WINE="true"
[[ "${media_ans,,}" == "n" ]] && INSTALL_MEDIA="false"
[[ "${photo_ans,,}" == "n" ]] && INSTALL_PHOTO="false"
[[ "${games_ans,,}" == "n" ]] && INSTALL_GAMES="false"

echo ""
echo -e "${BLUE_BG}${WHITE_TEXT}  Installing...  ${RESET}"
echo ""

ARCH=$(dpkg --print-architecture)

echo -e "${CYAN_TEXT}📦 Updating...${RESET}"
apt update -y && apt upgrade -y

echo -e "${CYAN_TEXT}🔧 Base tools...${RESET}"
apt install -y dbus dbus-x11 wget curl git nano mesa-utils libgl1-mesa-dri libvulkan1 \
  gtk2-engines-murrine gtk2-engines-pixbuf greybird-gtk-theme

echo -e "${CYAN_TEXT}🖥️ $DE...${RESET}"
apt install -y xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar

[[ "$INSTALL_MEDIA" == "true" ]] && apt install -y vlc mpv 2>/dev/null && echo -e "${CYAN_TEXT}✅ Media${RESET}"
[[ "$INSTALL_PHOTO" == "true" ]] && apt install -y gimp darktable 2>/dev/null && echo -e "${CYAN_TEXT}✅ Photo${RESET}"

if [[ "$INSTALL_GAMES" == "true" ]]; then
  echo -e "${CYAN_TEXT}🎮 Games ($ARCH)...${RESET}"
  apt install -y supertuxkart neverball extremetuxracer freedoom pingus 2>/dev/null
  [[ "$ARCH" == "amd64" ]] && apt install -y openarena xonotic 2>/dev/null
  echo -e "${CYAN_TEXT}✅ Games${RESET}"
fi

[[ "$INSTALL_WINE" == "true" ]] && dpkg --add-architecture i386 && apt update && \
  apt install -y wine wine64 wine32 2>/dev/null && echo -e "${CYAN_TEXT}✅ Wine${RESET}"

cat >> ~/.bashrc << 'EOF'

export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1
export WINEDEBUG=-all
export mesa_glthread=true
export MESA_NO_ERROR=1
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval $(dbus-launch --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
fi
EOF

source ~/.bashrc
eval $(dbus-launch --sh-syntax) 2>/dev/null
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null

echo ""
echo -e "${BLUE_BG}${WHITE_TEXT}✅ Debian ready!        ${RESET}"
echo ""
echo -e "${CYAN_TEXT}👉 exit${RESET}"
echo -e "${CYAN_TEXT}👉 tx11start${RESET}"
