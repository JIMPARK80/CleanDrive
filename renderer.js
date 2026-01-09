// Renderer Process - UI Logic

let startTime;
let timerInterval;

// Window controls
document.getElementById('minimize-btn').addEventListener('click', () => {
    window.electronAPI.minimizeWindow();
});

document.getElementById('maximize-btn').addEventListener('click', () => {
    window.electronAPI.maximizeWindow();
});

document.getElementById('close-btn').addEventListener('click', () => {
    window.electronAPI.closeWindow();
});

// Option card interactions
document.querySelectorAll('.option-card').forEach(card => {
    card.addEventListener('click', (e) => {
        if (e.target.tagName !== 'INPUT' && e.target.tagName !== 'LABEL') {
            const checkbox = card.querySelector('input[type="checkbox"]');
            checkbox.checked = !checkbox.checked;
            updateCardState(card, checkbox.checked);
        }
    });

    const checkbox = card.querySelector('input[type="checkbox"]');
    checkbox.addEventListener('change', (e) => {
        updateCardState(card, e.target.checked);
    });

    // Initialize state
    updateCardState(card, checkbox.checked);
});

function updateCardState(card, checked) {
    if (checked) {
        card.classList.add('active');
    } else {
        card.classList.remove('active');
    }
}

// Start cleanup
document.getElementById('start-cleanup-btn').addEventListener('click', () => {
    const options = {
        deep: document.getElementById('opt-deep').checked,
        hibernate: document.getElementById('opt-hibernate').checked,
        pagefile: document.getElementById('opt-pagefile').checked
    };

    // Switch to progress screen
    switchScreen('progress-screen');

    // Start timer
    startTime = Date.now();
    timerInterval = setInterval(updateTimer, 1000);

    // Run cleanup
    window.electronAPI.runCleanup(options);
});

// Cleanup again
document.getElementById('cleanup-again-btn').addEventListener('click', () => {
    switchScreen('welcome-screen');
    resetProgress();
});

// Listen for progress updates
window.electronAPI.onCleanupProgress((data) => {
    updateProgress(data.progress);
    updateStatus(data.status);
});

// Listen for completion
window.electronAPI.onCleanupComplete((data) => {
    clearInterval(timerInterval);

    if (data.success) {
        showComplete(data.freedSpace);
    } else {
        showError();
    }
});

function switchScreen(screenId) {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });
    document.getElementById(screenId).classList.add('active');
}

function updateProgress(percentage) {
    const circle = document.querySelector('.progress-ring-circle');
    const radius = 90;
    const circumference = 2 * Math.PI * radius;
    const offset = circumference - (percentage / 100) * circumference;

    circle.style.strokeDashoffset = offset;

    document.querySelector('.progress-percentage').textContent = Math.round(percentage) + '%';
}

function updateStatus(status) {
    document.getElementById('status-text').textContent = status;
}

function updateTimer() {
    const elapsed = Math.floor((Date.now() - startTime) / 1000);
    const minutes = Math.floor(elapsed / 60);
    const seconds = elapsed % 60;
    document.getElementById('elapsed-time').textContent =
        `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

function showComplete(freedSpace) {
    switchScreen('complete-screen');

    // Animate the space freed number
    animateNumber(document.getElementById('final-space'), freedSpace, 'GB');
}

function showError() {
    alert('정리 중 오류가 발생했습니다. 관리자 권한으로 실행했는지 확인하세요.');
    switchScreen('welcome-screen');
    resetProgress();
}

function resetProgress() {
    updateProgress(0);
    updateStatus('준비 중...');
    document.getElementById('space-freed').textContent = '0 GB';
    document.getElementById('elapsed-time').textContent = '0:00';
}

function animateNumber(element, target, suffix = '') {
    let current = 0;
    const increment = target / 30;
    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            current = target;
            clearInterval(timer);
        }
        element.textContent = current.toFixed(2) + ' ' + suffix;
    }, 30);
}

// Add SVG gradient for progress ring
const svg = document.querySelector('.progress-ring');
const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
const gradient = document.createElementNS('http://www.w3.org/2000/svg', 'linearGradient');
gradient.setAttribute('id', 'gradient');
gradient.setAttribute('x1', '0%');
gradient.setAttribute('y1', '0%');
gradient.setAttribute('x2', '100%');
gradient.setAttribute('y2', '100%');

const stop1 = document.createElementNS('http://www.w3.org/2000/svg', 'stop');
stop1.setAttribute('offset', '0%');
stop1.setAttribute('style', 'stop-color:#7c4dff;stop-opacity:1');

const stop2 = document.createElementNS('http://www.w3.org/2000/svg', 'stop');
stop2.setAttribute('offset', '100%');
stop2.setAttribute('style', 'stop-color:#00bcd4;stop-opacity:1');

gradient.appendChild(stop1);
gradient.appendChild(stop2);
defs.appendChild(gradient);
svg.insertBefore(defs, svg.firstChild);
