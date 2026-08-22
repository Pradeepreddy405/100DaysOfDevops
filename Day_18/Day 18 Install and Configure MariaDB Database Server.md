# Day 18: Install and Configure MariaDB Database Server

## 📌 Lab Overview

In this lab, I configured the **MariaDB database server** on the Nautilus DB Server (`stdb01`) in the Stratos Datacenter.

### 🎯 Objectives

- Install and configure MariaDB Server
- Create a database named `kodekloud_db4`
- Create a MariaDB user named `kodekloud_tim`
- Set the required password
- Grant full privileges on `kodekloud_db4`
- Verify the configuration

---

## 🏗️ Infrastructure

| Server | Hostname | User | Purpose |
|---|---|---|---|
| Database Server | `stdb01` | `peter` | Hosts Nautilus Database |
| Jump Host | `jump-host` | `thor` | Secure access to Stratos Datacenter |

---

## 🔐 Database Configuration

| Parameter | Value |
|---|---|
| Database Server | `stdb01` |
| Database | `kodekloud_db4` |
| Database User | `kodekloud_tim` |
| Privilege | `ALL PRIVILEGES` |
| MariaDB | Installed and enabled |

> **Note:** Passwords are intentionally not documented in this README.

---

# 🚀 Implementation

## 1. Connect to the Database Server

From the Jump Host:

```bash
ssh peter@stdb01
```

---

## 2. Install MariaDB

Check the operating system:

```bash
cat /etc/os-release
```

Install MariaDB Server:

```bash
sudo dnf install -y mariadb-server
```

---

## 3. Start and Enable MariaDB

Start MariaDB:

```bash
sudo systemctl start mariadb
```

Enable MariaDB at boot:

```bash
sudo systemctl enable mariadb
```

Or perform both operations together:

```bash
sudo systemctl enable --now mariadb
```

Verify the service:

```bash
sudo systemctl status mariadb
```

Quick verification:

```bash
sudo systemctl is-active mariadb
```

Expected:

```text
active
```

---

# 🗄️ Database Configuration

## 4. Access MariaDB

```bash
sudo mysql
```

---

## 5. Create the Database

Create the required database:

```sql
CREATE DATABASE kodekloud_db4;
```

Verify:

```sql
SHOW DATABASES;
```

Expected:

```text
kodekloud_db4
```

---

# 👤 Create Database User

## 6. Create `kodekloud_tim`

```sql
CREATE USER 'kodekloud_tim'@'localhost'
IDENTIFIED BY '<PASSWORD>';
```

Verify the user:

```sql
SELECT User, Host FROM mysql.user;
```

Expected:

```text
kodekloud_tim    localhost
```

---

# 🔑 Grant Permissions

## 7. Grant Full Permissions

Grant all privileges **only on the required database**:

```sql
GRANT ALL PRIVILEGES
ON kodekloud_db4.*
TO 'kodekloud_tim'@'localhost';
```

Reload privileges:

```sql
FLUSH PRIVILEGES;
```

Verify:

```sql
SHOW GRANTS FOR 'kodekloud_tim'@'localhost';
```

Expected result should contain:

```text
GRANT ALL PRIVILEGES ON `kodekloud_db4`.* TO `kodekloud_tim`@`localhost`
```

---

# 🧪 Verification

## 8. Test Database User

Exit MariaDB:

```sql
EXIT;
```

Login using the newly created account:

```bash
mysql -u kodekloud_tim -p
```

Enter the configured password.

Check available databases:

```sql
SHOW DATABASES;
```

Select the database:

```sql
USE kodekloud_db4;
```

Expected:

```text
Database changed
```

---

# 🔍 Final Verification

Check MariaDB:

```bash
sudo systemctl is-active mariadb
```

Expected:

```text
active
```

Check the database:

```sql
SHOW DATABASES;
```

Check privileges:

```sql
SHOW GRANTS FOR 'kodekloud_tim'@'localhost';
```

---

# 🧠 What I Learned

### MariaDB Service

```bash
systemctl start mariadb
systemctl enable mariadb
```

`start` runs the service immediately, while `enable` makes it start automatically after reboot.

### Database

```sql
CREATE DATABASE kodekloud_db4;
```

Creates the logical database used by the application.

### Database User

```sql
CREATE USER 'kodekloud_tim'@'localhost' IDENTIFIED BY '...';
```

Creates a dedicated database account.

### Database-Level Permissions

```sql
GRANT ALL PRIVILEGES
ON kodekloud_db4.*
TO 'kodekloud_tim'@'localhost';
```

The `*` after `kodekloud_db4.` means the user receives privileges on objects inside that database.

### Important Security Principle

Do **not** unnecessarily use:

```sql
GRANT ALL PRIVILEGES ON *.*
```

That would grant the user privileges across **all databases**.

For this task, the correct scope is:

```text
kodekloud_db4.*
```

---

# 🔄 Workflow

```text
                Jump Host
                    │
                    │ SSH
                    ▼
              ┌──────────┐
              │  stdb01  │
              │ DB Server│
              └─────┬────┘
                    │
                    ▼
              ┌──────────┐
              │ MariaDB  │
              └─────┬────┘
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
 kodekloud_db4          kodekloud_tim
                              │
                              │ ALL PRIVILEGES
                              ▼
                       kodekloud_db4.*
```

---

# ✅ Task Completion Checklist

- [x] Connected to `stdb01`
- [x] Installed MariaDB Server
- [x] Started MariaDB
- [x] Enabled MariaDB at boot
- [x] Created `kodekloud_db4`
- [x] Created `kodekloud_tim`
- [x] Configured the required password
- [x] Granted full privileges on `kodekloud_db4`
- [x] Verified user privileges
- [x] Tested database access

---

## 🛠️ Commands Used

```bash
ssh peter@stdb01

sudo dnf install -y mariadb-server

sudo systemctl enable --now mariadb

sudo systemctl status mariadb

sudo mysql
```

```sql
CREATE DATABASE kodekloud_db4;

CREATE USER 'kodekloud_tim'@'localhost'
IDENTIFIED BY '<PASSWORD>';

GRANT ALL PRIVILEGES
ON kodekloud_db4.*
TO 'kodekloud_tim'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'kodekloud_tim'@'localhost';
```

---

## 📚 Key DevOps Skills Practiced

- Linux Server Administration
- Package Management with DNF
- systemd Service Management
- MariaDB Administration
- Database Creation
- Database User Management
- SQL Privilege Management
- Access Control
- Infrastructure Troubleshooting
- Verification and Validation

---

**Lab:** KodeKloud Engineer — Nautilus Infrastructure  
**Day:** 18  
**Topic:** Install and Configure DB Server  
**Technology:** MariaDB / Linux