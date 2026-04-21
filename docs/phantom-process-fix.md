# 🔧 Phantom Process Fix (Android 12+)

---

## Wireless ADB (No PC needed — Android 13+)

```bash
pkg install android-tools -y
```

1. Settings → Developer Options → Wireless Debugging
2. Tap **Pair device with pairing code**

```bash
adb pair IP:PORT        # enter pairing code
adb connect IP:PORT
adb shell "device_config set_sync_disabled_for_tests persistent"
adb shell "device_config put activity_manager max_phantom_processes 2147483647"
```

Verify:
```bash
adb shell device_config get activity_manager max_phantom_processes
# Should print: 2147483647
```

---

## Termux:Boot (Keep alive)

```bash
pkg install termux-boot -y
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/wake.sh << 'EOF'
#!/bin/bash
termux-wake-lock
EOF
chmod +x ~/.termux/boot/wake.sh
```

---

## Developer Options (Android 12)

Settings → Developer Options → Feature Flags → disable `settings_enable_monitor_phantom_procs`
