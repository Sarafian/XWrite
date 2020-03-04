<#
.Synopsis
    Gets the message to output for the XWriteProgress
.DESCRIPTION
    Gets the message to output for the XWriteProgress
.EXAMPLE
   Get-XProgressRender -Command Enable-XWrite
#>
function Get-XProgressRender
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
        $prefix=Get-Variable -Name "XWriteProgress:Prefix" -Scope Global -ValueOnly
        $renderingSegments=@()
        if($PSBoundParameters.ContainsKey("Activity"))
        {
            $renderingSegments+="Activity=$Activity"
        }
        if($PSBoundParameters.ContainsKey("Status"))
        {
            $renderingSegments+="Status=$Status"
        }
        if($PSBoundParameters.ContainsKey("CurrentOperation"))
        {
            $renderingSegments+="CurrentOperation=$CurrentOperation"
        }
        if($PSBoundParameters.ContainsKey("PercentComplete"))
        {
            $renderingSegments+="PercentComplete=$PercentComplete"
        }
        if($PSBoundParameters.ContainsKey("SecondsRemaining"))
        {
            $renderingSegments+="SecondsRemaining=$SecondsRemaining"
        }
        if($PSBoundParameters.ContainsKey("Completed"))
        {
            $renderingSegments+="Completed"
        }

        $prefix+ ($renderingSegments -join '|')
    }

    end {

    }
}