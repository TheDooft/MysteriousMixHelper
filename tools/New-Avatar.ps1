<#
.SYNOPSIS
    Builds the 400x400 CurseForge project avatar from the achievement's icon.

.DESCRIPTION
    Composes the avatar in the same colours as the in-game window: the addon's
    panel background, a few of its green bubbles, and the cauldron icon crisp on
    top over a soft blown-up copy of itself.

    Composition is pure System.Drawing, so nothing needs installing.

    Give it the icon in any format System.Drawing reads (PNG, JPG, BMP). The
    game ships icons as TGA, which System.Drawing does not read, so a .tga input
    is handed to a converter script first — pass -Converter to point at one.
    Any TGA-to-PNG tool will do; the default is where the author's lives, and it
    is not part of this repository.

.EXAMPLE
    .\New-Avatar.ps1 -Icon .\cauldron.png
    Composes from an already-decoded icon and writes docs/avatar-400.png.

.EXAMPLE
    .\New-Avatar.ps1 -Icon 'D:\...\INV_Misc_Cauldron_Arcane.tga' -OutFile out.png
#>
[CmdletBinding()]
param(
    # The achievement's icon, inv_misc_cauldron_arcane. The default is the
    # author's client install; give your own path.
    [string] $Icon = 'D:\World of Warcraft\_retail_\Interface\ICONS\INV_Misc_Cauldron_Arcane.tga',

    [string] $OutFile,

    # Only consulted for a .tga input. Not shipped with this addon.
    [string] $Converter = 'C:\dev\Claude-PC\tools\Convert-Tga.ps1',

    [int] $Size = 400
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent
if (-not $OutFile) { $OutFile = Join-Path $root 'docs\avatar-400.png' }

# --- Colours, matching UI.lua ----------------------------------------------

$panel  = [System.Drawing.Color]::FromArgb(255, 11, 12, 15)   # PANEL_BG
$edge   = [System.Drawing.Color]::FromArgb(28, 255, 255, 255) # PANEL_EDGE
$bubble = [System.Drawing.Color]::FromArgb(117, 255, 158)     # BUBBLE_COLOR
$accent = [System.Drawing.Color]::FromArgb(255, 255, 184, 51) # ACCENT

# Hand-placed rather than random, so the composition is the same every run.
# Kept large and very faint: an avatar is read at 64px more often than at 400,
# and anything with an edge to it turns into confetti at that size. x, y,
# diameter, peak alpha out of 255.
$bubbles = @(
    @( -40, 150, 220, 30),
    @( 250, -30, 240, 24),
    @( 210, 240, 260, 26),
    @( -20, -40, 160, 20)
)

# --- Decode the icon --------------------------------------------------------

if (-not (Test-Path $Icon)) { throw "No icon at '$Icon'. Pass -Icon with your own path." }

$temp = $null
if ([System.IO.Path]::GetExtension($Icon) -eq '.tga') {
    if (-not (Test-Path $Converter)) {
        throw "'$Icon' is a TGA and System.Drawing cannot read one. Convert it to PNG with any tool and pass that instead, or point -Converter at a TGA decoder. The default path is the author's own and is not part of this repository."
    }
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("mmh-icon-{0}.png" -f [guid]::NewGuid())
    & $Converter $Icon -OutFile $temp | Out-Null
    if (-not (Test-Path $temp)) { throw "'$Converter' produced no file." }
    $Icon = $temp
}

$source = [System.Drawing.Image]::FromFile($Icon)
$canvas = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

try {
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    try {
        $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

        $g.Clear($panel)

        # A copy of the icon blown well past the frame and left at low opacity.
        # Upscaling 128px by four is its own blur, so this reads as an out-of-
        # focus wash without any convolution to write.
        $wash = New-Object System.Drawing.Imaging.ColorMatrix
        $wash.Matrix33 = 0.09
        $washAttributes = New-Object System.Drawing.Imaging.ImageAttributes
        $washAttributes.SetColorMatrix($wash)
        $bleed = [int]($Size * 0.14)
        $washRect = New-Object System.Drawing.Rectangle(
            (-$bleed), (-$bleed), ($Size + $bleed * 2), ($Size + $bleed * 2))
        $g.DrawImage($source, $washRect, 0, 0, $source.Width, $source.Height,
            [System.Drawing.GraphicsUnit]::Pixel, $washAttributes)

        # Bubbles, as real radial gradients rather than the stack of concentric
        # discs the addon has to use for want of one.
        foreach ($b in $bubbles) {
            $rect = New-Object System.Drawing.Rectangle($b[0], $b[1], $b[2], $b[2])
            $path = New-Object System.Drawing.Drawing2D.GraphicsPath
            try {
                $path.AddEllipse($rect)
                $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
                try {
                    $brush.CenterColor = [System.Drawing.Color]::FromArgb(
                        $b[3], $bubble.R, $bubble.G, $bubble.B)
                    $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(
                        0, $bubble.R, $bubble.G, $bubble.B))
                    $g.FillPath($brush, $path)
                } finally { $brush.Dispose() }
            } finally { $path.Dispose() }
        }

        # The icon itself, crisp and dominant: at thumbnail size it is the only
        # thing anyone will actually recognise, so it gets the room.
        $inset = [int]($Size * 0.085)
        $side  = $Size - $inset * 2
        $g.DrawImage($source, $inset, $inset, $side, $side)

        # A thin accent frame around it, borrowing the title bar's gold.
        $pen = New-Object System.Drawing.Pen(
            [System.Drawing.Color]::FromArgb(90, $accent.R, $accent.G, $accent.B), 2)
        try { $g.DrawRectangle($pen, $inset - 1, $inset - 1, $side + 1, $side + 1) } finally { $pen.Dispose() }

        $frame = New-Object System.Drawing.Pen($edge, 1)
        try { $g.DrawRectangle($frame, 0, 0, $Size - 1, $Size - 1) } finally { $frame.Dispose() }
    } finally {
        $g.Dispose()
    }

    $canvas.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Wrote $OutFile (${Size}x${Size})" -ForegroundColor Green
} finally {
    $canvas.Dispose()
    $source.Dispose()
    if ($temp) { Remove-Item $temp -ErrorAction SilentlyContinue }
}
