on error resume next
Err.clear
Set service = CreateObject("Schedule.Service")
service.Connect
Set rootFolder = service.GetFolder("\HardDiskSentinel")
if Err.Number<>0 then
	Wscript.Echo "Already REMOVED"
	Wscript.Quit
	end if
Set colTasks = rootFolder.GetTasks(0)
For Each task In colTasks
	rootFolder.DeleteTask task.Name, 0	
Next

if (rootFolder.GetTasks(0).Count=0) then
	Set rootFolder = service.GetFolder("\")
	rootFolder.DeleteFolder "HardDiskSentinel",0
  end if
Wscript.Echo "REMOVED"
