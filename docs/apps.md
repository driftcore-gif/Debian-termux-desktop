# 🎬 Apps — Media & Photo

Set in `debian-setup.sh` before running:

```bash
INSTALL_MEDIA=true   # VLC + MPV
INSTALL_PHOTO=true   # GIMP + Darktable
```

---

## 🎬 Media Players

### VLC
```bash
apt install vlc -y
vlc
```
- Plays almost any format
- Supports subtitles, streaming
- Good for videos and music

### MPV
```bash
apt install mpv -y
mpv video.mp4
```
- Lightweight and fast
- Great GPU playback support
- Terminal + GUI mode

---

## 🖼️ Photo Editors

### GIMP
```bash
apt install gimp -y
gimp
```
- Full-featured photo editor
- Layers, filters, plugins
- Similar to Photoshop

### Darktable
```bash
apt install darktable -y
darktable
```
- RAW photo processing
- Non-destructive editing
- Similar to Lightroom

---

## Manual Install (inside proot)

```bash
# Media only
apt install vlc mpv -y

# Photo only
apt install gimp darktable -y

# Both
apt install vlc mpv gimp darktable -y
```
