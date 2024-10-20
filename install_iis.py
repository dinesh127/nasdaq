import subprocess

def install_iis():
    try:
        # Install IIS Web Server
        subprocess.run(['powershell', 'Install-WindowsFeature -Name Web-Server -IncludeManagementTools'], check=True)
        print("IIS has been installed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while installing IIS: {e}")

if __name__ == "__main__":
    install_iis()
