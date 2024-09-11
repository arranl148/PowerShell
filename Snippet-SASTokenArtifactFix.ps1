$artifactsLocationSasToken = "?sv=2023-08-03&se=2024-03-27TBaF4gBKb8E%2BeW08BK2M%3D"

## Option1
# Check if the SAS token is missing a question mark at the start and add it if it is
if ($artifactsLocationSasToken.Substring(0, 1) -ne '?') {
    $artifactsLocationSasToken = "?$artifactsLocationSasToken"
}

## Option 2
# Check if the SAS token is missing a question mark at the start and add it if it is
if ( -not ($artifactsLocationSasToken.StartsWith("?"))) {
        $artifactsLocationSasToken = "?$artifactsLocationSasToken"


############# Actual
#Checks if the SAS token starts with a ? and if it doesn't, add one    
    if ($ArtifactsLocationSasToken.Substring(0, 1) -ne '?') {
        $ArtifactsLocationSasToken = "?$ArtifactsLocationSasToken"
    }

