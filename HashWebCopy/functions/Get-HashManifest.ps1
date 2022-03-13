function Get-HashManifest {
    [CmdletBinding()]
    [OutputType([hashtable[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateScript( { if (Test-Path $_ -PathType Container) { $True } Else { Throw '-Path must be a valid directory.' } })]
        [String]
        $Path,

        [Parameter(Mandatory)]
        [Uri]
        $BaseUri,

        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MACTripleDES', 'MD5', 'RIPEMD160')]
        [String]
        $Algorithm = 'MD5'
    )

    Begin {
        $Path = (Resolve-Path -Path $Path).Path
    }

    Process {
        Get-ChildItem $Path -Recurse -File | ForEach-Object {
            $private:relative = [System.IO.Path]::GetRelativePath($Path, $_.FullName)
            $private:location = [uri]::new($BaseUri, $Private:relative)
            $private:hash = (Get-FileHash -Path $_.FullName -Algorithm $Algorithm).Hash
            @{
                Filename = $private:relative
                Location = $private:location
                Hash     = $private:hash
            }
        }
    }    
}
