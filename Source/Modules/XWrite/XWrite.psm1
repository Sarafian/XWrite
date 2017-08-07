<#PSScriptInfo

.DESCRIPTION PowerShell module for XWrite

.VERSION 1.0

#>

#requires -Version 4.0

$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude @("*.Tests.ps1"))
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude @("*.Tests.ps1"))

Foreach($import in @($public + $private))
{
	. $import.FullName
}

Export-ModuleMember -Function $public.BaseName
