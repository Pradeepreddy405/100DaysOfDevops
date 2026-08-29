# Create Git Branch from Master – Nautilus Project

## 📌 Task Description

The Nautilus development team required a new feature branch for the `media` project repository.

The requirement was to create a new branch named:

```text
xfusioncorp_media
```

The branch had to be created from the existing **`master`** branch on the **Storage Server** in the Stratos Datacenter.

> **Note:** No application source code or project files were modified.

---

## 🖥️ Infrastructure Details

| Component | Details |
|---|---|
| Server | Storage Server |
| Hostname | `ststor01` |
| User | `natasha` |
| Datacenter | Stratos Datacenter |
| Repository | `/usr/src/kodekloudrepos/media` |
| Source Branch | `master` |
| New Branch | `xfusioncorp_media` |

---

## 🔐 Step 1: Connect to the Storage Server

From the jump host, connect to the Storage Server:

```bash
ssh natasha@ststor01
```

Verify the hostname:

```bash
hostname
```

Expected output:

```text
ststor01
```

Verify the logged-in user:

```bash
whoami
```

Expected output:

```text
natasha
```

---

## 📂 Step 2: Navigate to the Repository

Change to the `media` repository:

```bash
cd /usr/src/kodekloudrepos/media
```

Verify the current directory:

```bash
pwd
```

Expected output:

```text
/usr/src/kodekloudrepos/media
```

---

## 🌿 Step 3: Check Existing Branches

List the existing branches:

```bash
git branch
```

Initially, the repository contained:

```text
* kodekloud_media
  master
```

The required source branch was **`master`**.

---

## 🔎 Step 4: Verify Repository Ownership and Permissions

Check the repository ownership:

```bash
ls -ld /usr/src/kodekloudrepos/media
```

Check the `.git` directory:

```bash
ls -ld /usr/src/kodekloudrepos/media/.git
```

Check the Git index:

```bash
ls -l /usr/src/kodekloudrepos/media/.git/index
```

The repository and Git metadata were owned by:

```text
root root
```

Because the repository was owned by `root`, Git operations performed by `natasha` could encounter permission issues when modifying Git metadata.

Git also reported an ownership protection error:

```text
fatal: detected dubious ownership in repository at
'/usr/src/kodekloudrepos/media'
```

To mark the repository as trusted:

```bash
git config --global --add safe.directory /usr/src/kodekloudrepos/media
```

For operations requiring write access to the root-owned Git metadata, `sudo` was used.

---

## 🧾 Step 5: Verify the Master Branch

Before creating the feature branch, verify the latest commit on `master`:

```bash
git log -1 --oneline master
```

Expected output:

```text
14c8ea3 (origin/master, master) initial commit
```

This confirmed that `master` was pointing to:

```text
14c8ea3
```

---

## 🔄 Step 6: Checkout Master

Switch to the required source branch:

```bash
sudo git checkout master
```

Expected output:

```text
Switched to branch 'master'
Your branch is up to date with 'origin/master'.
```

Verify the active branch:

```bash
git branch
```

Expected output:

```text
* master
  kodekloud_media
```

---

## 🌱 Step 7: Create the Feature Branch

Create the new branch from the currently checked-out `master` branch:

```bash
sudo git checkout -b xfusioncorp_media
```

Expected output:

```text
Switched to a new branch 'xfusioncorp_media'
```

The command performs two operations:

1. Creates `xfusioncorp_media` from the current `master` commit.
2. Switches the working tree to `xfusioncorp_media`.

---

## ✅ Step 8: Verify the New Branch

List the branches:

```bash
git branch
```

Expected output:

```text
  kodekloud_media
  master
* xfusioncorp_media
```

The `*` indicates that `xfusioncorp_media` is the currently active branch.

---

## 🔍 Step 9: Verify the Branch Starting Point

Check the latest commit:

```bash
git log -1 --oneline
```

Expected output:

```text
14c8ea3 (HEAD -> xfusioncorp_media, master, origin/master) initial commit
```

This confirms that both branches point to the same starting commit:

```text
master
   │
   └── 14c8ea3
          │
          └── xfusioncorp_media
```

Therefore, the feature branch was created directly from `master`.

---

## 🧪 Step 10: Final Verification

Check the repository status:

```bash
git status
```

The repository should show:

```text
On branch xfusioncorp_media
```

Verify the latest commit on both branches:

```bash
git log -1 --oneline master
git log -1 --oneline xfusioncorp_media
```

Both should point to:

```text
14c8ea3 initial commit
```

This confirms that the new branch was created correctly without introducing any additional commits or code changes.

---

## 📸 Verification Evidence

The terminal verification confirmed:

- Successful login to `ststor01`
- Correct user: `natasha`
- Correct repository path
- Existing `master` branch
- `master` pointing to commit `14c8ea3`
- Successful checkout of `master`
- Successful creation of `xfusioncorp_media`
- `HEAD` pointing to `xfusioncorp_media`
- `xfusioncorp_media` and `master` pointing to the same commit
- No application source code modifications

---

## 🎯 Final Result

The required feature branch was successfully created:

```text
xfusioncorp_media
```

from:

```text
master
```

### Repository

```text
/usr/src/kodekloudrepos/media
```

### Storage Server

```text
ststor01
```

### User

```text
natasha
```

### Starting Commit

```text
14c8ea3 initial commit
```

### Final Branch State

```text
  kodekloud_media
  master
* xfusioncorp_media
```

No application source code or project files were modified.

---

## 💡 Key Git / DevOps Concepts

### 1. `git checkout -b`

```bash
git checkout -b <branch-name>
```

Creates a new branch from the currently checked-out commit and immediately switches to it.

In this task:

```bash
sudo git checkout master
sudo git checkout -b xfusioncorp_media
```

This ensured that `xfusioncorp_media` was created from `master`.

---

### 2. Repository Ownership

The repository was owned by `root`:

```text
root root
```

Therefore, operations that modified Git metadata could require elevated privileges.

This is why commands such as:

```bash
sudo git checkout master
sudo git checkout -b xfusioncorp_media
```

were used.

---

### 3. `.git/index.lock`

Git creates a temporary lock file such as:

```text
.git/index.lock
```

when modifying the Git index.

If the current user does not have write permissions to the `.git` directory, Git operations that update the index may fail with:

```text
Permission denied
```

The important troubleshooting step is to check:

```bash
ls -ld .git
ls -l .git/index
```

before changing permissions or using elevated privileges.

---

### 4. Git Safe Directory

Git can reject repositories owned by another user with:

```text
fatal: detected dubious ownership in repository
```

The repository can be explicitly marked as trusted:

```bash
git config --global --add safe.directory /usr/src/kodekloudrepos/media
```

This addresses Git's ownership safety check.

---

## 🔄 Check → Change → Verify Workflow

This task demonstrates a practical DevOps operational workflow:

```text
CHECK
  │
  ├── Verify server
  ├── Verify user
  ├── Verify repository
  ├── Verify permissions
  └── Verify existing branches
       │
       ▼
CHANGE
  │
  ├── Checkout master
  └── Create feature branch
       │
       ▼
VERIFY
  │
  ├── Verify active branch
  ├── Verify commit
  ├── Verify repository status
  └── Compare master and feature branch
```

This approach reduces accidental changes and makes infrastructure operations easier to troubleshoot and audit.

---

## 🏁 Conclusion

The Nautilus `media` repository was successfully prepared for feature development by creating the required:

```text
xfusioncorp_media
```

branch from:

```text
master
```

The new branch starts from the expected commit:

```text
14c8ea3
```

The repository remains clean, and no application source code was modified during the operation.

---

## 🛠️ Commands Summary

For quick reference:

```bash
# Connect to Storage Server
ssh natasha@ststor01

# Navigate to repository
cd /usr/src/kodekloudrepos/media

# Verify repository
pwd
git branch

# Trust repository if Git reports dubious ownership
git config --global --add safe.directory /usr/src/kodekloudrepos/media

# Verify master commit
git log -1 --oneline master

# Switch to master
sudo git checkout master

# Create feature branch
sudo git checkout -b xfusioncorp_media

# Verify branch
git branch

# Verify commit
git log -1 --oneline

# Verify working tree
git status

# Compare branch starting commits
git log -1 --oneline master
git log -1 --oneline xfusioncorp_media
```