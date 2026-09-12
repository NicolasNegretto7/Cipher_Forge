$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8080'
$suffix = Get-Random -Minimum 1000 -Maximum 9999
$stamp = Get-Date -Format 'HHmmss'
$emailFoto = "foto_$($stamp)_$suffix@test.dev"
$emailCli = "cliente_$($stamp)_$suffix@test.dev"
$password = "Passw0rd!123"

function Invoke-Json($method, $path, $body = $null, $token = $null) {
    $params = @{
        Uri         = "$base$path"
        Method      = $method
        UseBasicParsing = $true
    }
    $headers = @{}
    if ($token) { $headers['Authorization'] = "Bearer $token" }
    if ($body) {
        $params['ContentType'] = 'application/json'
        $params['Body'] = ($body | ConvertTo-Json -Depth 6)
    }
    if ($headers.Count -gt 0) { $params['Headers'] = $headers }
    try {
        $r = Invoke-WebRequest @params
        $content = $r.Content
        if ($content) { return [pscustomobject]@{ Status = $r.StatusCode; Json = ($content | ConvertFrom-Json) } }
        return [pscustomobject]@{ Status = $r.StatusCode; Json = $null }
    } catch {
        $resp = $_.Exception.Response
        $code = [int]$resp.StatusCode
        $stream = $resp.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $txt = $reader.ReadToEnd()
        if ($txt) {
            try { return [pscustomobject]@{ Status = $code; Json = ($txt | ConvertFrom-Json) } }
            catch { return [pscustomobject]@{ Status = $code; Json = $null; Raw = $txt } }
        }
        return [pscustomobject]@{ Status = $code; Json = $null }
    }
}

function Get-CodigoVerificacion($email) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = & docker exec cipher_forge_db mysql -ucipher_user -pcipher_password cipher_forge -N -s -e "SELECT codigo_verificacion FROM usuarios WHERE email='$email' ORDER BY id DESC LIMIT 1" 2>$null
    $ErrorActionPreference = $prev
    return ($out | Where-Object { $_ -match '^\d' } | Select-Object -Last 1).Trim()
}

Write-Output "== 1. Registro fotografo =="
$regFoto = Invoke-Json 'POST' '/auth/register' @{ nombre_completo='Foto Test'; email=$emailFoto; password=$password; rol='fotografo'; terminos_aceptados=$true }
Write-Output "  status=$($regFoto.Status)"
if ($regFoto.Json) { Write-Output "  ok=$($regFoto.Json.ok) mensaje=$($regFoto.Json.mensaje)" }

Write-Output "== 2. Verificar email fotografo =="
$cod = Get-CodigoVerificacion $emailFoto
Write-Output "  codigo=$cod"
$verFoto = Invoke-Json 'POST' '/auth/verificar-email' @{ email=$emailFoto; codigo=$cod }
Write-Output "  status=$($verFoto.Status) ok=$($verFoto.Json.ok)"

Write-Output "== 3. Login fotografo =="
$logFoto = Invoke-Json 'POST' '/auth/login' @{ email=$emailFoto; password=$password }
$tokenFoto = $logFoto.Json.datos.token
Write-Output "  status=$($logFoto.Status) token=$(if($tokenFoto){'OK'}else{'NULL'})"

Write-Output "== 4. GET /fotografos/cuota (fotografo, espera 200) =="
$cuota = Invoke-Json 'GET' '/fotografos/cuota' $null $tokenFoto
Write-Output "  status=$($cuota.Status)"
if ($cuota.Json) { Write-Output "  ok=$($cuota.Json.ok) mensaje=$($cuota.Json.mensaje)" }

Write-Output "== 5. Registro cliente =="
$regCli = Invoke-Json 'POST' '/auth/register' @{ nombre_completo='Cliente Test'; email=$emailCli; password=$password; rol='cliente'; terminos_aceptados=$true }
Write-Output "  status=$($regCli.Status)"

Write-Output "== 6. Verificar email cliente =="
$codC = Get-CodigoVerificacion $emailCli
$verCli = Invoke-Json 'POST' '/auth/verificar-email' @{ email=$emailCli; codigo=$codC }
Write-Output "  status=$($verCli.Status) ok=$($verCli.Json.ok)"

Write-Output "== 7. Login cliente =="
$logCli = Invoke-Json 'POST' '/auth/login' @{ email=$emailCli; password=$password }
$tokenCli = $logCli.Json.datos.token
Write-Output "  status=$($logCli.Status) token=$(if($tokenCli){'OK'}else{'NULL'})"

Write-Output "== 8. GET /fotografos/cuota (cliente, espera 403) =="
$cuotaCli = Invoke-Json 'GET' '/fotografos/cuota' $null $tokenCli
Write-Output "  status=$($cuotaCli.Status)"
if ($cuotaCli.Json) { Write-Output "  ok=$($cuotaCli.Json.ok) mensaje=$($cuotaCli.Json.mensaje)" }

Write-Output "== 9. GET /fotografos/cuota (sin token, espera 401) =="
$cuotaNo = Invoke-Json 'GET' '/fotografos/cuota' $null $null
Write-Output "  status=$($cuotaNo.Status)"
if ($cuotaNo.Json) { Write-Output "  ok=$($cuotaNo.Json.ok) mensaje=$($cuotaNo.Json.mensaje)" }

Write-Output "== 10. GET /fotografos/1 perfil (publico, espera 200) =="
$perf = Invoke-Json 'GET' '/fotografos/1' $null $null
Write-Output "  status=$($perf.Status)"