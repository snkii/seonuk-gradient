# Seonuk Gradient

**[English](#seonuk-gradient) · [한국어](#한국어)**

**Static mesh gradient wallpaper for macOS.**

Soft organic color blobs are generated as still scenes on a dark background. Inspired by the background on [seon.uk](https://seon.uk).

---

![preview](https://raw.githubusercontent.com/snkii/seonuk-gradient/main/preview.gif)

---

## Platform

| Platform | Format | Tech |
|----------|--------|------|
| macOS | Wallpaper app | Swift · AppKit |

---

## Features

- **3 organic color blobs** with randomized but separated position, size, stretch, rotation, and color
- **Static scenes** generated on launch, manually, or by a low-power timer
- **Menu bar controls** for 1/3/5/10 minute random still modes, pause, save, preview, and load
- **Favorite scenes** you can preview, save, and restore later
- **Static lock screen background** synced from the same desktop scene
- **Shared multi-display scene** so every connected display uses the same generated scene
- **Lifted color rendering** with subtle fine/coarse grain and warm tone overlay
- Zero dependencies beyond the macOS SDK

---

## Install

**[Download GradientWallpaper-macOS.zip](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientWallpaper-macOS.zip)**

1. Unzip and open `GradientWallpaper.app`
2. A sparkles icon appears in the menu bar
3. First launch: macOS may block it, so right-click and choose Open

To auto-start at login: **System Settings -> General -> Login Items -> + -> GradientWallpaper**

<details>
<summary>Build from source</summary>

```bash
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient/wallpaper
make install        # install to /Applications
make install-login  # also auto-start at login
```
</details>

The default mode is **Random Still - 10 Minutes**. Loading a saved scene switches to **Paused** so it stays put. The lock screen wallpaper is refreshed from the same scene shown on the desktop. No Dock icon.

---

## Color Palette

The gradient uses 10 Gruvbox accent colors:

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

## Website

The same visual language appears in the background of **[seon.uk](https://seon.uk)**.

---

## License

MIT. See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---

# 한국어

**[English](#seonuk-gradient) · [한국어](#한국어)**

**macOS용 정적 메시 그래디언트 배경화면.**

부드러운 유기적 색상 블롭을 어두운 배경 위의 정적 scene으로 생성합니다. [seon.uk](https://seon.uk) 배경화면에서 영감을 받았습니다.

---

## 지원 플랫폼

| 플랫폼 | 형식 | 기술 |
|--------|------|------|
| macOS | 배경화면 앱 | Swift · AppKit |

---

## 특징

- **3개의 유기적 색상 블롭**이 서로 분리된 위치와 색상을 유지하면서 크기, 비율, 회전을 랜덤으로 가짐
- **정적 scene**을 실행 시, 수동 생성 시, 또는 저전력 타이머로 생성
- **메뉴바 제어**로 1/3/5/10분 랜덤 정지 화면, 일시정지, 저장, 미리보기, 불러오기 가능
- **마음에 드는 scene 저장** 및 미리보기 후 복원 가능
- **잠금화면 정적 배경**을 데스크톱과 같은 scene으로 동기화
- **멀티 디스플레이 공유 scene**으로 모든 디스플레이가 같은 생성 scene 사용
- **살짝 올린 컬러 렌더링**에 subtle fine/coarse grain과 따뜻한 tone overlay 적용
- macOS SDK 외 별도 의존성 없음

---

## 설치

**[GradientWallpaper-macOS.zip 다운로드](https://github.com/snkii/seonuk-gradient/releases/latest/download/GradientWallpaper-macOS.zip)**

1. 압축 해제 후 `GradientWallpaper.app` 실행
2. 메뉴바에 sparkles 아이콘이 나타남
3. 첫 실행 시 macOS가 차단하면 우클릭 후 열기 선택

로그인 시 자동 실행: **시스템 설정 -> 일반 -> 로그인 항목 -> + -> GradientWallpaper**

<details>
<summary>소스에서 빌드</summary>

```bash
git clone https://github.com/snkii/seonuk-gradient
cd seonuk-gradient/wallpaper
make install        # /Applications 에 설치
make install-login  # 로그인 항목에도 자동 등록
```
</details>

기본값은 **Random Still - 10 Minutes**입니다. 저장한 scene을 불러오면 그대로 유지되도록 **Paused**로 전환됩니다. 잠금화면 배경은 데스크톱에 보이는 같은 장면으로 갱신됩니다. Dock 아이콘은 없습니다.

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

## 웹사이트

같은 시각 언어가 **[seon.uk](https://seon.uk)** 배경에 쓰이고 있습니다.

---

## 라이선스

MIT. [LICENSE](LICENSE)와 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)를 참고하세요.
