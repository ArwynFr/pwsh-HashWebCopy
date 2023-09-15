function Test-FileHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Path,
        
        [Parameter(Mandatory)]
        [string]
        $Hash,

        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MACTripleDES', 'MD5', 'RIPEMD160')]
        [String]
        $Algorithm = 'MD5'
    )

    Process {
    
        if (-Not(Test-Path $Path -PathType Leaf)) {
            Write-Debug "$Path is not a file"
            return $false
        }   

        $private:actual = (Get-FileHash -Path $Path -Algorithm MD5).Hash
        Write-Debug "$Path $Algorithm hash is $private:actual"
        return $Hash -eq $Private:actual
        
    }
}

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

function Copy-HashManifest {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Manifest')]
        [psobject[]]
        $Manifest,

        [Parameter(Mandatory)]
        [ValidateScript( { if (Test-Path $_ -PathType Container -IsValid) { $True } Else { Throw '-Destination must be a valid path.' } })]
        [String]
        $Destination,

        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MACTripleDES', 'MD5', 'RIPEMD160')]
        [String]
        $Algorithm = 'MD5',

        [switch]
        $Mirror,

        [switch]
        $PassThru
    )

    Begin {
        If (-Not (Test-Path $Destination)) {
            Throw "$Destination does not exist"
        }
        Else {
            $Destination = Join-Path ((Resolve-Path -Path $Destination).Path) -ChildPath '/'
        }
    }

    Process {

        $client = New-Object net.webclient
        $Manifest | Where-Object {
            $private:filename = Join-Path $Destination -ChildPath $_.Filename
            -Not(Test-FileHash -Path $private:filename -Algorithm $Algorithm -Hash $_.Hash)
        } | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.Location, 'Download')) {
                $private:filename = Join-Path $Destination -ChildPath $_.Filename
                New-Item -Force -Path $private:filename -ItemType 'file' | Out-Null
                $client.Downloadfile($_.Location, $private:filename)
            }
        }

        if (-not $Mirror) { return }
            
        [string[]] $private:filenames = $Manifest | Select-Object -ExpandProperty Filename | ForEach-Object {
            Join-Path -Path $Destination -ChildPath $_
        }

        Get-ChildItem $Destination -Recurse -File | Where-Object {
            -Not $private:filenames.Contains($_.FullName)
        } | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.FullName, 'Remove-Item')) {
                Remove-Item $_
            }
        }

    }
}