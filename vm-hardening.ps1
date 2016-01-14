﻿## Preparation
# Load SnapIn
if (!(get-pssnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
    add-pssnapin VMware.VimAutomation.Core
}
# Inputs
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$yourvCenter = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your vCenter FQDN or IP", "vCenter", "$env:computername") 

# Connect to vCenter
Connect-VIServer $yourvCenter

# Create Options
$ExtraOptions = @{
    "isolation.tools.diskShrink.disable"="true";
    "isolation.tools.diskWiper.disable"="true";
    "isolation.tools.copy.disable"="true";
    "isolation.tools.paste.disable"="true";
    "isolation.tools.dnd.disable"="true";
    "isolation.tools.setGUIOptions.enable"="false"; 
    "log.keepOld"="10";
    "log.rotateSize"="100000"
    "RemoteDisplay.maxConnections"="2";
    "RemoteDisplay.vnc.enabled"="false";  

}

$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

Foreach ($Option in $ExtraOptions.GetEnumerator()) {
    $OptionValue = New-Object VMware.Vim.optionvalue
    $OptionValue.Key = $Option.Key
    $OptionValue.Value = $Option.Value
    $vmConfigSpec.extraconfig += $OptionValue
}

## Apply

ForEach ($vm in (get-folder -Name "TEST" | Get-VM )){
    $vmv = Get-VM $vm | Get-View
    $state = $vmv.Summary.Runtime.PowerState
     ($vmv).ReconfigVM_Task($vmConfigSpec)
        if ($state -eq "poweredOn") {
            $vmv.MigrateVM_Task($null, $_.Runtime.Host, 'highPriority', $null)
            }
    }