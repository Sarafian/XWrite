<#
.Synopsis
   Sets global preference values
.DESCRIPTION
   Sets global preference values to enable global tracing
.EXAMPLE
   Set-XGlobalTrace -ForAll
.EXAMPLE
   Set-XGlobalTrace -ForDebug -ForVerbose -ForInformation -ForWarning
. Link
   Undo-XGlobalTrace
#>
function Set-XGlobalTrace 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName="All")]
        [switch]$ForAll,
        [Parameter(Mandatory=$false,ParameterSetName="Per level")]
        [switch]$ForDebug=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Per level")]
        [switch]$ForVerbose=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Per level")]
        [switch]$ForInformation=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Per level")]
        [switch]$ForWarning=$false
    )
    begin {

        $parameterSetName=$PSCmdlet.ParameterSetName
        Microsoft.PowerShell.Utility\Write-Debug "parameterSetName=$parameterSetName"

    }

    process {
        
        #region Capture current preference values

        $preferenceToBackup=@(
            "DebugPreference"
            "VerbosePreference"
            "InformationPreference"
            "WarningPreference"
        )
        $preferenceToBackup|ForEach-Object {
            $existing=Get-Variable -Name "XWrite:Trace:$_" -Scope Global -ErrorAction SilentlyContinue
            if(-not $existing)
            {
                $original=Get-Variable -Name "$_" -Scope Global -ErrorAction SilentlyContinue
                if($original)
                {
                    Set-Variable -Name "XWrite:Trace:$_" -Value $original.Value -Scope Global
                }
            }
        }

        #endregion

        #set global preference values
        $preferenceToSet=@()
        switch($PSCmdlet.ParameterSetName)
        {
            'All' {
                $preferenceToSet+="DebugPreference"
                $preferenceToSet+="VerbosePreference"
                if($PSVersionTable.PSVersion.Major -ge 5)
                {
                    $preferenceToSet+="InformationPreference"
                }
                $preferenceToSet+="WarningPreference"
            }
            'Per level' {
                if($ForDebug)
                {
                    $preferenceToSet+="DebugPreference"
                }
                if($ForVerbose)
                {
                    $preferenceToSet+="VerbosePreference"
                }
                if($ForInformation)
                {
                    if($PSVersionTable.PSVersion.Major -ge 5)
                    {
                        $preferenceToSet+="InformationPreference"
                    }
                    else
                    {
                        Microsoft.PowerShell.Utility\Write-Warning "Write-Information is not available on PowerShell version $($PSVersionTable.PSVersion)"
                    }
                }
                if($ForWarning)
                {
                    $preferenceToSet+="WarningPreference"
                }
            }
        }

        $preferenceToSet|ForEach-Object {
            Set-Variable -Name $_ -Value ([System.Management.Automation.ActionPreference]::Continue) -Scope Global
        }

        #endregion
    }

    end {

    }
}