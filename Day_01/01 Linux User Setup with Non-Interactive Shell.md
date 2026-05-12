### 1 Linux User Setup with Non-Interactive Shell

- In production environments, many Linux users are created only for running applications or services, not for human access.

- To improve security, we assign a non-interactive shell like `/sbin/nologin` or `/bin/false`. This prevents SSH or terminal login while still allowing the account to own files and run processes.

- This follows the Principle of Least Privilege and reduces attack surface. For example, if a web application service account gets compromised, the attacker cannot obtain an interactive shell session on the server.


### 2 Interview Explanation :
A non-interactive Linux user is a secure service account used to run applications (or) automation without allowing direct shell login, helping enforce least privilege and reduce server attack surface in production environments.




### 3 Solution

#### Step 1: Verify User Exists or Not
	- id jim
	- if Output will be - " id: 'jim': no such user "
	
	
#### Step 2: Create User with Non-Interactive Shell
	- sudo useradd -s /sbin/nologin jim
	
#### Step 3: Check the user 
	- grep jim /etc/passwd
	
#### Step 4: Test the login behaviour
	-  su - jim 
	- Output should be "This account is currently not available."