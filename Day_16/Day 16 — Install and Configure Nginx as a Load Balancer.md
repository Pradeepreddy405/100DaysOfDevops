# Day 16 — Install and Configure Nginx as a Load Balancer

## 📌 Lab Overview

This lab demonstrates how to configure **Nginx as a Load Balancer (LBR)** in a multi-server environment.

The objective is to configure the `LBR` server so that incoming HTTP traffic on port `80` is distributed across all available application servers.

### Architecture

```text
                         Client
                           |
                           | HTTP :80
                           v
                  +-------------------+
                  |      stlb01        |
                  |  Nginx Load       |
                  |     Balancer       |
                  +---------+---------+
                            |
              +-------------+-------------+
              |             |             |
              v             v             v
        +-----------+ +-----------+ +-----------+
        | stapp01   | | stapp02   | | stapp03   |
        | Apache    | | Apache    | | Apache    |
        | :5001     | | :5001     | | :5001     |
        +-----------+ +-----------+ +-----------+
```

---

## 🎯 Lab Requirements

- Install Nginx on `stlb01` if not already installed.
- Configure Nginx as a Load Balancer.
- Use the `http` context in `/etc/nginx/nginx.conf`.
- Include **all App Servers** in the upstream configuration.
- Do not change the existing Apache ports.
- Ensure Apache is running on all App Servers.
- Make the website accessible through:

```bash
curl http://stlb01:80
```

---

## 🖥️ Server Information

| Server | Role | Service | Port |
|---|---|---|---:|
| `stlb01` | Load Balancer | Nginx | 80 |
| `stapp01` | Application Server | Apache | 5001 |
| `stapp02` | Application Server | Apache | 5001 |
| `stapp03` | Application Server | Apache | 5001 |

> **Note:** Always verify the Apache port using `ss` before configuring Nginx. Do not blindly assume the port.

---

# 🚀 Implementation

## 1. Connect to the Load Balancer

```bash
ssh loki@stlb01
```

Verify the hostname:

```bash
hostname
```

Expected:

```text
stlb01
```

---

## 2. Install Nginx

Install Nginx:

```bash
sudo dnf install nginx -y
```

Verify installation:

```bash
nginx -v
```

---

## 3. Verify Apache on App Servers

From `stlb01`, test each backend server.

### App Server 1

```bash
curl http://stapp01:5001
```

### App Server 2

```bash
curl http://stapp02:5001
```

### App Server 3

```bash
curl http://stapp03:5001
```

Expected response:

```text
Welcome to xFusionCorp Industries!
```

---

## 4. Verify Apache Port

If the Apache port is unknown, log into each App Server and run:

```bash
sudo ss -lntp | grep httpd
```

Example:

```text
LISTEN 0 128 0.0.0.0:5001 0.0.0.0:* users:(("httpd",pid=1234,fd=4))
```

This confirms that Apache is listening on port `5001`.

---

## 5. Verify Apache Service

On each App Server:

```bash
sudo systemctl status httpd
```

If Apache is stopped:

```bash
sudo systemctl start httpd
sudo systemctl enable httpd
```

Verify again:

```bash
sudo systemctl is-active httpd
```

Expected:

```text
active
```

---

# ⚙️ Configure Nginx Load Balancer

The requirement specifically says to update only:

```text
/etc/nginx/nginx.conf
```

Edit the file:

```bash
sudo vi /etc/nginx/nginx.conf
```

Inside the existing `http { }` context, configure the upstream servers:

```nginx
http {

    upstream app_servers {
        server stapp01:5001;
        server stapp02:5001;
        server stapp03:5001;
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://app_servers;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

}
```

### Important

Do **not** change:

```text
stapp01:5001
stapp02:5001
stapp03:5001
```

to another port unless the actual Apache configuration uses a different port.

The Load Balancer must adapt to the application servers.

---

# 🔍 Test Nginx Configuration

Before restarting Nginx:

```bash
sudo nginx -t
```

Expected:

```text
syntax is ok
test is successful
```

If this fails, **do not restart Nginx**. Fix the configuration first.

---

# ▶️ Start Nginx

```bash
sudo systemctl enable --now nginx
```

Check status:

```bash
sudo systemctl status nginx
```

Verify port 80:

```bash
sudo ss -lntp | grep :80
```

Expected:

```text
LISTEN ... :80 ... nginx
```

---

# 🧪 Testing

## Test Backend Servers Directly

From `stlb01`:

```bash
curl http://stapp01:5001
```

```bash
curl http://stapp02:5001
```

```bash
curl http://stapp03:5001
```

All servers should return:

```text
Welcome to xFusionCorp Industries!
```

---

## Test All Backend Servers

```bash
for server in stapp01 stapp02 stapp03; do
    echo "Testing $server:5001"
    curl -s http://$server:5001
    echo
done
```

Expected:

```text
Testing stapp01:5001
Welcome to xFusionCorp Industries!

Testing stapp02:5001
Welcome to xFusionCorp Industries!

Testing stapp03:5001
Welcome to xFusionCorp Industries!
```

---

# 🌐 Test the Load Balancer

The final test:

```bash
curl http://stlb01:80
```

Expected:

```text
Welcome to xFusionCorp Industries!
```

You can also send multiple requests:

```bash
for i in {1..10}; do
    curl -s http://stlb01:80
    echo
done
```

---

# 🔄 Traffic Flow

```text
                    HTTP Request
                         |
                         v
                  +-------------+
                  |   stlb01    |
                  |    Nginx    |
                  |    :80      |
                  +------+------+
                         |
                    upstream
                  app_servers
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
     stapp01:5001   stapp02:5001   stapp03:5001
          |              |              |
          +--------------+--------------+
                         |
                    Apache Response
                         |
                         v
                       Client
```

---

# 🧠 What I Learned

### 1. Reverse Proxy

Nginx receives the client request and forwards it to a backend server.

```text
Client → Nginx → Apache
```

### 2. Load Balancing

Instead of sending every request to one server:

```text
Client
  |
  v
Server
```

traffic can be distributed:

```text
             Nginx
               |
       +-------+-------+
       |       |       |
      App1   App2    App3
```

### 3. Upstream

Nginx uses the `upstream` block to define backend servers:

```nginx
upstream app_servers {
    server stapp01:5001;
    server stapp02:5001;
    server stapp03:5001;
}
```

### 4. Proxy Pass

The `proxy_pass` directive tells Nginx where to forward requests:

```nginx
proxy_pass http://app_servers;
```

### 5. Backend Ports

The backend Apache servers don't need to listen on port `80`.

For example:

```text
Nginx
  |
  | :80
  v
LBR
  |
  | :5001
  v
Apache
```

---

# 🔧 Useful Troubleshooting Commands

### Check Nginx status

```bash
sudo systemctl status nginx
```

### Check Apache status

```bash
sudo systemctl status httpd
```

### Check listening ports

```bash
sudo ss -lntp
```

### Check Nginx configuration

```bash
sudo nginx -t
```

### Check Nginx logs

```bash
sudo tail -f /var/log/nginx/access.log
```

```bash
sudo tail -f /var/log/nginx/error.log
```

### Test backend connectivity

```bash
curl -v http://stapp01:5001
```

```bash
curl -v http://stapp02:5001
```

```bash
curl -v http://stapp03:5001
```

### Test Load Balancer

```bash
curl -v http://stlb01:80
```

---

# ❌ Common Mistakes

### Mistake 1 — Changing Apache ports

Don't change the existing Apache port just to make Nginx work.

Incorrect:

```text
Change Apache :5001 → :80
```

Correct:

```text
Nginx :80 → Apache :5001
```

---

### Mistake 2 — Putting `upstream` outside `http`

Incorrect:

```nginx
upstream app_servers {
    ...
}

http {
    ...
}
```

Correct:

```nginx
http {

    upstream app_servers {
        ...
    }

}
```

---

### Mistake 3 — Forgetting `nginx -t`

Always test before restarting:

```bash
sudo nginx -t
```

Then:

```bash
sudo systemctl restart nginx
```

---

### Mistake 4 — Testing only Nginx

If this fails:

```bash
curl http://stlb01:80
```

don't immediately blame Nginx.

Test the complete chain:

```text
stlb01
  ↓
stapp01:5001
stapp02:5001
stapp03:5001
```

Then test:

```text
stlb01:80
```

This isolates whether the problem is the **backend or the load balancer**.

---

# ✅ Lab Completion Checklist

- [x] Installed Nginx on `stlb01`
- [x] Verified Apache on `stapp01`
- [x] Verified Apache on `stapp02`
- [x] Verified Apache on `stapp03`
- [x] Verified backend port `5001`
- [x] Configured Nginx upstream
- [x] Added all App Servers
- [x] Used `/etc/nginx/nginx.conf`
- [x] Tested Nginx configuration
- [x] Started Nginx
- [x] Verified port 80
- [x] Tested backend connectivity
- [x] Tested Load Balancer
- [x] Successfully completed the lab

---

## 📚 Key Commands

```bash
sudo dnf install nginx -y

sudo nginx -t

sudo systemctl enable --now nginx

sudo systemctl status nginx

sudo ss -lntp | grep :80

sudo systemctl status httpd

sudo ss -lntp | grep httpd

curl http://stapp01:5001
curl http://stapp02:5001
curl http://stapp03:5001

curl http://stlb01:80
```

---

## 🏆 Result

**Day 16 completed successfully.**

This lab gave practical experience with:

- Nginx
- Reverse Proxy
- Load Balancing
- Upstream servers
- Apache backend servers
- HTTP networking
- Port troubleshooting
- Service management
- Nginx configuration validation

This is an important DevOps concept because the same architecture appears in larger environments using **AWS Load Balancers, Kubernetes Ingress, HAProxy, Nginx, and cloud-native load-balancing solutions**.