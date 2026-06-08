# Seonuk Gradient

## 프로젝트 목적

Gruvbox 팔레트 기반의 macOS 전용 정적 mesh gradient 배경화면.
[seon.uk](https://seon.uk) 홈페이지의 canvas blob 배경과 동일한 느낌.

---

## 파일 구조

```
seonuk-gradient/
├── wallpaper/
│   ├── GradientWallpaper.swift      # macOS 배경화면 — native NSView @ desktop window level
│   ├── Info.plist
│   ├── AppIcon.icns
│   └── Makefile
├── preview.gif
├── README.md
├── THIRD_PARTY_NOTICES.md
├── LICENSE
└── CLAUDE.md
```

---

## macOS 배경화면 빌드 & 실행

```bash
cd wallpaper
make run            # 빌드 후 백그라운드 실행
make stop           # 종료
make install        # /Applications 에 설치
make install-login  # 로그인 시 자동 실행 등록
```

---

## 동작 방식

- 3개의 컬러 blob이 정적 scene으로 생성됨
- 각 blob은 실행/생성마다 위치, 크기, 비율, 회전, 색상이 랜덤으로 결정되며 색상/중심점은 최소 거리 조건으로 분리
- 기본 모드는 Random Still 10분
- 메뉴바 아이콘에서 Paused / Random Still 1·3·5·10분 모드 전환 가능
- 메뉴바에서 현재 scene 저장 및 저장한 scene 미리보기/불러오기 가능
- 저장한 scene을 불러오면 장면 유지를 위해 Paused로 전환
- 선택한 분 간격으로 새 랜덤 장면과 같은 장면의 잠금화면용 PNG만 재생성
- 멀티 디스플레이는 하나의 shared scene을 모든 화면에 적용
- 잠금화면 PNG는 현재 desktop scene과 동기화
- 최신 scene은 `~/Library/Application Support/Seonuk Gradient/current_scene.json`에 저장

---

## 디자인 컨셉

- **배경색:** `#282828`
- **blob 팔레트:** Gruvbox accent 10색
- blob은 CSS blur 기반 홈페이지 구현을 네이티브 radial mesh로 근사
- blob 크기: 화면 단변의 약 77~97%, blur는 단변의 22%
- 모든 렌더는 홈페이지와 맞춘 film grain/tone pass를 마지막에 적용
- blob 렌더링 색상은 팔레트 정체성을 유지하면서 saturation/brightness를 살짝 lift
- macOS grain은 큰 비정형 tile과 낮은 alpha로 subtle하게 적용

---

## 나에 대해

- **이름:** 김선욱 (Seonuk Kim)
- **GitHub:** snkii
- Gruvbox 색상 팔레트를 좋아함
- 이 프로젝트는 개인 홈페이지(seon.uk)의 배경에서 파생됨

---

## 코딩 규칙

- 불필요한 주석 달지 말 것
- 커밋 메시지에 `Co-Authored-By: Claude` 서명 넣지 말 것
- macOS: `wallpaper/GradientWallpaper.swift` 단일 앱 유지 선호
