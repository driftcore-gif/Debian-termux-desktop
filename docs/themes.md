# 🎨 XFCE Themes — Experimental

> ⚠️ Custom themes are experimental. DBus issues in proot may cause failures.

---

## Stock Theme (Stable)

```bash
apt install greybird-gtk-theme -y
eval $(dbus-launch --sh-syntax)
xfconf-query -c xsettings -p /Net/ThemeName -s "Greybird"
xfconf-query -c xsettings -p /Net/IconThemeName -s "hicolor"
xfconf-query -c xfwm4 -p /general/theme -s "Greybird"
```

---

## Available Styles

| Style | Theme | Icons |
|---|---|---|
| Basic | Nordic-darker + Qogir | kora + Qogir |
| Minimalist 1 | Materia Manjaro + Tokyo Night | Tela circle |
| Windows 10 | kali-undercover | Win10 |
| Windows 95 | Chicago95 | Chicago95 |
| Modern | WhiteSur-Nord | Colloid |
| Minimalist 2 | Otis | Deepin2022 |

---

## Fix DBus Error

```bash
mkdir -p /run/dbus
dbus-daemon --system --fork 2>/dev/null || true
eval $(dbus-launch --sh-syntax)
```
