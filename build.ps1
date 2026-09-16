# Generates the per-page HTML files, sitemap.xml and 404.html from site/index.html.
#
#   site/index.html  is the single source of truth for ALL page content.
#   pages.json       holds each page's URL, <title> and meta description.
#
# Run this after editing either file:   powershell -ExecutionPolicy Bypass -File build.ps1
# It rewrites site/services/index.html, site/experience/index.html, … so that every
# page has its own URL, title and description (what search engines index), while the
# page runtime picks which section to show from the URL path.

$ErrorActionPreference = "Stop"
$root   = $PSScriptRoot
$site   = Join-Path $root "site"
$origin = "https://tillstone.land"
$utf8   = New-Object Text.UTF8Encoding($false)

$pages  = [IO.File]::ReadAllText((Join-Path $root "pages.json"), $utf8) | ConvertFrom-Json
$master = [IO.File]::ReadAllText((Join-Path $site "index.html"))

function Esc([string]$s) { $s.Replace("&", "&amp;").Replace('"', "&quot;").Replace("<", "&lt;") }

function SeoBlock($p, [bool]$noindex) {
  $t = Esc $p.title; $d = Esc $p.description; $u = "$origin$($p.path)"
  $robots = if ($noindex) { "`n<meta name=`"robots`" content=`"noindex`">" } else { "" }
  @"
<!-- SEO:BEGIN — per-page values; build.ps1 rewrites this block for /services/, /about/, etc. Edit pages.json, not this. -->
<title>$t</title>
<meta name="description" content="$d">
<link rel="canonical" href="$u">$robots
<meta property="og:type" content="website">
<meta property="og:site_name" content="Tillstone Land Solutions">
<meta property="og:url" content="$u">
<meta property="og:title" content="$t">
<meta property="og:description" content="$d">
<meta property="og:image" content="$origin/assets/img/og-image.jpg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="Tillstone Land Solutions — aerial view of a master-planned community under development">
<meta name="twitter:card" content="summary_large_image">
<!-- SEO:END -->
"@
}

$re = [regex]'(?s)<!-- SEO:BEGIN.*?<!-- SEO:END -->'
if (-not $re.IsMatch($master)) { throw "site/index.html is missing the <!-- SEO:BEGIN --> … <!-- SEO:END --> block" }

$urls = @()
foreach ($p in $pages) {
  $html = $re.Replace($master, (SeoBlock $p $false).TrimEnd(), 1)
  $dir  = Join-Path $site ($p.path.Trim("/") -replace "/", "\")
  if ($p.path -ne "/") { New-Item -ItemType Directory -Force $dir | Out-Null }
  $file = Join-Path $dir "index.html"
  [IO.File]::WriteAllText($file, $html, $utf8)
  $urls += "  <url><loc>$origin$($p.path)</loc></url>"
  Write-Host ("wrote {0}" -f $file.Substring($root.Length + 1))
}

# 404 page: the home page marked noindex, so a mistyped URL still shows the site.
$homePage = $pages | Where-Object { $_.path -eq "/" }
[IO.File]::WriteAllText((Join-Path $site "404.html"), $re.Replace($master, (SeoBlock $homePage $true).TrimEnd(), 1), $utf8)
Write-Host "wrote site\404.html"

$sitemap = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n" + ($urls -join "`n") + "`n</urlset>`n"
[IO.File]::WriteAllText((Join-Path $site "sitemap.xml"), $sitemap, $utf8)
Write-Host "wrote site\sitemap.xml"
