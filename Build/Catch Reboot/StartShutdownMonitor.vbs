Runapp "powershell.exe","-noprofile -executionpolicy bypass -file " & GetScriptPatH() & "shutdown.ps1"
 
Private Function RunApp(AppPath,Switches)
Dim WShell
Dim RunString
Dim RetVal
Dim Success
 
On Error Resume Next
 
Set WShell=CreateObject("WScript.Shell")
 
RunString=Chr(34) &AppPath & Chr(34) & " " & Switches
Retval=WShell.Run(RunString,0,False)
 
RunApp=Retval
 
Set WShell=Nothing
End Function
 
Private Function GetScriptPath
GetScriptPath=Replace(WScript.ScriptFullName,WScript.ScriptName,"")
End Function