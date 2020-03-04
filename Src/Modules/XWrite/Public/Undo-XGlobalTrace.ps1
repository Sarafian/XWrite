<#
.Synopsis
   Reverts the global preference values to their original
.DESCRIPTION
   Reverts the global preference values to their original kept by Set-XGlobalTrace
.EXAMPLE
   Undo-XGlobalTrace
. Link
   Set-XGlobalTrace
#>
function Undo-XGlobalTrace 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(

    )
    begin {
        $parameterSetName=$PSCmdlet.ParameterSetName
        Microsoft.PowerShell.Utility\Write-Debug "parameterSetName=$parameterSetName"
    }

    process {
        $preferenceToUndo=@(
            "DebugPreference"
            "VerbosePreference"
            "InformationPreference"
            "WarningPreference"
        )
        $preferenceToUndo|ForEach-Object {
            $original=Get-Variable -Name "XWrite:Trace:$_" -Scope Global -ErrorAction SilentlyContinue
            if($original)
            {
                Set-Variable -Name $_ -Value $original.Value -Scope Global
                Remove-Variable -Name "XWrite:Trace:$_" -Scope Global
            }
        }

    }

    end {

    }
}