<#
.Synopsis
   Remove the enhanced inline output of the Write-Progress
.DESCRIPTION
   Remove the enhanced inline output of the Write-Progress
.EXAMPLE
   Disable-XWriteProgress
.Link
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
        $variablesToRemove=@(
            "XWriteProgress:Prefix"
        )
        $variablesToRemove|ForEach-Object {
            Get-Variable -Name $_ -Scope Global -ErrorAction SilentlyContinue | Remove-Variable -Scope Global
        }
    }

    end {

    }
}