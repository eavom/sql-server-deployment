#Setting up Title
$host.UI.RawUI.WindowTitle = "Database Deployment Tool | DriveLogistics"
$vConfigFileName = "Settings.xml" # Setting file for Deployment Tool

# Variable Declaration
$vProjectName
$vDeploymentEnvironment
$vDeploymentStartTime
$vDeploymentEndTimeDate
$vDeploymentStatus
$vDeploymentStatusMessage
$vDeploymentLogFileName
$vObjFileList= @()

# Setting up Default value of variables
$vDeploymentStatus = "Success"

# Generating Log file name and creating the one
$vDeploymentLogFileName = "Status_"+(Get-Date -Format yyyy_MM_dd_HHmmssfff)+".log"
"" | Out-File -FilePath $vDeploymentLogFileName

If (Test-Path $vConfigFileName)
{
	[xml]$vConfigSettings = Get-Content -Path $vConfigFileName

	Write-Host "======================================================================" -ForegroundColor Cyan
	Write-Host "                          Validate Settings                           " -ForegroundColor Cyan
	Write-Host "======================================================================" -ForegroundColor Cyan
	Write-Host "Validating setting from $vConfigFileName... `n"
	
	If ($vConfigSettings.Settings -ne $null -And $vConfigSettings.Settings.ProjectName -ne $null -And $vConfigSettings.Settings.DeploymentEnvironment -ne $null -And $vConfigSettings.Settings.DeploymentWait -ne $null -And $vConfigSettings.Settings.ReleaseTrackerTable -ne $null -And $vConfigSettings.Settings.Servers -ne $null)
	{
		Write-Host "$vConfigFileName Validated Successfully... `n" -ForegroundColor Green
		Write-Host "Reading $vConfigFileName...`n"
		
		$vProjectName = $vConfigSettings.Settings.ProjectName
		$vDeploymentEnvironment = $vConfigSettings.Settings.DeploymentEnvironment
		$vReleaseTrackerTable = $vConfigSettings.Settings.ReleaseTrackerTable
		$vServerInformation = $vConfigSettings.Settings.Servers.ChildNodes | Where {$_.Environment -eq $vDeploymentEnvironment}

		[int]$vDeploymentWait = $vConfigSettings.Settings.DeploymentWait
		
		$vServerName  = ($vServerInformation | Select -Property "ServerName").ServerName
		$vServerPort = ($vServerInformation | Select -Property "ServerPort").ServerPort
		$vDatabaseName = ($vServerInformation | Select -Property "DatabaseName").DatabaseName
		$vAuthType = ($vServerInformation | Select -Property "AuthenticationType").AuthenticationType
		$vUserName = ($vServerInformation | Select -Property "UserName").UserName
		$vPassword = ($vServerInformation | Select -Property "Password").Password
		$vServerNameWithPort = IF (-not [string]::IsNullOrWhitespace($vServerPort)) { $vServerName+","+$vServerPort } else { $vServerName }
		
		Write-Host "Reading $vConfigFileName Completed Successfully...`n" -ForegroundColor Green
		
		Write-Host "======================================================================" -ForegroundColor Cyan
		Write-Host "                              Server Info                             " -ForegroundColor Cyan
		Write-Host "======================================================================" -ForegroundColor Cyan
		Write-Host "Project              : $vProjectName" 
		Write-Host "Environment          : $vDeploymentEnvironment" 
		Write-Host "Server Name          : $vServerName" 
		Write-Host "Server Port          : $vServerPort"
		Write-Host "Database Name        : $vDatabaseName"
		Write-Host "Authentication Type  : $vAuthType"
		Write-Host "User Name            : $vUserName"
		Write-Host "======================================================================"
		Write-Host "Deployment will start in $vDeploymentWait seconds... Press Ctrl + C to STOP NOW..." -ForegroundColor Red
		Write-Host "======================================================================`n"
		
		# In case if Settings are not as per user need, they can Stop the deployement
		Start-Sleep -s $vDeploymentWait
		
		ForEach ($item in $vConfigSettings.Settings.ObjectSetting.ObjectList.ObjectType)
		{
			
			Get-ChildItem -Path $item.ObjectPath -Include *.sql -Recurse |
			Foreach-Object {
				$fObj = New-Object -TypeName PSObject
				$fObj | Add-Member -Name 'ObjectType' -MemberType Noteproperty -Value $item.ObjectType
				$fObj | Add-Member -Name 'ObjectPath' -MemberType Noteproperty -Value $item.ObjectPath
				$fObj | Add-Member -Name 'FullFilePath' -MemberType Noteproperty -Value $_.FullName
				$fObj | Add-Member -Name 'FilePath' -MemberType Noteproperty -Value $_.FullName.Replace((Split-Path -Path (Get-Location).Path -Parent).ToString(), "")
				$fObj | Add-Member -Name 'DeploymentStatus' -MemberType Noteproperty -Value "Pending"
				$fObj | Add-Member -Name 'DeploymentMessage' -MemberType Noteproperty -Value $null
				$fObj | Add-Member -Name 'StartTime' -MemberType Noteproperty -Value $null
				$fObj | Add-Member -Name 'EndTime' -MemberType Noteproperty -Value $null
				
				$vObjFileList += $fObj
			}
		}

		# Script Deployment Starts Here
		$vDeploymentStartTime = Get-Date
		Write-Host "Deployment Started @ "$($vDeploymentStartTime).ToString("MM-dd-yyyy hh:mm:ss.fff") " ...." -ForegroundColor Green
		"Deployment Started @ " + ($vDeploymentStartTime).ToString("MM-dd-yyyy hh:mm:ss.fff") | Out-File -FilePath $vDeploymentLogFileName -Append
		# Just adding blank Line in file
		"*********************************************`r`n" | Out-File -FilePath $vDeploymentLogFileName -Append 

		$sqlConnObj = New-Object System.Data.SqlClient.SqlConnection
		$sqlConnObj.ConnectionString = 
			IF ($vAuthType -eq "Windows") { "Server=" + $vServerNameWithPort +";Initial Catalog="+$vDatabaseName+";Integrated Security=true;" }
			else { "Server=" + $vServerNameWithPort +";Initial Catalog="+$vDatabaseName+";User Id="+$vUserName+";Password="+$vPassword+";" }
			
		try{
			# Just to Check if Connection to provided SQL Server is available or not
			$sqlConnObj.Open() 
			$sqlConnObj.Close()

			$vObjFileList.foreach(
			{
				# Clear Error Message Variable
				$sqlErrorMsg = $null

				# Record Start Time
				$_.StartTime = Get-Date

				Write-Host "Deploying " $_.FilePath -ForegroundColor Cyan
				# Execute SQL File
				Invoke-SqlCmd -InputFile $_.FullFilePath -ConnectionString ($sqlConnObj.ConnectionString).ToString() -ErrorAction SilentlyContinue -ErrorVariable sqlErrorMsg -Verbose *> "SomeVerboseData.log"
				
				if (-not [string]::IsNullOrWhitespace($sqlErrorMsg)) 
				{ 
					$_.DeploymentStatus = "Failed"
					$_.DeploymentMessage = $sqlErrorMsg
					$vDeploymentStatus = "Failed" # Mark Overall status as Failed
				} 
				else 
				{ 
					$_.DeploymentStatus = "Success"
					$_.DeploymentMessage = "Script Deployed Successfully"
				}

				# Record End Time
				$_.EndTime = Get-Date
				
				$_.FilePath + " | " + $_.DeploymentStatus `
							+ " | [Start Time] : " + $_.StartTime `
							+ " | [End Time] : " + $_.EndTime `
							+ " | [Time Taken] : " + $($_.EndTime - $_.StartTime).ToString('hh\:mm\:ss') `
							+ " | [Deployment Message] : " + $_.DeploymentMessage `
					| Out-File -FilePath $vDeploymentLogFileName -Append 
			})
			
			
		}
		catch [Exception]{
			$vDeploymentStatus = "Failed"
			"Error!" + $_.Exception.Message | Out-File -FilePath $vDeploymentLogFileName -Append     
			$vDeploymentStatusMessage = $_.Exception.Message
		} 

		finally{
			If ($sqlConnObj.State -eq "Open"){
				$sqlConnObj.Close()
			}

			# To Close Connection in case if it is still open with Invode-SqlCmd
			[System.Data.SqlClient.SqlConnection]::ClearAllPools()
		}


		# Remove Verbose log file
		if (Test-Path "SomeVerboseData.log") { Remove-Item -Path "SomeVerboseData.log" -Force }

		$vDeploymentEndTime = Get-Date
		Write-Host "Deployment Completed @ "$($vDeploymentEndTime).ToString("MM-dd-yyyy hh:mm:ss.fff") " ...." -ForegroundColor Green
		"`r`n*********************************************" | Out-File -FilePath $vDeploymentLogFileName -Append
		"Deployment Completed @ " + ($vDeploymentEndTime).ToString("MM-dd-yyyy hh:mm:ss.fff") | Out-File -FilePath $vDeploymentLogFileName -Append 
		
		Write-Host "`n===========================================================================" -ForegroundColor Yellow
		Write-Host "                        Deployment Status                   " -ForegroundColor Yellow
		Write-Host "===========================================================================" -ForegroundColor Yellow
		Write-Host "Start Time            : " $($vDeploymentStartTime).ToString("MM-dd-yyyy hh:mm:ss.fff") -ForegroundColor Cyan
		Write-Host "End Time              : " $($vDeploymentEndTime).ToString("MM-dd-yyyy hh:mm:ss.fff") -ForegroundColor Cyan
		Write-Host "Time Taken [HH:MM:SS] : " $($vDeploymentEndTime - $vDeploymentStartTime).ToString('hh\:mm\:ss') -ForegroundColor Cyan
		Write-Host "Deployment Status     :  " -NoNewLine -ForegroundColor Cyan
												if($vDeploymentStatus -eq "Success") { Write-Host $vDeploymentStatus -ForegroundColor Green }
												if($vDeploymentStatus -eq "Failed") { Write-Host $vDeploymentStatus -ForegroundColor Red }
		Write-Host "Status Message        : " $(if($vDeploymentStatus -eq "Success") { "Completed Successfully " } 
											  else { 
													if (-not [string]::IsNullOrWhitespace($vDeploymentStatusMessage)) { $vDeploymentStatusMessage } 
													else { "Review log file for Failure Reason" } 
												   }) -ForegroundColor Cyan
		Write-Host "Summary               :  Total Script -" $vObjFileList.count -ForegroundColor Cyan -NoNewLine
										  Write-Host " | " -ForegroundColor Cyan -NoNewLine
										  Write-Host "Success -" ($vObjFileList | where {$_.DeploymentStatus -eq "Success" }).count -ForegroundColor Green -NoNewLine
										  Write-Host " | " -ForegroundColor Cyan -NoNewLine
										  Write-Host "Failed -" ($vObjFileList.count - (($vObjFileList | where {$_.DeploymentStatus -eq "Success" }).count)) -ForegroundColor Red
		Write-Host "Log File              : " $vDeploymentLogFileName -ForegroundColor Cyan
		Write-Host "===========================================================================" -ForegroundColor Yellow

		# Add The Same Summary To Log File

		"`r`n" | Out-File -FilePath $vDeploymentLogFileName -Append
		"`n===========================================================================" `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"                        Deployment Status                                    " `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"===========================================================================" `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"Start Time            : " + $($vDeploymentStartTime).ToString("MM-dd-yyyy hh:mm:ss.fff") `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"End Time              : " + $($vDeploymentEndTime).ToString("MM-dd-yyyy hh:mm:ss.fff") `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"Time Taken [HH:MM:SS] : " + $($vDeploymentEndTime - $vDeploymentStartTime).ToString('hh\:mm\:ss') `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"Deployment Status     : " + $vDeploymentStatus `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"Summary               : Total Script - " + $vObjFileList.count + " | Success - " + ($vObjFileList | where {$_.DeploymentStatus -eq "Success" }).count + " | Failed - " + ($vObjFileList.count - (($vObjFileList | where {$_.DeploymentStatus -eq "Success" }).count)) `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"Log File              : " + $vDeploymentLogFileName `
			| Out-File -FilePath $vDeploymentLogFileName -Append
		"===========================================================================" `
			| Out-File -FilePath $vDeploymentLogFileName -Append

		# Script Deployment Ends Here
	}
	else 
	{
		Write-Host "======================================================================" -ForegroundColor Cyan
		Write-Host "                          Validation Failed                           " -ForegroundColor Cyan
		Write-Host "======================================================================" -ForegroundColor Cyan
		Write-Host "Required settings are not availale in $vConfigFileName                " -ForegroundColor Cyan
		Write-Host "======================================================================"
	}
}
else
{
		Write-Host "======================================================================" -ForegroundColor Cyan
		Write-Host "                          Something Is Broken                         " -ForegroundColor Cyan
		Write-Host "======================================================================" -ForegroundColor Cyan
		Write-Host "Not able to load $vConfigFileName                                     " -ForegroundColor Cyan
		Write-Host "Please make sure it is available and valid                            " -ForegroundColor Cyan
		Write-Host "======================================================================" -ForegroundColor Cyan
}