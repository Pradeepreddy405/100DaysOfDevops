## Day 5: SELinux Installation and Permanent Disable

## 1 Explanation
 - This task is about managing SELinux configuration in Linux.
 - SELinux stands for Security-Enhanced Linux.
 - It provides Mandatory Access Control (MAC) security on top of normal Linux permissions.
 - Even if a user has normal Linux access, SELinux can still block actions based on security policies.
 - Linux security layers:
	- Traditional Linux permissions (rwx)
	- SELinux policies and contexts

 - Example:
	- A web server process may have permission to read a file.
	- SELinux can still deny access if the security context is not allowed.

## 2 Task
- The xFusionCorp Industries security team wants to prepare SELinux testing on App Server 3.
 - This task focuses on:
 - Installing SELinux management packages
 - Configuring SELinux permanently
 - Preparing the system for future SELinux policy testing
 - Understanding persistent configuration vs runtime state

 - The important concept:
	- SELinux has:
		- Runtime state → current live status
		- Persistent configuration → what happens after reboot

 - This task only cares about the persistent configuration.

 - Your task is to:
	- Install required SELinux packages
	- Permanently disable SELinux
	- Do NOT reboot the server
	- Ignore the current runtime status
	- After the next reboot, SELinux must become disabled

## 3 Solution

 ### Step 1 : Login to jump host
	ssh banner@jump_host
	
 ### Step 2 : Login to App Server 3
	ssh banner@stapp03
	
 ### Step 3 : Install SELinux packages
	sudo yum install -y selinux-policy selinux-policy-targeted policycoreutils
	
 ### Step 4 : Open SELinux config file
	sudo vi /etc/selinux/config
	
 ### Step 5 : Change SELinux mode
	Find:
		SELINUX=enforcing (OR) SELINUX=permissive

	Change to:
		SELINUX=disabled
		
 ### Step 6 : Save and exit
	In vi:
	:wq

 ### Step 7 : Verify configuration
	grep SELINUX /etc/selinux/config

	Expected output:
		SELINUX=disabled
		SELINUXTYPE=targeted