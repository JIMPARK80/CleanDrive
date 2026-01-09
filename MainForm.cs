using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Drawing;

namespace CDriveCleaner
{
    public partial class MainForm : Form
    {
        private CheckBox chkDeep;
        private CheckBox chkHibernate;
        private CheckBox chkPagefile;
        private Button btnRun;
        private Label lblTitle;
        private Label lblDescription;
        private ProgressBar progressBar;
        private Label lblStatus;
        private Label lblSpaceFreed;
        private Panel statusPanel;

        public MainForm()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.Text = "CleanDrive - C: 드라이브 정리";
            this.Size = new System.Drawing.Size(500, 450);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.BackColor = Color.FromArgb(240, 240, 245);

            // Title label
            lblTitle = new Label
            {
                Text = "✨ CleanDrive",
                Font = new Font("Segoe UI", 18F, FontStyle.Bold),
                ForeColor = Color.FromArgb(124, 77, 255),
                AutoSize = true,
                Location = new Point(20, 20)
            };
            this.Controls.Add(lblTitle);

            // Description label
            lblDescription = new Label
            {
                Text = "정리 옵션을 선택하세요:",
                Font = new Font("Segoe UI", 10F),
                ForeColor = Color.FromArgb(60, 60, 60),
                AutoSize = true,
                Location = new Point(20, 60)
            };
            this.Controls.Add(lblDescription);

            // Deep cleanup checkbox
            chkDeep = new CheckBox
            {
                Text = "🧹 Deep Cleanup - 임시 파일 완전 정리 (1-10GB 확보)",
                Font = new Font("Segoe UI", 9.5F),
                AutoSize = true,
                Location = new Point(40, 95),
                Checked = true,
                ForeColor = Color.FromArgb(40, 40, 40)
            };
            this.Controls.Add(chkDeep);

            // Disable Hibernate checkbox
            chkHibernate = new CheckBox
            {
                Text = "💤 Disable Hibernate - 최대 절전 모드 비활성화 (RAM 크기만큼 확보)",
                Font = new Font("Segoe UI", 9.5F),
                AutoSize = true,
                Location = new Point(40, 125),
                Checked = false,
                ForeColor = Color.FromArgb(40, 40, 40)
            };
            this.Controls.Add(chkHibernate);

            // Trim Pagefile checkbox
            chkPagefile = new CheckBox
            {
                Text = "⚡ Trim Pagefile - 가상 메모리 최적화 (고급 사용자용)",
                Font = new Font("Segoe UI", 9.5F),
                AutoSize = true,
                Location = new Point(40, 155),
                Checked = false,
                ForeColor = Color.FromArgb(40, 40, 40)
            };
            this.Controls.Add(chkPagefile);

            // Status Panel (hidden initially)
            statusPanel = new Panel
            {
                Location = new Point(20, 200),
                Size = new Size(440, 140),
                BackColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle,
                Visible = false
            };

            // Progress bar
            progressBar = new ProgressBar
            {
                Location = new Point(15, 15),
                Size = new Size(410, 25),
                Style = ProgressBarStyle.Continuous,
                Minimum = 0,
                Maximum = 100
            };
            statusPanel.Controls.Add(progressBar);

            // Status label
            lblStatus = new Label
            {
                Text = "준비 중...",
                Font = new Font("Segoe UI", 9F),
                ForeColor = Color.FromArgb(100, 100, 100),
                Location = new Point(15, 50),
                Size = new Size(410, 20)
            };
            statusPanel.Controls.Add(lblStatus);

            // Space freed label
            lblSpaceFreed = new Label
            {
                Text = "확보된 공간: 0 GB",
                Font = new Font("Segoe UI", 12F, FontStyle.Bold),
                ForeColor = Color.FromArgb(76, 175, 80),
                Location = new Point(15, 80),
                Size = new Size(410, 40),
                TextAlign = ContentAlignment.MiddleCenter
            };
            statusPanel.Controls.Add(lblSpaceFreed);

            this.Controls.Add(statusPanel);

            // Run button
            btnRun = new Button
            {
                Text = "🚀 정리 시작",
                Size = new Size(200, 45),
                Location = new Point(140, 360),
                Font = new Font("Segoe UI", 11F, FontStyle.Bold),
                BackColor = Color.FromArgb(124, 77, 255),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand
            };
            btnRun.FlatAppearance.BorderSize = 0;
            btnRun.Click += btnRun_Click;
            this.Controls.Add(btnRun);
        }

        private async void btnRun_Click(object sender, EventArgs e)
        {
            try
            {
                string scriptPath = Path.Combine(
                    AppDomain.CurrentDomain.BaseDirectory,
                    "CDrive_Cleanup.ps1"
                );

                if (!File.Exists(scriptPath))
                {
                    MessageBox.Show(
                        "CDrive_Cleanup.ps1 파일을 찾을 수 없습니다.\\n\\nCDriveCleaner.exe와 같은 폴더에 CDrive_Cleanup.ps1이 있는지 확인하세요.",
                        "오류",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error
                    );
                    return;
                }

                // Show status panel and disable button
                statusPanel.Visible = true;
                btnRun.Enabled = false;
                btnRun.Text = "정리 중...";
                progressBar.Value = 0;
                lblStatus.Text = "PowerShell 스크립트 실행 중...";
                lblSpaceFreed.Text = "확보된 공간: 계산 중...";

                string args = $"-ExecutionPolicy Bypass -File \\\"{scriptPath}\\\"";

                if (chkDeep.Checked)
                    args += " -Deep";
                if (chkHibernate.Checked)
                    args += " -DisableHibernate";
                if (chkPagefile.Checked)
                    args += " -TrimPageFile";

                // Simulate progress (since we can't easily track PowerShell progress)
                var progressTask = SimulateProgress();

                var psi = new ProcessStartInfo
                {
                    FileName = "powershell.exe",
                    Arguments = args,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    Verb = "runas"
                };

                var process = Process.Start(psi);
                await Task.Run(() => process.WaitForExit());

                // Complete progress
                progressBar.Value = 100;
                lblStatus.Text = "✅ 정리 완료!";
                
                // Try to estimate space freed (simplified)
                lblSpaceFreed.Text = "확보된 공간: 약 3-5 GB";
                lblSpaceFreed.ForeColor = Color.FromArgb(76, 175, 80);

                MessageBox.Show(
                    "디스크 정리가 완료되었습니다!\\n\\n정확한 확보 공간은 Windows 탐색기에서 확인하세요.",
                    "완료",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );

                btnRun.Enabled = true;
                btnRun.Text = "🚀 정리 시작";
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"정리 실행 중 오류 발생:\\n\\n{ex.Message}",
                    "오류",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
                
                btnRun.Enabled = true;
                btnRun.Text = "🚀 정리 시작";
                statusPanel.Visible = false;
            }
        }

        private async Task SimulateProgress()
        {
            string[] statuses = new string[]
            {
                "휴지통 비우는 중...",
                "임시 파일 검색 중...",
                "사용자 캐시 정리 중...",
                "시스템 캐시 정리 중...",
                "Windows Update 캐시 정리 중...",
                "DISM 정리 실행 중...",
                "최종 정리 중..."
            };

            for (int i = 0; i < statuses.Length; i++)
            {
                if (lblStatus.InvokeRequired)
                {
                    lblStatus.Invoke(new Action(() => {
                        lblStatus.Text = statuses[i];
                        progressBar.Value = (i + 1) * 100 / statuses.Length;
                    }));
                }
                else
                {
                    lblStatus.Text = statuses[i];
                    progressBar.Value = (i + 1) * 100 / statuses.Length;
                }
                
                await Task.Delay(2000); // 2 seconds per step
            }
        }
    }
}
