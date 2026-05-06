param(
  [string]$EnvFile = "lib/env/ci_env.json"
)

$ErrorActionPreference = "Stop"

Write-Host "Reading env from: $EnvFile"

if (!(Test-Path $EnvFile)) {
  throw "Env file not found: $EnvFile"
}

$envJson = Get-Content $EnvFile -Raw | ConvertFrom-Json

function Clean-AppName([string]$name) {
  if ([string]::IsNullOrWhiteSpace($name)) {
    return "B2B Wholesale App"
  }

  $clean = $name.Trim()
  $clean = $clean.Replace("'", "\'")
  $clean = [regex]::Replace($clean, '[\x00-\x1F\x7F]', ' ').Trim()

  if ([string]::IsNullOrWhiteSpace($clean)) {
    return "B2B Wholesale App"
  }

  return $clean
}

$appName = Clean-AppName "$($envJson.APP_NAME)"
$appNameEscaped = [System.Security.SecurityElement]::Escape($appName)

$apiBaseUrl = "$($envJson.API_BASE_URL)".TrimEnd("/")
$apiRootUrl = $apiBaseUrl -replace "/api/?$", ""

$logoPath = ""
$splashColor = "#FFFFFF"

if ($envJson.BRANDING -ne $null) {
  $logoPath = "$($envJson.BRANDING.logoPath)"

  if (![string]::IsNullOrWhiteSpace("$($envJson.BRANDING.splashColor)")) {
    $splashColor = "$($envJson.BRANDING.splashColor)"
  }
}

$brandingDir = "assets/branding"
New-Item -ItemType Directory -Force -Path $brandingDir | Out-Null

$logoFile = "$brandingDir/logo.png"
$launcherPath = "$brandingDir/launcher.png"
$splashPath = "$brandingDir/splash.png"

$fallbackLogo = "assets/logo/default_launcher_icon.png"

if (![string]::IsNullOrWhiteSpace($logoPath)) {
  if ($logoPath.StartsWith("http")) {
    $logoUrl = $logoPath
  } elseif ($logoPath.StartsWith("/")) {
    $logoUrl = "$apiRootUrl$logoPath"
  } else {
    $logoUrl = "$apiRootUrl/$logoPath"
  }

  Write-Host "Logo URL: $logoUrl"

  try {
    Invoke-WebRequest -Uri $logoUrl -OutFile $logoFile
    Write-Host "Logo downloaded to: $logoFile"
  } catch {
    Write-Host "Logo download failed. Using fallback logo."
    Write-Host "Error: $($_.Exception.Message)"

    if (Test-Path $fallbackLogo) {
      Copy-Item $fallbackLogo $logoFile -Force
    }
  }
} else {
  Write-Host "No BRANDING.logoPath found. Using fallback logo."

  if (Test-Path $fallbackLogo) {
    Copy-Item $fallbackLogo $logoFile -Force
  }
}

if (!(Test-Path $logoFile)) {
  throw "Logo file was not created. Please check assets/logo/default_launcher_icon.png"
}

Add-Type -AssemblyName System.Drawing

$original = [System.Drawing.Image]::FromFile((Resolve-Path $logoFile).Path)

$size = 1024
$canvas = New-Object System.Drawing.Bitmap $size, $size
$graphics = [System.Drawing.Graphics]::FromImage($canvas)

$backgroundColor = [System.Drawing.ColorTranslator]::FromHtml($splashColor)
$graphics.Clear($backgroundColor)

$paddingPercent = 0.30
$targetSize = [int]($size * (1 - $paddingPercent))

$x = [int](($size - $targetSize) / 2)
$y = [int](($size - $targetSize) / 2)

$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$graphics.DrawImage($original, $x, $y, $targetSize, $targetSize)

$canvas.Save($launcherPath, [System.Drawing.Imaging.ImageFormat]::Png)
$canvas.Save($splashPath, [System.Drawing.Imaging.ImageFormat]::Png)

$graphics.Dispose()
$canvas.Dispose()
$original.Dispose()

Write-Host "Launcher generated: $launcherPath"
Write-Host "Splash generated: $splashPath"

# Android app name
$valuesDir = "android/app/src/main/res/values"
$stringsFile = Join-Path $valuesDir "strings.xml"

New-Item -ItemType Directory -Force -Path $valuesDir | Out-Null

$androidXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$appNameEscaped</string>
</resources>
"@

[System.IO.File]::WriteAllText(
  (Resolve-Path $valuesDir).Path + "\strings.xml",
  $androidXml,
  [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Android app_name updated: $appName"

# iOS app name
$iosInfoPlist = "ios/Runner/Info.plist"

if (Test-Path $iosInfoPlist) {
  [xml]$plist = Get-Content $iosInfoPlist

  $dict = $plist.plist.dict
  $nodes = @($dict.ChildNodes)

  function Set-PlistValue {
    param(
      [string]$Key,
      [string]$Value
    )

    $nodes = @($dict.ChildNodes)

    for ($i = 0; $i -lt $nodes.Count; $i++) {
      if ($nodes[$i].Name -eq "key" -and $nodes[$i].InnerText -eq $Key) {
        if (($i + 1) -lt $nodes.Count) {
          $nodes[$i + 1].InnerText = $Value
          return
        }
      }
    }
  }

  Set-PlistValue -Key "CFBundleDisplayName" -Value $appName
  Set-PlistValue -Key "CFBundleName" -Value $appName

  $plist.Save((Resolve-Path $iosInfoPlist).Path)

  Write-Host "iOS app name updated: $appName"
}

Write-Host "Done branding from env."