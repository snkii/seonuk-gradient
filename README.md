# Seonuk Gradient

**[English](#seonuk-gradient) · [한국어](#한국어)**

**Animated mesh gradient for your desktop — Windows screensaver, Windows wallpaper & macOS wallpaper.**

Soft organic color blobs drift across a dark background, slowly cycling through a handpicked palette. Inspired by the background on [seon.uk](https://seon.uk).

---

![preview](https://raw.githubusercontent.com/snkii/seonuk-gradient/main/preview.gif)

---

## Platforms

| Platform | Format | Tech |
|----------|--------|------|
| 🪟 Windows | `.scr` screensaver | C# · .NET 8 · WinForms |
| 🪟 Windows | Live wallpaper | C# · .NET 8 · WinForms · WorkerW |
| 🍎 macOS | `.saver` screensaver | Swift · ScreenSaverView |
| 🍎 macOS | Wallpaper | Swift · AppKit |

---

## Features

- **3 organic color blobs** with randomized position, velocity, size, stretch, and rotation
- **Auto-cycles** — palette shifts every 7 seconds with smooth 6.5 second transitions
- **Gruvbox-inspired palette** — 10 handpicked accent colors
- **Vintage film grain texture** — subtle fine/coarse grain plus warm tone overlay to soften 4K banding
- **Auto-pauses on sleep / lock screen** (macOS wallpaper)
- **Static mesh lock screen background** on macOS by syncing a generated wallpaper image
- Zero dependencies beyond the platform SDK

---

## Install

### 🪟 Windows — Screensaver

**[⬇ Download GradientScreenSaver-Windows-x64.zip](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientScreenSaver-Windows-x64.zip)**

> Requires [.NET 8 SDK](https://dotnet.microsoft.com/download)

```powershell
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient
dotnet publish -c Release
```

1. Go to `bin\Release\net8.0-windows\win-x64\publish\`
2. Rename `GradientScreenSaver.exe` → `GradientScreenSaver.scr`
3. Copy to `C:\Windows\System32\`
4. Right-click desktop → Personalize → Screen Saver → **GradientScreenSaver**

---

### 🪟 Windows — Live Wallpaper

**[⬇ Download GradientWallpaper-Windows-x64.zip](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientWallpaper-Windows-x64.zip)**

```powershell
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient\wallpaper-win
dotnet publish -c Release
```

Run `bin\Release\net8.0-windows\win-x64\publish\GradientWallpaper.exe`. A tray icon lets you quit.

---

### 🍎 macOS — Screensaver

**[⬇ Download GradientScreenSaver-macOS.zip](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientScreenSaver-macOS.zip)**

```bash
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient/macos
make install
```

Open **System Settings → Screen Saver** and select **GradientScreenSaver**.

When the macOS wallpaper app has run, the screensaver starts from the latest saved desktop scene.

---

### 🍎 macOS — Wallpaper

**[⬇ Download GradientWallpaper-macOS.zip](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientWallpaper-macOS.zip)**

1. Unzip and open `GradientWallpaper.app`
2. A ✦ icon appears in the menu bar
3. First launch: macOS may block it — right-click → Open to bypass Gatekeeper

To auto-start at login: **System Settings → General → Login Items → + → GradientWallpaper**

<details>
<summary>Build from source</summary>

```bash
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient/wallpaper
make install        # install to /Applications
make install-login  # also auto-start at login
```
</details>

A ✦ icon in the menu bar lets you switch between low-power random still modes that refresh every 1/3/5/10 minutes, or pause automatic refreshes. The default is Random Still - 10 Minutes. The lock screen wallpaper is refreshed from the same scene shown on the desktop. You can also generate a new random scene or quit from the menu. No Dock icon.

---

## Color Palette

The gradient cycles through 10 Gruvbox accent colors:

<table>
<tr>
  <td align="center"><img src="https://singlecolorimage.com/get/fabd2f/40x40" width="40" height="40"><br><code>#fabd2f</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/d79921/40x40" width="40" height="40"><br><code>#d79921</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/fe8019/40x40" width="40" height="40"><br><code>#fe8019</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/fb4934/40x40" width="40" height="40"><br><code>#fb4934</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/b8bb26/40x40" width="40" height="40"><br><code>#b8bb26</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/8ec07c/40x40" width="40" height="40"><br><code>#8ec07c</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/83a598/40x40" width="40" height="40"><br><code>#83a598</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/458588/40x40" width="40" height="40"><br><code>#458588</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/d3869b/40x40" width="40" height="40"><br><code>#d3869b</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/928374/40x40" width="40" height="40"><br><code>#928374</code></td>
</tr>
</table>

---

## Live Demo

The same autonomous mesh animation runs as the background of **[seon.uk](https://seon.uk)**.

---

## License

MIT. See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---
---

# 한국어

**[English](#seonuk-gradient) · [한국어](#한국어)**

**데스크탑을 위한 움직이는 메시 그래디언트 — Windows 화면보호기, Windows 배경화면 & macOS 배경화면.**

부드러운 유기적 색상 블롭이 어두운 배경 위를 천천히 떠다니며 Gruvbox 팔레트를 순환합니다. [seon.uk](https://seon.uk) 배경화면에서 영감을 받았습니다.

---

## 지원 플랫폼

| 플랫폼 | 형식 | 기술 |
|--------|------|------|
| 🪟 Windows | `.scr` 화면보호기 | C# · .NET 8 · WinForms |
| 🪟 Windows | 라이브 배경화면 | C# · .NET 8 · WinForms · WorkerW |
| 🍎 macOS | `.saver` 화면보호기 | Swift · ScreenSaverView |
| 🍎 macOS | 배경화면 | Swift · AppKit |

---

## 특징

- **3개의 유기적 색상 블롭**이 위치, 속도, 크기, 비율, 회전을 랜덤으로 갖고 떠다님
- **자동 색상 순환** — 7초마다 팔레트 변경, 6.5초 동안 부드럽게 전환
- **Gruvbox 팔레트** — 10가지 엑센트 컬러
- **빈티지 필름 그레인 질감** — 4K banding을 줄이기 위한 fine/coarse grain + 따뜻한 tone overlay
- **절전 모드/잠금화면 자동 일시정지** (macOS 배경화면)
- **macOS 잠금화면 정적 mesh 배경** — 생성된 wallpaper 이미지를 시스템 배경으로 동기화
- 플랫폼 SDK 외 별도 의존성 없음

---

## 설치

### 🪟 Windows — 화면보호기

**[⬇ GradientScreenSaver-Windows-x64.zip 다운로드](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientScreenSaver-Windows-x64.zip)**

> [.NET 8 SDK](https://dotnet.microsoft.com/download) 필요

```powershell
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient
dotnet publish -c Release
```

1. `bin\Release\net8.0-windows\win-x64\publish\` 폴더로 이동
2. `GradientScreenSaver.exe` → `GradientScreenSaver.scr` 로 이름 변경
3. `C:\Windows\System32\` 에 복사
4. 바탕화면 우클릭 → 개인 설정 → 화면 보호기 → **GradientScreenSaver** 선택

---

### 🪟 Windows — 라이브 배경화면

**[⬇ GradientWallpaper-Windows-x64.zip 다운로드](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientWallpaper-Windows-x64.zip)**

```powershell
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient\wallpaper-win
dotnet publish -c Release
```

`bin\Release\net8.0-windows\win-x64\publish\GradientWallpaper.exe`를 실행하세요. 트레이 아이콘에서 종료할 수 있습니다.

---

### 🍎 macOS — 화면보호기

**[⬇ GradientScreenSaver-macOS.zip 다운로드](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientScreenSaver-macOS.zip)**

```bash
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient/macos
make install
```

**시스템 설정 → 화면 보호기**에서 **GradientScreenSaver** 선택.

macOS 배경화면 앱이 실행된 적이 있으면, 화면보호기는 마지막으로 저장된 데스크톱 scene에서 시작합니다.

---

### 🍎 macOS — 배경화면

**[⬇ GradientWallpaper-macOS.zip 다운로드](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientWallpaper-macOS.zip)**

1. 압축 해제 후 `GradientWallpaper.app` 실행
2. 메뉴바에 ✦ 아이콘이 나타남
3. 첫 실행 시 Gatekeeper 차단 → 우클릭 → 열기로 우회

로그인 시 자동 실행: **시스템 설정 → 일반 → 로그인 항목 → + → GradientWallpaper**

<details>
<summary>소스에서 빌드</summary>

```bash
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient/wallpaper
make install        # /Applications 에 설치
make install-login  # 로그인 항목에도 자동 등록
```
</details>

메뉴바의 ✦ 아이콘에서 1/3/5/10분 간격 저전력 랜덤 정지 화면 모드나 자동 갱신 일시정지로 전환할 수 있습니다. 기본값은 Random Still - 10 Minutes입니다. 잠금화면 배경은 데스크톱에 보이는 같은 장면으로 갱신됩니다. 즉시 새 랜덤 장면을 만들거나 종료할 수도 있고, Dock 아이콘은 없습니다.

---

## 색상 팔레트

Gruvbox 팔레트의 10가지 엑센트 컬러:

<table>
<tr>
  <td align="center"><img src="https://singlecolorimage.com/get/fabd2f/40x40" width="40" height="40"><br><code>#fabd2f</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/d79921/40x40" width="40" height="40"><br><code>#d79921</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/fe8019/40x40" width="40" height="40"><br><code>#fe8019</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/fb4934/40x40" width="40" height="40"><br><code>#fb4934</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/b8bb26/40x40" width="40" height="40"><br><code>#b8bb26</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/8ec07c/40x40" width="40" height="40"><br><code>#8ec07c</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/83a598/40x40" width="40" height="40"><br><code>#83a598</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/458588/40x40" width="40" height="40"><br><code>#458588</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/d3869b/40x40" width="40" height="40"><br><code>#d3869b</code></td>
  <td align="center"><img src="https://singlecolorimage.com/get/928374/40x40" width="40" height="40"><br><code>#928374</code></td>
</tr>
</table>

---

## 라이브 데모

동일한 자율 mesh 애니메이션이 **[seon.uk](https://seon.uk)** 배경화면으로 실행 중입니다.

---

## 라이선스

MIT. [LICENSE](LICENSE)와 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)를 참고하세요.
