# Git Bare Repository Setup – Nautilus Storage Server

## 📌 Lab Overview

The Nautilus development team requested the creation of a Git repository for a new application development project.

The requirement was to configure a **bare Git repository** on the **Storage Server** in the Stratos Datacenter.

This lab demonstrates how to:

- Connect to the Storage Server
- Verify whether Git is already installed
- Install Git using `yum` only when required
- Create a bare Git repository
- Validate the repository
- Understand why bare repositories are used in DevOps environments

---

## 🏗️ Infrastructure

| Server | Hostname | User | Purpose |
|---|---|---|---|
| Storage Server | `ststor01` | `natasha` | Git repository storage |

Repository location:

```text
/opt/blog.git
```

---

# 🎯 Requirements

The task requirements were:

1. Install the `git` package using `yum` on the Storage Server.
2. Create a bare Git repository named:

```text
/opt/blog.git
```

---

# 🔐 Step 1 – Connect to the Storage Server

From the Jump Host:

```bash
ssh natasha@ststor01
```

Verify the logged-in user:

```bash
whoami
```

Expected:

```text
natasha
```

Verify the hostname:

```bash
hostname
```

Expected:

```text
ststor01
```

---

# 🔎 Step 2 – Check Whether Git Is Already Installed

Before installing any package, check the current state.

```bash
git --version
```

In this lab, Git was already installed:

```text
git version 2.52.0
```

### DevOps approach

Do **not** blindly install packages.

Use:

```text
Check → Decide → Change → Verify
```

Because Git was already installed, there was no need to install it again.

You can also verify the RPM package:

```bash
rpm -q git
```

---

# 📦 Step 3 – Install Git If It Is Missing

If the following command:

```bash
git --version
```

returns:

```text
-bash: git: command not found
```

then install Git using the required package manager:

```bash
sudo yum install -y git
```

After installation, verify:

```bash
git --version
```

---

# 📁 Step 4 – Check Whether the Repository Already Exists

Before creating the repository, check the target path:

```bash
sudo ls -ld /opt/blog.git
```

If it does not exist:

```text
No such file or directory
```

proceed with repository creation.

If it already exists, inspect it before making changes.

---

# 🚀 Step 5 – Create the Bare Git Repository

Create the repository using:

```bash
sudo git init --bare /opt/blog.git
```

Expected output:

```text
Initialized empty Git repository in /opt/blog.git/
```

The `--bare` option creates a repository without a working directory. This is the standard model for a central Git repository that developers push to and clone from.

---

# 🔍 Step 6 – Verify the Repository

Check the repository directory:

```bash
sudo ls -la /opt/blog.git
```

Expected Git repository structure includes:

```text
HEAD
config
description
hooks
info
objects
refs
```

Example:

```text
drwxr-xr-x  6 root root 4096 Aug 26 10:03 .
drwxr-xr-x  3 root root 4096 Aug 26 10:03 ..
-rw-r--r--  1 root root   23 Aug 26 10:03 HEAD
-rw-r--r--  1 root root   66 Aug 26 10:03 config
-rw-r--r--  1 root root   73 Aug 26 10:03 description
drwxr-xr-x  2 root root 4096 Aug 26 10:03 hooks
drwxr-xr-x  2 root root 4096 Aug 26 10:03 info
drwxr-xr-x  4 root root 4096 Aug 26 10:03 objects
drwxr-xr-x  4 root root 4096 Aug 26 10:03 refs
```

---

# ✅ Step 7 – Confirm It Is a Bare Repository

This is the most important validation:

```bash
sudo git --git-dir=/opt/blog.git rev-parse --is-bare-repository
```

Expected:

```text
true
```

Output from this lab:

```text
true
```

This confirms that `/opt/blog.git` is actually a bare Git repository.

---

# 🧪 Final Verification

Run the following commands:

```bash
git --version

sudo git --git-dir=/opt/blog.git rev-parse --is-bare-repository

sudo ls -la /opt/blog.git
```

Expected:

```text
git version 2.52.0

true
```

And the repository should contain:

```text
HEAD
config
description
hooks
info
objects
refs
```

---

# 🧠 What Is a Bare Git Repository?

A normal Git repository looks like:

```text
project/
├── .git/
├── index.html
├── app.py
└── README.md
```

The `.git` directory contains Git's internal repository data while the remaining files form the working tree.

A bare repository looks different:

```text
blog.git/
├── HEAD
├── config
├── description
├── hooks/
├── info/
├── objects/
└── refs/
```

There is **no working directory**.

This makes a bare repository suitable as a central remote repository.

---

# 🔄 Typical DevOps Git Workflow

A common architecture is:

```text
Developer
    |
    | git push
    v
+----------------------+
| Central Git Server   |
| /opt/blog.git        |
| Bare Repository      |
+----------------------+
    ^
    |
    | git clone / git pull
    |
Developer
```

Developers work in normal Git repositories on their machines.

The central server stores the shared Git repository as a **bare repository**.

---

# ⚠️ Why Not Use Normal `git init`?

A normal repository:

```bash
git init /opt/blog
```

creates a repository with a working tree.

A central server repository normally should not be used as a place where developers directly edit application files.

Instead:

```bash
git init --bare /opt/blog.git
```

creates the repository specifically for remote Git operations.

---

# 🛠️ Commands Used

### Check Git

```bash
git --version
```

### Check installed RPM

```bash
rpm -q git
```

### Install Git

```bash
sudo yum install -y git
```

### Check repository path

```bash
sudo ls -ld /opt/blog.git
```

### Create bare repository

```bash
sudo git init --bare /opt/blog.git
```

### Inspect repository

```bash
sudo ls -la /opt/blog.git
```

### Verify bare repository

```bash
sudo git --git-dir=/opt/blog.git rev-parse --is-bare-repository
```

---

# 📋 Final Result

| Requirement | Result |
|---|---|
| Connect to Storage Server | ✅ Completed |
| Verify Git installation | ✅ Git 2.52.0 |
| Install Git if required | ✅ Not required — already installed |
| Create `/opt/blog.git` | ✅ Completed |
| Create bare repository | ✅ Completed |
| Verify repository | ✅ `true` |
| KodeKloud task | ✅ Successfully completed |

---

# 🎓 Key DevOps Lessons

### 1. Always check before changing

Instead of immediately running:

```bash
sudo yum install -y git
```

first check:

```bash
git --version
```

This avoids unnecessary changes.

### 2. Understand the difference between normal and bare repositories

```bash
git init
```

creates a working repository.

```bash
git init --bare
```

creates a repository intended to act as a remote/central repository.

### 3. Always verify after making changes

Don't stop after:

```bash
git init --bare /opt/blog.git
```

Validate:

```bash
sudo git --git-dir=/opt/blog.git rev-parse --is-bare-repository
```

Expected:

```text
true
```

---

# 🏁 Lab Status

**Status: COMPLETED ✅**

**Server:** `ststor01`

**Repository:** `/opt/blog.git`

**Git Version:** `2.52.0`

**Repository Type:** Bare Git Repository

**Validation:** `true`

**KodeKloud Result:** Successfully completed