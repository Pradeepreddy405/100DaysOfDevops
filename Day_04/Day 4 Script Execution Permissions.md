## Day 4: Script Execution Permissions

## 1 Explanation
 - This task is about controlling who can execute a script in Linux.
 - In Linux, a file is not executable by default just because it contains commands.
 - The system checks:
	- Does the file have execute permission (x)?
	- Which users/groups are allowed to execute it?
 - The goal of this task is usually:
	- Allow a script to run properly
	- Prevent unauthorized execution
	- Ensure only intended users can execute automation scripts
 - This is one of the most fundamental Linux permission management tasks.

## 2 Task
 - The Nautilus application development team has deployed a script on one of the app servers within the Stratos Datacenter.
 - Your task is to ensure the script has executable permissions so it can run successfully.

## 3 Solution

 ### Step 1 : Login to jump host
	- ssh thor@jump_host
		
 ### Step 2 : Login to the Application server
	- ssh tony@stapp01
	
 ### Step 3 : Check the script permissions
	- ls -l /tmp/xfusioncorp.sh
	
	Output : -rw-r--r-- 1 root root 245 May 15  script.sh
	
 ### Step 4 : Add executable permission
	- chmod +x /tmp/xfusioncorp.sh
	- chmod 755 /tmp/xfusioncorp.sh
		
	
 ### Step 5 : Verify permissions
	- ls -l /tmp/xfusioncorp.sh
		
		
 ### Step 6 : Test the script
	- ./script.sh
	

---
### Check points 

chmod = change mode

 - Used to modify permissions on files/directories.
	- read (r)
	- write (w)
	- execute (x)



- Section		Meaning
  =======     =================
  rwx			Owner permissions
  r-x			Group permissions
  r--			Others permissions


---


## 4 By doing this task ?
Script execution permissions are configured to ensure automation files can run securely and correctly. Linux uses execute permissions to control whether a file is allowed to run as a program or script. Proper permission management reduces operational failures and prevents unauthorized execution of sensitive scripts.