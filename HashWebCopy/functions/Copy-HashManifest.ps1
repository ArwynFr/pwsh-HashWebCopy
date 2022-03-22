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