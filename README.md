# Gradient Screensaver

**Animated mesh gradient for your desktop — Windows screensaver & macOS wallpaper.**

Soft color blobs drift across a dark background, slowly cycling through a handpicked palette. Inspired by the background on [seon.uk](https://seon.uk).

---

![preview](https://raw.githubusercontent.com/snkii/gradient-screensaver/main/preview.gif)

---

## Platforms

| Platform | Format | Tech |
|----------|--------|------|
| 🪟 Windows | `.scr` screensaver | C# · .NET 8 · WinForms |
| 🍎 macOS | `.saver` screensaver | Swift · ScreenSaverView |
| 🍎 macOS | Live wallpaper | Swift · WKWebView |

---

## Features

- **3 floating color blobs** that drift continuously across the screen
- **Auto-cycles** — palette shifts every 6 seconds with smooth color lerp
- **Gruvbox-inspired palette** — 8 handpicked accent colors (yellow, orange, red, pink, green, aqua, teal, blue)
- **Multi-monitor support** on Windows
- Zero dependencies beyond the platform SDK

---

## Install

### 🪟 Windows — Screensaver

> Requires [.NET 8 SDK](https://dotnet.microsoft.com/download)

```powershell
git clone https://github.com/snkii/gradient-screensaver
cd gradient-screensaver
dotnet publish -c Release
```

1. Go to `bin\Release\net8.0-windows\win-x64\publish\`
2. Rename `GradientScreenSaver.exe` → `GradientScreenSaver.scr`
3. Copy to `C:\Windows\System32\`
4. Right-click desktop → Personalize → Screen Saver → **GradientScreenSaver**

---

### 🍎 macOS — Screensaver

```bash
git clone https://github.com/snkii/gradient-screensaver
cd gradient-screensaver/macos
make install
```

Open **System Settings → Screen Saver** and select **GradientScreenSaver**.

---

### 🍎 macOS — Live Wallpaper

```bash
git clone https://github.com/snkii/gradient-screensaver
cd gradient-screensaver/wallpaper
make install        # install to /Applications
make install-login  # also auto-start at login
```

Installs as a proper `.app`. A ✦ icon appears in the menu bar — click it to quit.  
No Dock icon. To manage auto-start: **System Settings → General → Login Items**.

---

## Color Palette

The gradient cycles through 8 Gruvbox accent colors:

<table>
<tr>
  <td align="center"><img src="https://singlecolorimage.com/get/fabd2f/40x40" width="40" height="40"><br><code>#fabd2f</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/fe8019/40x40" width="40" height="40"><br><code>#fe8019</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/fb4934/40x40" width="40" height="40"><br><code>#fb4934</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/d3869b/40x40" width="40" height="40"><br><code>#d3869b</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/b8bb26/40x40" width="40" height="40"><br><code>#b8bb26</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/8ec07c/40x40" width="40" height="40"><br><code>#8ec07c</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/83a598/40x40" width="40" height="40"><br><code>#83a598</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/458588/40x40" width="40" height="40"><br><code>#458588</code></td>
</tr>
</table>

---

## Live Demo

The same animation runs as the background of **[seon.uk](https://seon.uk)** — click anywhere to cycle colors.

---

## License

MIT
