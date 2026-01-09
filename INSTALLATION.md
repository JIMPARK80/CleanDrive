# CleanDrive 설치 가이드 / Installation Guide

## Windows 보안 경고에 대하여 / About Windows Security Warning

CleanDrive를 처음 실행할 때 Windows가 보안 경고를 표시할 수 있습니다. 이는 **정상적인 현상**입니다.

### 왜 경고가 나타나나요? / Why does this warning appear?

- CleanDrive는 **무료 오픈소스 소프트웨어**입니다
- 상용 코드 서명 인증서($100-400/년)를 구매하지 않았습니다
- Windows는 서명되지 않은 모든 프로그램에 대해 이 경고를 표시합니다

### 안전한가요? / Is it safe?

✅ **예, 완전히 안전합니다!**
- 소스 코드가 GitHub에 공개되어 있습니다
- 악성 코드나 바이러스가 없습니다
- Windows 임시 파일만 삭제합니다

---

## 설치 방법 / Installation Steps

### 1단계: ZIP 파일 다운로드 및 압축 해제

웹사이트에서 `CleanDrive.zip`을 다운로드하고 압축을 풉니다.

### 2단계: Windows 보안 경고 처리

`CDriveCleaner.exe`를 실행하면 다음과 같은 경고가 나타납니다:

```
Windows protected your PC
Microsoft Defender SmartScreen prevented an unrecognised app from starting.
Publisher: Unknown publisher
```

**해결 방법:**

1. **"More info"** 또는 **"자세한 정보"** 클릭
2. **"Run anyway"** 또는 **"실행"** 버튼 클릭

### 3단계: 관리자 권한으로 실행

최상의 결과를 위해 관리자 권한으로 실행하세요:

1. `CDriveCleaner.exe` 우클릭
2. **"관리자 권한으로 실행"** 선택
3. UAC 프롬프트에서 **"예"** 클릭

### 4단계: 클린업 옵션 선택

프로그램이 실행되면:
- ✅ **Deep Cleanup**: 기본 임시 파일 삭제
- ⬜ **Disable Hibernate**: 최대 절전 모드 비활성화 (디스크 공간 확보)
- ⬜ **Trim Pagefile**: 페이지 파일 최적화

원하는 옵션을 선택하고 **"Run Cleanup"** 클릭!

---

## FAQ

### Q: 왜 "Unknown publisher"라고 나오나요?
**A:** 코드 서명 인증서가 없기 때문입니다. 이는 무료 소프트웨어에서 흔한 일입니다.

### Q: 정말 안전한가요?
**A:** 네! 소스 코드를 GitHub에서 확인할 수 있습니다: https://github.com/JIMPARK80/CleanDrive

### Q: 경고를 제거할 수 있나요?
**A:** 프로그램을 여러 번 실행하면 Windows가 신뢰하기 시작할 수 있습니다. 또는 상용 인증서를 구매하면 경고가 사라집니다.

### Q: 어떤 파일이 삭제되나요?
**A:** 
- Windows 임시 파일 (`%TEMP%`)
- 시스템 임시 파일 (`C:\Windows\Temp`)
- 휴지통 내용
- Windows Update 캐시
- 기타 안전하게 삭제 가능한 임시 파일

---

## 문제 해결 / Troubleshooting

### "Access Denied" 오류
→ 관리자 권한으로 실행하세요

### 프로그램이 실행되지 않음
→ .NET Framework가 설치되어 있는지 확인하세요

### 여전히 문제가 있나요?
→ GitHub Issues에 문의하세요: https://github.com/JIMPARK80/CleanDrive/issues

---

**즐거운 클린업 되세요! 🚀**
