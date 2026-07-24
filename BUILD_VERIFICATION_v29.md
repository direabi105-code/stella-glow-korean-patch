# Stella Glow 한국어화 v29 빌드·검증 보고서

- 작성일: 2026-07-25
- 대상 타이틀 ID: `0004000000173700`
- 기준 빌드: v28
- 결과물: `StellaGlow_KO_Resolution_v29_Emulator.cia`

## 1. 최종 결과

| 항목 | 결과 |
|---|---|
| v29 정적 검증 | PASS |
| RomFS 준비 및 오버레이 검증 | PASS |
| RomFS 이미지 생성 | PASS |
| CXI 재구성 | PASS |
| CIA 패키징 | PASS |
| CIA 내부 콘텐츠 해시 | PASS |
| Title ID 확인 | PASS |
| Azahar 런타임 검증 | 사용자 직접 테스트로 전환 |

빌드 자체와 파일 구조·해시 검증은 모두 통과했다. Azahar 설치 단계는 파일 선택 자동화 도중 사용자가 직접 설치·테스트하기로 전환했으므로, 이 보고서는 런타임 정상 동작을 확정했다고 기록하지 않는다.

## 2. 배포 파일

`P:\AI\Codex\visualizations\2026\07\21\019f83fd-da1e-72f0-bcc5-4924aee881dd\stella_glow_v29_release\StellaGlow_KO_Resolution_v29_Emulator.cia`

- 크기: 1,705,219,008 bytes
- SHA-256: `3FEFEFD19F7E8599080BA5A947C9DC9BDB1F1BECD879F807F7A5EA8E82C3C8FD`

Azahar에서 **File → CIA 설치하기...**로 위 파일을 선택하면 된다.

## 3. v29 반영 범위

v28 전체 RomFS를 기준으로 검증된 v29 오버레이 43개 파일을 적용했다.

- 전체 RomFS 파일: 26,997개
- v29 변경 파일: 43개
- 변경되지 않아 v28과 동일하게 유지된 파일: 26,954개
- 출력 RomFS의 경로 집합: v28과 완전히 동일
- 변경 대상: 누적 매니페스트 허용 목록과 일치
- 원본 파일 크기 보존이 필요한 대사 FLW: 모두 보존

변경 파일은 다음 두 계열로 구성된다.

1. **대사/문자열 수정**
   - 이벤트 및 TALK 계열 FLW
   - 누적 교정 사항과 확정된 표기·오역 수정 반영
   - 파일 크기와 구조를 유지한 채 검증된 슬롯만 교체

2. **안전 UI 수정**
   - 하단 버튼, 메뉴 상단, 전투 상태/스킬 화면, 상점, 저장 화면 등
   - 폰트 명도·가독성, 버튼 안쪽 배치, 용어 한국어화, 일부 숫자·기호 간격 교정
   - 고위험 런타임 코드나 불확실한 이미지 영역은 제외

## 4. RomFS 준비 검증

- 기준 RomFS: `stella_glow_v28_build\romfs_full`
- 출력 RomFS: `stella_glow_v29_build\romfs_full`
- 준비 방식: 변경되지 않은 파일은 하드링크 복제, 허용 목록 43개 대상만 링크 해제 후 검증 오버레이 복사
- 준비 시간: 약 47.69초
- 결과: PASS

이 방식으로 기준 빌드의 대용량 파일을 중복 복사하지 않으면서, 변경 대상만 독립 파일로 안전하게 교체했다.

## 5. 컨테이너 무결성 검증

### RomFS

- 크기: 1,703,600,128 bytes
- SHA-256: `8BCC1FCDBDD9F8E3575732FFD6CACE356C0FF3335C8887CD9CFDB472F8FF5005`

### CXI

- 크기: 1,705,189,376 bytes
- SHA-256: `76C58301C2662F5BB61A5ACC5E4AE8DC16513F33D868660061B3760F928DA95D`
- RomFS 오프셋: 1,589,248
- 내장 RomFS 크기: 1,703,600,128 bytes
- 내장 RomFS와 생성 RomFS의 바이트 단위 동일성: PASS
- RomFS superblock hash: PASS
- no-crypto 플래그 보존: PASS

### CIA

- 크기: 1,705,219,008 bytes
- SHA-256: `3FEFEFD19F7E8599080BA5A947C9DC9BDB1F1BECD879F807F7A5EA8E82C3C8FD`
- 콘텐츠 오프셋: 14,592
- 콘텐츠 크기: 1,705,189,376 bytes
- CIA 내부 콘텐츠와 CXI의 바이트 단위 동일성: PASS
- ctrtool Content hash: OK
- Title ID: `0004000000173700`

## 6. 수행한 테스트

1. v29 최종 정적 검증 스크립트 재실행
2. v28 기준 파일 경로 집합 비교
3. 오버레이 43개 파일의 허용 목록 및 해시 확인
4. 변경되지 않은 26,954개 파일의 하드링크 상태 확인
5. RomFS 이미지 생성
6. CXI 헤더와 RomFS 위치·크기 검사
7. CXI 내장 RomFS의 완전 일치 검사
8. superblock hash 검사
9. no-crypto 플래그 보존 검사
10. CIA 내부 CXI의 완전 일치 검사
11. ctrtool 콘텐츠 해시 및 Title ID 확인
12. CIA/CXI/RomFS SHA-256 산출

## 7. 런타임 확인 시 우선 점검할 항목

Azahar에서 기존 저장 데이터를 불러온 뒤 다음 항목을 우선 확인한다.

- 타이틀 및 메인 메뉴 진입
- 저장 데이터 로드와 필드 이동
- 프로필의 숫자 간격: `제28대`, `명중80` 등의 붙음/벌어짐
- 장비 설명의 `+숫자`, `×1` 표기
- 이동 형식 `보행`, `수상`의 받침 유무에 따른 크기와 명도
- `장비`, `전리품`, `훔칠 물품`의 하단 잘림 여부
- 전투 준비 화면의 `배치`, `임무 시작`, 세로 탭 가독성
- 하단 버튼 텍스트의 버튼 영역 이탈 여부
- 대사창의 빈 문자열, 강제 개행, 2줄/3줄 잘림 재발 여부

## 8. 관련 검증 자료

- `verification_v29.json`: 최종 기계 검증 결과
- `SHA256SUMS.txt`: CIA/CXI/RomFS 해시
- `ctrtool_verify_v29.txt`: ctrtool 컨테이너 검사 로그
- `makerom_v29.log`: CIA 패키징 로그
- `romfs_preparation_manifest.json`: 43개 변경 파일의 이전/이후 해시 및 파일 크기

## 9. 결론

v29 CIA는 정적 파일 검증, RomFS 구성, CXI 재구성, CIA 패키징 및 컨테이너 해시 검사를 모두 통과했다. 설치 가능한 에뮬레이터용 CIA로 생성되었으며, 남은 단계는 실제 저장 데이터와 여러 UI 화면을 이용한 사용자 런타임 육안 검증이다.
