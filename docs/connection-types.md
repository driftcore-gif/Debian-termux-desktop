# 📺 Connection Types

Set `CONNECTION=` in `tx11start`.

---

## Termux:X11 (Recommended)

```bash
CONNECTION="tx11"
```

- Lowest latency
- Best performance
- Requires [Termux:X11 app](https://github.com/termux/termux-x11/releases)

Install in Termux:
```bash
pkg install termux-x11-nightly -y
```

---

## VNC

```bash
CONNECTION="vnc"
VNC_PORT="5901"
VNC_DISPLAY=":1"
```

- Works with any VNC viewer app
- Good for remote access
- Slightly higher latency than TX11

Install VNC server:
```bash
pkg install tigervnc -y
```

VNC viewer apps (Android):
- **AVNC** (recommended, F-Droid)
- **RealVNC Viewer**
- **bVNC**

Connect to: `localhost:5901`

---

## Comparison

| Feature | TX11 | VNC |
|---|---|---|
| Latency | 🟢 Very low | 🟡 Low |
| Performance | 🟢 Best | 🟡 Good |
| Setup | 🟢 Easy | 🟡 Medium |
| Remote access | ❌ Local only | ✅ Yes |
| App needed | Termux:X11 | Any VNC viewer |
