#!/data/data/com.termux/files/usr/bin/bash
# install.sh — Termux ONLY (minimal, no distro/DE sync issues)
# Just installs packages + tx11start

TERMUX_BIN="/data/data/com.termux/files/usr/bin"
TX11_BIN="$TERMUX_BIN/tx11start"

BLUE_BG='\033[44m'
WHITE_TEXT='\033[1;37m'
CYAN_TEXT='\033[1;36m'
RESET='\033[0m'

clear
echo -e "${BLUE_BG}${WHITE_TEXT}                                           ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}    debian-termux-desktop                    ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}    Termux Setup (Minimal)                   ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}                                           ${RESET}"
echo ""

# Install Termux packages
echo -e "${CYAN_TEXT}📦 Installing Termux packages...${RESET}"
pkg update -y
pkg install -y proot-distro termux-x11-nightly virglrenderer-android pulseaudio wget curl git
echo -e "${CYAN_TEXT}✅ Done${RESET}"
echo ""

# Select connection type only
echo -e "${BLUE_BG}${WHITE_TEXT} Select Connection Type: ${RESET}"
echo ""
echo -e "${CYAN_TEXT}1) Termux:X11${RESET}  Fast, low latency (recommended)"
echo -e "${CYAN_TEXT}2) VNC${RESET}         Remote capable"
echo ""
read -r -p "$(echo -e ${CYAN_TEXT}Enter [1]:${RESET}) " conn_num
conn_num="${conn_num:-1}"
case "$conn_num" in
  1) CONNECTION="tx11" ;;
  2) CONNECTION="vnc" ;;
  *) CONNECTION="tx11" ;;
esac
echo -e "${CYAN_TEXT}✅ Connection: $CONNECTION${RESET}"
echo ""

[[ "$CONNECTION" == "vnc" ]] && pkg install -y tigervnc

# Generate tx11start
echo -e "${CYAN_TEXT}⚙️  Generating tx11start...${RESET}"

cat > "$TX11_BIN" << 'SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
CONNECTION="${CONNECTION}"
VNC_PORT="5901"
VNC_DISPLAY=":1"

detect_gpu() {
  local egl hw renderer
  egl=$(getprop ro.hardware.egl 2>/dev/null | tr '[:upper:]' '[:lower:]')
  hw=$(cat /proc/cpuinfo 2>/dev/null | grep -i "hardware" | tr '[:upper:]' '[:lower:]')
  renderer=$(getprop ro.hardware 2>/dev/null | tr '[:upper:]' '[:lower:]')

  if echo "$egl $hw $renderer" | grep -qi "nvidia\|tegra"; then echo "nvidia"
  elif echo "$egl $hw $renderer" | grep -qi "intel\|i915\|iris"; then echo "intel"
  elif echo "$egl $hw $renderer" | grep -qi "rockchip\|rk3"; then echo "rockchip"
  elif echo "$egl $hw $renderer" | grep -qi "adreno\|qcom\|qualcomm\|snapdragon"; then echo "adreno"
  elif echo "$egl $hw $renderer" | grep -qi "mali\|exynos\|mediatek\|dimensity\|helio"; then echo "mali"
  elif echo "$hw" | grep -qi "x86\|x86_64"; then echo "intel"
  else echo "others"
  fi
}

GPU=$(detect_gpu)
echo "🚀 Booting (GPU: $GPU)..."

pkill -f virgl_test_server 2>/dev/null
pkill -f termux-x11 2>/dev/null
pkill -f Xvnc 2>/dev/null
sleep 1

case "$GPU" in
  "nvidia")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.6COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 \
    GALLIUM_DRIVER=virpipe virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.6COMPAT; export mesa_glthread=true"
    ;;
  "intel")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.6COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 \
    GALLIUM_DRIVER=virpipe virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.6COMPAT; export mesa_glthread=true"
    ;;
  "rockchip")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=3.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.1 \
    GALLIUM_DRIVER=virpipe virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=3.3COMPAT; export mesa_glthread=true"
    ;;
  "adreno")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 \
    MESA_EXTENSION_OVERRIDE="+GL_EXT_shader_texture_lod" GALLIUM_DRIVER=virpipe \
    virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.3COMPAT; export mesa_glthread=true"
    ;;
  "mali")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 \
    GALLIUM_DRIVER=virpipe virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.3COMPAT; export mesa_glthread=true"
    ;;
  *)
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.0 GALLIUM_DRIVER=virpipe virgl_test_server_android &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.0; export mesa_glthread=true"
    ;;
esac
sleep 1

echo "🎙️ Audio..."
pulseaudio --kill 2>/dev/null; sleep 1
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --load="module-sles-source" --exit-idle-time=-1 2>/dev/null || \
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --load="module-aaudio-source" --exit-idle-time=-1 2>/dev/null || \
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 2>/dev/null
sleep 1

if [[ "$CONNECTION" == "tx11" ]]; then
  echo "📺 Termux:X11..."
  am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity 2>/dev/null
  sleep 2
  termux-x11 :0 -ac &
  sleep 2
  DISPLAY_VAR=":0"
else
  echo "🖥️ VNC:$VNC_PORT..."
  vncserver $VNC_DISPLAY -geometry 1280x720 -depth 24 2>/dev/null
  sleep 2
  DISPLAY_VAR="$VNC_DISPLAY"
fi

# Check which distro is installed
DISTRO=$(ls /data/data/com.termux/files/home/.proot-distro/ 2>/dev/null | head -1)
[[ -z "$DISTRO" ]] && DISTRO="debian"

# Detect DE from setup file
if [ -f ~/.proot-de ]; then
  DE=$(cat ~/.proot-de)
else
  DE="xfce"
fi

case "$DE" in
  "xfce")     DE_CMD="startxfce4" ;;
  "kde")      DE_CMD="startplasma-x11" ;;
  "gnome")    DE_CMD="gnome-session" ;;
  "mate")     DE_CMD="mate-session" ;;
  "lxqt")     DE_CMD="startlxqt" ;;
  "openbox")  DE_CMD="openbox-session" ;;
  "i3wm")     DE_CMD="i3" ;;
  "cinnamon") DE_CMD="cinnamon-session" ;;
  *)          DE_CMD="startxfce4" ;;
esac

proot-distro login "$DISTRO" --shared-tmp -- bash -c "
  export DISPLAY=${DISPLAY_VAR}
  export PULSE_SERVER=tcp:127.0.0.1
  export WINEDEBUG=-all
  export WINEPREFIX=~/.wine
  ${GPU_ENV}
  mkdir -p /run/dbus
  dbus-daemon --system --fork 2>/dev/null || true
  sleep 1
  [ -z \"\\\$DBUS_SESSION_BUS_ADDRESS\" ] && eval \\\$(dbus-launch --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
  xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
  echo \"🎮 Ready\"
  ${DE_CMD}
"
SCRIPT

chmod +x "$TX11_BIN"
echo -e "${CYAN_TEXT}✅ tx11start installed${RESET}"

echo ""
echo -e "${BLUE_BG}${WHITE_TEXT}                                           ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}  ✅ Termux done!                           ${RESET}"
echo -e "${BLUE_BG}${WHITE_TEXT}                                           ${RESET}"
echo ""
echo -e "${CYAN_TEXT}📖 Next steps:${RESET}"
echo ""
echo -e "${CYAN_TEXT}1. Choose distro:${RESET}"
echo "   proot-distro install debian"
echo "   proot-distro install ubuntu"
echo "   proot-distro install archlinux"
echo "   proot-distro install fedora"
echo "   proot-distro install void"
echo ""
echo -e "${CYAN_TEXT}2. Run inside proot:${RESET}"
echo "   proot-distro login DISTRO --shared-tmp"
echo "   bash ~/desktop/setup/DISTRO-setup.sh"
echo ""
echo -e "${CYAN_TEXT}3. Launch:${RESET}"
echo "   tx11start"
echo ""
