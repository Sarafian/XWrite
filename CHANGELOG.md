**1.3**

- New functionality that adds inline output for the `Write-Progress` native cmdlets.
    - `Enable-XWriteProgress`
    - `Disable-XWriteProgress`
- Minor decorative fixes in other cmdlets.    

**1.1**

- New segment in output `-Source` or `%source%` which can be 
  - `Script`
  - `Function`
  - a module name
- Fix `Enable-XWrite` parameter set names
- Parameter `-Caller` is removed. Caller will be always outputed.
- New cmdlets for enabling and reseting preference variables:
  - Set-XGlobalTrace
  - Undo-XGlobalTrace

**1.0**

XWrite PowerShell module introduced

- Enable-XWrite
- Disable-XWrite