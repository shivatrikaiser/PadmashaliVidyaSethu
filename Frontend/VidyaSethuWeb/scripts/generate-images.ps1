# Regenerates the brand images in public/ from the master logo branding/vidyasethu-logo.png (1254x1254, transparent).
#   powershell -ExecutionPolicy Bypass -File scripts/generate-images.ps1
# Windows only (System.Drawing). The master file itself is not deployed (it is 1.4 MB).
# Outputs:
#   public/brand/vidyasethu-logo-96.png, -192.png, -480.png   site logo (header / footer / home page)
#   public/favicon-48.png, public/apple-touch-icon.png          browser and home-screen icons
#   public/og-image.png                                         1200x630 social-sharing image
Add-Type -AssemblyName System.Drawing

$root = Join-Path $PSScriptRoot '..'
$public = Join-Path $root 'public'
$master = [System.Drawing.Image]::FromFile((Resolve-Path (Join-Path $root 'branding\vidyasethu-logo.png')))
New-Item -ItemType Directory -Force (Join-Path $public 'brand') | Out-Null

$navy = [System.Drawing.ColorTranslator]::FromHtml('#01377f')
$blue = [System.Drawing.ColorTranslator]::FromHtml('#097cd6')
$text = [System.Drawing.ColorTranslator]::FromHtml('#3a4a5e')

function New-Canvas([int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return @($bmp, $g)
}

function Save-Logo([int]$size, [string]$path, $background) {
    $bmp, $g = New-Canvas $size $size
    if ($background) { $g.Clear($background) }
    $pad = if ($background) { [int]($size * 0.04) } else { 0 }
    $g.DrawImage($master, $pad, $pad, $size - 2 * $pad, $size - 2 * $pad)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

foreach ($size in 96, 192, 480) {
    Save-Logo $size (Join-Path $public "brand\vidyasethu-logo-$size.png") $null
}
Save-Logo 48 (Join-Path $public 'favicon-48.png') $null
# iOS shows transparency as black: use a white square.
Save-Logo 180 (Join-Path $public 'apple-touch-icon.png') ([System.Drawing.Color]::White)

# Social-sharing image: light background, logo on the left, name and tagline on the right.
$bmp, $g = New-Canvas 1200 630
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)), (New-Object System.Drawing.Point(1200, 630)),
    [System.Drawing.Color]::White, [System.Drawing.ColorTranslator]::FromHtml('#e3f1fd'))
$g.FillRectangle($bg, 0, 0, 1200, 630)
$g.FillRectangle((New-Object System.Drawing.SolidBrush($navy)), 0, 610, 1200, 20)
$g.DrawImage($master, 70, 85, 460, 460)

$bold = [System.Drawing.FontStyle]::Bold
$px = [System.Drawing.GraphicsUnit]::Pixel
$typo = [System.Drawing.StringFormat]::GenericTypographic
$nameFont = New-Object System.Drawing.Font('Segoe UI', 76, $bold, $px)
$g.DrawString('Vidya', $nameFont, (New-Object System.Drawing.SolidBrush($navy)), 580, 170, $typo)
$vidyaWidth = $g.MeasureString('Vidya', $nameFont, 1000, $typo).Width
$g.DrawString('Sethu', $nameFont, (New-Object System.Drawing.SolidBrush($blue)), 580 + $vidyaWidth, 170, $typo)
$g.DrawString("Connecting Communities`nto a Brighter Future", (New-Object System.Drawing.Font('Segoe UI', 40, $bold, $px)),
    (New-Object System.Drawing.SolidBrush($navy)), 584, 290, $typo)
$g.DrawString('vidyasethu.co.in', (New-Object System.Drawing.Font('Segoe UI', 30, [System.Drawing.FontStyle]::Regular, $px)),
    (New-Object System.Drawing.SolidBrush($text)), 586, 430, $typo)
$bmp.Save((Join-Path $public 'og-image.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
$master.Dispose()

Write-Output 'Generated brand/vidyasethu-logo-{96,192,480}.png, favicon-48.png, apple-touch-icon.png, og-image.png'
