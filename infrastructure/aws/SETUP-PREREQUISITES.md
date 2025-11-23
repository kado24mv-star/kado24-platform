# Prerequisites Setup Guide for Windows

Before deploying, you need to install the required tools.

## Required Tools

1. **AWS CLI** - For interacting with AWS
2. **Terraform** - For infrastructure as code
3. **Docker** - For building container images
4. **Maven** - For building Java services
5. **Node.js** - For building Angular admin portal
6. **Flutter** - For building Flutter apps (optional for deployment)

## Installation Steps

### 1. Install AWS CLI

**Option A: Using MSI Installer (Recommended)**
1. Download: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run the installer
3. Verify: Open new PowerShell and run `aws --version`

**Option B: Using Chocolatey**
```powershell
choco install awscli
```

**Option C: Using Winget**
```powershell
winget install Amazon.AWSCLI
```

### 2. Install Terraform

**Option A: Using Chocolatey (Recommended)**
```powershell
choco install terraform
```

**Option B: Using Winget**
```powershell
winget install Hashicorp.Terraform
```

**Option C: Manual Installation**
1. Download: https://developer.hashicorp.com/terraform/downloads
2. Extract to a folder (e.g., `C:\terraform`)
3. Add to PATH: `$env:Path += ";C:\terraform"`

### 3. Install Docker Desktop

1. Download: https://www.docker.com/products/docker-desktop/
2. Install Docker Desktop
3. Start Docker Desktop
4. Verify: `docker --version`

### 4. Install Maven

**Using Chocolatey:**
```powershell
choco install maven
```

**Or download from:** https://maven.apache.org/download.cgi

### 5. Install Node.js

**Using Chocolatey:**
```powershell
choco install nodejs
```

**Or download from:** https://nodejs.org/

### 6. Configure AWS CLI

After installing AWS CLI:

```powershell
aws configure
```

You'll need:
- **AWS Access Key ID**: Get from AWS Console → IAM → Users → Your User → Security Credentials
- **AWS Secret Access Key**: Same location
- **Default region**: `us-east-1` (or your preferred region)
- **Default output format**: `json`

### 7. Verify Installation

Run these commands to verify everything is installed:

```powershell
aws --version
terraform version
docker --version
mvn --version
node --version
npm --version
```

## Quick Install Script (Chocolatey)

If you have Chocolatey installed, run this script:

```powershell
# Install all prerequisites
choco install awscli terraform docker-desktop maven nodejs -y

# Restart PowerShell after installation
```

## Alternative: Use AWS CloudShell

If you prefer not to install tools locally, you can use AWS CloudShell:
1. Go to AWS Console
2. Click the CloudShell icon (top right)
3. CloudShell has AWS CLI and Terraform pre-installed
4. Upload your project files to CloudShell

## Next Steps

After installing prerequisites:
1. Configure AWS CLI: `aws configure`
2. Verify account: `aws sts get-caller-identity`
3. Proceed with deployment: See [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)

## Troubleshooting

### AWS CLI not found
- Restart PowerShell after installation
- Check PATH: `$env:Path`
- Reinstall if needed

### Terraform not found
- Restart PowerShell
- Verify installation: `terraform version`
- Check PATH

### Docker not running
- Start Docker Desktop
- Wait for it to fully start
- Verify: `docker ps`

---

**Need help?** Check the official documentation:
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform Installation](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Docker Installation](https://docs.docker.com/get-docker/)

