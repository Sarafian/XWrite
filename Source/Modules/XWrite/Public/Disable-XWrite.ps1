<#
.Synopsis
   Remove the enhanced version of the Write-* cmdlets that include a prefix with the caller's name
.DESCRIPTION
   Remove all overwrites from .\Import-EnhancedWriteCommands.ps1
.EXAMPLE
   Disable-XWrite
. Link
   Enable-XWrite
#>
function Disable-XWrite
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
    )

    begin {
        $parameterSetName=$PSCmdlet.ParameterSetName
        Microsoft.PowerShell.Utility\Write-Debug "parameterSetName=$parameterSetName"
    }

    process {
        $cmdNames=@(
            "Write-Host"
            "Write-Debug"
            "Write-Verbose"
            "Write-Information"
            "Write-Warning"
        )|ForEach-Object {
            Get-ChildItem -Path "Function:\$_" -ErrorAction SilentlyContinue|Remove-Item -ErrorAction SilentlyContinue 
        }

        if(Get-Variable -Name "XWrite:Prefix" -Scope Global -ErrorAction SilentlyContinue)
        {
            Remove-Variable -Name "XWrite:Prefix" -Scope Global -ErrorAction SilentlyContinue
        }
    }

    end {

    }
}