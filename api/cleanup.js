const { exec } = require('child_process');
const path = require('path');
const os = require('os');

module.exports = async (req, res) => {
    if (req.method !== 'POST') {
        return res.status(405).json({ success: false, message: 'Method Not Allowed' });
    }

    const { deep, hibernate, pagefile } = req.body;
    const isWindows = os.platform() === 'win32';

    if (isWindows) {
        // Real operation for Windows (Local testing)
        const scriptPath = path.join(process.cwd(), 'CDrive_Cleanup.ps1');
        let command = `powershell.exe -ExecutionPolicy Bypass -File "${scriptPath}"`;
        if (deep) command += ' -Deep';
        if (hibernate) command += ' -DisableHibernate';
        if (pagefile) command += ' -TrimPageFile';

        exec(command, (error, stdout, stderr) => {
            if (error) {
                return res.status(500).json({ success: false, message: error.message });
            }
            res.status(200).json({ success: true, message: 'Windows cleanup completed successfully.', log: stdout });
        });
    } else {
        // Simulation for Server/Linux environment
        setTimeout(() => {
            res.status(200).json({
                success: true,
                message: 'Server environment detected. Simulation cleanup completed.',
                simulated_actions: [
                    'Scanning /tmp for abandoned sessions...',
                    'Cleaning server log rotations...',
                    'Optimizing cache directories (simulated)'
                ]
            });
        }, 2000);
    }
};
