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
    
    if (-Not(Test-Path $Path -PathType Leaf)) {
        Write-Debug "$Path is not a file"
        return $false
    }   

    $private:actual = (Get-FileHash -Path $Path -Algorithm MD5).Hash
    Write-Debug "$Path $Algorithm hash is $private:actual"
    return $Hash -eq $Private:actual
}
