<#
.Synopsis
   Remove the enhanced version of the Write-* cmdlets that include a prefix with the caller's name
.DESCRIPTION
   Remove all overwrites from .\Import-EnhancedWriteCommands.ps1
.EXAMPLE
   Disable-XWrite
.Link
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

        $variablesToRemove=@(
            "XWrite:Prefix:Custom"
            "XWrite:Prefix:Source"
            "XWrite:Prefix:Date"
            "XWrite:Prefix:Time"
            "XWrite:Prefix:Separator"
            "XWrite:Prefix:Format"
        )
        $variablesToRemove|ForEach-Object {
            Get-Variable -Name $_ -Scope Global -ErrorAction SilentlyContinue | Remove-Variable -Scope Global
        }
    }

    end {

    }
}