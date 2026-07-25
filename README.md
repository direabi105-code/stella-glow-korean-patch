# Stella Glow 한국어 패치 v29

Nintendo 3DS용 **Stella Glow 영어판 Undub**(`CTR-P-BS3E`)에 적용하는 한국어 LayeredFS 패치입니다.

- 대상 Title ID: `0004000000173700`
- 최신 버전: **v29**
- 기준 원본 CIA SHA-256: `9388921B8209F8F2741916335A33EDF0D661BE8F1450CAF38314D7EF309437C9`
- 패치 파일: 1,455개
- 패치 데이터: 약 20.2 MB
- 완성 CIA와 원본 게임 데이터 전체는 포함하지 않습니다.

## 지원 범위

- 전체 대사 한국어화
- 인물·지명·아이템·스킬·프로필 문자열 교정
- 한글 폰트와 문자 폭·명도 조정
- 메뉴·전투·상점·저장 화면 등 안전한 범위의 UI 한국어화
- v29까지 확인된 오역, 표기 통일, 숫자·기호 간격 및 UI 잘림 개선

## Luma3DS 설치

1. 게임과 홈 메뉴를 종료합니다.
2. 배포 ZIP의 `luma` 폴더를 SD 카드 루트에 병합합니다.
3. 다음 경로가 존재하는지 확인합니다.

```text
luma/titles/0004000000173700/romfs
```

4. Luma3DS 설정에서 **Enable game patching**을 켭니다.
5. Stella Glow를 실행합니다.

## Azahar 설치

1. Azahar의 게임 목록에서 Stella Glow를 우클릭합니다.
2. 모드 데이터 위치를 엽니다.
3. 이 패치의 `romfs` 폴더 내용을 해당 타이틀의 모드 RomFS 위치에 복사합니다.
4. 기존 구버전 패치가 있다면 혼합하지 말고 교체합니다.
5. 게임을 실행합니다.

완성된 CIA가 필요한 경우에는 사용자가 보유한 원본을 직접 추출하여 패치하거나, 제공된 LayeredFS 형식으로 실행하십시오.

## 무결성 확인

PowerShell에서 다음 명령을 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\verify_patch.ps1
```

검증기는 `metadata/patch_manifest_v29.json`에 기록된 1,455개 파일의 크기와 SHA-256을 확인합니다.

## 알려진 사항

- UI 크기와 글꼴 렌더링은 실제 3DS와 에뮬레이터 배율에 따라 조금 다르게 보일 수 있습니다.
- 저장 데이터는 패치에 포함되지 않으며 LayeredFS 패치 교체로 삭제되지 않습니다.
- 다른 지역판이나 일본 정식판에는 그대로 적용하지 마십시오.

## 구성

```text
luma/titles/0004000000173700/romfs/  패치 파일
metadata/patch_manifest_v29.json    파일별 원본/패치 해시
verify_patch.ps1                    패치 무결성 검사
CHANGELOG.md                        변경 기록
```
