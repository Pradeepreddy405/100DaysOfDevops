# PostgreSQL Database Setup – Nautilus

## 📌 Task Overview

The Nautilus application development team needs a PostgreSQL database server prepared for a newly developed application.

The PostgreSQL server is already installed on the **Nautilus Database Server (`stdb01`)**.

### Requirements

- Create PostgreSQL user `kodekloud_sam`
- Set password to `BruCStnMT5`
- Create database `kodekloud_db9`
- Grant full privileges on the database to `kodekloud_sam`
- **Do not restart PostgreSQL**

---

## 🏗️ Infrastructure

| Server | Hostname | User | Purpose |
|---|---|---|---|
| Database Server | `stdb01` | `peter` | PostgreSQL Database |
| Jump Host | `jump-host` | `thor` | Secure access to Stratos DC |

---

## 🔄 Workflow

```text
                    ┌─────────────────────┐
                    │     Jump Host       │
                    │     jump-host       │
                    │       thor          │
                    └──────────┬──────────┘
                               │
                               │ SSH
                               ▼
                    ┌─────────────────────┐
                    │   Database Server   │
                    │       stdb01        │
                    │       peter         │
                    └──────────┬──────────┘
                               │
                               │ sudo
                               ▼
                    ┌─────────────────────┐
                    │    PostgreSQL       │
                    │                     │
                    │ User: kodekloud_sam │
                    │ DB:   kodekloud_db9 │
                    └──────────┬──────────┘
                               │
                               │ GRANT
                               ▼
                    ┌─────────────────────┐
                    │ Database Privileges │
                    │                     │
                    │ kodekloud_sam       │
                    │       ↓             │
                    │ kodekloud_db9       │
                    └─────────────────────┘
```

---

## 1. Connect to Database Server

From the Jump Host:

```bash
ssh peter@stdb01
```

Enter the database server password when prompted.

---

## 2. Switch to PostgreSQL User

```bash
sudo -i -u postgres
```

Verify:

```bash
whoami
```

Expected:

```text
postgres
```

---

## 3. Connect to PostgreSQL

```bash
psql
```

Expected prompt:

```text
postgres=#
```

---

## 4. Create PostgreSQL User

```sql
CREATE USER kodekloud_sam WITH PASSWORD 'BruCStnMT5';
```

Verify:

```sql
\du
```

---

## 5. Create Database

```sql
CREATE DATABASE kodekloud_db9;
```

Verify:

```sql
\l
```

---

## 6. Grant Full Database Privileges

```sql
GRANT ALL PRIVILEGES ON DATABASE kodekloud_db9 TO kodekloud_sam;
```

Verify:

```sql
\l kodekloud_db9
```

The database should show privileges for `kodekloud_sam`.

---

## 7. Exit PostgreSQL

```sql
\q
```

Then exit the PostgreSQL system user:

```bash
exit
```

---

## 🔍 Verification

### Check PostgreSQL User

```bash
sudo -u postgres psql -c "\du"
```

### Check Database

```bash
sudo -u postgres psql -c "\l kodekloud_db9"
```

### Test Login as Application User

```bash
psql -U kodekloud_sam -d kodekloud_db9 -h localhost -W
```

Enter:

```text
BruCStnMT5
```

If the connection succeeds:

```text
kodekloud_db9=>
```

The PostgreSQL setup is working.

---

## ⚠️ Important

Do **not** restart PostgreSQL.

```bash
# DO NOT RUN
systemctl restart postgresql
```

Creating users, databases, and privileges does not require a PostgreSQL restart.

---

## 🧠 What This Lab Teaches

- Connecting to a remote Linux server using SSH
- Switching to the PostgreSQL OS user
- Using the PostgreSQL `psql` client
- Creating PostgreSQL users
- Creating databases
- Granting database privileges
- Verifying PostgreSQL configuration
- Testing database authentication
- Understanding that database privilege changes do not require a service restart

---

## ✅ Final State

```text
PostgreSQL
│
├── User
│   └── kodekloud_sam
│
└── Database
    └── kodekloud_db9
         │
         └── Full privileges
             └── kodekloud_sam
```

## Result

PostgreSQL on `stdb01` is prepared for the Nautilus application without restarting the PostgreSQL service.