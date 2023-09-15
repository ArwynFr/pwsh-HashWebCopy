@{
    Author            = 'Arwyn'
    CompanyName       = 'arwynfr'
    Copyright         = '(c) 2019-2023 - ArwynFr - MIT license'

    ModuleVersion     = '0.1.0'
    GUID              = '5ca6a93b-0d13-465a-ad11-31a9a4dbcbdb'
    Description       = 'Powershell module for hash-based file synchronization over HTTP'
    HelpInfoURI       = 'https://github.com/ArwynFr/pwsh-HashWebCopy#readme'
    
    PrivateData       = @{
        ProjectUri = 'https://github.com/ArwynFr/pwsh-HashWebCopy'
        LicenseUri = 'https://github.com/ArwynFr/pwsh-HashWebCopy/blob/main/LICENSE'
    }

    RootModule        = 'HashWebCopy.psm1'
    FunctionsToExport = @(
        'Copy-HashManifest'
        'Get-HashManifest'
    )
}

