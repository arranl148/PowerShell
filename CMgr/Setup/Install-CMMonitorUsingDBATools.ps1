# From https://skatterbrainz.wordpress.com/2020/02/16/cool-sql-tricks-with-dbatools-and-mem-configmgr/
Install-Module dbatools

# From https://stevethompsonmvp.wordpress.com/2021/08/25/create-the-optimize-database-solution-using-powershell-and-dbatools/
# Create new database for Database Maintenance plan, install Ola's solution, create and schedule IndexOptimize task
# 8/27/2021
# Author: Steve Thompson

# Change variables as appropriate
$SQLInstance = "localhost"
$DBName = "CMMonitor"

# Create a new database on the localhost named DBA
New-DbaDatabase -SqlInstance $SQLInstance -Name $DBName -Owner sa -RecoveryModel Simple

# Install Ola Hallengrens Database Maintenance solution using the DBA database
Install-DbaMaintenanceSolution -SqlInstance $SQLInstance -Database $DBName -ReplaceExisting -InstallJobs

# Create a new SQL Server Agent Job to schedule the custom Agent Task
New-DbaAgentJob -SqlInstance $SQLInstance -Job OptimizeIndexes -Owner sa -Description 'Ola Hallengren Optimize Indexes' 

# Create a new SQL Agent Task step with the optimal parameters for MEMCM
New-DbaAgentJobStep -SqlInstance $SQLInstance -Job OptimizeIndexes -StepName Step1 -Database $DBName -Command "EXECUTE dbo.IndexOptimize

@Databases = 'USER_DATABASES',

@FragmentationLow = NULL,

@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',

@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',

@FragmentationLevel1 = 10,

@FragmentationLevel2 = 40,

@UpdateStatistics = 'ALL',

@OnlyModifiedStatistics = 'Y',

@LogToTable = 'Y'"

# Optionally, create a schedule to run the SQL Agent Tast once a week on Sunday @ 1:00AM
New-DbaAgentSchedule -SqlInstance $SQLInstance -Job OptimizeIndexes -Schedule RunWeekly -FrequencyType Weekly -FrequencyInterval Sunday -StartTime 010000 -Force