#####################################
#           For Windows 10          #
#                                   #
#   A Script to reinstall missing   #
#   Windows 10 Pre-installed Apps   #
#                                   #
#          By: DBazeley95           #
#                                   #
#            Version 4.0            #
#                                   #
#####################################

#####################################
#          Version History:         #
#####################################

# - Version 1.0
#   Initial release version of the script, based of a custom WIM designed for deployment via MDT.

# - Version 2.0: 
#   This updated version of the script includes logic to check the Windows 10 Version and run the correct APPX/APPXBUNDLE.
#   The script relys on the APPX/APPXBUNDLE file being named in the format, e.g. 19044-WindowsAlarms.appx
#   After the query is run, the WindowsVersion variable is injected into the value for the APPXFILENAME variable.

# - Version 3.0: 
#   This updated version of the script includes logic to skip installation attempts on Windows 10 versions where the source app files were not readily available or compatible.
#   Also includeded is updated notes about the script and formatting changes to the script

# - Version 4.0: 
#   Updated to include a link to the Inbox Apps ISO for Windows 10 21H2

#####################################
#                Notes:             #
#####################################

# - If deploying via a Windows Startup Script (GPO), please use a WMI filter on the GPO to exclude running on devices which aren't Windows 10.
#   Example of this filter is as follows; select * from Win32_OperatingSystem where ((Version < "10.0.22000") and (ProductType="1")) 

# - AppX Files can be version specific, if deploying a missing preinstalled Windows 10 App, please download the
#   Windows 10 Inbox Apps ISO file from Microsoft VLSC and obtain the files via this method.

# - The ISO Files can also be found from these links;
#   1903/1909 - https://software-download.microsoft.com/download/pr/18362.1.190318-1202.19h1_release_amd64fre_InboxApps.iso
#   2004 - https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_amd64fre_InboxApps.iso
#   20H2 - https://software-download.microsoft.com/download/pr/19041.508.200905-1327.vb_release_svc_prod1_amd64fre_InboxApps.iso
#   21H1/21H2 - https://software-download.microsoft.com/download/sg/19041.928.210407-2138.vb_release_svc_prod1_amd64fre_InboxApps.iso

# - For newer Windows 10 versions, check the following site for a link to the ISO files; https://docs.microsoft.com/en-us/azure/virtual-desktop/language-packs

# - Another way to obtain an AppX/AppXBundle file for deployment via this script is from https://store.rg-adguard.net

# - Please remember to update the source path variable, if this script is being run on a new network location

# - Build Version Numbers:
#   21H2 - 19044
#   21H1 - 19043
#   20H2 - 19042
#   2004 - 19041
#   1909 - 18363
#   1903 - 18362

#####################################
#               Script:             #
#####################################

############################### Obtain Windows 10 OSBuildNumber ###############################
$WindowsVersion = Get-ComputerInfo | Select-Object -Expand OsBuildNumber

############################### Specific Windows 10 APPX Exclusions ###############################
$AV1AppOSExclusion = @('19041','18363','18362')
$WhiteboardAppOSExclusion = @('18363','18362')

############################### Define location of AppX Files ###############################
$SourcePath = "\\Server\NetworkShare\"

############################### Create Directory to copy AppX Files to ###############################
$InstallerPath = "C:\ProgramData\StoreApps"

if (Test-Path -Path $InstallerPath) {
    write-host "Path exists!"
} else {
    mkdir "C:\ProgramData\StoreApps"
}

############################### AppX File Names ###############################
$AlarmsAppXFileName = (-join($WindowsVersion,"-Microsoft.WindowsAlarms.appxbundle"))
$AV1ExtAppXFileName = (-join($WindowsVersion,"-Microsoft.AV1VideoExtension.appx"))
$AppInstallerAppXFileName = (-join($WindowsVersion,"-Microsoft.DesktopAppInstaller.AppxBundle"))
$HEIFExtAppXFileName = (-join($WindowsVersion,"-Microsoft.HEIFImageExtension.Appx"))
$HEVCExtAppXFileName = (-join($WindowsVersion,"-Microsoft.HEVCVideoExtension.appx"))
$MPEG2ExtAppXFileName = (-join($WindowsVersion,"-Microsoft.MPEG2VideoExtension.appx"))
$OfficeHubAppXFileName = (-join($WindowsVersion,"-Microsoft.MicrosoftOfficeHub.AppXBundle"))
$OneNoteAppXFileName = (-join($WindowsVersion,"-Microsoft.Office.OneNote.appxbundle"))
$Paint3DAppXFileName = (-join($WindowsVersion,"-Microsoft.MSPaint3D.AppxBundle"))
$PhotosAppXFileName = (-join($WindowsVersion,"-Microsoft.Windows.Photos.AppxBundle"))
$SnipAppXFileName = (-join($WindowsVersion,"-Microsoft.ScreenSketch.AppxBundle"))
$StickyNotesAppXFileName = (-join($WindowsVersion,"-Microsoft.MicrosoftStickyNotes.AppxBundle"))
$StoreAppXFileName = (-join($WindowsVersion,"-Microsoft.WindowsStore.AppxBundle"))
$StorePurchaseAppXFileName = (-join($WindowsVersion,"-Microsoft.StorePurchaseApp.appxbundle"))
$VoiceRecorderAppXFileName = (-join($WindowsVersion,"-Microsoft.WindowsSoundRecorder.AppxBundle"))
$VP9ExtAppXFileName = (-join($WindowsVersion,"-Microsoft.VP9VideoExtensions.Appx"))
$WebMediaAppXFileName = (-join($WindowsVersion,"-Microsoft.WebMediaExtensions.AppxBundle"))
$WebPImageAppXFileName = (-join($WindowsVersion,"-Microsoft.WebpImageExtension.Appx"))
$WhiteboardAppXFileName = (-join($WindowsVersion,"-Microsoft.Whiteboard.appxbundle"))

############################### AppX Package Names ###############################
$AlarmsApp = "Microsoft.WindowsAlarms"
$AV1ExtApp = "Microsoft.AV1VideoExtension"
$AppInstallerApp = "Microsoft.DesktopAppInstaller"
$HEIFExtApp = "Microsoft.HEIFImageExtension"
$HEVCExtApp = "Microsoft.HEVCVideoExtension"
$MPEG2ExtApp = "Microsoft.MPEG2VideoExtension"
$OfficeHubApp = "Microsoft.MicrosoftOfficeHub"
$OneNoteApp = "Microsoft.Office.OneNote"
$Paint3DApp = "Microsoft.MSPaint"
$PhotosApp = "Microsoft.Windows.Photos"
$SnipApp = "Microsoft.ScreenSketch"
$StickyNotesApp = "Microsoft.MicrosoftStickyNotes"
$StoreApp = "Microsoft.WindowsStore"
$StorePurchaseApp = "Microsoft.StorePurchaseApp"
$VoiceRecorderApp = "Microsoft.WindowsSoundRecorder"
$VP9ExtApp = "Microsoft.VP9VideoExtensions"
$WebMediaApp = "Microsoft.WebMediaExtensions"
$WebPImageApp = "Microsoft.WebpImageExtension"
$WhiteboardApp = "Microsoft.Whiteboard"

############################### Validate if AppX is Installed ###############################
$AlarmsCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $AlarmsApp })
$AV1ExtCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $AV1ExtApp })
$AppInstallerCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $AppInstallerApp })
$HEIFExtCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $HEIFExtApp })
$HEVCExtCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $HEVCExtApp })
$MPEG2ExtCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $MPEG2ExtApp })
$OfficeHubCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $OfficeHubApp })
$OneNoteCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $OneNoteApp })
$Paint3DCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $Paint3DApp })
$PhotosCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $PhotosApp })
$SnipCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $SnipApp })
$StickyNotesCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $StickyNotesApp })
$StoreCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $StoreApp })
$StorePurchaseCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $StorePurchaseApp })
$VoiceRecorderCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $VoiceRecorderApp })
$VP9ExtCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $VP9ExtApp })
$WebMediaCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $WebMediaApp })
$WebPImageCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $WebPImageApp })
$WhiteboardCheckInstalled = (Get-AppxPackage -allusers | Select Name | Where { $_.Name -match $WhiteboardApp })

############################### Local AppX Path ###############################
$AlarmsLocalPath = (-join($InstallerPath,"\",$AlarmsAppXFileName))
$AV1ExtLocalPath = (-join($InstallerPath,"\",$AV1ExtAppXFileName))
$AppInstallerLocalPath = (-join($InstallerPath,"\",$AppInstallerAppXFileName))
$HEIFExtLocalPath = (-join($InstallerPath,"\",$HEIFExtAppXFileName))
$HEVCExtLocalPath = (-join($InstallerPath,"\",$HEVCExtAppXFileName))
$MPEG2ExtLocalPath = (-join($InstallerPath,"\",$MPEG2ExtAppXFileName))
$OfficeHubLocalPath = (-join($InstallerPath,"\",$OfficeHubAppXFileName))
$OneNoteLocalPath = (-join($InstallerPath,"\",$OneNoteAppXFileName))
$Paint3DLocalPath = (-join($InstallerPath,"\",$Paint3DAppXFileName))
$PhotosLocalPath = (-join($InstallerPath,"\",$PhotosAppXFileName))
$SnipLocalPath = (-join($InstallerPath,"\",$SnipAppXFileName))
$StickyNotesLocalPath = (-join($InstallerPath,"\",$StickyNotesAppXFileName))
$StoreLocalPath = (-join($InstallerPath,"\",$StoreAppXFileName))
$StorePurchaseLocalPath = (-join($InstallerPath,"\",$StorePurchaseAppXFileName))
$VoiceRecorderLocalPath = (-join($InstallerPath,"\",$VoiceRecorderAppXFileName))
$VP9LocalPath = (-join($InstallerPath,"\",$VP9ExtAppXFileName))
$WebMediaLocalPath = (-join($InstallerPath,"\",$WebMediaAppXFileName))
$WebPImageLocalPath = (-join($InstallerPath,"\",$WebPImageAppXFileName))
$WhiteboardLocalPath = (-join($InstallerPath,"\",$WhiteboardAppXFileName))

############################### Network Share AppX Path ###############################
$AlarmsSharePath = (-join($SourcePath,$AlarmsAppXFileName))
$AV1ExtSharePath = (-join($SourcePath,$AV1ExtAppXFileName))
$AppInstallerSharePath = (-join($SourcePath,$AppInstallerAppXFileName))
$HEIFExtSharePath = (-join($SourcePath,$HEIFExtAppXFileName))
$HEVCExtSharePath = (-join($SourcePath,$HEVCExtAppXFileName))
$MPEG2ExtSharePath = (-join($SourcePath,$MPEG2ExtAppXFileName))
$OfficeHubSharePath = (-join($SourcePath,$OfficeHubAppXFileName))
$OneNoteSharePath = (-join($SourcePath,$OneNoteAppXFileName))
$Paint3DSharePath = (-join($SourcePath,$Paint3DAppXFileName))
$PhotosSharePath = (-join($SourcePath,$PhotosAppXFileName))
$SnipSharePath = (-join($SourcePath,$SnipAppXFileName))
$StickyNotesSharePath = (-join($SourcePath,$StickyNotesAppXFileName))
$StoreSharePath = (-join($SourcePath,$StoreAppXFileName))
$StorePurchaseSharePath = (-join($SourcePath,$StorePurchaseAppXFileName))
$VoiceRecorderSharePath = (-join($SourcePath,$VoiceRecorderAppXFileName))
$VP9SharePath = (-join($SourcePath,$VP9ExtAppXFileName))
$WebMediaSharePath = (-join($SourcePath,$WebMediaAppXFileName))
$WebPImageSharePath = (-join($SourcePath,$WebPImageAppXFileName))
$WhiteboardSharePath = (-join($SourcePath,$WhiteboardAppXFileName))

############################### Alarms ###############################
if ( $AlarmsCheckInstalled -match $AlarmsApp ) {
	write-host "Microsoft Alarms is already installed"
} 
else {
    xcopy $AlarmsSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$AlarmsLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "MicrosoftAlarms.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### AV1 Video Extension ###############################
if ( $AV1ExtCheckInstalled -match $AV1ExtApp ) {
	write-host "Microsoft AV1 Video Extension is already installed"
} 
elseif ( $Windows10OSVersion -in $AV1AppOSExclusion ) {
	write-host "Microsoft AV1 Video Extension is not compatible with this OS Version"
}
else {
    xcopy $AV1ExtSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$AV1ExtLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "MicrosoftAV1Ext.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### AppInstaller ###############################
if ( $AppInstallerCheckInstalled -match $AppInstallerApp ) {
	write-host "Microsoft App Installer is already installed"
} 
else {
    xcopy $AppInstallerSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$AppInstallerLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "AppInstaller.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### HEIF Image Extension ###############################
if ( $HEIFExtCheckInstalled -match $HEIFExtApp ) {
	write-host "Microsoft HEIF Image Extension is already installed"
} 
else {
    xcopy $HEIFExtSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$HEIFExtLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "HEIFExt.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### HEVC Video Extension ###############################
if ( $HEVCExtCheckInstalled -match $HEVCExtApp ) {
	write-host "Microsoft HEVC Video Extension is already installed"
} 
else {
    xcopy $HEVCExtSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$HEVCExtLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "HEVCExt.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### MPEG2 Video Extension ###############################
if ( $MPEG2ExtCheckInstalled -match $MPEG2ExtApp ) {
	write-host "Microsoft MPEG2 Video Extension is already installed"
} 
else {
    xcopy $MPEG2ExtSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$MPEG2ExtLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "MPEG2Ext.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Office Hub ###############################
if ( $OfficeHubCheckInstalled -match $OfficeHubApp ) {
	write-host "Microsoft Office Hub is already installed"
} 
else {
    xcopy $OfficeHubSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$OfficeHubLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "OfficeHub.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### OneNote ###############################
if ( $OneNoteCheckInstalled -match $OneNoteApp ) {
	write-host "Microsoft OneNote is already installed"
} 
else {
    xcopy $OneNoteSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$OneNoteLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "OneNote.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Paint3D ###############################
if ( $Paint3DCheckInstalled -match $Paint3DApp ) {
	write-host "Microsoft Paint3D is already installed"
} 
else {
    xcopy $Paint3DSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$Paint3DLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "Paint3D.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Photos ###############################
if ( $PhotosCheckInstalled -match $PhotosApp ) {
	write-host "Microsoft Photos is already installed"
} 
else {
    xcopy $PhotosSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$PhotosLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "MicrosoftPhotos.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Snip & Sketch ###############################
if ( $SnipCheckInstalled -match $SnipApp ) {
	write-host "Microsoft Snip and Sketch is already installed"
} 
else {
    xcopy $SnipSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$SnipLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "Microsoft SnipSketch.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Sticky Notes ###############################
if ( $StickyNotesCheckInstalled -match $StickyNotesApp ) {
	write-host "Microsoft Sticky Notes is already installed"
} 
else {
    xcopy $StickyNotesSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$StickyNotesLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "StickyNotesApp.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Store ###############################
if ( $StoreCheckInstalled -match $StoreApp ) {
	write-host "Microsoft Store is already installed"
} 
else {
    xcopy $StoreSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$StoreLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "MicrosoftStore.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Store Purchase ###############################
if ( $StorePurchaseCheckInstalled -match $StorePurchaseApp ) {
	write-host "Microsoft Store Purchase is already installed"
} 
else {
    xcopy $StorePurchaseSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$StorePurchaseLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "MicrosoftStorePurchase.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Voice Recorder ###############################
if ( $VoiceRecorderCheckInstalled -match $VoiceRecorderApp ) {
	write-host "Microsoft Voice Recorder is already installed"
} 
else {
    xcopy $VoiceRecorderSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$VoiceRecorderLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "VoiceRecorder.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### VP9 Extension ###############################
if ( $VP9ExtCheckInstalled -match $VP9ExtApp ) {
	write-host "Microsoft VP9 Extension is already installed"
} 
else {
    xcopy $VP9SharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$VP9LocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "VP9Ext.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Web Media Extension ###############################
if ( $WebMediaCheckInstalled -match $WebMediaApp ) {
	write-host "Microsoft Web Media Extension is already installed"
} 
else {
    xcopy $WebMediaSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$WebMediaLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "WebMediaExt.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### WebP Image Extension ###############################
if ( $WebPImageCheckInstalled -match $WebPImageApp ) {
	write-host "Microsoft WebP Image Extension is already installed"
} 
else {
    xcopy $WebPImageSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$WebPImageLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "WebPImageExt.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Whiteboard ###############################
if ( $WhiteboardCheckInstalled -match $WhiteboardApp ) {
	write-host "Microsoft Whiteboard is already installed"
} 
elseif ( $Windows10OSVersion -in $WhiteboardAppOSExclusion ) {
	write-host "Microsoft Whiteboard is not compatible with this OS Version"
}
else {
    xcopy $WhiteboardSharePath $InstallerPath
    DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$WhiteboardLocalPath /SkipLicense
    New-Item -Path "C:\ProgramData\StoreApps\" -Name "Whiteboard.txt" -ItemType "file" -Value "AppX File Installation Attempted."
}

############################### Clean Up after Script Running ###############################
Remove-Item -LiteralPath "C:\ProgramData\StoreApps" -Force -Recurse
