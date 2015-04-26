<#

.SYNOPSIS

Switches to the next powerplan on the list defined by powercfg.



.DESCRIPTION

Retrieves each powerplan from powercfg (also the active one) then sets
the next item on the list.

It displays the name of the newly activated powerplan in a small bubble
notification for 1 sec.

#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$INDEX_OF_GUID_CODE = 3
$INDEX_OF_SCHEME_NAME = 5

$powerCfgActiveOutput = powercfg.exe -getactivescheme
$powerCfgListOutput = powercfg.exe -list

$activeScheme = ($powerCfgActiveOutput -split ' ')[$INDEX_OF_GUID_CODE]
[System.Collections.ArrayList]$powerSchemes = $powerCfgListOutput -split '["\n\r"|"\r\n"|\n|\r]'
$powerSchemes.RemoveRange(0,3) # remove powerCfgOutput's header

[System.Collections.ArrayList]$cleanedSchemes = @()
foreach ($scheme in $powerSchemes) {
    [System.Collections.ArrayList]$splitScheme = $scheme -split ' '
    $index = $cleanedSchemes.Add($splitScheme[3])
}

$indexOfActive = $cleanedSchemes.IndexOf($activeScheme)
$indexOfNext = ($indexOfActive + 1) % $powerSchemes.Count
$nameOfNext = ($powerSchemes[$indexOfNext] -split ' ')[$INDEX_OF_SCHEME_NAME]
$nameOfNext = $nameOfNext.Substring(1, $nameOfNext.Length - 2) # remove parentheses

powercfg.exe -setactive $cleanedSchemes[$indexOfNext]

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$notification = New-Object System.Windows.Forms.NotifyIcon 
$notification.Icon = [System.Drawing.SystemIcons]::Information
$notification.BalloonTipTitle = "Power scheme switched"
$notification.BalloonTipIcon = "Info"
$notification.BalloonTipText = $nameOfNext
$notification.Visible = $True
$notification.ShowBalloonTip(1000)
Start-Sleep -Seconds 1
$notification.Visible = $false