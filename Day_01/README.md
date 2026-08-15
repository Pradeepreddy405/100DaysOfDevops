# Create a Linux User with a Non-Interactive Shell

## 📌 Task

The system administration team at **xFusionCorp Industries** requires a user to be created for a backup agent tool.

### Requirement

Create a Linux user named:

```text
kareem
```

The user must have a **non-interactive shell**.

Target server:

```text
App Server 3
```

---

## 🎯 Objective

By completing this task, we will:

1. Connect to App Server 3.
2. Identify the available non-interactive shell.
3. Create the `kareem` user.
4. Assign `/sbin/nologin` as the user's shell.
5. Verify the user.
6. Verify the assigned shell.

---

# Step 1: Connect to App Server 3

From the jump host, connect to App Server 3.

```bash
ssh <username>@stapp03
```

Example:

```bash
ssh tony@stapp03
```

Enter the password when prompted.

> The exact username and authentication details depend on the lab environment.

---

# Step 2: Check the Operating System

After connecting to App Server 3, check the operating system:

```bash
cat /etc/os-release
```

Example output:

```text
NAME="CentOS Linux"
VERSION="7"
```

This helps identify which Linux distribution is running on the server.

---

# Step 3: Check the `nologin` Shell

A non-interactive shell prevents the user from getting a normal interactive terminal.

Check where `nologin` is installed:

```bash
which nologin
```

Possible output:

```text
/usr/sbin/nologin
```

or:

```text
/sbin/nologin
```

Use the path returned by your server.

You can also check the valid shells:

```bash
cat /etc/shells
```

---

# Step 4: Create the User

If the server returns:

```text
/sbin/nologin
```

create the user with:

```bash
sudo useradd -s /sbin/nologin kareem
```

If the server returns:

```text
/usr/sbin/nologin
```

use:

```bash
sudo useradd -s /usr/sbin/nologin kareem
```

### What does this command mean?

```bash
sudo useradd -s /sbin/nologin kareem
```

Breakdown:

| Component | Meaning |
|---|---|
| `sudo` | Execute the command with administrative privileges |
| `useradd` | Create a Linux user |
| `-s` | Specify the user's login shell |
| `/sbin/nologin` | Non-interactive shell |
| `kareem` | Username |

---

# Step 5: Verify the User Exists

Run:

```bash
id kareem
```

Example:

```text
uid=1002(kareem) gid=1002(kareem) groups=1002(kareem)
```

This confirms that the user was successfully created.

---

# Step 6: Verify the User's Shell

Run:

```bash
getent passwd kareem
```

Example:

```text
kareem:x:1002:1002::/home/kareem:/sbin/nologin
```

The last field is the user's shell:

```text
/sbin/nologin
```

This confirms that `kareem` has a non-interactive shell.

---

# Step 7: Verify Using `/etc/passwd`

You can also check directly:

```bash
grep '^kareem:' /etc/passwd
```

Expected output:

```text
kareem:x:1002:1002::/home/kareem:/sbin/nologin
```

The important part is:

```text
/sbin/nologin
```

---

# Step 8: Verify the Shell with `getent`

Another clean verification method:

```bash
getent passwd kareem | cut -d: -f1,7
```

Expected:

```text
kareem:/sbin/nologin
```

This confirms that the `kareem` account is configured with the non-interactive shell.

---

# Step 9: Optional — Test the Non-Interactive Shell

You can test the account by attempting to switch to it:

```bash
sudo su - kareem
```

Because the account uses `nologin`, access should be denied.

Typical output:

```text
This account is currently not available.
```

This is **expected behavior**.

---

# Complete Command Sequence

For a server using `/sbin/nologin`:

```bash
ssh tony@stapp03

cat /etc/os-release

which nologin

sudo useradd -s /sbin/nologin kareem

id kareem

getent passwd kareem

grep '^kareem:' /etc/passwd

getent passwd kareem | cut -d: -f1,7
```

Expected final verification:

```text
kareem:/sbin/nologin
```

---

# Important Linux Concepts

## Interactive Shell

An interactive shell allows a user to log in and execute commands.

Example:

```text
/bin/bash
```

A user configured with `/bin/bash` can normally obtain an interactive terminal.

---

## Non-Interactive Shell

A non-interactive shell prevents normal interactive login.

Common example:

```text
/sbin/nologin
```

This is useful for:

- Service accounts
- Backup agents
- Application accounts
- Monitoring agents
- Automation accounts
- System processes

The account can exist and own files/processes without being intended for human interactive login.

---

# Why Use `/sbin/nologin`?

Suppose an application needs a Linux account:

```text
backup-agent
```

The application may need an account to own files or run processes.

However, there may be no reason for a human to log into the server using that account.

Instead of giving the account:

```text
/bin/bash
```

we assign:

```text
/sbin/nologin
```

This follows the principle of **least privilege** and reduces unnecessary interactive access.

---

# Troubleshooting

## User Already Exists

If you receive:

```text
useradd: user 'kareem' already exists
```

check the existing account:

```bash
id kareem
```

Then check its shell:

```bash
getent passwd kareem
```

If the shell is incorrect, change it with:

```bash
sudo usermod -s /sbin/nologin kareem
```

Verify again:

```bash
getent passwd kareem
```

---

## `nologin` Path Is Different

Do not blindly assume the path.

First run:

```bash
which nologin
```

If it returns:

```text
/usr/sbin/nologin
```

then use:

```bash
sudo useradd -s /usr/sbin/nologin kareem
```

---

## Permission Denied

If you run:

```bash
useradd -s /sbin/nologin kareem
```

and receive a permission error, use:

```bash
sudo useradd -s /sbin/nologin kareem
```

You need administrative privileges to create system users.

---

# Final Verification Checklist

- [ ] Connected to App Server 3
- [ ] Checked the Linux operating system
- [ ] Located the `nologin` shell
- [ ] Created user `kareem`
- [ ] Assigned a non-interactive shell
- [ ] Verified the user with `id`
- [ ] Verified the shell with `getent passwd`
- [ ] Confirmed `/sbin/nologin` or `/usr/sbin/nologin`
- [ ] Optionally tested interactive login

---

# Result

The required user has been created:

```text
Username: kareem
Shell: /sbin/nologin
Server: App Server 3
```

The final verification should show:

```text
kareem:/sbin/nologin
```

This confirms that `kareem` exists and is configured with a **non-interactive shell**.