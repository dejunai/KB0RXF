param(
    [string]$ZipPath = ".\txt.zip",
    [string]$PostsTemplatePath = ".\first batch set\kb0rxf76radioarchive.posts.WordPress.2026-05-04.xml",
    [string]$AcfJsonPath = ".\acf-v3-bulletproof.json",
    [string]$OutputDir = ".\container experiment",
    [int]$BatchSize = 50,
    [int]$StartingPostId = 2000
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
        try { return $reader.ReadToEnd() }
        finally { $reader.Dispose() }
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

function Get-LabelValue {
    param(
        [string[]]$Lines,
        [string[]]$Labels,
        [int]$Start,
        [int]$End
    )
    for ($i = $Start; $i -lt $End; $i++) {
        foreach ($label in $Labels) {
            if ($Lines[$i] -match ("^\s*" + [regex]::Escape($label) + "\s*:\s*(.+?)\s*$")) {
                return (Normalize-Value $Matches[1])
            }
        }
    }
    return ""
}

function Get-LabelMatch {
    param(
        [string[]]$Lines,
        [string[]]$Labels,
        [int]$Start,
        [int]$End
    )
    for ($i = $Start; $i -lt $End; $i++) {
        foreach ($label in $Labels) {
            if ($Lines[$i] -match ("^\s*(" + [regex]::Escape($label) + ")\s*:\s*(.+?)\s*$")) {
                return [pscustomobject]@{
                    Label = (Normalize-Value $Matches[1])
                    Value = (Normalize-Value $Matches[2])
                }
            }
        }
    }
    return $null
}

function Get-MediaTypeValue {
    param([string]$Label)
    switch -Regex ($Label) {
        "^(Tape|Tapes)$" { return "cassette" }
        "^(CD|CDs|CD-R)$" { return "cd" }
        "^VCR$" { return "vhs" }
        "^Reel$" { return "reel" }
    }
    return ""
}

function Get-AcfFieldMap {
    param([string]$Path)
    $json = Get-Content -Raw -LiteralPath (Resolve-Path $Path)
    $group = $json | ConvertFrom-Json
    $map = @{}
    function Add-Field {
        param($Field)
        if ($Field.name) { $map[$Field.name] = $Field.key }
        if ($Field.PSObject.Properties.Name -contains "sub_fields" -and $Field.sub_fields) {
            foreach ($sub in $Field.sub_fields) { Add-Field $sub }
        }
    }
    foreach ($field in $group.fields) { Add-Field $field }
    return $map
}

function Get-TopLevelAcfNames {
    param([string]$Path)
    $json = Get-Content -Raw -LiteralPath (Resolve-Path $Path)
    $group = $json | ConvertFrom-Json
    return @($group.fields | ForEach-Object { $_.name })
}

function New-ContentRow {
    param([string]$Line)
    $line = Normalize-Value $Line
    if (-not $line) { return $null }

    $row = [ordered]@{
        content_type = "commercial"
        song_artist = @()
        commercial = ""
        segment_type = ""
    }

    if ($line -match "^(?i:COMMERCIALS?)\s*:\s*(.+)$") {
        $row.content_type = "commercial"
        $row.commercial = Normalize-Value $Matches[1]
        return $row
    }

    if ($line -match "^(?i:TRAFFIC|WEATHER|SPORTS|NEWS|BUMPER)\b") {
        $row.content_type = "segment"
        $row.segment_type = $Matches[0].ToLowerInvariant()
        return $row
    }

    if ($line -match "^(.+?)--(.+)$") {
        $row.content_type = "song"
        $row.song_artist = @([ordered]@{
            song = Normalize-Value $Matches[1]
            artist = Normalize-Value $Matches[2]
        })
        return $row
    }

    $row.content_type = "commercial"
    $row.commercial = $line
    return $row
}

function New-ContainerRow {
    param(
        [string]$Kind,
        [string]$Number,
        [string[]]$ContentLines
    )
    $contents = New-Object System.Collections.Generic.List[object]
    foreach ($line in $ContentLines) {
        $row = New-ContentRow $line
        if ($null -ne $row) { $contents.Add($row) }
    }
    $obj = [pscustomobject]@{}
    $obj | Add-Member -NotePropertyName side_disk_other -NotePropertyValue $Kind
    $obj | Add-Member -NotePropertyName a_b_n_none -NotePropertyValue $Number
    $obj | Add-Member -NotePropertyName content_rows -NotePropertyValue ([object[]]@($contents.ToArray()))
    return $obj
}

function Extract-ContainerRows {
    param([string[]]$Lines)
    $rows = New-Object System.Collections.Generic.List[object]
    $markers = New-Object System.Collections.Generic.List[object]

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i].Trim()
        if ($line -match "^(?i:SIDE)\s+([A-D])$") {
            $markers.Add([ordered]@{ index = $i; kind = "side"; number = $Matches[1].ToLowerInvariant() })
        }
        elseif ($line -match "^(?i:DISK|DISC)\s*#?\s*([1-9])\s*:?\s*(.*)$") {
            $markers.Add([ordered]@{ index = $i; kind = "disk"; number = $Matches[1]; inline = (Normalize-Value $Matches[2]) })
        }
    }

    for ($m = 0; $m -lt $markers.Count; $m++) {
        $start = [int]$markers[$m].index + 1
        $end = $Lines.Count
        if ($m + 1 -lt $markers.Count) { $end = [int]$markers[$m + 1].index }
        $content = New-Object System.Collections.Generic.List[string]
        if ($markers[$m].Contains("inline") -and $markers[$m].inline) {
            $content.Add($markers[$m].inline)
        }
        for ($i = $start; $i -lt $end; $i++) {
            $line = Normalize-Value $Lines[$i]
            if ($line) { $content.Add($line) }
        }
        $rows.Add((New-ContainerRow $markers[$m].kind $markers[$m].number @($content)))
    }

    return [object[]]$rows.ToArray()
}

function Split-ShowTalent {
    param([string[]]$Lines, [int]$Start, [int]$End)
    $showNames = New-Object System.Collections.Generic.List[string]
    $talents = New-Object System.Collections.Generic.List[string]

    for ($i = $Start; $i -lt $End; $i++) {
        $line = Normalize-Value $Lines[$i]
        if (-not $line) { continue }
        if ($line -match "^(?i:DISK|DISC)\b") { continue }
        if ($line -match "^(Recorded By|Receiver|Receiver/Tape Deck|Tape Deck|Recorder|Tape|Tapes|CD|CDs|CD-R|VCR|Recording Location|Digitized By|CD Burner|Software)\s*:") { continue }
        if (Test-DateLike $line) { continue }

        foreach ($part in @($line -split "/")) {
            $p = Normalize-Value $part
            if (-not $p) { continue }
            $p = [regex]::Replace($p, "^(?i:Side\s+[A-D]\s*:\s*)", "")
            if (Test-DateLike $p) { continue }
            if ($p -match "^([^:]{2,60})\s*:\s*(.+)$") {
                $talents.Add((Normalize-Value $Matches[1]))
                $showNames.Add((Normalize-Value $Matches[2]))
            }
            else {
                $talents.Add($p)
            }
        }
    }

    return @{
        show_name = Normalize-Value (($showNames | Select-Object -Unique) -join " / ")
        talent_dj = Normalize-Value (($talents | Select-Object -Unique) -join " / ")
    }
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
        recording_category = "broadcast"
        tape_id = $TapeId
        date_recorded = Get-DateFromName $EntryName
        time_utc = ""
        station = ""
        frequency = ""
        station_location = ""
        show_name = ""
        talent_dj = ""
        recorded_by = ""
        receiver = ""
        original_recording_device = ""
        media_type = "cassette"
        media_description = ""
        recording_location = ""
        digitized_by = ""
        digitization_device = ""
        cd_burner = ""
        software = ""
        container = @()
        playback_status = "pending"
        condition_notes = ""
        kb0rxf76_remembers = ""
        sample_30sec = ""
    }

    $headerEnd = $lines.Count
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $trim = $lines[$i].Trim().ToUpperInvariant()
        if ($trim -match "^(SIDE\s+[A-D]|DISK\s*#?\s*[1-9]|DISC\s*#?\s*[1-9])$") {
            $headerEnd = $i
            break
        }
    }

    if ($nonEmpty.Count -gt 0 -and $nonEmpty[0] -notmatch "^TRACK" -and $nonEmpty[0] -notmatch ":\s*$" -and -not (Test-DateLike $nonEmpty[0])) {
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
    for ($i = 1; $i -lt [math]::Min($nonEmpty.Count, 12); $i++) {
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

    $digitizedIndex = $headerEnd
    for ($i = 0; $i -lt $headerEnd; $i++) {
        if ($lines[$i] -match "^\s*Digitized By\s*:") {
            $digitizedIndex = $i
            break
        }
    }

    $talentStart = if ($dateIndex -ge 0) { $dateIndex + 1 } else { 1 }
    $showTalent = Split-ShowTalent $lines $talentStart $digitizedIndex
    $fields.show_name = $showTalent.show_name
    $fields.talent_dj = $showTalent.talent_dj

    $fields.recorded_by = Get-LabelValue $lines @("Recorded By") 0 $digitizedIndex
    $fields.receiver = Get-LabelValue $lines @("Receiver") 0 $digitizedIndex
    $combined = Get-LabelValue $lines @("Receiver/Tape Deck") 0 $digitizedIndex
    if ($combined) {
        $fields.receiver = $combined
        $fields.original_recording_device = $combined
    }
    else {
        $fields.original_recording_device = Get-LabelValue $lines @("Recorder", "Tape Deck", "VCR") 0 $digitizedIndex
    }

    $mediaMatch = Get-LabelMatch $lines @("Tape", "Tapes", "CD", "CDs", "CD-R", "VCR", "Reel") 0 $headerEnd
    if ($null -ne $mediaMatch) {
        $mediaType = Get-MediaTypeValue $mediaMatch.Label
        if ($mediaType) {
            $fields.media_type = $mediaType
        }
        $fields.media_description = $mediaMatch.Value
    }

    $fields.recording_location = Get-LabelValue $lines @("Recording Location") 0 $digitizedIndex
    $fields.digitized_by = Get-LabelValue $lines @("Digitized By") $digitizedIndex $headerEnd
    $fields.digitization_device = Get-LabelValue $lines @("Tape Deck", "VCR", "Recorder") $digitizedIndex $headerEnd
    $fields.cd_burner = Get-LabelValue $lines @("CD Burner") $digitizedIndex $headerEnd
    $fields.software = Get-LabelValue $lines @("Software") $digitizedIndex $headerEnd
    $fields.container = @(Extract-ContainerRows $lines)

    $knownLine = "^(TRACKS?\b|SIDE\s+[A-D]$|DISK\s*#?\s*[1-9]\s*:|DISC\s*#?\s*[1-9]\s*:|Recorded By\s*:|Receiver\s*:|Receiver/Tape Deck\s*:|Tape Deck\s*:|Recorder\s*:|Tape\s*:|Tapes\s*:|CD\s*:|CDs\s*:|CD-R\s*:|VCR\s*:|Reel\s*:|Recording Location\s*:|Digitized By\s*:|CD Burner\s*:|Software\s*:)"
    $leftovers = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $headerEnd; $i++) {
        $line = $lines[$i].Trim()
        if (-not $line) { continue }
        if ($i -lt 3 -and $nonEmpty -contains $line) { continue }
        if ($line -match $knownLine) { continue }
        if ($fields.talent_dj -and $fields.talent_dj.Contains($line)) { continue }
        if ($fields.show_name -and $fields.show_name.Contains($line)) { continue }
        $leftovers.Add($line)
    }
    if ($leftovers.Count -gt 0) {
        $fields.condition_notes = Normalize-Value ($leftovers -join "`n")
    }

    # Auto-classify the recording category based on simple heuristics
    if ($fields.station -match "(?i)dispatch|police|fire|sheriff|patrol|emergency|ems") {
        $fields.recording_category = "scanner"
    }
    elseif ($fields.station -match "(?i)india|bbc|radio exterior|shortwave|international|world service" -or $fields.frequency -match "(?i)khz" -or $fields.time_utc) {
        $fields.recording_category = "shortwave"
    }
    elseif ($fields.station -match "(?i)found tape|unknown content") {
        $fields.recording_category = "other"
    }

    return $fields
}

function Add-PostMeta {
    param(
        [System.Text.StringBuilder]$Builder,
        [string]$Key,
        [AllowNull()][string]$Value
    )
    [void]$Builder.AppendLine("		<wp:postmeta>")
    [void]$Builder.AppendLine("		<wp:meta_key>$(CData $Key)</wp:meta_key>")
    [void]$Builder.AppendLine("		<wp:meta_value>$(CData $Value)</wp:meta_value>")
    [void]$Builder.AppendLine("		</wp:postmeta>")
}

function Add-AcfMeta {
    param(
        [System.Text.StringBuilder]$Builder,
        [hashtable]$FieldMap,
        [string]$Name,
        [AllowNull()][string]$Value
    )
    Add-PostMeta $Builder $Name $Value
    $fieldName = $Name
    if (-not $FieldMap.ContainsKey($fieldName)) {
        if ($fieldName -match "^container_\d+_(.+)$") {
            $fieldName = $Matches[1]
        }
        if ($fieldName -match "^contents_\d+_(.+)$") {
            $fieldName = $Matches[1]
        }
        if ($fieldName -match "^song_artist_\d+_(.+)$") {
            $fieldName = $Matches[1]
        }
    }
    if ($FieldMap.ContainsKey($fieldName)) {
        Add-PostMeta $Builder "_$Name" $FieldMap[$fieldName]
    }
}

function Add-ContainerMeta {
    param(
        [System.Text.StringBuilder]$Builder,
        [hashtable]$FieldMap,
        [object[]]$Rows
    )
    Add-AcfMeta $Builder $FieldMap "container" ([string]$Rows.Count)
    for ($i = 0; $i -lt $Rows.Count; $i++) {
        $row = $Rows[$i]
        Add-AcfMeta $Builder $FieldMap "container_${i}_side_disk_other" $row.side_disk_other
        Add-AcfMeta $Builder $FieldMap "container_${i}_a_b_n_none" $row.a_b_n_none
        Add-AcfMeta $Builder $FieldMap "container_${i}_contents" ([string]$row.content_rows.Count)
        for ($j = 0; $j -lt $row.content_rows.Count; $j++) {
            $content = $row.content_rows[$j]
            Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_content_type" $content.content_type
            if ($content.content_type -eq "song") {
                Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_song_artist" ([string]$content.song_artist.Count)
                for ($k = 0; $k -lt $content.song_artist.Count; $k++) {
                    Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_song_artist_${k}_song" $content.song_artist[$k].song
                    Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_song_artist_${k}_artist" $content.song_artist[$k].artist
                }
            }
            else {
                Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_song_artist" "0"
            }
            if ($content.content_type -eq "commercial") {
                Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_commercial" $content.commercial
            }
            else {
                Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_commercial" ""
            }
            if ($content.content_type -eq "segment") {
                Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_segment_type" $content.segment_type
            }
            else {
                Add-AcfMeta $Builder $FieldMap "container_${i}_contents_${j}_segment_type" ""
            }
        }
    }
}

function Build-Item {
    param(
        $Values,
        [string[]]$TopFields,
        [hashtable]$FieldMap,
        [string]$Title,
        [int]$PostId,
        [string]$PostName,
        [string]$SourceName,
        [string]$SourceText
    )
    $now = "2026-05-06 00:00:00"
    $pubDate = "Wed, 06 May 2026 00:00:00 +0000"
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

    foreach ($field in $TopFields) {
        if ($field -eq "container") {
            Add-ContainerMeta $sb $FieldMap @($Values.container)
            continue
        }
        $value = ""
        if ($Values.Contains($field)) { $value = $Values[$field] }
        Add-AcfMeta $sb $FieldMap $field $value
    }
    Add-PostMeta $sb "_source_txt_file" $SourceName
    Add-PostMeta $sb "_source_txt_full" $SourceText
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

if (-not (Test-Path -LiteralPath $OutputDir)) {
    [void](New-Item -ItemType Directory -Path $OutputDir)
}

$zipResolved = (Resolve-Path $ZipPath).Path
$outResolved = (Resolve-Path $OutputDir).Path
$fieldMap = Get-AcfFieldMap $AcfJsonPath
$topFields = Get-TopLevelAcfNames $AcfJsonPath
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
        $items.Add((Build-Item $values $topFields $fieldMap $title $postId $slug $entry.FullName $text))
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

    $mergedPath = Join-Path $outResolved "merged-container-experiment.xml"
    [System.IO.File]::WriteAllText($mergedPath, $template.Header + ($items -join "") + $template.Footer, $utf8NoBom)

    Write-Host "Converted $($entries.Count) txt files."
    Write-Host "Wrote $($batchFiles.Count) batch files of up to $BatchSize items."
    Write-Host "Merged file: $mergedPath"
}
finally {
    $archive.Dispose()
}
