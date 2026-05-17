param (
    [string]$TargetDirectory = ".\container experiment"
)

Write-Host "Starting Audio Batch Conversion & Sampling..." -ForegroundColor Cyan
Write-Host "Target Directory: $TargetDirectory"

if (-not (Test-Path $TargetDirectory)) {
    Write-Error "Directory not found: $TargetDirectory"
    exit 1
}

# Ensure ffmpeg is installed/available
if (-not (Get-Command "ffmpeg" -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg is not recognized as a command. Please ensure it is installed and in your system PATH."
    exit 1
}

$wavFiles = Get-ChildItem -Path $TargetDirectory -Filter "*.wav" -Recurse

if ($wavFiles.Count -eq 0) {
    Write-Host "No .wav files found in $TargetDirectory." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($wavFiles.Count) .wav files. Processing..." -ForegroundColor Green

foreach ($file in $wavFiles) {
    $baseName = $file.BaseName
    $dir = $file.DirectoryName
    
    $flacPath = Join-Path $dir "$baseName.flac"
    $mp3SamplePath = Join-Path $dir "${baseName}_sample30s.mp3"

    Write-Host "`nProcessing: $baseName" -ForegroundColor Yellow

    # 1. Convert WAV to FLAC (Preserving Archive Quality)
    if (-not (Test-Path $flacPath)) {
        Write-Host "  -> Creating FLAC master..."
        # -y to overwrite (if needed), -i input, -c:a flac codec, -compression_level 5 (default)
        $flacArgs = "-y", "-i", "`"$($file.FullName)`"", "-c:a", "flac", "`"$flacPath`""
        $process = Start-Process -FilePath "ffmpeg" -ArgumentList $flacArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "  -> FLAC created successfully." -ForegroundColor Green
        } else {
            Write-Error "  -> Failed to create FLAC."
            continue
        }
    } else {
        Write-Host "  -> FLAC already exists, skipping conversion." -ForegroundColor DarkGray
    }

    # 2. Extract 30-second MP3 sample from the new FLAC
    if (-not (Test-Path $mp3SamplePath)) {
        Write-Host "  -> Creating 30-second MP3 sample..."
        # -t 30 limits duration to 30 seconds, -b:a 128k sets bitrate for web
        $mp3Args = "-y", "-i", "`"$flacPath`"", "-t", "30", "-c:a", "libmp3lame", "-b:a", "128k", "`"$mp3SamplePath`""
        $process = Start-Process -FilePath "ffmpeg" -ArgumentList $mp3Args -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "  -> MP3 sample created successfully." -ForegroundColor Green
        } else {
            Write-Error "  -> Failed to create MP3 sample."
        }
    } else {
        Write-Host "  -> MP3 sample already exists, skipping." -ForegroundColor DarkGray
    }
}

Write-Host "`nBatch complete! Archival FLACs and 30-second web samples are ready." -ForegroundColor Cyan
