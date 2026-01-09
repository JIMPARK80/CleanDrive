// Minimal app.js - Web version only provides download functionality
document.addEventListener('DOMContentLoaded', () => {
    const osBadge = document.getElementById('os-badge');
    
    // Detect OS
    const isWindows = navigator.platform.indexOf('Win') !== -1;
    osBadge.innerText = isWindows ? '💻 Windows Detected' : '🌐 Other OS Detected';
});
