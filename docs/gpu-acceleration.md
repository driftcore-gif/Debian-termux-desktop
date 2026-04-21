# ⚡ GPU Acceleration

Auto-detected by `tx11start` based on your device GPU.

---

## Supported GPUs

| GPU | Driver | Method |
|---|---|---|
| Adreno (Snapdragon) | VirGL + ANGLE | `virgl_test_server_android --angle-gl` |
| Mali (Exynos/Dimensity) | VirGL + ANGLE | `virgl_test_server_android --angle-gl` |
| Other / Unknown | VirGL generic | `virgl_test_server_android` |
| No HWA | llvmpipe | Software only (slow) |

---

## Manual GPU Check

```bash
getprop ro.hardware.egl
cat /proc/cpuinfo | grep -i hardware
```

---

## Test GPU inside Debian

```bash
glxinfo | grep "OpenGL renderer"
glxgears
```

Good result: `virgl` in renderer name, 100+ FPS on glxgears.

---

## Adreno Config
```bash
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.3COMPAT
export MESA_GLES_VERSION_OVERRIDE=3.2
export LIBGL_DRI3_DISABLE=1
virgl_test_server_android --angle-gl
```

## Mali Config
```bash
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.3COMPAT
export MESA_VK_WSI_PRESENT_MODE=mailbox
export MESA_VK_WSI_DEBUG=blit
virgl_test_server_android --angle-gl
```

## Generic Fallback
```bash
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.0
virgl_test_server_android
```
