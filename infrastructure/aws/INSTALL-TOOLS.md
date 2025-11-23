# Install Missing Tools - Manual Instructions

## Missing Tools: AWS CLI and Terraform

Since Chocolatey requires admin privileges, here are manual installation steps:

## Option 1: Manual Installation (Recommended)

### Install AWS CLI

1. **Download AWS CLI:**
   - Go to: https://awscli.amazonaws.com/AWSCLIV2.msi
   - Download the MSI installer

2. **Install:**
   - Double-click the downloaded MSI file
   - Follow the installation wizard
   - Restart PowerShell after installation

3. **Verify:**
   ```powershell
   aws --version
   ```

### Install Terraform

1. **Download Terraform:**
   - Go to: https://developer.hashicorp.com/terraform/downloads
   - Download Windows 64-bit version
   - Extract to a folder (e.g., `C:\terraform`)

2. **Add to PATH:**
   ```powershell
   # Add to user PATH permanently
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\terraform", "User")
   ```
   
   Or manually:
   - Right-click "This PC" → Properties → Advanced System Settings
   - Environment Variables → User variables → Path → Edit → New
   - Add: `C:\terraform`
   - OK all dialogs

3. **Restart PowerShell** and verify:
   ```powershell
   terraform version
   ```

## Option 2: Run PowerShell as Administrator

If you have admin access:

1. **Right-click PowerShell** → "Run as Administrator"
2. **Install Chocolatey:**
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

3. **Install tools:**
   ```powershell
   choco install awscli terraform -y
   ```

4. **Restart PowerShell**

## After Installation

1. **Restart PowerShell** (important!)
2. **Verify installation:**
   ```powershell
   cd infrastructure/aws/scripts
   .\check-prerequisites.ps1
   ```

3. **Configure AWS:**
   ```powershell
   aws configure
   ```

4. **Proceed with deployment**

---

**Quick Links:**
- AWS CLI: https://awscli.amazonaws.com/AWSCLIV2.msi
- Terraform: https://developer.hashicorp.com/terraform/downloads

