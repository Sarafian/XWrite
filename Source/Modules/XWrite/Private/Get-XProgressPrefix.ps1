<#
.Synopsis
    Gets the prefix for the XWriteProgress
.DESCRIPTION
    Gets the prefix for the XWriteProgress
.EXAMPLE
   Get-XProgressPrefix -Command Enable-XWrite
#>
function Get-XProgressPrefix
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        ${Activity},
    
        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Status},
    
        [Parameter(Position=2)]
        [ValidateRange(0, 2147483647)]
        [int]
        ${Id},
    
        [ValidateRange(-1, 100)]
        [int]
        ${PercentComplete},
    
        [int]
        ${SecondsRemaining},
    
        [string]
        ${CurrentOperation},
    
        [ValidateRange(-1, 2147483647)]
        [int]
        ${ParentId},
    
        [switch]
        ${Completed},
    
        [int]
        ${SourceId}
    )
    begin {

    }

    process {
        if(Get-Variable -Name "XWrite:Prefix:CustomProgress" -Scope Global -ValueOnly -ErrorAction SilentlyContinue)
        {
            $prefix=$format.Replace("%source%",'$($callerSource)').Replace("%caller%",'$($callerName)').Replace("%date%",'$($dateStamp)').Replace("%time%",'$($timeStamp)')
        }
        else
        {
            $prefix=@()
            if($PSBoundParameters.ContainsKey("Activity"))
            {
                $prefix+="Activity=$Activity"
            }
            if($PSBoundParameters.ContainsKey("Status"))
            {
                $prefix+="Status=$Status"
            }
            if($PSBoundParameters.ContainsKey("CurrentOperation"))
            {
                $prefix+="CurrentOperation=$CurrentOperation"
            }
            if($PSBoundParameters.ContainsKey("PercentComplete"))
            {
                $prefix+="PercentComplete=$PercentComplete"
            }
            if($PSBoundParameters.ContainsKey("SecondsRemaining"))
            {
                $prefix+="SecondsRemaining=$SecondsRemaining"
            }
            if($PSBoundParameters.ContainsKey("Completed"))
            {
                $prefix+="Completed"
            }

            "Write-Progress:$($prefix -join '|')"
        }

    }

    end {

    }
}