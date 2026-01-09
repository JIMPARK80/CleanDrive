const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    // Window controls
    minimizeWindow: () => ipcRenderer.send('window-minimize'),
    maximizeWindow: () => ipcRenderer.send('window-maximize'),
    closeWindow: () => ipcRenderer.send('window-close'),

    // Cleanup operations
    runCleanup: (options) => ipcRenderer.send('run-cleanup', options),
    onCleanupProgress: (callback) => ipcRenderer.on('cleanup-progress', (event, data) => callback(data)),
    onCleanupComplete: (callback) => ipcRenderer.on('cleanup-complete', (event, data) => callback(data))
});
