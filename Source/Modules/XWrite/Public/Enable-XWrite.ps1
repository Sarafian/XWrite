<#
.Synopsis
   Short description
.DESCRIPTION
   Import and overwrite enhanced versions of 
   - Write-Host
   - Write-Debug
   - Write-Verbose
   - Write-Information
   - Write-Warning
.EXAMPLE
   Enable-XWrite -ForAll
.EXAMPLE
   Enable-XWrite -ForDebug -ForVerbose -ForInformation -ForWarning -ForHost
.EXAMPLE
   Enable-XWrite -ForAll -Caller -Date -Time
.EXAMPLE
   Enable-XWrite -ForAll -Format "%caller% %date% %time%"
. Link
   https://www.powershellgallery.com/packages/Disable-XWrite
#>
function Enable-XWrite 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Custom format")]
        [switch]$For=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Custom format")]
        [switch]$ForVerbose=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Custom format")]
        [switch]$ForInformation=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Custom format")]
        [switch]$ForWarning=$false,
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Custom format")]
        [switch]$ForHost=$false,
        [Parameter(Mandatory=$true,ParameterSetName="All level - Column format")]
        [Parameter(Mandatory=$true,ParameterSetName="All level - Custom format")]
        [switch]$ForAll,
        [Parameter(Mandatory=$false,ParameterSetName="All level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [switch]$Source=$false,
        [Parameter(Mandatory=$false,ParameterSetName="All level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [switch]$Date=$false,
        [Parameter(Mandatory=$false,ParameterSetName="All level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [switch]$Time=$false,
        [Parameter(Mandatory=$false,ParameterSetName="All level - Column format")]
        [Parameter(Mandatory=$false,ParameterSetName="Per level - Column format")]
        [String]$Separator=": ",
        [Parameter(Mandatory=$true,ParameterSetName="All level - Custom format")]
        [Parameter(Mandatory=$true,ParameterSetName="Per level - Custom format")]
        [string]$Format
    )
    begin {
        Disable-XWrite

        $parameterSetName=$PSCmdlet.ParameterSetName
        Microsoft.PowerShell.Utility\Write-Debug "parameterSetName=$parameterSetName"

        #region Set formating global variables

        switch($PSCmdlet.ParameterSetName)
        {
            {$_ -like '*Column format'} {
                Set-Variable -Name "XWrite:Prefix:Custom" -Value $false -Scope Global
                Set-Variable -Name "XWrite:Prefix:Source" -Value $Source -Scope Global
                Set-Variable -Name "XWrite:Prefix:Date" -Value $Date -Scope Global
                Set-Variable -Name "XWrite:Prefix:Time" -Value $Time -Scope Global
                Set-Variable -Name "XWrite:Prefix:Separator" -Value $Separator -Scope Global
            }
            {$_ -like '*Custom format'} {
                Set-Variable -Name "XWrite:Prefix:Custom" -Value $true -Scope Global
                Set-Variable -Name "XWrite:Prefix:Format" -Value $Format -Scope Global
            }
        }

        #endregion
        #region Injection fragments

        $injections=@{
            'Write-Host'=@{
                Begin=@'
        #region Begin step injection

        $prefix=Get-XPrefix

        $PSBoundParameters.Object=$prefix+$PSBoundParameters.Object

        #endregion
'@
            }
            'Write-Debug'=@{
                Begin=@'
        #region Begin step injection

        $prefix=Get-XPrefix

        $PSBoundParameters.Message=$prefix+$PSBoundParameters.Message

        #endregion
'@
            }
            'Write-Information'=@{
                Begin=@'
        #region Begin step injection

        $prefix=Get-XPrefix

        $PSBoundParameters.MessageData=$prefix+$PSBoundParameters.MessageData
    
        #endregion
'@
            }
        }

        $injections["Write-Verbose"]=$injections["Write-Debug"]
        $injections["Write-Warning"]=$injections["Write-Debug"]


        #endregion

        #region command names to overwrite

        switch($PSCmdlet.ParameterSetName)
        {
            {$_ -like 'All*'} {
                $ForDebug=$true
                $ForVerbose=$true
                $ForInformation=$true
                $ForWarning=$true
                $ForHost=$true
            }
        }

        $cmdNames=@(
        )

        if($ForDebug)
        {
            $cmdNames+="Write-Debug"
        }
        if($ForVerbose)
        {
            $cmdNames+="Write-Verbose"
        }
        if($ForInformation)
        {
            if($PSVersionTable.PSVersion.Major -ge 5)
            {
                $cmdNames+="Write-Information"
            }
            else
            {
                Microsoft.PowerShell.Utility\Write-Warning "Write-Information is not available on PowerShell version $($PSVersionTable.PSVersion)"
            }
        }
        if($ForWarning)
        {
            $cmdNames+="Write-Warning"
        }
        if($ForHost)
        {
            $cmdNames+="Write-Host"
        }

        #endregion
    }

    process {
        
        #region Build bodies

        foreach($name in $cmdNames)
        {
            Microsoft.PowerShell.Utility\Write-Debug "name=$name"
            $originalCommand=Get-Command -Name "Microsoft.PowerShell.Utility\$name"
            $metaData = New-Object -TypeName 'System.Management.Automation.CommandMetaData' -ArgumentList $originalCommand

            $proxyLines = [System.Management.Automation.ProxyCommand]::Create($metaData) -split [System.Environment]::NewLine
        
            $enhancedProxyLines=@()

            $stepName=""
            $insideTryBlock=$false

            foreach($proxyLine in $proxyLines)
            {
                switch ($proxyLine)
                {
                    'begin' {
                        $stepName="begin"
                    }
                    'process' {
                        $stepName="process"
                    }
                    'end' {
                        $stepName="end"
                    }
                    {$_ -like '*try* {'} {
                        $insideTryBlock=$true
                    }
                    Default {}
                }

                $enhancedProxyLines+=$proxyLine

                if($insideTryBlock)
                {
                    if($injections[$name][$stepName])
                    {
                        $enhancedProxyLines+=""
                        $enhancedProxyLines+=$injections[$name][$stepName] -split [Environment]::NewLine
                        $enhancedProxyLines+=""
                    }
                    $stepName=""
                    $insideTryBlock=$false
                }

            }
            $enhancedCmdImplementation=@"

        function global:$name {

        $($enhancedProxyLines -join [System.Environment]::NewLine)

        }

"@

            Microsoft.PowerShell.Utility\Write-Debug "Implementation for $name"
            Microsoft.PowerShell.Utility\Write-Debug $enhancedCmdImplementation

            if($PSCmdlet.ShouldProcess("Microsoft.PowerShell.Utility\$name","Overwrite with enhanced version."))
            {
                $enhancedCmdImplementation|Invoke-Expression
            }
        }

        #endregion
    }

    end {

    }
}