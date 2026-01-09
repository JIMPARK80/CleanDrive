# C: Drive Cleanup Tool

C 드라이브 정리 도구 / C Drive Cleanup Tool

[![VirusTotal](https://img.shields.io/badge/VirusTotal-0%2F68%20Clean-success)](https://www.virustotal.com/gui/file/037bb0c8e57691f201b9029d92866bd20f4ae37d70c84972d0408a5459436e1c)

> [!IMPORTANT]
> **처음 설치하시나요?** Windows 보안 경고가 나타날 수 있습니다. [설치 가이드](INSTALLATION.md)를 참고하세요.
> 
> **First time installing?** You may see a Windows security warning. See the [Installation Guide](INSTALLATION.md).

> [!NOTE]
> **안전성 확인 / Security Verified**: 이 프로그램은 VirusTotal에서 68개 바이러스 백신 엔진으로 검사되었으며, 모두 안전하다고 확인되었습니다.
> This program has been scanned by 68 antivirus engines on VirusTotal and verified as clean.

## 사용 방법 / Usage

### 방법 1: 간단한 배치 파일 / Method 1: Simple Batch File

**RunCleanup.bat**를 관리자 권한으로 실행하세요.
- Deep cleanup + Hibernate 비활성화가 자동으로 실행됩니다.

Right-click **RunCleanup.bat** → **Run as administrator**
- Automatically runs Deep cleanup + Disable Hibernate

### 방법 2: 메뉴가 있는 배치 파일 / Method 2: Menu Batch File

**RunCleanupMenu.bat**를 관리자 권한으로 실행한 후 옵션을 선택하세요:
1. Basic cleanup
2. Deep cleanup
3. Deep + Disable Hibernate
4. Deep + Disable Hibernate + Trim Pagefile

Right-click **RunCleanupMenu.bat** → **Run as administrator**, then select an option.

### 방법 3: GUI 프로그램 / Method 3: GUI Application

#### 배포용 빌드 방법 / How to Build for Distribution

**가장 쉬운 방법 / Easiest Method:**
```bash
CreateDistribution.bat
```
이 스크립트를 실행하면 배포용 폴더가 자동으로 생성됩니다.
Run this script to automatically create a distribution folder.

**수동 빌드 / Manual Build:**
```bash
dotnet publish CDriveCleaner.csproj -c Release
```

빌드 후 `bin/Release/net6.0-windows/win-x64/publish/` 폴더에 단일 실행 파일이 생성됩니다.
After building, a single executable file will be created in `bin/Release/net6.0-windows/win-x64/publish/` folder.

**특징 / Features:**
- ✅ **Self-contained**: .NET 런타임이 설치되어 있지 않아도 실행 가능 / Runs without .NET runtime installed
- ✅ **Single file**: 모든 의존성이 포함된 단일 EXE 파일 / Single EXE file with all dependencies
- ✅ **Ready to distribute**: 다른 사람에게 바로 배포 가능 / Ready to share with others

#### 사용 방법 / How to Use

1. `CDriveCleaner.exe`를 `CDrive_Cleanup.ps1`과 같은 폴더에 복사하세요.
   Copy `CDriveCleaner.exe` to the same folder as `CDrive_Cleanup.ps1`.

2. `CDriveCleaner.exe`를 실행하세요 (관리자 권한이 필요합니다).
   Run `CDriveCleaner.exe` (requires administrator privileges).

3. 원하는 옵션을 선택하고 "Run Cleanup" 버튼을 클릭하세요.
   Select desired options and click "Run Cleanup" button.

#### 배포 패키지 만들기 / Creating Distribution Package

`CreateDistribution.bat`를 실행하면 `CDriveCleaner_Distribution` 폴더가 생성됩니다.
이 폴더를 압축해서 다른 사람에게 배포할 수 있습니다.

Run `CreateDistribution.bat` to create a `CDriveCleaner_Distribution` folder.
You can zip this folder and distribute it to others.

## 파일 구조 / File Structure

```
CleanDrive/
├── CDrive_Cleanup.ps1          # PowerShell cleanup script
├── RunCleanup.bat              # Simple batch file
├── RunCleanupMenu.bat          # Menu batch file
├── CDriveCleaner.csproj        # C# project file
├── Program.cs                  # Entry point
├── MainForm.cs                 # GUI form
├── Build.bat                   # Build script (batch)
├── Build.ps1                   # Build script (PowerShell)
├── CreateDistribution.bat      # Create distribution package
└── README.md                   ## 🛠️ 개발 및 빌드

```bash
# 의존성 설치
npm install

# 개발 모드 실행
npm start

# Windows 인스톨러 빌드 (CleanDrive Setup.exe)
npm run build:app

# Portable 버전 (ZIP) 생성
# npx electron-packager . CleanDrive --platform=win32 --arch=x64 --out=dist
```
### 최종 사용자용 / For End Users
- Windows 10/11 (64-bit)
- PowerShell 5.1 or higher

