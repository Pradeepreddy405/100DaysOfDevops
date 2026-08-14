## Day 8: Install Ansible


## 1 Concept Explanation

 - MariaDB is a relational database server used to store and manage structured data for applications.
 - It runs as a background service (mariadbd) and depends heavily on correct Linux permissions, filesystem paths, and system service configuration.
 - When MariaDB fails to start, it is almost never “random”. It is usually caused by:
 - Incorrect file or directory permissions
 - Missing runtime directories like /run/mariadb
 - Corrupted or locked PID files
 - Wrong ownership of /var/lib/mysql
 - Service misconfiguration or leftover stale process state
 - The server must be able to:
	- Create a PID file (process tracking file)
	- Write to runtime directories
	- Access data directory with correct mysql ownership
	- Mostly: if MariaDB doesn’t start, 90% of the time it’s a permission or filesystem problem, not the database engine itself.


## 2 Task

The Nautilus DevOps team is facing a production outage where the application cannot connect to the database.
Investigation shows that the MariaDB service on the database server is down.
The objective is to bring the service back online by identifying and fixing the root cause.
You are required to:
	- Troubleshoot why MariaDB service is failing to start
	- Fix permission or directory-related issues
	- Ensure the service starts successfully
	- Verify database service status after fix
## 3 Solution

 ### Step 0 : SSH into Database server
	- ssh peter@stdb01

 ### Step 1: Check service status
	- First confirm what exactly is broken:
		- systemctl status mariadb
		- If it shows failed, do not restart blindly. Always inspect logs first.
 
 ### Step 2: Check detailed logs
	- journalctl -xeu mariadb
	- Look for errors like:
		- Can't create/write to file '/run/mariadb/mariadb.pid'
		- Permission denied
		- Missing directory
 
 ### Step 3: Identify runtime directory issue
	- Most common root cause:
		- ls -ld /run/mariadb
		- If directory does not exist or ownership is wrong, MariaDB cannot start.
 
 ### Step 4: Fix runtime directory
	- mkdir -p /run/mariadb
	- chown mysql:mysql /run/mariadb
	- chmod 755 /run/mariadb
	- This ensures MariaDB can create PID and socket files.
 
 ### Step 5: Fix data directory ownership (if needed)
	- chown -R mysql:mysql /var/lib/mysql
	- Wrong ownership here will silently break startup.
 
 ### Step 6: Remove stale PID file (if exists)
	- rm -f /run/mariadb/mariadb.pid
	- Stale PID files confuse the service into thinking it is already running.
 
 ### Step 7: Start MariaDB service
	- systemctl start mariadb
 
 ### Step 8: Verify service status
	- systemctl status mariadb
	- You should see: active (running)
 
 ### Step 9: Confirm database access
	- mysql -u root -p
	- If login works, service is fully restored.		



### 4 By doing this task ?
	- You learn the real reason production databases fail: filesystem and permission issues, not “mystery errors”.
	- You gain control over MariaDB service recovery instead of guessing.
	- You can now confidently:
	- Recover crashed database services
	- Fix permission-related startup failures
	- Validate system-level dependencies before restarting services
	- if you cannot fix /run and ownership issues, you cannot operate databases in real production environments.