# Clone Git Repository to Storage Server

## 📌 Task Overview

The Nautilus application development team requires a copy of an existing Git repository on the **Storage Server** in the Stratos DC.

### Requirements

| Item | Details |
|---|---|
| Server | Storage Server (`ststor01`) |
| User | `natasha` |
| Source Repository | `/opt/media.git` |
| Destination | `/usr/src/kodekloudrepos` |
| Repository Type | Existing Git repository |
| Operation | Clone |
| Restrictions | Do not modify the source repository or existing directories |

Git's `clone` command creates a new repository from an existing repository and establishes the cloned repository's remote configuration.

---

## 🏗️ Infrastructure

```text
Jump Host
    |
    | SSH
    v
Storage Server (ststor01)
    |
    +-- /opt/media.git
    |
    +-- /usr/src/kodekloudrepos/
            |
            +-- media/
                    |
                    +-- .git/
                    +-- repository files
```

---

## 🔧 Step 1 — Connect to Storage Server

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

## 🔍 Step 2 — Verify the Source Repository

Check that the repository exists:

```bash
ls -ld /opt/media.git
```

Verify that it is a bare Git repository:

```bash
git -C /opt/media.git rev-parse --is-bare-repository
```

Expected:

```text
true
```

---

## 🔍 Step 3 — Verify the Destination Directory

Check the existing destination directory:

```bash
ls -ld /usr/src/kodekloudrepos
```

Do **not** change its permissions or ownership.

Avoid unnecessary commands such as:

```bash
chmod
chown
rm -rf
```

The task explicitly requires that existing directories remain unchanged.

---

## 📥 Step 4 — Clone the Repository

Clone `/opt/media.git` into `/usr/src/kodekloudrepos/media`:

```bash
git clone /opt/media.git /usr/src/kodekloudrepos/media
```

Expected output:

```text
Cloning into '/usr/src/kodekloudrepos/media'...
done.
```

The destination is explicitly specified so that Git creates the working copy under the required directory. Git documents the final argument as the directory into which the repository is cloned.

---

## 🔎 Step 5 — Verify the Cloned Repository

List the destination:

```bash
ls -la /usr/src/kodekloudrepos/
```

Expected:

```text
media
```

Enter the cloned repository:

```bash
cd /usr/src/kodekloudrepos/media
```

Check its contents:

```bash
ls -la
```

You should see:

```text
.git
```

and the repository files.

---

## 🔎 Step 6 — Verify Git Status

Run:

```bash
git status
```

Expected output should indicate a clean working tree, for example:

```text
On branch master
nothing to commit, working tree clean
```

The branch may instead be `main`, depending on the source repository.

---

## 🔗 Step 7 — Verify Remote

Run:

```bash
git remote -v
```

Expected:

```text
origin  /opt/media.git (fetch)
origin  /opt/media.git (push)
```

Git normally configures the cloned repository's remote as `origin`.

---

## 🧪 Step 8 — Verify Repository Integrity

Check that Git recognizes the directory as a working tree:

```bash
git rev-parse --is-inside-work-tree
```

Expected:

```text
true
```

Check the available commits:

```bash
git log --oneline -5
```

---

## 🚫 Important Restrictions

Do **not**:

```bash
sudo git clone ...
```

The task specifically requires the operation to be performed as `natasha`.

Do **not** modify the source repository:

```text
/opt/media.git
```

Do **not** change permissions:

```bash
chmod
```

Do **not** change ownership:

```bash
chown
```

Do **not** delete or recreate:

```text
/usr/src/kodekloudrepos
```

Do **not** use:

```bash
git init
```

The repository already exists; the required operation is `git clone`.

---

## ⚡ Complete Command Sequence

If you are already logged into `ststor01` as `natasha`:

```bash
whoami
hostname

ls -ld /opt/media.git
ls -ld /usr/src/kodekloudrepos

git clone /opt/media.git /usr/src/kodekloudrepos/media

cd /usr/src/kodekloudrepos/media

git status
git remote -v
git rev-parse --is-inside-work-tree
git log --oneline -5
```

---

## ✅ Expected Final State

```text
/usr/src/kodekloudrepos/
└── media/
    ├── .git/
    └── repository files
```

### Validation Checklist

- [ ] Connected to `ststor01`
- [ ] Operation performed as `natasha`
- [ ] `/opt/media.git` verified
- [ ] `/usr/src/kodekloudrepos` left unchanged
- [ ] Repository cloned successfully
- [ ] `/usr/src/kodekloudrepos/media` exists
- [ ] `.git` directory exists
- [ ] `git status` is clean
- [ ] `origin` points to `/opt/media.git`
- [ ] No unnecessary permission or ownership changes made

## 🎯 Result

The existing `/opt/media.git` repository was cloned as the `natasha` user into:

```text
/usr/src/kodekloudrepos/media
```

No modifications were made to the source repository or existing destination directory.