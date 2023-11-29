# Install Chocolatey package manager if it's not already installed
if (!(Get-Module -ListAvailable -Name chocolatey)) {
    iwr -Uri https://chocolatey.org/install.ps1 -OutFile install.ps1
    powershell -ExecutionPolicy Bypass -File install.ps1
}

# Install Git using Chocolatey
choco install git

# Clone the MTProto proxy repository from GitHub
git clone https://github.com/TelegramMessenger/MTProxy.git

# Change directory to the cloned repository
$repositoryDir = (Join-Path (Get-ChildItem env:USERPROFILE "Documents" -Directory) "MTProxy")
cd $repositoryDir

# Build the MTProto proxy
dotnet build

# Install the MTProto proxy
dotnet publish -f netcoreapp3.1 -r linux-x64 -o mtproxy

# Create a service configuration file
$serviceFile = (Join-Path $repositoryDir "mtproxy.service")
New-Item -Path $serviceFile -ItemType File
$serviceContent = "[Unit]
Description=MTProto Proxy
After=network.target

[Service]
Type=simple
User=root
ExecStart=%s/mtproxy

[Install]
WantedBy=multi-user.target"

Set-Content -Path $serviceFile -Value $serviceContent

# Copy the MTProto proxy executable and service file to the system directory
Copy-Item -Path (Join-Path $repositoryDir "bin/Debug/netcoreapp3.1/linux-x64/publish/mtproxy") -Destination "/usr/local/bin/mtproxy"
Copy-Item -Path $serviceFile -Destination "/etc/systemd/system/"

# Enable and start the MTProto proxy service
systemctl enable mtproxy
systemctl start mtproxy
