# Stella Glow 한국어 패치 롤백·회귀 감사 보고서

- 감사일: 2026-07-28
- 대상: v31 작업 트리, `kr_fixes`, `dist/romfs`, Azahar 실설치본, Git 배포 원본
- 목적: 임시 설치본에는 남아 있지만 원본 저장소·재빌드 과정에서 사라질 수 있는 수정과 실제 재발한 문제를 전수 비교

## 결론

확정된 실제 회귀 2계열과, 다음 정리·체크아웃·배포 때 회귀할 뻔한 원본 불일치 2계열을 찾았다. 현재는 Git 원본, `kr_fixes`, 빌드 산출물, Azahar 설치본을 바이트 단위로 일치시켰으며 총 1,469개 RomFS 파일과 1개 추가 파일의 무결성 검사를 통과했다.

## 1. 실제로 재발했던 회귀

### 1.1 이벤트 대사 복원 419파일 소실

- 과거 직접 설치한 이벤트 대사 복원본 419파일이 `kr_fixes`에 흡수되지 않은 상태에서 전체 빌드를 수행해 사라진 이력이 있다.
- 원인: Azahar 실설치본만 최신이고 재빌드의 입력 원본은 과거 상태였음.
- 현재: 이벤트 오버라이드 430파일을 빌드 입력에 흡수했다.
- 방지: `check_codex_overlay()`가 복원 파일 누락을 검사하며, 누락 시 설치 빌드를 중단한다.

### 1.2 HP·SP·닫는 낫표 및 기호 뒤 간격 재발

사용자가 확인한 다음 현상은 실제 폰트 메트릭과 문자열 데이터가 과거 값으로 돌아간 회귀였다.

- `HP`, `SP`의 영문 자간 확대
- 닫는 낫표 `」` 뒤 공간 확대
- `%`, 숫자, `× 1`처럼 혼합 문자열의 부자연스러운 간격

확인된 소형 설명 폰트 `font_common(.2)` 메트릭 변화:

| 글리프 | 과거 v30/v31 계열 | 현재 수정값 |
|---|---:|---:|
| H | advance 11 | advance 10 |
| S | advance 10 | advance 9 |
| `」` | advance 12 | advance 6 |

- `skill_param.str`의 `」\u3000` 조합도 현재 0건이다.
- 원인: 앞선 개선이 큰 UI용 `_font_common`에만 남거나 실설치본에만 적용되고, 작은 설명용 `font_common` 원본에는 완전히 흡수되지 않았음.
- 현재: `font_common.bffnt`, `font_common2.bffnt`, `skill_param.str`를 Git 배포 원본까지 동기화했다.
- 방지: 빌더의 `check_spacing_regressions()`가 위 메트릭과 전각 공백 재출현을 검사하고 실패 처리한다.

## 2. 아직 화면에서 재발하지는 않았지만 롤백 직전이었던 항목

### 2.1 AUTO → 자동 UI 2파일

다음 최종 에셋이 `kr_fixes`와 Azahar에는 있었지만 Git 배포 원본에는 없었다.

- `indicator/message_window/message_window.arc.cmp`
- `indicator/message_window/system_window.arc.cmp`

이 상태에서는 현재 빌더로는 유지되더라도 `kr_fixes` 정리, 새 체크아웃, 다른 PC 인계 또는 Git 기반 재패키징 시 영어 `AUTO`로 돌아간다. 두 파일을 Git 원본에 추가했다.

### 2.2 소지금 UI 사선·테두리 형상

- `indicator/menu/menu_top.arc.cmp`
- `kr_fixes`의 최종본과 Git 배포본이 달랐다.
- Git 쪽은 소지금 라벨 가장자리 사각형 돌출 수정 전 상태여서, Git 기반 재배포 시 외형 문제가 재발할 수 있었다.
- 최종 네이티브 사선 형상 파일로 통일했다.

## 3. 추가로 발견한 구조적 문제

### 3.1 v31 매니페스트가 실제 패치보다 오래됨

- 기존 매니페스트: RomFS 1,467파일
- 현재 실제 패치: RomFS 1,469파일
- 폰트 해시도 수정 전 값이었다.
- 기존 검증기는 매니페스트에 없는 새 파일을 탐지하지 못했으므로, AUTO 파일 2개가 배포본에 추가되어도 검증을 통과할 수 있었다.

수정:

- `metadata/patch_manifest_v31.json`을 1,469파일 기준으로 재생성
- `verify_patch.ps1`에 미등록 파일(`UNLISTED`) 검출 추가
- 실제 파일 수와 매니페스트 파일 수 불일치 검출 추가

현재 결과:

```text
PASS: 1469 RomFS + 1 extra v31 patch files verified.
```

### 3.2 생성 스크립트가 오래된 Git 원본을 다시 읽는 위험

다음 계열의 폰트·파라미터 생성 스크립트는 Git 또는 `kr_fixes`를 입력으로 다시 파일을 만든다.

- `build_dialog_font.py`
- `fix_kr_font.py`
- `fix_hangul_alpha.py`
- `fix_faint_glyphs.py`
- 기타 파라미터 재작성 스크립트

Git 원본이 실설치본보다 오래된 상태에서는 스크립트를 다시 실행하는 것만으로 고친 자간·투명도·UI가 되돌아갈 수 있었다. 현재 Git과 `kr_fixes`가 동일하므로 이 경로도 닫혔다.

## 4. 전수 동기화 결과

감사 직전 `kr_fixes` 472개 파일을 비교했을 때:

- Git에 누락: 2개(AUTO 관련)
- Git과 내용 상이: 1개(소지금 UI)
- dist와 상이: 0개
- Azahar와 상이: 0개

수정 후 전체 1,469개 RomFS 패치 파일 비교:

- Git ↔ `kr_fixes`: 차이 0
- Git ↔ dist: 차이 0
- dist ↔ Azahar 실설치본: 차이 0
- `code.ips` Git ↔ `kr_fixes_exefs`: 차이 0

즉 현재 화면에서 테스트한 최종 설치 상태와 배포·재빌드 원본이 동일하다.

## 5. 새 회귀 방지 장치

1. `check_spacing_regressions()`
   - H/S/닫는 낫표 메트릭 검사
   - `」` 뒤 전각 공백 재출현 검사
2. `check_codex_overlay()`
   - 직접 설치했던 이벤트 대사 복원본이 빌드 입력에 흡수됐는지 검사
3. `check_source_closure()`
   - `kr_fixes` 및 `kr_fixes_exefs`와 Git 배포 원본을 전수 비교
   - 일반 스테이징에서는 경고
   - `--install`에서는 불일치가 있으면 설치 거부
4. 강화된 `verify_patch.ps1`
   - 해시, 누락, 미등록 파일, 총 파일 수를 모두 검사

## 6. 남는 운영 원칙

- Azahar 폴더에만 직접 덮어쓴 변경은 완료로 보지 않는다.
- 최종 수정은 반드시 `kr_fixes`와 Git 배포 원본 양쪽에 흡수한다.
- 전체 빌드 전 소스 폐쇄성 검사를 통과시킨다.
- 릴리스 전 매니페스트를 재생성하고 `verify_patch.ps1` PASS를 확인한다.
- 마이너 UI 수정이라도 `.arc.cmp`, 폰트, `.str` 원본을 함께 보존한다.
