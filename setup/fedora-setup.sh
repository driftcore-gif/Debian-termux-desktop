#!/bin/bash
# Fedora setup
BLUE_BG='\033[44m'
WHITE_TEXT='\033[1;37m'
CYAN_TEXT='\033[1;36m'
RESET='\033[0m'

clear
echo -e "${BLUE_BG}${WHITE_TEXT}  Fedora Setup (Inside Proot)             ${RESET}"
echo ""

echo -e "${CYAN_TEXT}🖥️ Select Desktop:${RESET}"
echo "1) XFCE  2) KDE  3) GNOME  4) MATE  5) LXQt  6) Openbox  7) i3wm  8) Cinnamon"
read -r -p "Enter [1]: " de_num
case "${de_num:-1}" in
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

read -r -p "Games? [Y/n]: " games_ans
ARCH=$(uname -m)

echo -e "${BLUE_BG}${WHITE_TEXT}Installing...${RESET}"
dnf upgrade -y
dnf install -y dbus git wget curl nano mesa-dri-drivers vulkan-loader
dnf install -y xfce4-session xdesktop xfwm4 xfce4-panel xfce4-terminal
dnf install -y vlc mpv 2>/dev/null
dnf install -y gimp darktable 2>/dev/null
[[ "${games_ans,,}" != "n" ]] && dnf install -y supertuxkart freedoom 2>/dev/null
[[ "${games_ans,,}" != "n" ]] && [[ "$ARCH" == "x86_64" ]] && dnf install -y xonotic openarena 2>/dev/null

cat >> ~/.bashrc << 'EOF'
export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1
export mesa_glthread=true
[ -z "$DBUS_SESSION_BUS_ADDRESS" ] && eval $(dbus-launch --sh-syntax)
EOF

source ~/.bashrc
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
echo -e "${BLUE_BG}${WHITE_TEXT}✅ Fedora ready!${RESET}"
