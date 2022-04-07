# File Integrity Monitor
# Zachery_Thiel
# version_1.1
# Last Modified_2022_04_05


# Changes From 1.0- Added Modularity to now accept specific path to files!!!

# Functions
Function Calculate-File-hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA256
    return $filehash 
}
Function Remove-baseline-If-Already-Exists() {
    $baselineExists = Test-Path -Path "C:\Users\zthie\Desktop\file_integrity_monitor\Files\baseline.txt" #test if baseline.txt exists

    if ($baselineExists) {
        Remove-Item -Path "C:\Users\zthie\Desktop\file_integrity_monitor\Files\baseline.txt" #Delete it
    }
}

#Ask User where the files are stored that they wish to monitor
$monitorpath = Read-Host -prompt "`n Please enter location of files you wish to monitor `n"

# Ask what user wants to do. Create new basline or check against existing.

$response = Read-Host -prompt "`n What would you like to do? `n`n A. Collect new Basline?`n B. Use saved Baseline to monitor files? `n `n Please enter  'A' or 'B'"

###USER INPUT ERROR
###if ($response -ne "A".ToUpper() -and $response -ne "B".ToUpper()) {
###    Write-Host " Try Again...Please Enter either A or B"
###}


# COLLECT NEW BASELINE
if ($response -eq "A".ToUpper()) {
    Remove-baseline-If-Already-Exists #Delete Baseline if already exists

# Collect all files in target folder
    $files = Get-ChildItem -Path "$monitorpath"
    
# For File, calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "$monitorpath\baseline.txt" -Append
    }
    Write-Host "Creating baseline.txt...done `n" -ForegroundColor Cyan
}

# MONITOR FILES USING SAVED BASELINE
elseif ($response -eq "B".ToUpper()){
    $filehashDictionary = @{}
# Load hashes from baseline.txt and store in a dictionary
    $filesPandH = Get-Content -Path "$monitorpath\baseline.txt"
    foreach ($f in $filesPandH) {
        $filehashDictionary.add($f.Split("|")[0], $f.Split("|")[1]) 
    }
# Continuous monitoring
    while ($true) {
        Start-Sleep -Seconds 1
        $files = Get-ChildItem -Path "$monitorpath"
    
# For File, calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-hash $f.FullName
        #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "$monitorpath\baseline.txt" -Append
# Notify if a new file has been created
        if ($null -eq $filehashDictionary[$hash.Path]) {
            #There is no chnage to Baseline
            Write-Host "There is no change to $filehashDictionary[$hash.Path]"
            #Write-Host "$($hash.Path) has been created! `n" -ForegroundColor Green
        }
        else {
            #Notify if a new file has been changed
            if ($filehashDictionary[$hash.Path] -eq $hash.Hash){
                #the file has not changed
    
            }
                else {
                #file has been comprosmised!, Notify the User
                Write-Host "$($hash.Path) has changed!!! `n" -ForegroundColor Yellow
            }
        }
    }
# Check If file has been deleted
    foreach($key in $filehashDictionary.Keys) {
        $baselinefileStillExists = Test-Path -Path $key
        if (-Not $baselinefileStillExists) {
            #One of the baseline files was deleted, notify the User
            Write-Host "$key has been deleted `n" -ForegroundColor Red
        }
    }
}
}




#TODO- Finish error checking of initial user input
# Differential from past files 