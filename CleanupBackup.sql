-- Add as last step to maintenance plan.
--Delete Files >= 5 days old.
EXECUTE master.dbo.xp_cmdshell '@PowerShell -noprofile -command "gci ''\\nfs\prodbackups\cluster1\*.bak'' | Where {$_.LastWriteTime -lt (Get-Date).AddDays(-5)} | Foreach { Remove-Item -Force -Verbose $_.fullname }" '
GO
