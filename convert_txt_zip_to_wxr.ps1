param(
    [string]$ZipPath = ".\txt.zip",
    [string]$PostsTemplatePath = ".\kb0rxf76radioarchive.posts.WordPress.2026-05-04.xml",
    [string]$FieldsPath = ".\kb0rxf76radioarchive.fields.WordPress.2026-05-04.xml",
    [string]$OutputDir = ".",
    [int]$BatchSize = 50,
    [int]$StartingPostId = 1000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Web

function Read-ZipEntryText {
    param([System.IO.Compression.ZipArchiveEntry]$Entry)
    $stream = $Entry.Open()
    try {
        $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8, $true)
        try {
            return $reader.ReadToEnd()
        }
        finally {
            $reader.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
}

function CData {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) { $Value = "" }
    return "<![CDATA[$($Value -replace '\]\]>', ']]]]><![CDATA[>')]]>"
}

function XmlText {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) { $Value = "" }
    return [System.Security.SecurityElement]::Escape($Value)
}

function Normalize-Value {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) { return "" }
    $v = $Value -replace "`r`n", "`n"
    $v = $v -replace "`r", "`n"
    $v = $v -replace "[`t ]{2,}", " "
    $v = $v -replace "(?m)^ +", ""
    return $v.Trim()
}

function Normalize-Date {
    param([string]$Value)
    $v = Normalize-Value $Value
    $v = $v -replace '^Circa-', 'Circa '
    return $v
}

function Slugify {
    param([string]$Value)
    $slug = $Value.ToLowerInvariant()
    $slug = [System.Text.RegularExpressions.Regex]::Replace($slug, "[^a-z0-9]+", "-")
    $slug = $slug.Trim("-")
    if ($slug.Length -gt 180) { $slug = $slug.Substring(0, 180).Trim("-") }
    return $slug
}

function Get-DateFromName {
    param([string]$Name)
    $matches = [System.Text.RegularExpressions.Regex]::Matches($Name, "\[([^\]]+)\]")
    foreach ($m in $matches) {
        $value = $m.Groups[1].Value
        if ($value -ne "Notes") { return (Normalize-Date $value) }
    }
    return ""
}

function Get-StationFromName {
    param([string]$Name)
    $base = [System.IO.Path]::GetFileNameWithoutExtension($Name)
    $base = [System.Text.RegularExpressions.Regex]::Replace($base, "\s*\[[^\]]+\]", "")
    $base = [System.Text.RegularExpressions.Regex]::Replace($base, "^ZZZ\s+", "")
    return (Normalize-Value $base)
}

function Split-StationLine {
    param([string]$Line)
    $line = Normalize-Value $Line
    $result = @{
        station = ""
        station_location = ""
        frequency = ""
    }
    if ($line -match "^(.*?),\s*((?:[0-9.]+\s*(?:kHz|MHz)(?:\s*(?:AM|FM|USB|LSB|DRM))?)|(?:Unknown Frequency(?:,\s*(?:AM|FM|USB|LSB|DRM))?))$") {
        $result.frequency = $Matches[2].Trim()
        $line = $Matches[1].Trim()
    }
    $parts = @($line -split ",\s*")
    if ($parts.Count -gt 1) {
        $result.station = $parts[0].Trim()
        $result.station_location = (($parts | Select-Object -Skip 1) -join ", ").Trim()
    }
    else {
        $result.station = $line
    }
    return $result
}

function Test-DateLike {
    param([string]$Value)
    $v = Normalize-Value $Value
    return ($v -match "^(?:Circa[- ]|Summer\b|Spring\b|Fall\b|Winter\b|[0-9]{4}\b|[0-9]{1,2}-[0-9]{4}\b|[0-9]{1,2}-[0-9]{1,2}-[0-9]{2,4}\b)")
}

function Extract-Side {
    param(
        [string[]]$Lines,
        [string]$StartMarker,
        [string[]]$StopMarkers
    )
    $start = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i].Trim() -ieq $StartMarker) {
            $start = $i + 1
            break
        }
    }
    if ($start -lt 0) { return "" }
    $end = $Lines.Count
    for ($i = $start; $i -lt $Lines.Count; $i++) {
        if ($StopMarkers -contains $Lines[$i].Trim().ToUpperInvariant()) {
            $end = $i
            break
        }
    }
    return (Normalize-Value (($Lines[$start..($end - 1)]) -join "`n"))
}

function Get-LabelValue {
    param(
        [string[]]$Lines,
        [string]$Label,
        [int]$Start,
        [int]$End
    )
    for ($i = $Start; $i -lt $End; $i++) {
        if ($Lines[$i] -match ("^\s*" + [regex]::Escape($Label) + "\s*:\s*(.+?)\s*$")) {
            return (Normalize-Value $Matches[1])
        }
    }
    return ""
}

function Get-FieldList {
    param([string]$Path)
    $text = [System.IO.File]::ReadAllText((Resolve-Path $Path))
    $fields = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($text, "<excerpt:encoded><!\[CDATA\[(.*?)\]\]></excerpt:encoded>")) {
        $fields.Add($m.Groups[1].Value)
    }
    return $fields
}

function Parse-Note {
    param(
        [string]$EntryName,
        [string]$Text,
        [string]$TapeId
    )
    $text = $Text -replace "`r`n", "`n"
    $text = $text -replace "`r", "`n"
    $lines = @($text -split "`n")
    $nonEmpty = @($lines | Where-Object { $_.Trim() -ne "" })

    $fields = [ordered]@{
        tape_id = $TapeId
        date_recorded = Get-DateFromName $EntryName
        time_utc = ""
        station = ""
        frequency = ""
        station_location = ""
        talent_dj = ""
        recorded_by = ""
        receiver = ""
        original_tape_deck = ""
        tape = ""
        recording_location = ""
        digitized_by = ""
        digitization_tape_deck = ""
        cd_burner = ""
        software = ""
        side_a = ""
        side_b = ""
        playback_status = "pending"
        condition_notes = ""
        kb0rxf76_remembers = ""
        sample_30sec = ""
    }

    $headerEnd = $lines.Count
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $trim = $lines[$i].Trim().ToUpperInvariant()
        if ($trim -in @("SIDE A", "SIDE B")) {
            $headerEnd = $i
            break
        }
    }

    if ($nonEmpty.Count -gt 0 -and $nonEmpty[0] -notmatch "^TRACK" -and $nonEmpty[0] -notmatch ":\s*$") {
        $stationParts = Split-StationLine $nonEmpty[0]
        $fields.station = $stationParts.station
        $fields.station_location = $stationParts.station_location
        $fields.frequency = $stationParts.frequency
    }
    else {
        $stationParts = Split-StationLine (Get-StationFromName $EntryName)
        $fields.station = $stationParts.station
        $fields.station_location = $stationParts.station_location
        $fields.frequency = $stationParts.frequency
    }

    $dateIndex = -1
    for ($i = 1; $i -lt [math]::Min($nonEmpty.Count, 10); $i++) {
        if (Test-DateLike $nonEmpty[$i]) {
            $dateIndex = $i
            break
        }
    }
    if ($dateIndex -ge 0) {
        $dateLine = Normalize-Date $nonEmpty[$dateIndex]
        if ($dateLine) { $fields.date_recorded = $dateLine }
        if ($dateLine -match "(between\s+.*?UTC|[0-9]{3,4}(?:-[0-9]{3,4})?\s*UTC)") {
            $fields.time_utc = Normalize-Value $Matches[1]
        }
    }
    $talentIndex = $dateIndex + 1
    if ($dateIndex -ge 0 -and $nonEmpty.Count -gt $talentIndex -and $nonEmpty[$talentIndex] -notmatch ":" -and $nonEmpty[$talentIndex] -notmatch "^TRACK") {
        $fields.talent_dj = Normalize-Value $nonEmpty[$talentIndex]
    }

    $digitizedIndex = $headerEnd
    for ($i = 0; $i -lt $headerEnd; $i++) {
        if ($lines[$i] -match "^\s*Digitized By\s*:") {
            $digitizedIndex = $i
            break
        }
    }

    $fields.recorded_by = Get-LabelValue $lines "Recorded By" 0 $digitizedIndex
    $fields.receiver = Get-LabelValue $lines "Receiver" 0 $digitizedIndex
    $combined = Get-LabelValue $lines "Receiver/Tape Deck" 0 $digitizedIndex
    if ($combined) {
        $fields.receiver = $combined
        $fields.original_tape_deck = $combined
    }
    else {
        $fields.original_tape_deck = Get-LabelValue $lines "Tape Deck" 0 $digitizedIndex
    }
    $fields.tape = Get-LabelValue $lines "Tape" 0 $digitizedIndex
    $fields.recording_location = Get-LabelValue $lines "Recording Location" 0 $digitizedIndex

    $fields.digitized_by = Get-LabelValue $lines "Digitized By" $digitizedIndex $headerEnd
    $fields.digitization_tape_deck = Get-LabelValue $lines "Tape Deck" $digitizedIndex $headerEnd
    $fields.cd_burner = Get-LabelValue $lines "CD Burner" $digitizedIndex $headerEnd
    $fields.software = Get-LabelValue $lines "Software" $digitizedIndex $headerEnd

    $fields.side_a = Extract-Side $lines "SIDE A" @("SIDE B")
    $fields.side_b = Extract-Side $lines "SIDE B" @("SIDE A")

    $knownLine = "^(TRACKS?\b|SIDE A$|SIDE B$|Recorded By\s*:|Receiver\s*:|Receiver/Tape Deck\s*:|Tape Deck\s*:|Tape\s*:|Recording Location\s*:|Digitized By\s*:|CD Burner\s*:|Software\s*:)"
    $leftovers = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $headerEnd; $i++) {
        $line = $lines[$i].Trim()
        if (-not $line) { continue }
        if ($i -lt 3 -and $nonEmpty -contains $line) { continue }
        if ($line -match $knownLine) { continue }
        $leftovers.Add($line)
    }
    if ($fields.side_a -eq "" -and $fields.side_b -eq "") {
        $fields.condition_notes = Normalize-Value (($lines | Where-Object { $_.Trim() -ne "" }) -join "`n")
    }
    elseif ($leftovers.Count -gt 0) {
        $fields.condition_notes = Normalize-Value ($leftovers -join "`n")
    }

    return $fields
}

function Build-Item {
    param(
        $Values,
        [System.Collections.Generic.List[string]]$FieldNames,
        [string]$Title,
        [int]$PostId,
        [string]$PostName,
        [string]$SourceName
    )
    $now = "2026-05-04 00:00:00"
    $pubDate = "Mon, 04 May 2026 00:00:00 +0000"
    $url = "https://kb0rxf.org/$PostName/"
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("		<item>")
    [void]$sb.AppendLine("		<title>$(CData $Title)</title>")
    [void]$sb.AppendLine("		<link>$(XmlText $url)</link>")
    [void]$sb.AppendLine("		<pubDate>$pubDate</pubDate>")
    [void]$sb.AppendLine("		<dc:creator>$(CData 'dejunai')</dc:creator>")
    [void]$sb.AppendLine("		<guid isPermaLink=""false"">$(XmlText "https://kb0rxf.org/?p=$PostId")</guid>")
    [void]$sb.AppendLine("		<description></description>")
    [void]$sb.AppendLine("		<content:encoded><![CDATA[]]></content:encoded>")
    [void]$sb.AppendLine("		<excerpt:encoded><![CDATA[]]></excerpt:encoded>")
    [void]$sb.AppendLine("		<wp:post_id>$PostId</wp:post_id>")
    [void]$sb.AppendLine("		<wp:post_date>$(CData $now)</wp:post_date>")
    [void]$sb.AppendLine("		<wp:post_date_gmt>$(CData $now)</wp:post_date_gmt>")
    [void]$sb.AppendLine("		<wp:post_modified>$(CData $now)</wp:post_modified>")
    [void]$sb.AppendLine("		<wp:post_modified_gmt>$(CData $now)</wp:post_modified_gmt>")
    [void]$sb.AppendLine("		<wp:comment_status>$(CData 'open')</wp:comment_status>")
    [void]$sb.AppendLine("		<wp:ping_status>$(CData 'open')</wp:ping_status>")
    [void]$sb.AppendLine("		<wp:post_name>$(CData $PostName)</wp:post_name>")
    [void]$sb.AppendLine("		<wp:status>$(CData 'publish')</wp:status>")
    [void]$sb.AppendLine("		<wp:post_parent>0</wp:post_parent>")
    [void]$sb.AppendLine("		<wp:menu_order>0</wp:menu_order>")
    [void]$sb.AppendLine("		<wp:post_type>$(CData 'post')</wp:post_type>")
    [void]$sb.AppendLine("		<wp:post_password>$(CData '')</wp:post_password>")
    [void]$sb.AppendLine("		<wp:is_sticky>0</wp:is_sticky>")
    [void]$sb.AppendLine("		<category domain=""category"" nicename=""uncategorized"">$(CData 'Uncategorized')</category>")

    foreach ($field in $FieldNames) {
        $value = ""
        if ($Values.Contains($field)) { $value = $Values[$field] }
        [void]$sb.AppendLine("		<wp:postmeta>")
        [void]$sb.AppendLine("		<wp:meta_key>$(CData $field)</wp:meta_key>")
        [void]$sb.AppendLine("		<wp:meta_value>$(CData $value)</wp:meta_value>")
        [void]$sb.AppendLine("		</wp:postmeta>")
        [void]$sb.AppendLine("		<wp:postmeta>")
        [void]$sb.AppendLine("		<wp:meta_key>$(CData "_$field")</wp:meta_key>")
        [void]$sb.AppendLine("		<wp:meta_value>$(CData "field_$field")</wp:meta_value>")
        [void]$sb.AppendLine("		</wp:postmeta>")
    }
    [void]$sb.AppendLine("		<wp:postmeta>")
    [void]$sb.AppendLine("		<wp:meta_key>$(CData '_source_txt_file')</wp:meta_key>")
    [void]$sb.AppendLine("		<wp:meta_value>$(CData $SourceName)</wp:meta_value>")
    [void]$sb.AppendLine("		</wp:postmeta>")
    [void]$sb.AppendLine("		</item>")
    return $sb.ToString()
}

function Get-HeaderAndFooter {
    param([string]$Path)
    $text = [System.IO.File]::ReadAllText((Resolve-Path $Path))
    $firstItem = [regex]::Match($text, "(?s)\s*<item>")
    $lastItem = [regex]::Matches($text, "(?s)</item>") | Select-Object -Last 1
    if (-not $firstItem.Success -or $null -eq $lastItem) {
        throw "Could not locate item boundaries in $Path"
    }
    return @{
        Header = $text.Substring(0, $firstItem.Index)
        Footer = $text.Substring($lastItem.Index + $lastItem.Length)
    }
}

$zipResolved = (Resolve-Path $ZipPath).Path
$outResolved = (Resolve-Path $OutputDir).Path
$fieldNames = Get-FieldList $FieldsPath
$template = Get-HeaderAndFooter $PostsTemplatePath

$archive = [System.IO.Compression.ZipFile]::OpenRead($zipResolved)
try {
    $entries = @(
        $archive.Entries |
            Where-Object { $_.FullName -like "*.txt" -and $_.Length -gt 0 } |
            Sort-Object FullName
    )
    $items = New-Object System.Collections.Generic.List[string]
    $index = 1
    foreach ($entry in $entries) {
        $tapeId = "T-{0:D4}" -f $index
        $text = Read-ZipEntryText $entry
        $values = Parse-Note $entry.FullName $text $tapeId
        $titleParts = @($values.tape_id)
        if ($values.station) { $titleParts += $values.station } else { $titleParts += (Get-StationFromName $entry.FullName) }
        if ($values.date_recorded) { $titleParts += $values.date_recorded }
        $title = $titleParts -join " | "
        $slug = Slugify $title
        $postId = $StartingPostId + $index - 1
        $items.Add((Build-Item $values $fieldNames $title $postId $slug $entry.FullName))
        $index++
    }

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    $batchFiles = New-Object System.Collections.Generic.List[string]
    for ($offset = 0; $offset -lt $items.Count; $offset += $BatchSize) {
        $batchNumber = [int]([math]::Floor($offset / $BatchSize) + 1)
        $batchName = "batch_{0:D2}.xml" -f $batchNumber
        $batchPath = Join-Path $outResolved $batchName
        $count = [math]::Min($BatchSize, $items.Count - $offset)
        $body = ($items.GetRange($offset, $count) -join "")
        [System.IO.File]::WriteAllText($batchPath, $template.Header + $body + $template.Footer, $utf8NoBom)
        $batchFiles.Add($batchPath)
    }

    $mergedPath = Join-Path $outResolved "merged.xml"
    [System.IO.File]::WriteAllText($mergedPath, $template.Header + ($items -join "") + $template.Footer, $utf8NoBom)

    Write-Host "Converted $($entries.Count) txt files."
    Write-Host "Wrote $($batchFiles.Count) batch files of up to $BatchSize items."
    Write-Host "Merged file: $mergedPath"
}
finally {
    $archive.Dispose()
}
