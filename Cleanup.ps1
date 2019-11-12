--Add as 1st step in maintenance plan.

--Keep Files <14 days old.
--Delete Files from 14 - 29 days old.
EXECUTE master.dbo.xp_cmdshell '@PowerShell -noprofile -command "gci ''\\nfs\sqlshared\prodbackups\cluster1\*.bak'' | Where {$_.LastWriteTime -lt (Get-Date).AddDays(-14) -and $_.LastWriteTime -gt (Get-Date).AddDays(-29)} | Foreach { Remove-Item -Force -Verbose $_.fullname }" '
GO

--Keep Files 30 days old.
--Delete Files from 31 - 59 days old.
EXECUTE master.dbo.xp_cmdshell '@PowerShell -noprofile -command "gci ''\\nfs\sqlshared\prodbackups\cluster1\*.bak'' | Where {$_.LastWriteTime -lt (Get-Date).AddDays(-31) -and $_.LastWriteTime -gt (Get-Date).AddDays(-59)} | Foreach { Remove-Item -Force -Verbose $_.fullname }" '
GO

--Keep Files 60 days old.
--Delete Files >= 61 days old.
EXECUTE master.dbo.xp_cmdshell '@PowerShell -noprofile -command "gci ''\\nfs\sqlshared\prodbackups\cluster1\*.bak'' | Where {$_.LastWriteTime -lt (Get-Date).AddDays(-61)} | Foreach { Remove-Item -Force -Verbose $_.fullname }" '
GO
