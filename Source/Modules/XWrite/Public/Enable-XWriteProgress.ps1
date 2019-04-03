function Enable-XWriteProgress
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory = $true, ParameterSetName = "Debug")]
#        [Parameter(Mandatory = $true, ParameterSetName = "Debug - Custom format")]
        [switch]$UseDebug = $false,
        [Parameter(Mandatory = $true, ParameterSetName = "Verbose")]
#        [Parameter(Mandatory = $true, ParameterSetName = "Verbose - Custom format")]
        [switch]$UseVerbose = $false,
        [Parameter(Mandatory = $true, ParameterSetName = "Information")]
#        [Parameter(Mandatory = $true, ParameterSetName = "Information - Custom format")]
        [switch]$UseInformation = $false,
        [Parameter(Mandatory = $true, ParameterSetName = "Host")]
#        [Parameter(Mandatory = $true, ParameterSetName = "Host - Custom format")]
        [switch]$UseHost = $false,
        [Parameter(Mandatory = $false, ParameterSetName = "Host")]
#        [Parameter(Mandatory = $false, ParameterSetName = "Host - Custom format")]
        [ConsoleColor]$ForegroundColor,
        [Parameter(Mandatory = $false, ParameterSetName = "Host")]
#        [Parameter(Mandatory = $false, ParameterSetName = "Host - Custom format")]
        [ConsoleColor]$BackgroundColor
<#
        [Parameter(Mandatory=$true,ParameterSetName="All level - Custom format")]
        [Parameter(Mandatory=$true,ParameterSetName="Per level - Custom format")]
        [string]$Format
#>        
    )
    begin
    {

        $parameterSetName = $PSCmdlet.ParameterSetName
        Write-Debug "parameterSetName=$parameterSetName"

        #region Injection fragments
        switch ($PSCmdlet.ParameterSetName)
        {
            {$_ -like 'Host*'}
            {
                $extraPSBoundParametersLines = @(
                    '       $extraPSBoundParameters.Object=$extraRendering'
                )
                if ($PSBoundParameters.ContainsKey("ForegroundColor"))
                {
                    $extraPSBoundParametersLines += '       $extraPSBoundParameters.ForegroundColor="' + $ForegroundColor+'"'
                }
                if ($PSBoundParameters.ContainsKey("BackgroundColor"))
                {
                    $extraPSBoundParametersLines += '       $extraPSBoundParameters.BackgroundColor="' + $BackgroundColor+'"'
                }
            }
            {$_ -like 'Debug*'}
            {
                $extraPSBoundParametersLines = @(
                    '       $extraPSBoundParameters.Message=$extraRendering'
                )
            }
            {$_ -like 'Verbose*'}
            {
                $extraPSBoundParametersLines = @(
                    '       $extraPSBoundParameters.Message=$extraRendering'
                )
            }
            {$_ -like 'Information*'}
            {
                $extraPSBoundParametersLines = @(
                    '       $extraPSBoundParameters.MessageData=$extraRendering'
                )
            }
        }

        $injections = @{
            Begin   = @'

        $extraRendering=Get-XProgressPrefix @PSBoundParameters

        #region Parameters for extra cmdlet

        $extraPSBoundParameters=@{}+$PSBoundParameters
        $null=$extraPSBoundParameters.Remove("Activity")
        $null=$extraPSBoundParameters.Remove("Status")
        $null=$extraPSBoundParameters.Remove("Id")
        $null=$extraPSBoundParameters.Remove("PercentComplete")
        $null=$extraPSBoundParameters.Remove("SecondsRemaining")
        $null=$extraPSBoundParameters.Remove("CurrentOperation")
        $null=$extraPSBoundParameters.Remove("ParentId")
        $null=$extraPSBoundParameters.Remove("Completed")
        $null=$extraPSBoundParameters.Remove("SourceId")

$extraPSBoundParametersRendering

        #endregion
'@
        }
        $injections.Begin=$injections.Begin.Replace('$extraPSBoundParametersRendering',$extraPSBoundParametersLines -join [System.Environment]::NewLine)
    }

    process
    {
        
        $name = "Write-Progress"
        Microsoft.PowerShell.Utility\Write-Debug "name=$name"
        $originalCommand = Get-Command -Name "Microsoft.PowerShell.Utility\$name"
        $metaData = New-Object -TypeName 'System.Management.Automation.CommandMetaData' -ArgumentList $originalCommand

        $proxyLines = [System.Management.Automation.ProxyCommand]::Create($metaData) -split [System.Environment]::NewLine
        
        $enhancedProxyLines = @()

        $stepName = ""
        $insideTryBlock = $false

        foreach ($proxyLine in $proxyLines)
        {
            switch ($proxyLine)
            {
                'begin'
                {
                    $stepName = "begin"
                }
                'process'
                {
                    $stepName = "process"
                }
                'end'
                {
                    $stepName = "end"
                }
                { $_ -like '*try* {' }
                {
                    $insideTryBlock = $true
                }
                Default { }
            }

            $enhancedProxyLines += $proxyLine
            if ($proxyLine -match ' *\$wrappedCmd *= *.+')
            {
                switch ($PSCmdlet.ParameterSetName)
                {
                    {$_ -like 'Host*'} {
                        $enhancedProxyLines += $proxyLine.Replace($name, "Write-Host").Replace('$wrappedCmd','$wrappedExtraCmd')
                    }
                    {$_ -like 'Debug*'} {
                        $enhancedProxyLines += $proxyLine.Replace($name, "Write-Debug").Replace('$wrappedCmd','$wrappedExtraCmd')
                    }
                    {$_ -like 'Verbose*'} {
                        $enhancedProxyLines += $proxyLine.Replace($name, "Write-Verbose").Replace('$wrappedCmd','$wrappedExtraCmd')
                    }
                    {$_ -like 'Information*'} {
                        $enhancedProxyLines += $proxyLine.Replace($name, "Write-Information").Replace('$wrappedCmd','$wrappedExtraCmd')
                    }
                }
            }
            elseif ($proxyLine -match ' *\$scriptCmd *= *.+')
            {
                $enhancedProxyLines += $proxyLine.Replace("PSBoundParameters", "extraPSBoundParameters").Replace('$scriptCmd','$scriptExtraCmd').Replace('$wrappedCmd','$wrappedExtraCmd')
            }
            elseif ($proxyLine -match ' *\$steppablePipeline *= *.+')
            {
                $enhancedProxyLines += $proxyLine.Replace('$scriptCmd','$scriptExtraCmd').Replace('$steppablePipeline','$steppableExtraPipeline')
            }
            elseif ($proxyLine -match ' *\$steppablePipeline\.Begin')
            {
                $enhancedProxyLines += $proxyLine.Replace('$steppablePipeline','$steppableExtraPipeline')
            }
            elseif ($proxyLine -match ' *\$steppablePipeline\.Process')
            {
                $enhancedProxyLines += $proxyLine.Replace('$steppablePipeline','$steppableExtraPipeline')
            }
            elseif ($proxyLine -match ' *\$steppablePipeline\.End')
            {
                $enhancedProxyLines += $proxyLine.Replace('$steppablePipeline','$steppableExtraPipeline')
            }
            else
            {
            }

            if ($insideTryBlock)
            {
                if ($injections[$stepName])
                {
                    $enhancedProxyLines += ""
                    $enhancedProxyLines += $injections[$stepName] -split [Environment]::NewLine
                    $enhancedProxyLines += ""
                }
                $stepName = ""
                $insideTryBlock = $false
            }

        }
        $enhancedCmdImplementation = @"

        function global:$name {

        $($enhancedProxyLines -join [System.Environment]::NewLine)

        }

"@

        Microsoft.PowerShell.Utility\Write-Debug "Implementation for $name"
        Microsoft.PowerShell.Utility\Write-Debug $enhancedCmdImplementation
        if ($PSCmdlet.ShouldProcess("Microsoft.PowerShell.Utility\$name", "Overwrite with enhanced version."))
        {
            $enhancedCmdImplementation | Invoke-Expression
        }
    }

    end
    {

    }
}