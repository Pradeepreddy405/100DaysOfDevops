# 🔥 IPTables Configuration – Apache Port 5000

## 📌 Task

The Nautilus infrastructure had Apache running on port `5000` on all application servers.

The security requirement was:

1. Install `iptables` and required dependencies on all application servers.
2. Allow port `5000` **only from the Load Balancer (LBR)**.
3. Block port `5000` from all other sources.
4. Make the firewall rules **persistent across reboot**.

---

# 🏗️ Architecture

```text
                    ┌─────────────────────┐
                    │     LBR Server      │
                    │ 10.244.226.173      │
                    └──────────┬──────────┘
                               │
                               │ TCP 5000
                               │ ✅ ALLOW
                               ▼
                    ┌─────────────────────┐
                    │    App Servers      │
                    │ Apache :5000        │
                    └─────────────────────┘
                               ▲
                               │
                    TCP 5000   │ ❌ BLOCK
                               │
                    Other Hosts
```

---

# 🔹 Step 1: Install IPTables

Run on every application server:

```bash
sudo dnf install -y iptables iptables-services
```

Verify installation:

```bash
iptables --version
```

---

# 🔹 Step 2: Find the LBR IP

On the Load Balancer server:

```bash
hostname -I
```

Example:

```text
10.244.226.173
```

This IP will be used as the trusted source.

---

# 🔹 Step 3: Check Existing IPTables Rules

On the App Server:

```bash
sudo iptables -L INPUT -n --line-numbers
```

Example:

```text
Chain INPUT (policy ACCEPT)

num  target     prot opt source          destination
1    ACCEPT     all  --  0.0.0.0/0       0.0.0.0/0
2    ACCEPT     icmp --  0.0.0.0/0       0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0       0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0       0.0.0.0/0  tcp dpt:22
5    REJECT     all  --  0.0.0.0/0       0.0.0.0/0
```

### Important

The `ACCEPT` rule for the LBR must come **before** any catch-all `REJECT` rule.

---

# 🔹 Step 4: Allow LBR Access to Port 5000

Use the LBR IP:

```bash
sudo iptables -I INPUT 5 -p tcp -s 10.244.226.173 --dport 5000 -j ACCEPT
```

Explanation:

```text
-I INPUT 5         → Insert rule at position 5
-p tcp             → TCP traffic
-s 10.244.226.173  → Traffic from LBR
--dport 5000       → Apache port
-j ACCEPT           → Allow traffic
```

---

# 🔹 Step 5: Block Everyone Else on Port 5000

```bash
sudo iptables -I INPUT 6 -p tcp --dport 5000 -j DROP
```

This means:

```text
LBR → Port 5000       ✅ ALLOW
Everyone else → 5000  ❌ DROP
```

---

# 🔹 Step 6: Verify IPTables Rules

```bash
sudo iptables -L INPUT -n --line-numbers
```

Expected result:

```text
num  target     prot opt source               destination
5    ACCEPT     tcp  --  10.244.226.173       0.0.0.0/0   tcp dpt:5000
6    DROP       tcp  --  0.0.0.0/0            0.0.0.0/0   tcp dpt:5000
```

### Rule Order

The order is critical:

```text
1. ACCEPT LBR → 5000
2. DROP everyone else → 5000
```

If `DROP` comes first, the LBR request will also be blocked.

---

# 🔹 Step 7: Test Apache Locally

On the App Server:

```bash
curl http://localhost:5000
```

Apache should return the application/webpage response.

---

# 🔹 Step 8: Test from LBR

From the Load Balancer:

```bash
curl http://APP_SERVER_IP:5000
```

Example:

```bash
curl http://10.244.226.171:5000
```

Expected:

```text
✅ Connection successful
```

---

# 🔹 Step 9: Test from Another Host

From a host other than the LBR:

```bash
curl http://APP_SERVER_IP:5000
```

Expected:

```text
❌ Connection blocked
```

---

# 🔹 Step 10: Save IPTables Rules

Runtime IPTables rules are not automatically permanent.

Save them:

```bash
sudo iptables-save | sudo tee /etc/sysconfig/iptables
```

Verify:

```bash
sudo cat /etc/sysconfig/iptables
```

The port `5000` rules should appear in the file.

---

# 🔹 Step 11: Enable IPTables at Boot

```bash
sudo systemctl enable iptables
```

Verify:

```bash
sudo systemctl is-enabled iptables
```

Expected:

```text
enabled
```

---

# 🔹 Final Configuration

The final IPTables configuration should provide:

```text
                 ┌───────────────────┐
                 │        LBR        │
                 │ 10.244.226.173    │
                 └─────────┬─────────┘
                           │
                           │ TCP/5000
                           ▼
                     ┌───────────┐
                     │ App Server│
                     │  :5000    │
                     └───────────┘
                           ▲
                           │
                           │ TCP/5000
                           X
                     Other Hosts
```

### Result

| Source | Port | Result |
|---|---:|---|
| LBR `10.244.226.173` | 5000 | ✅ ALLOW |
| Any other host | 5000 | ❌ DROP |
| SSH | 22 | ✅ Existing rule remains |
| Established connections | — | ✅ Existing rule remains |

---

# 🧠 Important IPTables Concepts

### `-A` vs `-I`

Append a rule:

```bash
sudo iptables -A INPUT ...
```

Insert a rule:

```bash
sudo iptables -I INPUT 5 ...
```

Use `-I` when the rule needs to be placed **before an existing rule**.

In this task, the LBR `ACCEPT` rule must be before the `DROP` rule.

---

### `ACCEPT` vs `DROP`

```text
ACCEPT → Allow the traffic
DROP   → Silently block the traffic
```

---

### Why save the rules?

This:

```bash
sudo iptables -A ...
```

changes the **currently running firewall**.

This:

```bash
sudo iptables-save | sudo tee /etc/sysconfig/iptables
```

stores the rules so they can be restored after reboot.

---

# ✅ Complete Command Summary

```bash
# Install
sudo dnf install -y iptables iptables-services

# Check existing rules
sudo iptables -L INPUT -n --line-numbers

# Allow LBR
sudo iptables -I INPUT 5 -p tcp -s 10.244.226.173 --dport 5000 -j ACCEPT

# Block everyone else
sudo iptables -I INPUT 6 -p tcp --dport 5000 -j DROP

# Verify
sudo iptables -L INPUT -n --line-numbers

# Save permanently
sudo iptables-save | sudo tee /etc/sysconfig/iptables

# Enable at boot
sudo systemctl enable iptables

# Verify
sudo systemctl is-enabled iptables
```

---

# 🎯 Interview Explanation

**Question:** How did you secure Apache port 5000?

**Answer:**

> "I installed IPTables on all application servers and configured an INPUT rule to allow TCP port 5000 only from the Load Balancer IP. I then added a DROP rule for port 5000 to block all other sources. Finally, I saved the IPTables configuration to `/etc/sysconfig/iptables` and enabled the IPTables service so the rules persist after reboot."

---

# 📝 Key Takeaways

```text
iptables
   ↓
INPUT chain
   ↓
Allow LBR → TCP 5000
   ↓
Drop everyone else → TCP 5000
   ↓
Save rules
   ↓
Enable service
   ↓
Persistent firewall configuration ✅
```