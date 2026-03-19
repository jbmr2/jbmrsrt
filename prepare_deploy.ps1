$server = "72.61.233.14"
$user = "root"
$password = "LOKEsh1@@@@@@"

# Create a temporary directory for deployment files
$tempDir = "C:\Users\JBMRSP~1\AppData\Local\Temp\deploy"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Copy-Item "manager.html", "server.js", "mediamtx.yml", "deploy.sh" -Destination $tempDir

# Create an SSH script for deployment using the provided password
$sshScript = @"
spawn scp manager.html server.js mediamtx.yml deploy.sh $user@$server:/root/
expect "password:"
send "$password\r"
expect eof

spawn ssh $user@$server
expect "password:"
send "$password\r"
expect "#"
send "chmod +x /root/deploy.sh\r"
expect "#"
send "cd /root && ./deploy.sh\r"
expect eof
"@

$sshScript | Out-File -FilePath "$tempDir\deploy_ssh.exp" -Encoding ascii

Write-Host "Deployment script prepared at $tempDir. Please note that 'expect' must be installed for this to run automatically."
