## Day 3: Secure Root SSH Access
## 1 Explanation
 - This task is about hardening SSH access on Linux servers.
 - The goal is usually:
	- Prevent attackers from logging in directly as root
	- Force admins to:
		- login with a normal user
		- then switch to root using sudo or su -

 - This is one of the most basic and important Linux security controls.

## 2 Task
 - Following security audits, the xFusionCorp Industries security team has rolled out new protocols, including the restriction of direct root SSH login.
 - Your task is to disable direct SSH root login on all app servers within the Stratos Datacenter.


## 3 Solution

 ### Step 1 : Login to jump host
	ssh thor@jump_host
		
 ### Step 2 : Login to the Application server
		ssh tony@stapp01
	
 ### Step 3 : Switch to root
		sudo su -
	
 ### Step 4 : Check current setting
		grep -i PermitRootLogin /etc/ssh/sshd_config
	
 ### Step 5 : Edit SSH config
		vi /etc/ssh/sshd_config
		
		Change: " PermitRootLogin yes " to " PermitRootLogin no "
	
 ### Step 6 : Validate config
		sshd -t
	
 ### Step 7 : Restart SSH service
		- systemctl restart sshd
	
 ### Step 8 : verify the changes
		- grep -i PermitRootLogin /etc/ssh/sshd_config

 ### Step 9 : Repeat the for the rest of the servers 
		- stapp02
		- stapp03






## 4 By doing this task ?
Direct root SSH login is disabled to reduce attack surface, improve accountability, and enforce secure privilege escalation. Users authenticate using individual accounts and elevate privileges through sudo, which provides audit logging and better access control.