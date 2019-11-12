-- Add before last step of maint plan.
--Archive *.bak(s) older than 3 days.
EXECUTE master.dbo.xp_cmdshell '@PowerShell -noprofile -command "gci ''\\nfs\prodbackups\cluster1\*.bak'' | Where {$_.LastWriteTime -lt (Get-Date).AddDays(-3)} | Move-Item -destination ''\\nfsarchive\prodarchive\cluster1\'' -Force -Verbose" '
GO
