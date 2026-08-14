## Day 9 MariaDB Troubleshooting


## 1 Concept Explanation




## 2 Task

- During the weekly meeting, the Nautilus DevOps team discussed about the automation and configuration management solutions that they want to implement. While considering several options, the team has decided to go with Ansible for now due to its simple setup and minimal pre-requisites. The team wanted to start testing using Ansible, so they have decided to use jump host as an Ansible controller to test different kind of tasks on rest of the servers.

- Install ansible version 4.10.0 on Jump host using pip3 only. Make sure Ansible binary is available globally on this system, i.e all users on this system are able to run Ansible commands.

## 3 Solution

		
 ### Step 1 : Switch to root user
	- sudo su -
 
 ### Step 2 : Verify python3 installed or not . If not installed go with installation process
	- python3 --version
	
 ### Step 3 : Verify pip3 installed or not 
	- pip3 --version

 ### Step 4 : Check whether Ansible is already installed
	- ansible --version

	
 ### Step 5 : Install Ansible 4.10.0 globally using pip3 
	- pip3 install ansible==4.10.0
	
 ### Step 6 : Verify installed version
	- ansible --version
	- pip3 show ansible


### 4 By doing this task ?
 - After achieving this task, the Jump Host becomes an Ansible controller machine that can automate tasks on multiple Linux servers from one place.

 - Now instead of manually logging into each server one by one, we can use Ansible to:
	- Install packages
	- Update servers
	- Configure services
	- Create users
	- Restart applications
	- Manage infrastructure

- across many servers simultaneously using SSH.