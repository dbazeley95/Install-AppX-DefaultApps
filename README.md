# Install-AppX-DefaultApps
For usage on Custom WIMS or Windows 10 Education/Enterprise editions with missing Packaged Apps or additional app requirements.

This script is designed for rollout via Group Policy Object as a startup script, to improve performance, before each app installation attempt, the script will verify if the application is already installed. To save space on the HDD/SSD of the destination computer, only the apps which need to be installed are copied locally to the drive at time of use and are removed after installation. 
