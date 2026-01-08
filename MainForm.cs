using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

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

        public MainForm()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.Text = "C: Drive Cleanup Tool";
            this.Size = new System.Drawing.Size(400, 250);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;

            // Title label
            lblTitle = new Label
            {
                Text = "C: Drive Cleanup",
                Font = new System.Drawing.Font("Microsoft Sans Serif", 14F, System.Drawing.FontStyle.Bold),
                AutoSize = true,
                Location = new System.Drawing.Point(20, 20)
            };
            this.Controls.Add(lblTitle);

            // Description label
            lblDescription = new Label
            {
                Text = "Select cleanup options:",
                AutoSize = true,
                Location = new System.Drawing.Point(20, 50)
            };
            this.Controls.Add(lblDescription);

            // Deep cleanup checkbox
            chkDeep = new CheckBox
            {
                Text = "Deep Cleanup (more thorough)",
                AutoSize = true,
                Location = new System.Drawing.Point(40, 80),
                Checked = true
            };
            this.Controls.Add(chkDeep);

            // Disable Hibernate checkbox
            chkHibernate = new CheckBox
            {
                Text = "Disable Hibernate (frees space)",
                AutoSize = true,
                Location = new System.Drawing.Point(40, 105),
                Checked = false
            };
            this.Controls.Add(chkHibernate);

            // Trim Pagefile checkbox
            chkPagefile = new CheckBox
            {
                Text = "Trim Pagefile",
                AutoSize = true,
                Location = new System.Drawing.Point(40, 130),
                Checked = false
            };
            this.Controls.Add(chkPagefile);

            // Run button
            btnRun = new Button
            {
                Text = "Run Cleanup",
                Size = new System.Drawing.Size(120, 35),
                Location = new System.Drawing.Point(130, 170),
                UseVisualStyleBackColor = true
            };
            btnRun.Click += btnRun_Click;
            this.Controls.Add(btnRun);
        }

        private void btnRun_Click(object sender, EventArgs e)
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
                        "CDrive_Cleanup.ps1 not found next to the EXE.\n\nPlease ensure CDrive_Cleanup.ps1 is in the same folder as CDriveCleaner.exe.",
                        "Error",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error
                    );
                    return;
                }

                string args = $"-ExecutionPolicy Bypass -File \"{scriptPath}\"";

                if (chkDeep.Checked)
                    args += " -Deep";
                if (chkHibernate.Checked)
                    args += " -DisableHibernate";
                if (chkPagefile.Checked)
                    args += " -TrimPageFile";

                var psi = new ProcessStartInfo
                {
                    FileName = "powershell.exe",
                    Arguments = args,
                    UseShellExecute = true,
                    Verb = "runas"  // ask for admin
                };

                Process.Start(psi);
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Error running cleanup:\n\n{ex.Message}",
                    "Run Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
        }
    }
}

