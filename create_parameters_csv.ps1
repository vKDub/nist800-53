param (
    [Parameter(Mandatory=$false)]
    [ValidatePattern("parameters.csv$")]
    [string]$File = ".\parameters.csv"
)

# PSCustomObject value
$AllParameters = @()

# Iterate through all controls to find parameters
foreach ($Family in $BaselineProfileFamilies) {
    foreach ($FamilyControl in $Family.controls) {
        $FamilyControl.params | ForEach-Object {
            if ($_.id) {
                if ($_.id -like "*_odp*") {
                    if ($_.Select -and $_.Select.'how-many') {
                        # Parameter for how-many and choice
                        $ParameterId = $_.id
                        $ParameterGuideline = "$($_.select.'how-many'): $($_.select.choice -join ", ")"
                        $Object = [PSCustomObject]@{
                            ParameterId = $ParameterId
                            ParameterValue = ""
                            ParameterGuideline = $ParameterGuideline.trim(";")
                        }
                        $AllParameters += $Object
                    } elseif ($_.Select -and !$_.Select.'how-many') {
                        # Parameter for choice
                        $ParameterId = $_.id
                        $ParameterGuideline = "choose-one: $($_.select.choice -join " or ")"
                        $Object = [PSCustomObject]@{
                            ParameterId = $ParameterId
                            ParameterValue = ""
                            ParameterGuideline = $ParameterGuideline.trim(";")
                        }
                        $AllParameters += $Object
                    } else {
                        # Parameter for single item
                        $ParameterId = $_.id
                        $ParameterGuideline = $_.guidelines.prose
                        $Object = [PSCustomObject]@{
                            ParameterId = $ParameterId
                            ParameterValue = ""
                            ParameterGuideline = $ParameterGuideline.trim(";")
                        }
                        $AllParameters += $Object
                    }
                } else {
                    # Parameter for single item
                    $ParameterId = $_.id
                    $ParameterGuideline = $_.label
                    $Object = [PSCustomObject]@{
                        ParameterId = $ParameterId
                        ParameterValue = ""
                        ParameterGuideline = $ParameterGuideline.trim(";")
                    }
                    $AllParameters += $Object
                }
            }
        }
    }
} 

# Output parameters.csv file to current diectory
Write-Host -BackgroundColor Yellow -ForegroundColor Black "By default, parameters.csv will output into the current directory of your PowerShell session. You can run the create_project_csv.ps1 with a -File parameter to change output location but it must end in parameters.csv"
$AllParameters | ConvertTo-Csv | Out-File $Path
