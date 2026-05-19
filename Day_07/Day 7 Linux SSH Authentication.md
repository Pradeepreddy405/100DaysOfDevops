## Day 7: Linux SSH Authentication

- SSH authentication is the process of proving identity when connecting to a Linux server using the OpenSSH protocol.
- SSH itself stands for Secure Shell and it creates an encrypted channel between:
	- SSH Client → your laptop/workstation
	- SSH Server (sshd) → remote Linux machine
	
	- Public Key Authentication and which uses cryptographic key pairs to validate the authentication and mostly used in Production systems

## 1 Concept Explanation

 - SSH is a secure remote access protocol widely used in Linux, cloud, and DevOps environments. Under the hood, SSH first establishes an encrypted tunnel using key exchange algorithms like Curve25519 or Diffie-Hellman. Then authentication happens using passwords or, more commonly, public key cryptography.

 - In public key authentication, the server sends a challenge, the client signs it using the private key locally, and the server verifies it using the public key stored in authorized_keys. The private key never leaves the client machine.

 - In production, SSH is used for cloud VM administration, CI/CD automation, Kubernetes node troubleshooting, Ansible automation, and secure tunneling. For debugging, I typically use ssh -vvv, inspect sshd logs, verify PAM integration, check permissions, and validate network/security group configurations systematically



## 2 Task
 - The system admins team of xFusionCorp Industries has set up some scripts on jump host that run on regular intervals and perform operations on all app servers in Stratos Datacenter.
 
 - To make these scripts work properly we need to make sure the thor user on jump host has password-less SSH access to all app servers through their respective sudo users.
 
 - This task is about setting up SSH key-based authentication between servers.
 
 - The goal is usually:
	- Allow automated scripts to connect without entering passwords
	- Enable secure communication between jump host and application servers
	- Avoid manual authentication during scheduled operations
 
 - In this scenario:
	- User thor exists on the jump host
	- Each app server has its own sudo user:
		- tony → stapp01
		- steve → stapp02
		- banner → stapp03
 - We must configure SSH keys so that:
 - thor can SSH into all app servers
 - No password prompt appears during login
 
 - Your task is to:
 - Configure password-less SSH authentication from thor@jump_host to:
 - tony@stapp01
 - steve@stapp02
 - banner@stapp03

## 3 Solution
 ### Step 1 : Login to jump host
	- ssh thor@jump_host
	
 ### Step 2 : Generate SSH key pair for thor user
	- ssh-keygen -t rsa
	- Press Enter for:
		- file location
		- passphrase
		- confirm passphrase
	- This creates:
		- ~/.ssh/id_rsa
		- ~/.ssh/id_rsa.pub
		
 ### Step 3 : Copy SSH key to App Server 1
	- ssh-copy-id tony@stapp01
	- Enter password when prompted.
 
 ### Step 4 : Copy SSH key to App Server 2
	- ssh-copy-id steve@stapp02
 
 ### Step 5 : Copy SSH key to App Server 3
	- ssh-copy-id banner@stapp03
 
 ### Step 6 : Verify password-less login for App Server 1
	- ssh tony@stapp01
	- Login should happen without password.
	- Exit from server:
	- exit
	
 ### Step 7 : Verify password-less login for App Server 2
	- ssh steve@stapp02
	- Exit:
	- exit
	
 ### Step 8 : Verify password-less login for App Server 3
	- ssh banner@stapp03
	- Exit:
	- exit



### 4 By doing this task ?
	- Password-less SSH authentication allows automated scripts to securely access remote servers without manual password entry.
	- SSH keys are more secure than password-based authentication because:
	- passwords are not exposed repeatedly
	- automation becomes reliable
	- scripts can run unattended
	- administrative tasks become faster and safer