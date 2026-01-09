const { app, BrowserWindow, ipcMain } = require('electron');
const { spawn } = require('child_process');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 900,
        height: 700,
        minWidth: 800,
        minHeight: 600,
        frame: false,
        backgroundColor: '#0a0e27',
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegration: false,
            contextIsolation: true
        },
        icon: path.join(__dirname, 'assets', 'icon.ico')
    });

    mainWindow.loadFile('index.html');

    // Open DevTools in development
    // mainWindow.webContents.openDevTools();
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});

// Window controls
ipcMain.on('window-minimize', () => {
    mainWindow.minimize();
});

ipcMain.on('window-maximize', () => {
    if (mainWindow.isMaximized()) {
        mainWindow.unmaximize();
    } else {
        mainWindow.maximize();
    }
});

ipcMain.on('window-close', () => {
    mainWindow.close();
});

// Cleanup execution
ipcMain.on('run-cleanup', (event, options) => {
    const scriptPath = path.join(__dirname, 'CDrive_Cleanup.ps1');
    const args = ['-ExecutionPolicy', 'Bypass', '-File', scriptPath];

    if (options.deep) args.push('-Deep');
    if (options.hibernate) args.push('-DisableHibernate');
    if (options.pagefile) args.push('-TrimPageFile');

    const ps = spawn('powershell.exe', args, {
        stdio: ['ignore', 'pipe', 'pipe']
    });

    let output = '';
    let freedSpace = 0;

    ps.stdout.on('data', (data) => {
        const text = data.toString();
        output += text;

        // Parse output for progress
        if (text.includes('[OK]')) {
            const match = text.match(/\[OK\]\s+(.+)/);
            if (match) {
                event.reply('cleanup-progress', {
                    status: match[1].trim(),
                    progress: calculateProgress(output)
                });
            }
        }

        // Parse space freed
        if (text.includes('Freed:')) {
            const match = text.match(/Freed:\s+([\d.]+)\s+GB/);
            if (match) {
                freedSpace = parseFloat(match[1]);
            }
        }

        // Send status updates
        if (text.includes('Free space before:')) {
            event.reply('cleanup-progress', { status: '시작 중...', progress: 0 });
        }
        if (text.includes('Recycle Bin')) {
            event.reply('cleanup-progress', { status: '휴지통 비우는 중...', progress: 10 });
        }
        if (text.includes('Temp')) {
            event.reply('cleanup-progress', { status: '임시 파일 정리 중...', progress: 30 });
        }
        if (text.includes('Update')) {
            event.reply('cleanup-progress', { status: 'Windows Update 캐시 정리 중...', progress: 60 });
        }
        if (text.includes('DISM')) {
            event.reply('cleanup-progress', { status: 'DISM 정리 실행 중...', progress: 80 });
        }
    });

    ps.stderr.on('data', (data) => {
        console.error('PowerShell Error:', data.toString());
    });

    ps.on('close', (code) => {
        event.reply('cleanup-complete', {
            success: code === 0,
            freedSpace: freedSpace,
            output: output
        });
    });
});

function calculateProgress(output) {
    const steps = [
        'Recycle Bin',
        'Temp',
        'Update',
        'DISM'
    ];

    let completed = 0;
    steps.forEach(step => {
        if (output.includes(step)) completed++;
    });

    return Math.min((completed / steps.length) * 100, 95);
}
