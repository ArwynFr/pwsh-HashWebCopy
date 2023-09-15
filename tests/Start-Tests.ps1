[CmdletBinding()]
param ()

$ModuleName = 'HashWebCopy'
$RootPath = Convert-Path $PSScriptRoot/..
$ModulePath = Convert-Path $RootPath/$ModuleName

Import-Module -Force Pester
Import-Module -Force PSScriptAnalyzer
Import-Module -Force $ModulePath

Test-ModuleManifest $ModulePath/$ModuleName.psd1
Invoke-ScriptAnalyzer -Recurse -Severity Warning $ModulePath

$configuration = [PesterConfiguration]@{
  Run          = @{
    Path = "$RootPath/tests/"
  }
  CodeCoverage = @{
    Enabled    = $true
    Path       = "$ModulePath/$ModuleName.psm1"
    OutputPath = "$RootPath/coverage.xml"
  }
  TestResult   = @{
    Enabled    = $true
    OutputPath = "$RootPath/output.xml"
  }
}

Invoke-Pester -Configuration $configuration