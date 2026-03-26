$inputFile = "d:\GITHUB\PRJ301_GROUP4_SELLING_TICKET\SellingTicketJava\database\schema\full_reset_seed.sql"
$lines = [System.IO.File]::ReadAllLines($inputFile, [System.Text.Encoding]::UTF8)
Write-Host "Original line count: $($lines.Count)"

$result = [System.Collections.Generic.List[string]]::new()
$prevBlank = $false

foreach ($line in $lines) {
    $trimmed = $line.TrimStart()
    
    # Keep section header comments (lines with === patterns)
    if ($trimmed -match '^--\s*={3,}') {
        $result.Add($line)
        $prevBlank = $false
        continue
    }
    
    # Remove all other comment lines
    if ($trimmed -match '^--') {
        continue
    }
    
    # Collapse consecutive blank lines into one
    if ($trimmed -eq '') {
        if (-not $prevBlank) {
            $result.Add($line)
            $prevBlank = $true
        }
        continue
    }
    
    # Normal line
    $result.Add($line)
    $prevBlank = $false
}

# Fix the PRINT statement: 23 -> 24
$finalLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in $result) {
    if ($line -match "All 23 tables created") {
        $finalLines.Add($line -replace "All 23 tables", "All 24 tables")
    } else {
        $finalLines.Add($line)
    }
}

$content = $finalLines -join "`r`n"
[System.IO.File]::WriteAllText($inputFile, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Final line count: $($finalLines.Count)"
Write-Host "Done!"
