# KodeKloud Nautilus — Fork Git Repository in Gitea

## Task Overview

A new developer named **Jon** joined the Nautilus project team and needed to start working on an existing Git repository.

The task was to:

1. Open the **Gitea UI** from the KodeKloud lab.
2. Log in to Gitea using the `jon` account.
3. Locate the repository `sarah/story-blog`.
4. Fork the repository under the `jon` user.

---

## Infrastructure Details

| Item | Details |
|---|---|
| Git Platform | Gitea |
| User | `jon` |
| Repository Owner | `sarah` |
| Repository | `story-blog` |
| Source Repository | `sarah/story-blog` |
| Target Fork | `jon/story-blog` |

> **Note:** The password is intentionally not documented in this README. Avoid committing credentials or secrets to GitHub.

---

# Step-by-Step Execution

## Step 1 — Open Gitea UI

From the KodeKloud lab environment, click the **Gitea UI** button in the top navigation bar.

This opens the Gitea web interface where the repository can be accessed.

![Gitea UI and login details](images/01-gitea-login.png)

---

## Step 2 — Log in to Gitea

Use the credentials provided by the lab:

```text
Username: jon
Password: <lab-provided password>
```

Click **Sign In**.

After successful authentication, you will be logged in as the `jon` user.

---

## Step 3 — Locate the Repository

Find the existing repository:

```text
sarah/story-blog
```

Open the repository page.

The repository contains the existing project files and has a **Fork** button in the upper-right section.

![Sarah's story-blog repository](images/02-story-blog-fork.png)

---

## Step 4 — Fork the Repository

Click the **Fork** button.

When Gitea asks where to create the fork:

- Select **`jon`** as the owner.
- Keep the repository name as **`story-blog`**.
- Confirm the fork.

The resulting repository should belong to Jon:

```text
jon/story-blog
```

---

# Verification

The final repository relationship should be:

```text
Original Repository
        |
        v
sarah/story-blog
        |
        | Fork
        v
jon/story-blog
```

The important verification is that the fork is under the **`jon`** account and not under `sarah`.

---

## Result

The repository `sarah/story-blog` was forked into the `jon` user account as:

```text
jon/story-blog
```

This completes the Gitea repository forking task.

---

## Key Git/Gitea Concept

### What is a Fork?

A **fork** creates an independent copy of an existing repository under another user or organization.

For this task:

```text
sarah/story-blog
       |
       | fork
       v
jon/story-blog
```

Jon can now work on his own copy without directly modifying Sarah's original repository.

---

## Screenshots

### Gitea Login

![Step 1 - Gitea Login](images/01-gitea-login.png)

### Repository and Fork Button

![Step 2 - Sarah story-blog repository](images/02-story-blog-fork.png)

---

## Important

Do **not** commit passwords, API keys, SSH private keys, or other credentials to a public GitHub repository.

For KodeKloud labs, document the **procedure and result**, but keep lab credentials out of the README.
