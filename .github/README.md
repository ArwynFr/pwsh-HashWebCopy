# HashWebCopy

HashWebCopy is a Powershell module that allows recrusive file synchronisation over HTTPS.

## Installing

You can install this module from PowershellGallery:

```ps1
Install-Module HashWebCopy -Scope CurrentUser
```

## Usage

You can create a manifest using the `New-HashManifest` cmdlet. It takes a local directory in which to scan for files, and the base url used to access that directory from the internet. It will list all files, calculating their hashes and download url.

You can can synchronize a manifest using the `Copy-HashManifest` cmdlet. It takes a manifest, and a local directory. It will compare files in the local directory with the information in the manifest, and downloading changed or missing files. You can also remove files not in the manifest using the `-Mirror` switch.

Manifests can be saved to files for remote access. Examples:
```ps1
# Write manifest to json file
New-HashManifest -Path .\sync\ -BaseUri https://localhost/sync/ | ConvertTo-Json -AsArray | Set-Content manifest.json

# Synchronize files from remote manifest
(Invoke-WebRequest https://localhost/manifest.json).Content | ConvertFrom-Json | Copy-HashManifest -Destination .\test\ -Mirror
```

## Contributing

You can contribute to this module in multiple ways:
* Discuss features and implementation
* Provide issues or security reports
* Fork this repository and provide pull requests