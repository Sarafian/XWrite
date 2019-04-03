<#
.Synopsis
   Remove the enhanced version of the Write-Progress
.DESCRIPTION
   Remove the enhanced version of the Write-Progress
.EXAMPLE
   Disable-XWriteProgress
. Link
   Enable-XWriteProgress
#>
function Disable-XWriteProgress
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
            "Write-Progress"
        )|ForEach-Object {
            Get-ChildItem -Path "Function:\$_" -ErrorAction SilentlyContinue|Remove-Item -ErrorAction SilentlyContinue 
        }
<#
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
#>
    }

    end {

    }
}