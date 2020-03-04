<#PSManifest
# This the hash to generate the module's manifest with New-ModuleManifest
@{
	# Required fields
	"RootModule"="XWrite.psm1"
	"Description"="PowerShell module to enhance the Write-* functionality"
	"Guid"="3e84f03d-f88a-408c-a465-bc58a3268e4d"
	"ModuleVersion"="1.3"
	# Optional fields
	"Author"="Alex Sarafian"
	# "CompanyName" = "Company name"
	# "Copyright"="Some Copyright"
	"LicenseUri"='https://github.com/Sarafian/XWrite/blob/master/LICENSE'
    "ProjectUri"= 'https://github.com/Sarafian/XWrite/'
    Tags = 'Tools'
    ReleaseNotes = 'https://github.com/Sarafian/XWrite/blob/master/CHANGELOG.md'
    # Auto generated. Don't implement
}
#>

#requires -Version 4.0

$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude @("*.Tests.ps1"))
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude @("*.Tests.ps1"))

Foreach($import in @($public + $private))
{
	. $import.FullName
}

Export-ModuleMember -Function $public.BaseName