# Create a new Task Sequence
$TS = New-CMTaskSequence -CustomTaskSequence -Name "Create TS Via PowerShell"
 
# Create the first group
$Group1 = New-CMTaskSequenceGroup -Name "First Group"
Add-CMTaskSequenceStep -InsertStepStartIndex 0 -TaskSequenceName $TS.Name -Step $Group1
 
# Create the first Run Command Line action
$Step1 = New-CMTaskSequenceStepRunCommandLine -StepName "Run Command 1" -CommandLine "cmd.exe /c"
Set-CMTaskSequenceGroup -TaskSequenceName $TS.Name -StepName $Group1.Name -AddStep $Step1 -InsertStepStartIndex 0
 
# Create the second group
$Group2 = New-CMTaskSequenceGroup -Name "Second Group"
Add-CMTaskSequenceStep -InsertStepStartIndex 1 -TaskSequenceName $TS.Name -Step $Group2
 
# Create the second Run Command Line action
$Step2 = New-CMTaskSequenceStepRunCommandLine -StepName "Run Command 2" -CommandLine "cmd.exe /c"
Set-CMTaskSequenceGroup -TaskSequenceName $TS.Name -StepName $Group2.Name -AddStep $Step2 -InsertStepStartIndex 0