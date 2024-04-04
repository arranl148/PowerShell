$ArtifactsLocationSasToken = "sv=test"
    # Check if the SAS token is missing a question mark at the start and add it if it is
    if ( -not ($artifactsLocationSasToken.StartsWith("?"))) {
        $artifactsLocationSasToken = "?$artifactsLocationSasToken"
    }
    $ArtifactsLocationSasToken