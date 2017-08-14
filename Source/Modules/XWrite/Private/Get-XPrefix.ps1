<#
.Synopsis
    Gets the prefix
.DESCRIPTION
    Gets the prefix
.EXAMPLE
   Get-XPrefix -Command Enable-XWrite
#>
function Get-XPrefix
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
<#
        [Parameter(Mandatory=$true)]
        [string]$Command
#>
    )
    begin {

        $callerName=(Get-PSCallStack)[2].Command

    }

    process {
        if(Get-Variable -Name "XWrite:Prefix:Custom" -Scope Global -ValueOnly)
        {
            $callerSource=Get-XCommandSource -Command $callerName
            $dateStamp=Get-Date -Format "yyyyMMdd"
            $timeStamp=Get-Date -Format "hh:mm:ss.fff"
            $format=Get-Variable -Name "XWrite:Prefix:Format" -Scope Global -ValueOnly
            $prefix=$format.Replace("%source%",'$($callerSource)').Replace("%caller%",'$($callerName)').Replace("%date%",'$($dateStamp)').Replace("%time%",'$($timeStamp)')
        }
        else
        {
            $prefix=@()
            if(Get-Variable -Name "XWrite:Prefix:Source" -Scope Global -ValueOnly)
            {
                $callerSource=Get-XCommandSource -Command $callerName
                if($callerSource -ne "Unknown")
                {
                    $prefix+='$($callerSource)'
                }
            }
            $prefix+='$($callerName)'
            if(Get-Variable -Name "XWrite:Prefix:Date" -Scope Global -ValueOnly)
            {
                $dateStamp=Get-Date -Format "yyyyMMdd"
                $prefix+='$($dateStamp)'
            }
            if(Get-Variable -Name "XWrite:Prefix:Time" -Scope Global -ValueOnly)
            {
                $timeStamp=Get-Date -Format "hh:mm:ss.fff"
                $prefix+='$($timeStamp)'
            }
            $separator=Get-Variable -Name "XWrite:Prefix:Separator" -Scope Global -ValueOnly
            $prefix=$prefix -join $separator
            $prefix+=$separator
        }

        $ExecutionContext.InvokeCommand.ExpandString($prefix)
    }

    end {

    }
}