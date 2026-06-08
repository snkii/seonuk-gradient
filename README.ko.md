# Gradient Screensaver

<p align="right"><a href="README.md">English</a></p>

**데스크탑을 위한 움직이는 메시 그래디언트 — Windows 화면보호기 & macOS 배경화면.**

부드러운 색상 블롭이 어두운 배경 위를 천천히 떠다니며 Gruvbox 팔레트를 순환합니다. [seon.uk](https://seon.uk) 배경화면에서 영감을 받았습니다.

---

![미리보기](https://raw.githubusercontent.com/snkii/gradient-screensaver/main/preview.gif)

---

## 지원 플랫폼

| 플랫폼 | 형식 | 기술 |
|--------|------|------|
| 🪟 Windows | `.scr` 화면보호기 | C# · .NET 8 · WinForms |
| 🍎 macOS | `.saver` 화면보호기 | Swift · ScreenSaverView |
| 🍎 macOS | 라이브 배경화면 | Swift · WKWebView |

---

## 특징

- **3개의 색상 블롭**이 화면을 부드럽게 떠다님
- **자동 색상 순환** — 6초마다 팔레트 변경, 부드러운 색상 전환
- **Gruvbox 팔레트** — 8가지 엑센트 컬러 (노랑, 주황, 빨강, 핑크, 초록, 아쿠아, 틸, 파랑)
- **절전 모드/잠금화면 자동 일시정지** (macOS 배경화면)
- 플랫폼 SDK 외 별도 의존성 없음

---

## 설치

### 🪟 Windows — 화면보호기

> [.NET 8 SDK](https://dotnet.microsoft.com/download) 필요

```powershell
git clone https://github.com/snkii/gradient-screensaver
cd gradient-screensaver
dotnet publish -c Release
```

1. `bin\Release\net8.0-windows\win-x64\publish\` 폴더로 이동
2. `GradientScreenSaver.exe` → `GradientScreenSaver.scr` 로 이름 변경
3. `C:\Windows\System32\` 에 복사
4. 바탕화면 우클릭 → 개인 설정 → 화면 보호기 → **GradientScreenSaver** 선택

---

### 🍎 macOS — 화면보호기

```bash
git clone https://github.com/snkii/gradient-screensaver
cd gradient-screensaver/macos
make install
```

**시스템 설정 → 화면 보호기**에서 **GradientScreenSaver** 선택.

---

### 🍎 macOS — 라이브 배경화면

**[⬇ GradientWallpaper-macOS.zip 다운로드](https://github.com/snkii/gradient-screensaver/releases/latest)**

1. 압축 해제 후 `GradientWallpaper.app` 실행
2. 메뉴바에 ✦ 아이콘이 나타남
3. 첫 실행 시 Gatekeeper 차단 → 우클릭 → 열기로 우회

로그인 시 자동 실행: **시스템 설정 → 일반 → 로그인 항목 → + → GradientWallpaper**

<details>
<summary>소스에서 빌드</summary>

```bash
git clone https://github.com/snkii/gradient-screensaver
cd gradient-screensaver/wallpaper
make install        # /Applications 에 설치
make install-login  # 로그인 항목에도 자동 등록
```
</details>

메뉴바 ✦ 아이콘에서 종료 가능. Dock 아이콘 없음.

---

## 색상 팔레트

Gruvbox 팔레트의 8가지 엑센트 컬러:

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

## 라이브 데모

동일한 애니메이션이 **[seon.uk](https://seon.uk)** 배경화면으로 실행 중입니다 — 아무 곳이나 클릭하면 색상이 바뀝니다.

---

## 라이선스

MIT
