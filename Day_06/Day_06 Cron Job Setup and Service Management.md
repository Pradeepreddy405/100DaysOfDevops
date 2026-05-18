### Day 3: Cron Job Setup and Service Management

### 1 Explanation
	- This task is about automating repetitive tasks in Linux using cron jobs.
	- In production environments, admins use cron to:
		- run backups
		- rotate logs
		- clean temp files
		- monitor services
		- execute scripts automatically
		- crond is the cron daemon (background service) that executes scheduled jobs.
		- cronie is the package that provides cron functionality in many RHEL/CentOS-based systems.

### 2 Task

- Perform the following on all Nautilus app servers:

 - a.
	- Install cronie
	- Start crond service
 - b.
	- Add this cron job for root user:
	- */5 * * * * echo hello > /tmp/cron_text
	- This runs every 5 minutes and writes hello into /tmp/cron_text.
	
### 3 Solution

### Step 1: SSH into App Servers (stapp01, stapp02, stapp03)
 - ssh tony@stapp01

### Step 2: Switch to root user
 - sudo su -
 
### Step 3: Check if package is available
 - dnf search cronie
 - yum list available | grep cronie
 
### Step 4: Install cronie
 - sudo yum install -y cronie


### Step 5: Start and enable crond service
 - sudo systemctl enable crond
 - sudo systemctl start crond

### Step 6: Configure Cron Job and Open root crontab to add cron entry
 - crontab -e
 - */5 * * * * echo hello > /tmp/cron_text
 - Save and Quit from editor
 
### Step 7: Verify cron entry
 - crontab -l
 
### Step 8: Verify cron execution
 - cat /tmp/cron_text
 
### Step 9: Repeat the same steps for remaining application servers