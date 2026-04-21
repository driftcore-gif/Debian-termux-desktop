# 🍷 Wine — Experimental

> ⚠️ Wine support is experimental on proot. Expect bugs and limited compatibility.

---

## Install (inside Debian proot)

```bash
dpkg --add-architecture i386
apt update
apt install wine wine64 wine32 winetricks -y
```

## Test
```bash
wine --version
winecfg
```

## Run apps
```bash
wine app.exe
wine setup.exe
```

---

## Wine Types

| Type | Description |
|---|---|
| Native | ARM Windows apps only |
| Mobox | x86_64 apps on ARM — best compat |
| Hangover | Similar to Mobox |

→ For x86_64 apps: [Mobox](https://github.com/olegos2/mobox)

---

## Performance Tips

```bash
export WINEDEBUG=-all
export STAGING_WRITECOPY=1
export mesa_glthread=true
```

- Resolution: 800x600 or lower
- Disable shadows, effects, AA in game
- Best for 2000–2006 era PC games
