<#
.Synopsis
    Gets the source of a command name
.DESCRIPTION
    Gets the source of a command name
.EXAMPLE
   Get-XCommandSource -Command Enable-XWrite
#>
function Get-XCommandSource
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Command
    )
    begin {

    }

    process {
        if(-not $Command)
        {
            "Unknown"
        }
        elseif($Command.EndsWith(".ps1"))
        {
            "Script"
        }
        elseif($Command -eq "<scriptblock>")
        {
            "Unknown"
        }
        else
        {
            $cmdlet=Get-Command -Name $command -ErrorAction SilentlyContinue
            if($cmdlet)
            {
                $moduleName=$cmdlet|Select-Object -ExpandProperty ModuleName

                if($moduleName)
                {
                    $moduleName
                }
                else
                {
                    "Function"
                }
            }
            else
            {
                "Unknown"
            }
        }
    }

    end {

    }
}