# Install Certify The Web (if not already installed)
#> Install-Module -Name Posh-ACME

$domain = 'example.com'
# Will do wildcard for *.$domain in addition to root

# Make an HTTP POST request
$response = Invoke-RestMethod -Uri "https://auth.acme-dns.io/register" -Method Post


# Print Instructions
Write-Host "Please add the following CNAME to your DNS:"
Write-Host "Host: _acme-challenge"
Write-Host "Target: "
$response.fulldomain

# Save response to use later
$response | ConvertTo-Json | Out-File -FilePath .\acme-dns.json


# Wait for DNS to update
Write-Host "Press any key after adding record..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')


# Read file back in (if you closed the shell)
# $response = Get-Content -Raw -Path .\acme-dns.json | ConvertFrom-Json 


$reg = @{
    "_acme-challenge.$domain" = @(
        # the array order of these values is important
        $response.subdomain
        $response.username
        $response.password
        $response.fulldomain
    )
}

$pArgs = @{
    ACMEServer = 'auth.acme-dns.io'
    ACMERegistration = $reg
}

$domains = '*.'+$domain,$domain
New-PACertificate $domains -Plugin AcmeDns -PluginArgs $pArgs -Verbose