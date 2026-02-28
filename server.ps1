$Path = "c:\Users\user\Desktop\ALVINE BARAKA\WEB PROJECTS\registration"
$Port = 8080

$HttpListener = New-Object System.Net.HttpListener
$HttpListener.Prefixes.Add("http://localhost:$Port/")
$HttpListener.Start()

Write-Host "Server running at http://localhost:$Port/"

try {
    while ($HttpListener.IsListening) {
        $Context = $HttpListener.GetContext()
        $Request = $Context.Request
        $Response = $Context.Response
        
        $LocalPath = $Request.Url.LocalPath
        if ($LocalPath -eq "/") { $LocalPath = "/index.html" }
        $FilePath = Join-Path $Path $LocalPath
        
        if (Test-Path $FilePath -PathType Leaf) {
            $Content = [System.IO.File]::ReadAllBytes($FilePath)
            $Response.ContentLength64 = $Content.Length
            $Response.SendChunked = $false
            
            if ($FilePath -match "\.html$") { $Response.ContentType = "text/html" }
            elseif ($FilePath -match "\.js$") { $Response.ContentType = "application/javascript" }
            elseif ($FilePath -match "\.css$") { $Response.ContentType = "text/css" }
            
            $Response.OutputStream.Write($Content, 0, $Content.Length)
        } else {
            $Response.StatusCode = 404
        }
        $Response.Close()
    }
} finally {
    $HttpListener.Stop()
}
