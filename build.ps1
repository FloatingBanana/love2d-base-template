# This is the first time I ever touched Powershell in my life,
# so the  stability and efficiency of this script is not guaranted

$PLATFORM = $args[0]
$NAME = 'ld50'
$LOVEFILE = '_build\' + $NAME + '.love'

function print_info([string]$text) {
    Write-Host -NoNewline -ForegroundColor Blue $text
}

function print_success([string]$text) {
    Write-Host -ForegroundColor Green $text
}

function print_error([string]$text) {
    Write-Host -ForegroundColor Red $text
}

function build_lovefile() {
    print_info -text "Building love project file: "

    if (Test-Path $LOVEFILE) {
        Remove-Item -Force -Path $LOVEFILE
    }

    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::NoCompression
    [System.IO.Compression.ZipFile]::CreateFromDirectory('src', $LOVEFILE, $compressionLevel, $false)

    if ($?) {
        print_success -text "Done"
    }
    else {
        print_error -text "Failed"
		exit 1
    }
}

function build_linux() {
    print_info -text "Building for Linux: "
    print_error -text "Cross platform build from Windows to Linux is unavailable"
}

function build_windows() {
    print_info "Building for Windows: "

    if (Test-Path '_build\windows') {
        Remove-Item -Force -Path '_build\windows' -Recurse
    }

    try {
        mkdir '_build\windows' | Out-Null
	    cmd /c copy /b "bin\love-windows\love.exe+_build\${NAME}.love" "_build\windows\${NAME}.exe" | Out-Null
	    Copy-Item -Path 'bin\love-windows\*.dll' -Destination '_build\windows\' -Recurse
	    Copy-Item -Path 'bin\love-windows\license.txt' -Destination '_build\windows\license.txt'
    }
    catch {
        print_error "Failed"
        return
    }
    
    print_success "Done"
}

function build_web() {
    print_info -text "Building for web browser: "

    if (Test-Path '_build\web') {
        Remove-Item -Force -Path '_build\web' -Recurse
    }

    if (cmd /c npx love.js -t $NAME -m 62914560 $LOVEFILE '_build\web') {
        print_success -text "Done"
    }
    else {
        print_error -text "Failed"
    }
}

if (!(Test-Path '_build')) {
    mkdir '_build'
}
build_lovefile

switch ($PLATFORM) {
    'windows' { 
        build_windows
     }
     'linux' { 
        build_linux
     }
     'web' {
        build_web
     }
     'all' {
        print_info -text 'Building for all platforms'
        Write-Host "" # New Line
        build_windows
        build_web
     }
    Default {
        
    }
}