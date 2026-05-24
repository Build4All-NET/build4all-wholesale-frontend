param(
  [string]$EnvFile = "lib/env/ci_env.json"
)

$ErrorActionPreference = "Stop"

function Ensure-Dir($p) {
  if (!(Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

function Get-JsonPropValue($obj, $propName) {
  if ($null -eq $obj) { return $null }
  $names = $obj.PSObject.Properties.Name
  if ($names -contains $propName) { return $obj.$propName }
  return $null
}

function First-Text([object[]]$values) {
  foreach ($v in $values) {
    if ($null -eq $v) { continue }
    $t = ("" + $v).Trim()
    if (![string]::IsNullOrWhiteSpace($t)) { return $t }
  }
  return ""
}

function Normalize-RootUrl([string]$url) {
  $clean = ("" + $url).Trim().TrimEnd('/')
  if ($clean.EndsWith('/api')) { return $clean.Substring(0, $clean.Length - 4) }
  return $clean
}

function Resolve-Url([string]$root, [string]$raw) {
  $r = ("" + $raw).Trim()
  if ([string]::IsNullOrWhiteSpace($r)) { return "" }
  if ($r.StartsWith('http://') -or $r.StartsWith('https://')) { return $r }
  if (-not $r.StartsWith('/')) { $r = "/$r" }
  return "$(Normalize-RootUrl $root)$r"
}

function Run-Ok([string]$cmd) {
  Write-Host ">> $cmd"
  & cmd.exe /c $cmd
  if ($LASTEXITCODE -ne 0) { throw "Command failed (exit $LASTEXITCODE): $cmd" }
}

try {
  if (!(Test-Path $EnvFile)) { throw "Env file not found: $EnvFile" }

  $cfg = (Get-Content $EnvFile -Raw) | ConvertFrom-Json

  $apiBase = First-Text @((Get-JsonPropValue $cfg "API_BASE_URL"))
  if ([string]::IsNullOrWhiteSpace($apiBase)) { throw "API_BASE_URL missing in env json" }
  $apiRoot = Normalize-RootUrl $apiBase

  $runtimeUrl = First-Text @((Get-JsonPropValue $cfg "RUNTIME_CONFIG_URL"))
  $ownerProjectLinkId = First-Text @((Get-JsonPropValue $cfg "OWNER_PROJECT_LINK_ID"))
  if ([string]::IsNullOrWhiteSpace($runtimeUrl) -and -not [string]::IsNullOrWhiteSpace($ownerProjectLinkId)) {
    $runtimeUrl = "$apiRoot/api/public/runtime-config/by-link?linkId=$ownerProjectLinkId"
  }

  $runtime = $null
  if (-not [string]::IsNullOrWhiteSpace($runtimeUrl)) {
    try {
      $headers = @{}
      $runtimeToken = First-Text @((Get-JsonPropValue $cfg "RUNTIME_CONFIG_TOKEN"))
      if (-not [string]::IsNullOrWhiteSpace($runtimeToken)) { $headers["X-Auth-Token"] = $runtimeToken }
      Write-Host "Runtime config URL: $runtimeUrl"
      $runtime = Invoke-RestMethod -Uri $runtimeUrl -Headers $headers -Method Get
    } catch {
      Write-Host "Could not fetch runtime config. Using env/local fallback. $($_.Exception.Message)" -ForegroundColor Yellow
    }
  }

  $branding = Get-JsonPropValue $cfg "BRANDING"

  $appName = First-Text @(
    (Get-JsonPropValue $runtime "APP_NAME"),
    (Get-JsonPropValue $runtime "appName"),
    (Get-JsonPropValue $runtime "displayName"),
    (Get-JsonPropValue $cfg "APP_NAME"),
    "B2B Wholesale App"
  )

  $logoRaw = First-Text @(
    (Get-JsonPropValue $runtime "LOGO_URL"),
    (Get-JsonPropValue $runtime "APP_LOGO_URL"),
    (Get-JsonPropValue $runtime "logoUrl"),
    (Get-JsonPropValue $runtime "logoPath"),
    (Get-JsonPropValue $cfg "APP_LOGO_URL"),
    (Get-JsonPropValue $branding "logoPath"),
    (Get-JsonPropValue $branding "logoUrl")
  )

  $splashColor = First-Text @(
    (Get-JsonPropValue $branding "splashColor"),
    "#FFFFFF"
  )

  Ensure-Dir "assets/branding"
  Ensure-Dir "android/app/src/main/res/values"

  $logoPath = "assets/branding/logo.png"
  $launcherPath = "assets/branding/launcher.png"
  $splashPath = "assets/branding/splash.png"

  if (-not [string]::IsNullOrWhiteSpace($logoRaw)) {
    $logoUrl = Resolve-Url $apiRoot $logoRaw
    Write-Host "Logo URL: $logoUrl"
    Invoke-WebRequest -Uri $logoUrl -OutFile $logoPath -UseBasicParsing
  } elseif (!(Test-Path $logoPath)) {
    throw "No LOGO_URL/logoPath found and assets/branding/logo.png does not exist."
  } else {
    Write-Host "Using existing local logo: $logoPath"
  }

  Copy-Item $logoPath $launcherPath -Force
  Copy-Item $logoPath $splashPath -Force

  Write-Host "APP_NAME: $appName"
  Write-Host "Splash color: $splashColor"

  # Android app label
  $stringsPath = "android/app/src/main/res/values/strings.xml"
  if (!(Test-Path $stringsPath)) {
@"
<resources>
    <string name="app_name">$appName</string>
</resources>
"@ | Set-Content $stringsPath -Encoding UTF8
  } else {
    $strings = Get-Content $stringsPath -Raw
    if ($strings -match 'name="app_name"') {
      $strings = $strings -replace '(?s)(<string name="app_name">).*?(</string>)', "`$1$appName`$2"
    } else {
      $strings = $strings -replace '</resources>', "    <string name=`"app_name`">$appName</string>`n</resources>"
    }
    Set-Content $stringsPath $strings -Encoding UTF8
  }

  # Android manifest should read label from strings.xml
  $manifestPath = "android/app/src/main/AndroidManifest.xml"
  if (Test-Path $manifestPath) {
    $m = Get-Content $manifestPath -Raw
    if ($m -match 'android:label="[^"]*"') {
      $m = $m -replace 'android:label="[^"]*"', 'android:label="@string/app_name"'
    } else {
      $m = $m -replace '<application', '<application android:label="@string/app_name"'
    }
    Set-Content $manifestPath $m -Encoding UTF8
  }

  # iOS display name
  $plistPath = "ios/Runner/Info.plist"
  if (Test-Path $plistPath) {
    $plist = Get-Content $plistPath -Raw
    if ($plist -match '<key>CFBundleDisplayName</key>') {
      $plist = $plist -replace '(?s)(<key>CFBundleDisplayName</key>\s*<string>).*?(</string>)', "`$1$appName`$2"
    } else {
      $inject = "  <key>CFBundleDisplayName</key>`n  <string>$appName</string>`n"
      $plist = $plist -replace '</dict>', "$inject</dict>"
    }
    Set-Content $plistPath $plist -Encoding UTF8
  }

  Run-Ok "flutter pub get"
  Run-Ok "flutter pub run flutter_launcher_icons"
  Run-Ok "flutter pub run flutter_native_splash:create"

  Write-Host "Branding applied successfully from $EnvFile"
  exit 0
}
catch {
  Write-Host "apply_env_branding failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
