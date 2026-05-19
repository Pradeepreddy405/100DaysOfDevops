### Day 7: Linux SSH Authentication

### 1 Explanation
This task is about setting up SSH key-based authentication between servers.
The goal is usually:
Allow automated scripts to connect without entering passwords
Enable secure communication between jump host and application servers
Avoid manual authentication during scheduled operations
In this scenario:
User thor exists on the jump host
Each app server has its own sudo user:
tony → stapp01
steve → stapp02
banner → stapp03
We must configure SSH keys so that:
thor can SSH into all app servers
No password prompt appears during login

### 2 Task
 - The system admins team of xFusionCorp Industries has set up some scripts on jump host that run on regular intervals and perform operations on all app servers in Stratos Datacenter.
 - To make these scripts work properly we need to make sure the thor user on jump host has password-less SSH access to all app servers through their respective sudo users.
 - Your task is to:
Configure password-less SSH authentication from:
thor@jump_host
 - To:
 - tony@stapp01
 - steve@stapp02
 - banner@stapp03

### 3 Solution
Step 1 : Login to jump host
ssh thor@jump_host
Step 2 : Generate SSH key pair for thor user
ssh-keygen -t rsa
Press Enter for:
file location
passphrase
confirm passphrase

This creates:

~/.ssh/id_rsa
~/.ssh/id_rsa.pub
Step 3 : Copy SSH key to App Server 1
ssh-copy-id tony@stapp01
Enter password when prompted.
Step 4 : Copy SSH key to App Server 2
ssh-copy-id steve@stapp02
Step 5 : Copy SSH key to App Server 3
ssh-copy-id banner@stapp03
Step 6 : Verify password-less login for App Server 1
ssh tony@stapp01
Login should happen without password.

Exit from server:

exit
Step 7 : Verify password-less login for App Server 2
ssh steve@stapp02

Exit:

exit
Step 8 : Verify password-less login for App Server 3
ssh banner@stapp03

Exit:

exit


### 4 By doing this task ?
Password-less SSH authentication allows automated scripts to securely access remote servers without manual password entry.
SSH keys are more secure than password-based authentication because:
passwords are not exposed repeatedly
automation becomes reliable
scripts can run unattended
administrative tasks become faster and safer