# Local preview server (no Node/Python needed). Mirrors how static hosts serve site/:
#   /services/  -> site/services/index.html      /services -> same
#   unknown URL -> site/404.html with a 404 status
param([int]$Port = 8765, [string]$Root = "$PSScriptRoot\site")
$mime = @{ ".html"="text/html; charset=utf-8"; ".js"="text/javascript"; ".css"="text/css"; ".svg"="image/svg+xml"; ".png"="image/png"; ".jpg"="image/jpeg"; ".jpeg"="image/jpeg"; ".webp"="image/webp"; ".woff2"="font/woff2"; ".ico"="image/x-icon"; ".json"="application/json"; ".txt"="text/plain"; ".xml"="application/xml" }
$l = New-Object Net.HttpListener; $l.Prefixes.Add("http://localhost:$Port/"); $l.Start()
Write-Host "Serving $Root on http://localhost:$Port/"
$rootFull = [IO.Path]::GetFullPath($Root)
while ($l.IsListening) {
  $c = $l.GetContext(); $p = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath)
  $f = Join-Path $Root ($p.TrimStart("/") -replace "/", "\")
  if (Test-Path $f -PathType Container) { $f = Join-Path $f "index.html" }
  $status = 200
  if (-not ((Test-Path $f -PathType Leaf) -and ([IO.Path]::GetFullPath($f)).StartsWith($rootFull))) { $f = Join-Path $Root "404.html"; $status = 404 }
  if (Test-Path $f -PathType Leaf) {
    $b = [IO.File]::ReadAllBytes($f); $e = [IO.Path]::GetExtension($f).ToLower()
    $c.Response.StatusCode = $status
    $c.Response.ContentType = if ($mime[$e]) { $mime[$e] } else { "application/octet-stream" }
    $c.Response.ContentLength64 = $b.Length; $c.Response.OutputStream.Write($b, 0, $b.Length)
  } else { $c.Response.StatusCode = 404 }
  $c.Response.Close()
}
