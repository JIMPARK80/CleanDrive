document.addEventListener('DOMContentLoaded', () => {
    const btnRun = document.getElementById('btnRun');
    const chkDeep = document.getElementById('chkDeep');
    const chkHibernate = document.getElementById('chkHibernate');
    const chkPagefile = document.getElementById('chkPagefile');
    const progressContainer = document.getElementById('progress-container');
    const progressFill = document.getElementById('progress-fill');
    const statusText = document.getElementById('status-text');
    const osBadge = document.getElementById('os-badge');

    // Detect OS (Simplified)
    const isWindows = navigator.platform.indexOf('Win') !== -1;
    osBadge.innerText = isWindows ? '💻 Windows Detected' : '🌐 Server Environment';

    btnRun.addEventListener('click', async () => {
        btnRun.disabled = true;
        progressContainer.classList.remove('hidden');
        progressFill.style.width = '0%';
        statusText.innerText = 'Initializing cleanup...';

        const params = {
            deep: chkDeep.checked,
            hibernate: chkHibernate.checked,
            pagefile: chkPagefile.checked
        };

        try {
            // Fake progress for UX
            simulateProgress();

            const response = await fetch('/api/cleanup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(params)
            });

            const data = await response.json();
            
            if (data.success) {
                progressFill.style.width = '100%';
                statusText.innerText = `✅ Success: ${data.message}`;
            } else {
                statusText.innerText = `❌ Error: ${data.message}`;
            }
        } catch (error) {
            statusText.innerText = '❌ Failed to connect to server.';
        } finally {
            setTimeout(() => {
                btnRun.disabled = false;
            }, 2000);
        }
    });

    function simulateProgress() {
        let progress = 0;
        const interval = setInterval(() => {
            progress += Math.random() * 15;
            if (progress >= 90) {
                clearInterval(interval);
                progress = 90;
            }
            progressFill.style.width = progress + '%';
            
            const statuses = [
                'Scanning temporary files...',
                'Analyzing system cache...',
                'Clearing browser data...',
                'Optimizing storage...',
                'Finalizing report...'
            ];
            statusText.innerText = statuses[Math.floor(progress / 20)] || 'Completing...';
        }, 400);
    }
});
