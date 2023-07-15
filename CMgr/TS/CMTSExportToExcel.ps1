<# 
 .SYNOPSIS 
     Document the selected SCCM task sequence in Excel
 
 .DESCRIPTION 
     Collections created:
        The Excel sheet will give you seven columns:
        - Id of the task
        - Name of the task
        - Type of the task (Step or group). The name and type are bold if group
        - The description
        - If there is condition on the task (Yes or No)
        - If Continue on error is checked (Yes or No)
		- If Step / Group is disabled (Yes or No)
        - The variables assigned to the step (For now issue with the formatting of the variables)

    
 .PARAMETER SiteServer
    Your site server name. Mandatory

 .PARAMETER SiteCode
    Your site code. Mandatory

 .PARAMETER TSName
    The name of the TS you want to export. Mandatory

 .NOTES 
     Author : Gregory Bouchu
     Website: http://microsoft-desktop.com/
     Twitter: @gbouchu

 .VERSION
    1.0: Still issue with Variables formatting
 
 .UPDATE
	29/06/2018: 
	1.1: Added Enabled Column

 .EXAMPLE 
     CMTSExportToExcel -Siteserver SCCM01 -Sitecode LAB -TSName Deployment_windows10

  #>

Param (
	[Parameter(Mandatory = $True, HelpMessage = "Please Enter Primary Server Site Server")]
	$SiteServer,
	[Parameter(Mandatory = $True, HelpMessage = "Please Enter Primary Server Site code")]
	$SiteCode,
	[Parameter(Mandatory = $True, HelpMessage = "Please Enter the name of the Task sequence you want to export")]
	$TSName
)


$XMLFile = $TSName + ".xml"
$path = "C:\Temp\"
$Pathfile = $path + $XMLFile

If (!(test-path $path))
{
	New-Item -ItemType Directory -Force -Path $path
}

# Generate the xml file
$TS = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -ErrorAction Stop | where Name -EQ $TSName
$TS.Get()
[System.Management.ManagementBaseObject]$TS | Out-Null
$TaskSequence = Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Name "GetSequence" -ArgumentList $TS -ErrorAction Stop
[System.Management.ManagementBaseObject]$TaskSequence | Out-Null
$TaskSequenceResult = Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequence -ComputerName $SiteServer -Name "SaveToXml" -ArgumentList $TaskSequence.TaskSequence -ErrorAction Stop
$TaskSequenceXML = [xml]$TaskSequenceResult.ReturnValue
$TaskSequenceXML.Save($pathfile)

$lines = Get-Content $pathfile
[xml]$xml = $lines

#Create excel COM object
$excel = New-Object -ComObject excel.application

#Make Visible
$excel.Visible = $True

# Add a workbook
$workbook = $excel.Workbooks.Add()

# Connect to worksheet, rename and make it active
$TSSheet = $workbook.Worksheets.Item(1)
$TSSheet.Name = "Export_TS"
$TSSheet.Activate() | Out-Null

# Create a Title for the first worksheet and adjust the font
$row = 1
$Column = 1
$TSSheet.Cells.Item($row, $column) = $TSName

$range = $TSSheet.Range("a1", "I1")
$range = $TSSheet.Range("a1", "H1")
$range.Merge() | Out-Null
$range.VerticalAlignment = -4160

$TSSheet.Cells.Item($row, $column).Font.Size = 20
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Name = "Cooper Black"
$TSSheet.Cells.Item($row, $column).Font.ThemeFont = 2
$TSSheet.Cells.Item($row, $column).Font.ThemeColor = 2
$TSSheet.Cells.Item($row, $column).Font.ColorIndex = 2
$TSSheet.Cells.Item($row, $column).Font.Color = 2
$TSSheet.Cells.Item($row, $column).Interior.ColorIndex = 41
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108

# Increment row
$row++
$initalRow = $row

# Create columns
$TSSheet.Cells.Item($row, $column) = 'ID'
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Size = 16
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108
$Column++
$TSSheet.Cells.Item($row, $column) = 'Name'
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Size = 16
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108
$Column++
$TSSheet.Cells.Item($row, $column) = 'Type'
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Size = 16
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108
$Column++
$TSSheet.Cells.Item($row, $column) = 'Description'
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Size = 16
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108
$Column++
$TSSheet.Cells.Item($row, $column) = 'Condition'
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Size = 16
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108
$Column++
$TSSheet.Cells.Item($row, $column) = 'Continue on error'
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Size = 16
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108
$Column++
$TSSheet.Cells.Item($row, $column) = 'Enabled'
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Size = 16
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108
$Column++
$TSSheet.Cells.Item($row, $column) = 'Variable'
$TSSheet.Cells.Item($row, $column).Font.Bold = $True
$TSSheet.Cells.Item($row, $column).Font.Size = 16
$TSSheet.Cells($row, $column).HorizontalAlignment = -4108
$Column++

$i = 0

foreach ($line in $lines)
{
	$Result = New-Object psobject -Property @{
		ID			     = ""
		Type			 = ""
		Name			 = ""
		description	     = ""
		condition	     = ""
		ContinueOnError  = ""
		Disable		     = ""
	}
	
	if ($line -like "*group name=*")
	{
		$i = $i + 1
		$row++
		$result.ID = $i
		$line.trim() | Out-Null
		$line = $line.Substring($line.IndexOf('"') + 1)
		$line = $line.Substring(0, $line.IndexOf('"'))
		$result.Name = $line
		$Result.Type = "Group"
		$TSSheet.Cells.Item($row, "A") = $i
		$TSSheet.Cells.Item($row, "A").font.bold = $true
		$TSSheet.Cells.Item($row, "A").font.size = 12
		$TSSheet.Cells.Item($row, "B") = $result.name
		$TSSheet.Cells.Item($row, "B").font.bold = $true
		$TSSheet.Cells.Item($row, "B").font.size = 12
		$TSSheet.Cells.Item($row, "C") = $Result.Type
		$TSSheet.Cells.Item($row, "C").font.bold = $true
		$TSSheet.Cells.Item($row, "C").font.size = 12
		$TSSheet.Cells.Item($row, "D") = $item.description
		$TSSheet.Cells.Item($row, "D").font.bold = $true
		$TSSheet.Cells.Item($row, "D").font.size = 12
		$item = $xml.GetElementsByTagName("group") | Where-Object { $_.Name -eq $Result.Name }
		
		if ($item.condition -ne $null)
		{
			$TSSheet.Cells.Item($row, "E") = "Yes"
			$TSSheet.Cells.Item($row, "E").Interior.ColorIndex = 6
			
			foreach ($condition in $item.condition.expression)
			{
				foreach ($val in $condition.variable)
				{
					$TSSheet.Cells.Item($row, "H") = $val.innertext
					$TSSheet.Cells.Item($row, "H").font.size = 12
				}
			}
		}
		else
		{
			$TSSheet.Cells.Item($row, "E") = "No"
		}
		$TSSheet.Cells.Item($row, "E").font.size = 12
		$TSSheet.Cells.Item($row, "E").font.bold = $true
		
		if ($item.continueOnError -ne $null)
		{
			$TSSheet.Cells.Item($row, "F") = "Yes"
			$TSSheet.Cells.Item($row, "F").Interior.ColorIndex = 6
		}
		else
		{
			$TSSheet.Cells.Item($row, "F") = "No"
		}
		$TSSheet.Cells.Item($row, "F").font.size = 12
		$TSSheet.Cells.Item($row, "F").font.bold = $true
		
		if ($item.disable -ne $null)
		{
			$TSSheet.Cells.Item($row, "G") = "No"
			$TSSheet.Cells.Item($row, "G").Interior.ColorIndex = 6
		}
		else
		{
			$TSSheet.Cells.Item($row, "G") = "Yes"
		}
		$TSSheet.Cells.Item($row, "G").font.size = 12
		$TSSheet.Cells.Item($row, "G").font.bold = $true
	}
	
	if ($line -like "*step type=*")
	{
		$i = $i + 1
		$row++
		$result.ID = $i
		$line.trim() | Out-Null
		$line = $line.Substring($line.IndexOf('name="') + 6)
		$line = $line.Substring(0, $line.IndexOf('"'))
		$Result.Type = "Step"
		$result.Name = $line
		$TSSheet.Cells.Item($row, "A") = $i
		$TSSheet.Cells.Item($row, "B") = $result.name
		$TSSheet.Cells.Item($row, "C") = $Result.Type
		$TSSheet.Cells.Item($row, "D") = $item.description
		$item = $xml.GetElementsByTagName("step") | Where-Object { $_.Name -eq $Result.Name }
		
		if ($item.condition -ne $null)
		{
			$TSSheet.Cells.Item($row, "E") = "Yes"
			$TSSheet.Cells.Item($row, "E").Interior.ColorIndex = 6
			foreach ($condition in $item.condition.expression)
			{
				foreach ($val in $condition.variable)
				{
					$var += $val.innertext + ";"
				}
			}
			$TSSheet.Cells.Item($row, "H") = $var
		}
		else
		{
			$TSSheet.Cells.Item($row, "E") = "No"
		}
		if ($item.continueOnError -ne $null)
		{
			$TSSheet.Cells.Item($row, "F") = "Yes"
			$TSSheet.Cells.Item($row, "F").Interior.ColorIndex = 6
		}
		else
		{
			$TSSheet.Cells.Item($row, "F") = "No"
		}
		if ($item.disable -ne $null)
		{
			$TSSheet.Cells.Item($row, "G") = "No"
			$TSSheet.Cells.Item($row, "G").Interior.ColorIndex = 6
		}
		else
		{
			$TSSheet.Cells.Item($row, "G") = "Yes"
		}
	}
}

# Format columns
$TSsheet.columns.Item('A').EntireColumn.Columnwidth = 5
$TSsheet.columns.Item('B').EntireColumn.Columnwidth = 40
$TSsheet.columns.Item('C').EntireColumn.Columnwidth = 8
$TSsheet.columns.Item('D').EntireColumn.Columnwidth = 100
$TSsheet.columns.Item('E').EntireColumn.Columnwidth = 13
$TSsheet.columns.Item('F').EntireColumn.Columnwidth = 13
$TSsheet.columns.Item('G').EntireColumn.Columnwidth = 13
$TSsheet.columns.Item('H').EntireColumn.Columnwidth = 100

# Remove temp XML file
Remove-Item -Path $Pathfile -Force