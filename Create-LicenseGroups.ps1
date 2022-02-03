cls
#region - Description
<#     
       .NOTES
       ==============================================================================
       Created on:         2022/01/31 
       Created by:         Drago Petrovic
       Organization:       MSB365.blog
       Filename:           Create-LicenseGroups.ps1
       Current version:    V0.10     
       Find us on:
             * Website:         https://www.msb365.blog
             * Technet:         https://social.technet.microsoft.com/Profile/MSB365
             * LinkedIn:        https://www.linkedin.com/in/drago-petrovic/
             * MVP Profile:     https://mvp.microsoft.com/de-de/PublicProfile/5003446
       ==============================================================================
       .DESCRIPTION
       This script can be executed without prior customisation.
       This script is used to create on-premise groups that will be synced to the Azure Active Directory.
       All variables that are required are queried by the script.
       This script creates the following elements:
            - On-premise groups for Intune administration and licence assignment
            
       
       .NOTES
       The following PowerShell modules are required:
            - MSOnline (Automatic check in the script. Module will be installed if not available)
            - ActiveDirectory (Automatic check in the script. Module will be installed if not available)
            - AzureAD (Automatic check in the script. Module will be installed if not available)
            - AzureADPreview (Automatic check in the script. Module will be installed if not available)
            - AzureADLicensing (Automatic check in the script. Module will be installed if not available)
        
        The executing account needs following permissions on-premise:
            - Create Active Directory groups
            - Create Active Directory Organizational Units
        
        The executing account needs following permissions in AzureAD:
            - Create groups
            - Assign licenses
       .EXAMPLE
       .\Create-LicenseGroups.ps1 
             
       .COPYRIGHT
       Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
       to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
       and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
       The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
       WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
       ===========================================================================
       .CHANGE LOG
             V0.10, 2022/01/31 - DrPe - Initial version
			 
--- keep it simple, but significant ---
--- by MSB365 Blog ---
#>
#endregion

#region - Info Screen
#################################################
# Show script information
Write-Host "MMMMMMMM               MMMMMMMM   SSSSSSSSSSSSSSS BBBBBBBBBBBBBBBBB   " -ForegroundColor gray -NoNewline 
Write-Host " 333333333333333           66666666   555555555555555555 " -ForegroundColor yellow
Write-Host "M:::::::M             M:::::::M SS:::::::::::::::SB::::::::::::::::B  " -ForegroundColor gray -NoNewline 
Write-Host "3:::::::::::::::33        6::::::6    5::::::::::::::::5 " -ForegroundColor yellow
Write-Host "M::::::::M           M::::::::MS:::::SSSSSS::::::SB::::::BBBBBB:::::B " -ForegroundColor gray -NoNewline 
Write-Host "3::::::33333::::::3      6::::::6     5::::::::::::::::5 " -ForegroundColor yellow
Write-Host "M:::::::::M         M:::::::::MS:::::S     SSSSSSSBB:::::B     B:::::B" -ForegroundColor gray -NoNewline 
Write-Host "3333333     3:::::3     6::::::6      5:::::555555555555 " -ForegroundColor yellow
Write-Host "M::::::::::M       M::::::::::MS:::::S              B::::B     B:::::B" -ForegroundColor gray -NoNewline 
Write-Host "            3:::::3    6::::::6       5:::::5            " -ForegroundColor yellow
Write-Host "M:::::::::::M     M:::::::::::MS:::::S              B::::B     B:::::B" -ForegroundColor gray -NoNewline 
Write-Host "            3:::::3   6::::::6        5:::::5            " -ForegroundColor yellow
Write-Host "M:::::::M::::M   M::::M:::::::M S::::SSSS           B::::BBBBBB:::::B " -ForegroundColor gray -NoNewline 
Write-Host "    33333333:::::3   6::::::6         5:::::5555555555   " -ForegroundColor yellow
Write-Host "M::::::M M::::M M::::M M::::::M  SS::::::SSSSS      B:::::::::::::BB  " -ForegroundColor gray -NoNewline 
Write-Host "    3:::::::::::3   6::::::::66666    5:::::::::::::::5  " -ForegroundColor yellow
Write-Host "M::::::M  M::::M::::M  M::::::M    SSS::::::::SS    B::::BBBBBB:::::B " -ForegroundColor gray -NoNewline 
Write-Host "    33333333:::::3 6::::::::::::::66  555555555555:::::5 " -ForegroundColor yellow
Write-Host "M::::::M   M:::::::M   M::::::M       SSSSSS::::S   B::::B     B:::::B" -ForegroundColor gray -NoNewline 
Write-Host "            3:::::36::::::66666:::::6             5:::::5" -ForegroundColor yellow
Write-Host "M::::::M    M:::::M    M::::::M            S:::::S  B::::B     B:::::B" -ForegroundColor gray -NoNewline 
Write-Host "            3:::::36:::::6     6:::::6            5:::::5" -ForegroundColor yellow
Write-Host "M::::::M     MMMMM     M::::::M            S:::::S  B::::B     B:::::B" -ForegroundColor gray -NoNewline 
Write-Host "            3:::::36:::::6     6:::::65555555     5:::::5" -ForegroundColor yellow
Write-Host "M::::::M               M::::::MSSSSSSS     S:::::SBB:::::BBBBBB::::::B" -ForegroundColor gray -NoNewline 
Write-Host "3333333     3:::::36::::::66666::::::65::::::55555::::::5" -ForegroundColor yellow
Write-Host "M::::::M               M::::::MS::::::SSSSSS:::::SB:::::::::::::::::B " -ForegroundColor gray -NoNewline 
Write-Host "3::::::33333::::::3 66:::::::::::::66  55:::::::::::::55 " -ForegroundColor yellow
Write-Host "M::::::M               M::::::MS:::::::::::::::SS B::::::::::::::::B  " -ForegroundColor gray -NoNewline 
Write-Host "3:::::::::::::::33    66:::::::::66      55:::::::::55   " -ForegroundColor yellow
Write-Host "MMMMMMMM               MMMMMMMM SSSSSSSSSSSSSSS   BBBBBBBBBBBBBBBBB   " -ForegroundColor gray -NoNewline 
Write-Host " 333333333333333        666666666          555555555     " -ForegroundColor yellow

Write-Host "                ------------------------------------------------------------------------------------------------------         " -ForegroundColor magenta
Write-Host "                        ┬┌─┌─┐┌─┐┌─┐  ┬┌┬┐  ┌─┐┬┌┬┐┌─┐┬  ┌─┐       ┌┐ ┬ ┬┌┬┐  ┌─┐┬┌─┐┌┐┌┬┌─┐┬┌─┐┌─┐┌┐┌┌┬┐" -ForegroundColor cyan
Write-Host "                        ├┴┐├┤ ├┤ ├─┘  │ │   └─┐││││├─┘│  ├┤   ───  ├┴┐│ │ │   └─┐││ ┬││││├┤ ││  ├─┤│││ │ " -ForegroundColor cyan
Write-Host "                        ┴ ┴└─┘└─┘┴    ┴ ┴   └─┘┴┴ ┴┴  ┴─┘└─┘       └─┘└─┘ ┴   └─┘┴└─┘┘└┘┴└  ┴└─┘┴ ┴┘└┘ ┴ " -ForegroundColor cyan 
Start-Sleep -s 4
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host "Script version V0.10 by Drago Petrovic" -ForegroundColor White -BackgroundColor Magenta
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
Start-Sleep -s 3
#endregion

#region - Function
#################################################
# Function
#check for module function
#check for module function
Function CheckModule($modulename){
    #Check if module is already imported
    $LoadedModule = Get-Module -Name $modulename
    if ($LoadedModule -ne $null) {
        Write-Host "$modulename Module is installed and loaded" -ForegroundColor Green
        Write-Log -type SUCCESS -Message "$modulename Module is installed and loaded"
        Return 0
    }Elseif (
        #Check if module is available for import
        Get-Module -ListAvailable -Name $modulename
        ) {
        Write-Log -type SUCCESS -Message "$modulename Module is installed"
    } 
    else {
        #if module is not installed, install it for the current user
        Write-Log -type WARNING -Message "$modulename Module not Installed. Installing module in user scope now........."
            try {
                Install-Module -Name $modulename -Scope CurrentUser -AllowClobber -Force -ErrorAction Stop
                Write-Log -type SUCCESS -Message "$modulename Module was successfully installed"
            }
            catch{
                Write-Log -Type ERROR -Message "Module $modulename could not be installed. $_"
                throw $_
                Return 1
            }
    }
    #import the module
    if ($LoadedModule -eq $null) {
        Try {
            Import-Module $modulename -ErrorAction stop
            Write-Log -type SUCCESS -Message "$modulename Module imported"
            Return 0
        }catch{
            Write-Log -Type ERROR -Message "Module $modulename could not be imported. $_"
            throw $_
            Return 2
        }
        
    }

}

#Write Log function
function Write-Log
{
    Param(
        [ValidateSet("INFO",“SUCCESS”,”WARNING”,”ERROR”)]
        [String]
        $type
    ,
        [STRING]
        $Message
    ,
        [SWITCH]
        $logOnly
    )
    Process
    {
        if (!(Test-path $log)){
            "Date       " + "Time     " + "Status  " + "Message" | Out-File $Log -Append
        }
        switch ($type){
            INFO {$spacer = "    "}
            ERROR {$spacer = "   "}
            Default {$spacer = " "}
        }
        (Get-Date -Format G) + " " + $type + $spacer + $Message | Out-File $Log -Append

        if (!$logonly.IsPresent)
        {
            Switch ($type){
                INFO {Write-host (Get-Date -Format G) $type $Message -ForegroundColor Magenta }
                SUCCESS {Write-host (Get-Date -Format G) $type $Message -ForegroundColor Green }
                WARNING {Write-host (Get-Date -Format G) $type $Message -ForegroundColor Yellow }
                ERROR {Write-host (Get-Date -Format G) $type $Message -ForegroundColor Red }
            }
            
        }
    }
	
}

#region create Log file for logging
$mdmdirectory = "C:\MDM\"
If ((Test-Path -Path $mdmdirectory) -eq $false)
{
    try{
        New-Item -Path $mdmdirectory -ItemType directory -ErrorAction Stop
    }catch{
        throw "Could not create folder ""$mdmdirectory"" for logs. " + $_
        Return
    }
        
}
$timestamp = get-date -Format yyyy-MM-dd_HHmmss
$Log = “C:\MDM\CreateGlobalSecurityGroups_” + $timestamp + “.log”
$ErrorActionPreference=”SilentlyContinue”

Start-Sleep -s 1
#endregion

#region Create on-prem account and groups

#Check if module ActiveDirectory is installed
$admodule = CheckModule ActiveDirectory
if ($admodule -ne 0){
    Write-Log -type ERROR -Message "Script execution aborted"
    return
}
#endregion

#region - Variables
#################################################
# Set variables
$GroupOUpath1 = $(Write-Host "Enter the OU Path where the Licensing Groups should be created. Example: " -NoNewLine) + $(Write-Host """" -NoNewline)  + $(Write-Host "OU=Licenses,OU=Groups,OU=MSB01,DC=contoso,DC=local" -ForegroundColor Yellow -NoNewline; Read-Host """")
#$GroupOUpath1 = "OU=ITP_Test,OU=MDM,DC=msb365,DC=online"
Start-Sleep -s 3
write-host "Variable set!" -ForegroundColor Green
Start-Sleep -s 3
#endregion

#region - Create Group
#################################################
# Create on-premise Groups in the definated OU structure
write-host "Creating on-premis Active Directory Groups for licensing..." -ForegroundColor Cyan
Start-Sleep -s 3
$grouptableIntuneL = @{
"_Licensing_AzAD_P1" = "Assigns the Azure Active Directory Premium P1 License"
"_Licensing_AzAD_P2" = "Assigns the Azure Active Directory Premium P2 License"
"_Licensing_AzInfoProtect_P1" = "Assigns the Azure Information Protection Premium P1 License"
"_Licensing_AzInfoProtect _P2" = "Assigns the Azure Information Protection Premium P2 License"
"_Licensing_EXO_P1" = "Assigns the Exchange Online (Plan 1) License"
"_Licensing_EXO_Kiosk" = "Assigns the Exchange Online Kiosk License"
"_Licensing_M365_AppsForBusiness" = "Assigns Microsoft 365 Apps for Business License"
"_Licensing_M365_AppsForEnterprise" = "Assigns Microsoft 365 Apps for Enterprise License"
"_Licensing_M365_AudioConf" = "Assigns Microsoft 365 Audio Conferencing License"
"_Licensing_BusinessVoice_exclCP" = "Assigns the Microsoft 365 Business Voice (without calling plan) License"
"_Licensing_TeamsRoomStd" = "Assigns the Microsoft 365 Microsoft Teams Rooms Standard License"
"_Licensing_M365_PhoneSys" = "Assigns the Microsoft 365 Phone System License"
"_Licensing_M365_PhoneSys_VirtUser" = "Assigns the Microsoft 365 Phone System – Virtual User License"
"_Licensing_M365_E3_Base" = "Assigns Microsoft 365 E3 License with the default apps"
"_Licensing_O365_E3_Base" = "Assigns Office 365 E3 License with the default apps"
"_Licensing_O365_F3_Base" = "Assigns Office 365 F3 License with the default apps"
"_Licensing_O365_E1_Base" = "Assigns Office 365 E1 License with the default apps"
"_Licensing_O365_ExtraFileStorage" = "Assigns Office 365 Extra File Storage License"
"_Licensing_EMS_E3_Base" = "Assigns the ENTERPRISE MOBILITY + SECURITY E3 License"
"_Licensing_EMS_E5_Base" = "Assigns the ENTERPRISE MOBILITY + SECURITY E5 License"
"_Licensing_O365_E5_Base" = "Assigns Office 365 E5 License with the default apps"
"_Licensing_M365_BusinessPremium_Base" = "Assigns Microsoft 365 Business Premium License with the default apps"
"_Licensing_M365_BusinessBasic_Base" = "Assigns Microsoft 365 Business Basic License with the default apps"
"_Licensing_M365_BusinessStd_Base" = "Assigns Microsoft 365 Business Standard License with the default apps"
"_Licensing_MSDefOffice_P1" = "Assigns Microsoft Defender for Office 365 (Plan 1) License"
"_Licensing_MSDefOffice_P2" = "Assigns Microsoft Defender for Office 365 (Plan 2) License"
"_Licensing_MSDefEndpoint_P1" = "Assigns Microsoft Defender for Endpoint (Plan 1) License"
"_Licensing_MSDefEndpoint_P2" = "Assigns Microsoft Defender for Endpoint (Plan 2) License"
"_Licensing_M365_E5_Base" = "Assigns Microsoft 365 E5 License with the default apps"
"_Licensing_PowerBI_Pro" = "Assigns the Power BI Pro License"
"_Licensing_Project_P1" = "Assigns the Project P1 License"
"_Licensing_Project_P3" = "Assigns the Project P3 License"
"_Licensing_Visio_P1" = "Assigns the Visio P1 License"
"_Licensing_Visio_P2" = "Assigns the Visio P2 License"
"_Licensing_Win10Enterp_E3" = "Assigns the Windows 10 Enterprise E3 License"
}


$grpsnotcreatedInt = @()
$grouptableIntuneL.GetEnumerator().ForEach({
    try {
        $grpname = $_.key
        New-ADGroup -Name $_.key –groupscope Global -Path $GroupOUpath1 -Description $_.Value -ErrorAction Stop
        Write-Host "Created AD group $grpname"
    }catch{
        Write-Log -Type ERROR -Message "AD group $grpname could not be created. $_" -logOnly
        Write-Warning "Could not create AD group $grpname"
        $grpsnotcreatedInt += $grpname
    }
})


Start-Sleep -s 3
write-host "Done!" -ForegroundColor Green
Start-Sleep -s 1
Write-Host "Following groups were created:" -ForegroundColor Green
$grouptableIntuneL.GetEnumerator().where({ !$grpsnotcreatedInt.Contains($_.Key)}) | ft -HideTableHeaders
Start-Sleep -s 3
#endregion

#region - Sync
#################################################
# Start Azure AD sync
write-host "Preparing ADSync tasks..." -BackgroundColor Magenta
#check if AAD Sync is installed
Start-Sleep -s 3
$Folder = "AD sync agent"
write-host "Checking if $Folder exists..." -ForegroundColor White -BackgroundColor Magenta
sleep -Seconds 2 
$FolderExIsts = Test-Path 'C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync'

#If AADSync is not installed, offer the option to start the AADSync cycle on a remote machine
if ($FolderExIsts -eq $false)
{
	Write-Host "ADSync is not installed on this machine" -ForegroundColor Yellow
	$remoteAADSync = "Do you want to connect to a remote machine to start the AAD sync? [y/n] (default is no)"
	Switch ($remoteAADSync)
	{
		y { $AADSyncServer = Read-Host "Enter name of AADC server" }
		n { Write-Host "AAD Sync will not be started manually. You have to wait for the next sync cycle" -ForegroundColor Yellow }
		default{ Write-Host "AAD Sync will not be started manually. You have to wait for the next sync cycle" -ForegroundColor Yellow}
	}#if a server name was specified, try to start the sync on that machine
	if ($AADSyncServer -ne $null)
	{
		try
		{
			#establish remote session 
			$session = New-PSSession -ComputerName $AADSyncServer -ErrorAction Stop
			Write-Log -type INFO -Message "Syncing on-premise objects to Azure Active Directory..."
			#invoke commands to start the sync in remote session
			Invoke-Command -Session $session { Import-Module ADSync; Start-ADSyncSyncCycle -PolicyType Delta } -ErrorAction Stop
			Write-Log -type SUCCESS -Message "Sync started"
			sleep -s 30
			#wait till sync is completed
			Do
			{
				$aadsyncstatus = Invoke-Command -Session $session { Get-ADSyncConnectorRunStatus }
				sleep -s 6
			}
			until ($aadsyncstatus -eq $null)
			Write-Log -type SUCCESS -Message "Sync is completed."
			
			Remove-PSSession $session
		}
		catch
		{
			Write-Log -type WARNING -Message "Could not start AADSync. Objects may not be synced to AAD yet. $_"
		}
	}
}
Else
{
	#Start local AADSync
	write-host "Syncing on-premise objects to Azure Active Directory..." -ForegroundColor cyan #
    Start-Sleep -s 3
    write-host "please wait..." -ForegroundColor cyan
	Try
	{
		Import-Module -Name "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync" -ErrorAction Stop
		$aadsyncstatusinit = Get-ADSyncConnectorRunStatus
		if ($aadsyncstatusinit -ne $null)
		{
			Write-Log -type INFO -Message "AADSync currently already running. Waiting until it is finished."
			#wait till sync is completed
			Do
			{
				$aadsyncstatusinit = Get-ADSyncConnectorRunStatus
				sleep -s 15
			}
			until ($aadsyncstatusinit -eq $null)
		}
		Start-ADSyncSyncCycle -PolicyType Delta -ErrorAction Stop
		Write-Log -type SUCCESS -Message "Sync started, please wait"
		sleep -s 30
		#wait till sync is completed
		Do
		{
			$aadsyncstatus = Get-ADSyncConnectorRunStatus
			sleep -s 6
		}
		until ($aadsyncstatus -eq $null)
		Write-Log -type SUCCESS -Message "Sync is completed."
	}
	Catch
	{
		Write-Log -type WARNING -Message "Could not start AADSync. Objects may not be synced to AAD yet. $_"
	}
}


#endregion

#region - Connect Azure AD
#################################################
# Connect to Azure Active directory module

#Load Azure Active Directory PowerShell Module
write-host "Connectig Azure Active Directory" -ForegroundColor Magenta -NoNewline
write-host " - Please enter the credentials..." -ForegroundColor Yellow 
Start-Sleep -s 5
if (Get-Module -ListAvailable -Name AzureADPreview) {
    Write-Host "AzureADPreview Module Already Installed" -ForegroundColor Green
} 
else {
    Write-Host "AzureADPreview Module Not Installed. Installing........." -ForegroundColor Red
        Install-Module -Name AzureADPreview -AllowClobber -Force
    Write-Host "AzureADPreview Module Installed" -ForegroundColor Green
}
Import-Module AzureADPreview
Connect-AzureAD
Start-Sleep -s 2

write-host "Connectig to the Microsoft 365 License Service Module" -ForegroundColor Magenta -NoNewline

#endregion

#region - Connect Azure Licensing
#################################################
# Connect to Azure Active licensing module
#check if licensing module is installed
write-host "Connectig to the Microsoft 365 License Service Module" -ForegroundColor Magenta -NoNewline
Start-Sleep -s 3
$aadlicmodule = CheckModule AzureADLicensing
if ($aadlicmodule -ne 0){
    Write-Host "AzureADLicensing Module Not Installed. Installing........." -ForegroundColor Red
        Install-Module -Name AzureADLicensing -AllowClobber -Force
    Write-Host "AzureADLicensing Module Installed" -ForegroundColor Green
}


#connect to Azure
try{
    Connect-AzAccount
    Write-Log -type SUCCESS -Message "Connected to Azure AD through ""Connect-AzACcount""" -logOnly
}catch{
	Write-Log -type ERROR -Message "Could not connect to AzureAD through ""Connect AzACcount""" + $_
	Write-Log -type ERROR -Message "Script execution aborted"
	return
}
Start-Sleep -s 3
#endregion

#region - Assign licenses
#################################################
# Assign licenses to licensing Groups
write-host "Assigning Licenses to synced Azure Groups..." -ForegroundColor Magenta
Start-Sleep -s 3
#Getting created License Groups
$licgrpscreated = $grouptableIntuneL.GetEnumerator().where({ !$grpsnotcreatedInt.Contains($_.Key) }) | ft -HideTableHeaders

#getting available licenses
Write-Log -type INFO -Message 'Getting available licenses'
$SKUs = Get-AADLicenseSku

#create mapping table for licenses and groups
$groupsAndLicenses = @{
"_Licensing_AzAD_P1" = ($SKUs | where { $_.AccountSKuID -like "*:AAD_PREMIUM" }).AccountSkuID 
"_Licensing_AzAD_P2" = ($SKUs | where { $_.AccountSKuID -like "*:AAD_PREMIUM_P2" }).AccountSkuID 
"_Licensing_EXO_P1" = ($SKUs | where { $_.AccountSKuID -like "*:EXCHANGESTANDARD" }).AccountSkuID 
"_Licensing_EXO_Kiosk" = ($SKUs | where { $_.AccountSKuID -like "*:EXCHANGEDESKLESS" }).AccountSkuID 
"_Licensing_M365_AppsForBusiness" = ($SKUs | where { $_.AccountSKuID -like "*:O365_BUSINESS" }).AccountSkuID 
"_Licensing_M365_AppsForEnterprise" = ($SKUs | where { $_.AccountSKuID -like "*:OFFICESUBSCRIPTION" }).AccountSkuID 
"_Licensing_M365_AudioConf" = ($SKUs | where { $_.AccountSKuID -like "*:MCOMEETADV" }).AccountSkuID 
"_Licensing_M365_BusinessVoice_exclCP" = ($SKUs | where { $_.AccountSKuID -like "*:BUSINESS_VOICE_DIRECTROUTING" }).AccountSkuID 
"_Licensing_M365_TeamsRoomStd" = ($SKUs | where { $_.AccountSKuID -like "*:MEETING_ROOM" }).AccountSkuID 
"_Licensing_M365_PhoneSys" = ($SKUs | where { $_.AccountSKuID -like "*:MCOEV" }).AccountSkuID 
"_Licensing_M365_PhoneSys_VirtUser" = ($SKUs | where { $_.AccountSKuID -like "*:PHONESYSTEM_VIRTUALUSER" }).AccountSkuID 
"_Licensing_M365_E3_Base" = ($SKUs | where { $_.AccountSKuID -like "*:SPE_E3" }).AccountSkuID 
"_Licensing_O365_E3_Base" = ($SKUs | where { $_.AccountSKuID -like "*:ENTERPRISEPACK" }).AccountSkuID 
"_Licensing_O365_F3_Base" = ($SKUs | where { $_.AccountSKuID -like "*:DESKLESSPACK" }).AccountSkuID 
"_Licensing_O365_E1_Base" = ($SKUs | where { $_.AccountSKuID -like "*:STANDARDPACK" }).AccountSkuID 
"_Licensing_O365_ExtraFileStorage" = ($SKUs | where { $_.AccountSKuID -like "*:SHAREPOINTSTORAGE" }).AccountSkuID 
"_Licensing_EMS_E3_Base" = ($SKUs | where { $_.AccountSKuID -like "*:EMS" }).AccountSkuID 
"_Licensing_EMS_E5_Base" = ($SKUs | where { $_.AccountSKuID -like "*:EMSPREMIUM" }).AccountSkuID 
"_Licensing_O365_E5_Base" = ($SKUs | where { $_.AccountSKuID -like "*:ENTERPRISEPREMIUM" }).AccountSkuID 
"_Licensing_M365_BusinessPremium_Base" = ($SKUs | where { $_.AccountSKuID -like "*:SPB" }).AccountSkuID 
"_Licensing_M365_BusinessBasic_Base" = ($SKUs | where { $_.AccountSKuID -like "*:O365_BUSINESS_ESSENTIALS" }).AccountSkuID 
"_Licensing_M365_BusinessStd_Base" = ($SKUs | where { $_.AccountSKuID -like "*:O365_BUSINESS_PREMIUM" }).AccountSkuID 
"_Licensing_MSDefOffice_P2" = = ($SKUs | where { $_.AccountSKuID -like "*:THREAT_INTELLIGENCE" }).AccountSkuID 
"_Licensing_MSDefEndpoint_P2" = ($SKUs | where { $_.AccountSKuID -like "*:" }).AccountSkuID
"_Licensing_M365_E5_Base"  = ($SKUs | where { $_.AccountSKuID -like "*:SPE_E5" }).AccountSkuID 
"_Licensing_PowerBI_Pro" = ($SKUs | where { $_.AccountSKuID -like "*:POWER_BI_PRO" }).AccountSkuID 
"_Licensing_Project_P1" = ($SKUs | where { $_.AccountSKuID -like "*:PROJECT_P1" }).AccountSkuID 
"_Licensing_Project_P3" = ($SKUs | where { $_.AccountSKuID -like "*:PROJECTPROFESSIONAL" }).AccountSkuID 
"_Licensing_Visio_P1" = ($SKUs | where { $_.AccountSKuID -like "*:VISIO_PLAN1_DEPT" }).AccountSkuID 
"_Licensing_Visio_P2" = ($SKUs | where { $_.AccountSKuID -like "*:VISIO_PLAN2_DEPT" }).AccountSkuID 
"_Licensing_Win10Enterp_E3" = ($SKUs | where { $_.AccountSKuID -like "*:WIN10_PRO_ENT_SUB" }).AccountSkuID 
"_Licensing_AzInfoProtect_P1" = ($SKUs | where { $_.AccountSKuID -like "*:RIGHTSMANAGEMENT" }).AccountSkuID 
"_Licensing_Project_P5" = ($SKUs | where { $_.AccountSKuID -like "*:PROJECTPREMIUM_GOV" }).AccountSkuID 
"_Licensing_MSDefOffice_P1" = = ($SKUs | where { $_.AccountSKuID -like "*:ATP_ENTERPRISE" }).AccountSkuID
}

Write-Log -type INFO -Message 'Done getting licenses'

$licsnotFound = ($groupsAndLicenses.GetEnumerator().Where({ $_.Value -eq $null })).name
if ($licsnotFound.Count > 0)
{
	Write-Log -type WARNING -Message 'licenses for the following groups were not found: ' + $licsnotFound -join ', '
}
$groupsAndIds = @{}

#create mapping table for groups and IDs
foreach ($item in $grouptableIntuneL.getEnumerator()){
    $ID = (Get-MsolGroup | where-object { $_.DisplayName -eq $item.Key}).ObjectID
    $groupsAndIds.add($item.Key,$ID)
}

#Assign licenses to groups
Write-Log -type INFO -Message "Assigning available licenses to groups..."
foreach ($i in $groupsAndIds.GetEnumerator()){
    #get license to assign from the mapping table $groupsAndLicenses
	$lic = $groupsAndLicenses.$($i.key)
	if ($lic -ne $null)
	{
		try
		{
			if ($i.key.EndsWith("exclEXO"))
			{
				#Assignment with Exchange Online Plan exclusion
				Add-AADGroupLicenseAssignment -groupId $i.value -accountSkuId $lic -disabledServicePlans @("EXCHANGE_S_ENTERPRISE") -ErrorAction Stop
				Write-Log -type SUCCESS -Message "Assigned license $lic to group $($i.key) without Exchange Online Plan"
			}
			Else
			{
				#license assignment
				Add-AADGroupLicenseAssignment -groupId $i.value -accountSkuId $lic -ErrorAction Stop
				Write-Log -type SUCCESS -Message "Assigned license $lic to group $($i.key)"
			}
		}
		catch
		{
			Write-Log -type ERROR -Message "Could not assign license $lic to group $($i.key). $_"
		}
	}
}

Write-Log -type SUCCESS -Message "License assignment done!"
write-host "Assignments done" -ForegroundColor Green
Start-Sleep -s 3
#endregion

#region - Closing message
#################################################
Write-Host "NOTE:" -ForegroundColor black -BackgroundColor Yellow
Start-Sleep -s 2
Write-Host "Only the Groups that have active licenses got assigned." -ForegroundColor Yellow
Start-Sleep -s 2
Write-Host "For licenses that got bought later, the assignment has to be done manually." -ForegroundColor Yellow
Start-Sleep -s 2
Write-Host "You can find more information here:" -ForegroundColor Yellow
Start-Sleep -s 2
Write-Host "https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-group-advanced" -ForegroundColor Yellow -BackgroundColor black
write-host ""
write-host ""
$TNlink = Read-Host -Prompt "Would you like to open the Technet Link in your Browser? [y] | [n]"
if ($TNlink -eq 'y') {
    Start-Process https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-group-advanced
} else {
    "continuing script..."
}
write-host ""
write-host ""
write-host ""
write-host ""
Start-Sleep -s 3
Write-Host "All configurations are set! - PowerShell can be closed!" -BackgroundColor Green -ForegroundColor Black
#################################################
#endregion

#region License codes overview
#################################################
# License codes overview
#####################################################################################################################################
<# LICENSE CODE OVERVIEW                                                                                                            #
MICROSOFT 365 BUSINESS PREMIUM                 SPB                                                                                  #
MICROSOFT 365 E3                               SPE_E3                                                                               #
MICROSOFT 365 E5                               SPE_E5                                                                               #
Microsoft Defender for Office 365 (Plan 1)     ATP_ENTERPRISE                                                                       #
Office 365 E3                                  ENTERPRISEPACK                                                                       #
Office 365 E5                                  ENTERPRISEPREMIUM                                                                    #
ENTERPRISE MOBILITY + SECURITY E3              EMS                                                                                  #
ENTERPRISE MOBILITY + SECURITY E5              EMSPREMIUM                                                                           #
MICROSOFT 365 PHONE SYSTEM                     MCOEV                                                                                #
                                                                                                                                    #
-----                                                                                                                               #
More information: https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference         #
-----                                                                                                                               #
                                                                                                                                    #
Customer:                                                                                                                           #
_Licensing_Teams_PhoneSystems                  reseller-account:MCOEV                                                               #
_Licensing_M365_E3_Base                        reseller-account:SPE_E3                                                              #
_Licensing_O365_E3_Base                        reseller-account:ENTERPRISEPACK                                                      #
_Licensing_M365_E3_exclEXO                                                                                                          #
_Licensing_O365_E3_exclEXO                                                                                                          #
_Licensing_EMS_E3_Base                         reseller-account:EMS                                                                 #
_Licensing_EMS_E5_Base                         reseller-account:EMSPREMIUM                                                          #
_Licensing_O365_E5_Base                        reseller-account:ENTERPRISEPREMIUM                                                   #
_Licensing_M365_BP_Base                        reseller-account:SPB                                                                 #
_Licensing_ATP_P1_Base                         reseller-account:ATP_ENTERPRISE                                                      #
_Licensing_M365_E5_Base                        reseller-account:SPE_E5                                                              #
#>                                                                                                                                  #
#####################################################################################################################################
#endregion
