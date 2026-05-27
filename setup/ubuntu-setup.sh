#!/bin/bash
# Ubuntu setup — Run inside proot
# bash ~/desktop/setup/ubuntu-setup.sh

BLUE_BG='\033[44m'
WHITE_TEXT='\033[1;37m'
CYAN_TEXT='\033[1;36m'
RESET='\033[0m'

clear
echo -e "${BLUE_BG}${WHITE_TEXT}                                           ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}    Ubuntu Setup (Inside Proot)             ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}                                           ${RESET}"
echo ""

# Select DE
echo -e "${CYAN_TEXT}🖥️ Select Desktop:${RESET}"
echo "1) XFCE  2) KDE  3) GNOME  4) MATE  5) LXQt  6) Openbox  7) i3wm  8) Cinnamon"
read -r -p "Enter [1]: " de_num
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
echo "$DE" > ~/.proot-de

# Options
read -r -p "Wine? [y/N]: " wine_ans
read -r -p "Media? [Y/n]: " media_ans
read -r -p "Photo? [Y/n]: " photo_ans
read -r -p "Games? [Y/n]: " games_ans

ARCH=$(dpkg --print-architecture)

echo -e "${BLUE_BG}${WHITE_TEXT}Installing...${RESET}"
apt update -y && apt upgrade -y
apt install -y dbus dbus-x11 wget curl git nano mesa-utils libgl1-mesa-dri
apt install -y xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar

[[ "${media_ans,,}" != "n" ]] && apt install -y vlc mpv 2>/dev/null
[[ "${photo_ans,,}" != "n" ]] && apt install -y gimp darktable 2>/dev/null
[[ "${games_ans,,}" != "n" ]] && apt install -y supertuxkart neverball freedoom 2>/dev/null
[[ "${games_ans,,}" != "n" ]] && [[ "$ARCH" == "amd64" ]] && apt install -y xonotic openarena 2>/dev/null
[[ "${wine_ans,,}" == "y" ]] && dpkg --add-architecture i386 && apt update && apt install -y wine wine32 wine64 2>/dev/null

cat >> ~/.bashrc << 'EOF'
export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1
export mesa_glthread=true
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval $(dbus-launch --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
fi
EOF

source ~/.bashrc
eval $(dbus-launch --sh-syntax) 2>/dev/null
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null

echo -e "${BLUE_BG}${WHITE_TEXT}✅ Ubuntu ready!${RESET}"
