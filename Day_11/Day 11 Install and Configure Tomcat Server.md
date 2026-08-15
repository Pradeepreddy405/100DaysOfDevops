# Tomcat Installation, Port Configuration & ROOT.war Deployment

## 📌 Task Overview

The **Nautilus application development team** has completed the beta version of a Java-based application and wants to deploy it on **App Server 1** in the **Stratos DC** environment.

The application server selected is **Apache Tomcat**.

### Requirements

1. Install Tomcat on **App Server 1 (`stapp01`)**
2. Configure Tomcat to listen on **port `6400`**
3. Deploy the `ROOT.war` file available on the **Jump Host** at:
   ```text
   /tmp/ROOT.war
   ```
4. The application must be accessible directly through:
   ```text
   http://stapp01:6400
   ```

---

# 🏗️ Environment

```text
                    Stratos DC
                       |
                       |
                ┌──────────────┐
                │  Jump Host   │
                │              │
                │ /tmp/ROOT.war│
                └──────┬───────┘
                       |
                       | SCP
                       ↓
                ┌──────────────┐
                │   stapp01    │
                │ App Server 1 │
                │              │
                │   Tomcat     │
                │   Port 6400  │
                │              │
                │ /webapps/    │
                │   ROOT.war   │
                └──────┬───────┘
                       |
                       ↓
              http://stapp01:6400
```

---

# 1. Connect to App Server 1

From the **Jump Host**, connect to `stapp01`.

```bash
ssh tony@stapp01
```

> Replace `tony` with the username provided by your lab environment.

Verify the server:

```bash
hostname
```

Expected:

```text
stapp01
```

---

# 2. Check the Operating System

Before installing anything, identify the Linux distribution.

```bash
cat /etc/os-release
```

Also check whether Tomcat is already installed:

```bash
rpm -qa | grep -i tomcat
```

If nothing is returned, Tomcat is probably not installed through RPM.

---

# 3. Check Available Tomcat Packages

Before installing Tomcat, check whether the package exists in the configured repositories.

```bash
sudo dnf list available | grep -i tomcat
```

You can also search installed/available packages with:

```bash
sudo dnf search tomcat
```

If the `tomcat` package is available, install it.

---

# 4. Install Tomcat

Install Tomcat:

```bash
sudo dnf install -y tomcat
```

Verify the installation:

```bash
rpm -qa | grep -i tomcat
```

You should see one or more Tomcat-related packages.

Check the Tomcat service:

```bash
systemctl status tomcat
```

At this point, Tomcat may not yet be running.

---

# 5. Locate Tomcat Configuration

The main Tomcat configuration is normally under:

```text
/etc/tomcat/
```

List the directory:

```bash
sudo ls -lah /etc/tomcat/
```

The important configuration file is:

```text
/etc/tomcat/server.xml
```

Tomcat's HTTP Connector controls the TCP port on which Tomcat accepts HTTP connections.

---

# 6. Check the Current Tomcat Port

Search `server.xml` for the HTTP connector:

```bash
sudo grep -n "Connector port" /etc/tomcat/server.xml
```

You will normally find something similar to:

```xml
<Connector port="8080" protocol="HTTP/1.1"
```

The default HTTP port is commonly `8080`.

---

# 7. Change Tomcat Port from 8080 to 6400

Create a backup before modifying the configuration:

```bash
sudo cp /etc/tomcat/server.xml /etc/tomcat/server.xml.bak
```

Edit the configuration:

```bash
sudo vi /etc/tomcat/server.xml
```

Find:

```xml
<Connector port="8080"
```

Change it to:

```xml
<Connector port="6400"
```

### Important

Do **not** blindly replace every occurrence of `8080`.

The requirement is specifically to change the **HTTP Connector** to:

```text
6400
```

Tomcat documentation defines the Connector `port` as the TCP port where the connector creates its server socket and waits for incoming connections.

Verify the change:

```bash
sudo grep -n "Connector port" /etc/tomcat/server.xml
```

---

# 8. Check Whether Port 6400 Is Already in Use

Before starting Tomcat, check the port:

```bash
sudo ss -lntp | grep 6400
```

If nothing is returned, port `6400` is free.

You can also use:

```bash
sudo netstat -lntp | grep 6400
```

if `netstat` is installed.

### Why this matters

Two applications cannot normally listen on the same IP address and TCP port.

If another process is already listening on `6400`, Tomcat will fail to start.

---

# 9. Start Tomcat

Enable Tomcat at boot:

```bash
sudo systemctl enable tomcat
```

Start the service:

```bash
sudo systemctl start tomcat
```

Or combine both:

```bash
sudo systemctl enable --now tomcat
```

Check the service:

```bash
sudo systemctl status tomcat
```

You want:

```text
Active: active (running)
```

---

# 10. Verify Tomcat Is Listening on Port 6400

Run:

```bash
sudo ss -lntp | grep 6400
```

Expected output will look similar to:

```text
LISTEN 0 100 0.0.0.0:6400 0.0.0.0:* users:(("java",pid=...,fd=...))
```

The exact output can differ depending on the operating system and Tomcat/Java version.

---

# 11. Test Tomcat Before Deploying the Application

From `stapp01`:

```bash
curl http://localhost:6400
```

If Tomcat is working, you should receive an HTTP response.

You can also test:

```bash
curl -I http://localhost:6400
```

Expected response should contain something similar to:

```text
HTTP/1.1 200
```

At this point:

```text
Tomcat
   ↓
Port 6400
   ↓
HTTP request
```

is working.

---

# 12. Find the Tomcat Web Application Directory

The WAR file must be deployed into Tomcat's application directory.

For a package-based installation, this is commonly:

```text
/var/lib/tomcat/webapps/
```

Check:

```bash
sudo ls -lah /var/lib/tomcat/webapps/
```

Tomcat deployments commonly use the `webapps` application base directory, where WAR files can be placed for deployment.

---

# 13. Check `ROOT.war` on the Jump Host

Exit from `stapp01`:

```bash
exit
```

You should now be back on the Jump Host.

Check the WAR file:

```bash
ls -lh /tmp/ROOT.war
```

Expected:

```text
-rw-r--r-- ... /tmp/ROOT.war
```

If the file does not exist:

```bash
ls -lah /tmp/
```

and verify the exact filename.

---

# 14. Copy `ROOT.war` to App Server 1

From the Jump Host:

```bash
scp /tmp/ROOT.war tony@stapp01:/tmp/
```

Verify that the transfer succeeded:

```bash
ssh tony@stapp01
```

Then:

```bash
ls -lh /tmp/ROOT.war
```

---

# 15. Deploy `ROOT.war`

Move the WAR file into Tomcat's `webapps` directory:

```bash
sudo mv /tmp/ROOT.war /var/lib/tomcat/webapps/
```

Verify:

```bash
sudo ls -lh /var/lib/tomcat/webapps/
```

You should see:

```text
ROOT.war
```

---

# 16. Why Is It Called `ROOT.war`?

This is one of the important concepts in this task.

Suppose you deploy:

```text
myapp.war
```

Tomcat normally makes the application available under:

```text
http://server:port/myapp
```

But the requirement is:

```text
http://stapp01:6400
```

with **no application path**.

Therefore the application needs to be deployed as:

```text
ROOT.war
```

The `ROOT` application represents the root context:

```text
/
```

So:

```text
ROOT.war
     ↓
/
     ↓
http://stapp01:6400/
```

This is why simply deploying a file such as:

```text
nautilus.war
```

would not satisfy the requirement.

You would typically access it as:

```text
http://stapp01:6400/nautilus
```

instead.

---

# 17. Restart Tomcat

After deploying the WAR:

```bash
sudo systemctl restart tomcat
```

Check:

```bash
sudo systemctl status tomcat
```

---

# 18. Verify WAR Deployment

Check the webapps directory:

```bash
sudo ls -lah /var/lib/tomcat/webapps/
```

You should normally see:

```text
ROOT.war
ROOT/
```

The `ROOT/` directory indicates that Tomcat has unpacked the WAR.

Depending on the Tomcat configuration, automatic WAR deployment/unpacking behavior can vary. Tomcat's deployment configuration controls this behavior.

---

# 19. Test the Application Locally

On `stapp01`:

```bash
curl http://localhost:6400
```

This should return the HTML generated by the application.

Also test:

```bash
curl -I http://localhost:6400
```

---

# 20. Test Using the Hostname

Still on `stapp01`:

```bash
curl http://stapp01:6400
```

The requirement specifically says the application must work using:

```text
http://stapp01:6400
```

So this test is important.

---

# 21. Test From the Jump Host

Exit from App Server 1:

```bash
exit
```

From the Jump Host:

```bash
curl http://stapp01:6400
```

If the application's HTML is returned, the deployment is successful.

---

# 22. Complete Verification

Run these checks on `stapp01`:

### Tomcat service

```bash
sudo systemctl is-active tomcat
```

Expected:

```text
active
```

### Port

```bash
sudo ss -lntp | grep 6400
```

Expected:

```text
LISTEN ... :6400 ... java
```

### WAR

```bash
sudo ls -lh /var/lib/tomcat/webapps/ROOT.war
```

### Application

```bash
curl http://localhost:6400
```

### Hostname

```bash
curl http://stapp01:6400
```

### Remote test

From Jump Host:

```bash
curl http://stapp01:6400
```

---

# 🔍 Troubleshooting

## Problem 1: Tomcat is not running

Check:

```bash
sudo systemctl status tomcat
```

Then inspect logs:

```bash
sudo journalctl -u tomcat --no-pager -n 100
```

---

## Problem 2: Port 6400 is not listening

Check:

```bash
sudo ss -lntp | grep 6400
```

Check the configuration:

```bash
sudo grep -n "Connector port" /etc/tomcat/server.xml
```

Make sure the HTTP Connector is configured with:

```xml
port="6400"
```

Then restart:

```bash
sudo systemctl restart tomcat
```

---

## Problem 3: Tomcat fails after changing the port

Check the logs:

```bash
sudo journalctl -u tomcat --no-pager -n 100
```

Also validate that another process isn't using the port:

```bash
sudo ss -lntp | grep 6400
```

---

## Problem 4: `ROOT.war` is not deployed

Check:

```bash
sudo ls -lah /var/lib/tomcat/webapps/
```

If `ROOT.war` is missing:

```bash
sudo mv /tmp/ROOT.war /var/lib/tomcat/webapps/
```

Then:

```bash
sudo systemctl restart tomcat
```

---

## Problem 5: `/` doesn't show the application

Check whether the ROOT application was unpacked:

```bash
sudo ls -lah /var/lib/tomcat/webapps/
```

You should normally have:

```text
ROOT/
ROOT.war
```

Check Tomcat logs:

```bash
sudo journalctl -u tomcat --no-pager -n 200
```

Look for errors related to:

```text
ROOT
deployment
application startup
ServletException
ClassNotFoundException
```

---

## Problem 6: Local curl works but Jump Host curl fails

If this works:

```bash
curl http://localhost:6400
```

but this fails from the Jump Host:

```bash
curl http://stapp01:6400
```

then Tomcat itself is probably working.

Check what address Tomcat is listening on:

```bash
sudo ss -lntp | grep 6400
```

If it is listening on:

```text
127.0.0.1:6400
```

it is only accessible locally.

If it is listening on:

```text
0.0.0.0:6400
```

or the server's appropriate interface address, remote access should be possible subject to firewall/network rules.

Then check the firewall:

```bash
sudo firewall-cmd --list-ports
```

If the lab requires opening the port:

```bash
sudo firewall-cmd --permanent --add-port=6400/tcp
sudo firewall-cmd --reload
```

Then test again from the Jump Host:

```bash
curl http://stapp01:6400
```

**Do not change firewall rules blindly.** First establish that the service is actually listening and that the connection is being blocked.

---

# 🧠 What We Learned

This task demonstrates several real-world DevOps concepts:

### 1. Package Management

```bash
dnf install
rpm -qa
```

Used to install and verify software packages.

### 2. Service Management

```bash
systemctl start
systemctl stop
systemctl restart
systemctl enable
systemctl status
```

Used to manage Linux services.

### 3. Application Configuration

```text
/etc/tomcat/server.xml
```

Tomcat's HTTP Connector determines which TCP port accepts HTTP traffic.

### 4. Networking

```bash
ss -lntp
netstat -lntp
curl
```

Used to verify whether an application is actually listening and reachable.

### 5. Secure File Transfer

```bash
scp
```

Used to transfer the WAR file from the Jump Host to the application server.

### 6. Java Application Deployment

```text
ROOT.war
     ↓
Tomcat webapps
     ↓
ROOT/
     ↓
HTTP :6400
```

### 7. Root Context

Deploying:

```text
ROOT.war
```

allows the application to be accessed at:

```text
http://stapp01:6400/
```

instead of:

```text
http://stapp01:6400/application-name/
```

---

# 📋 Final Command Summary

```bash
# Connect to App Server
ssh tony@stapp01

# Check OS
cat /etc/os-release

# Check Tomcat
rpm -qa | grep -i tomcat

# Check available package
sudo dnf list available | grep -i tomcat

# Install Tomcat
sudo dnf install -y tomcat

# Backup configuration
sudo cp /etc/tomcat/server.xml /etc/tomcat/server.xml.bak

# Edit Tomcat port
sudo vi /etc/tomcat/server.xml

# Verify connector
sudo grep -n "Connector port" /etc/tomcat/server.xml

# Check port
sudo ss -lntp | grep 6400

# Start and enable Tomcat
sudo systemctl enable --now tomcat

# Verify service
sudo systemctl status tomcat

# Verify port
sudo ss -lntp | grep 6400

# Exit to Jump Host
exit

# Verify WAR
ls -lh /tmp/ROOT.war

# Copy WAR
scp /tmp/ROOT.war tony@stapp01:/tmp/

# Connect again
ssh tony@stapp01

# Deploy WAR
sudo mv /tmp/ROOT.war /var/lib/tomcat/webapps/

# Restart Tomcat
sudo systemctl restart tomcat

# Verify deployment
sudo ls -lah /var/lib/tomcat/webapps/

# Test locally
curl http://localhost:6400

# Test using hostname
curl http://stapp01:6400

# Exit
exit

# Test from Jump Host
curl http://stapp01:6400
```

---

# ✅ Expected Final Architecture

```text
                    Jump Host
                       |
                       | scp
                       |
                 /tmp/ROOT.war
                       |
                       ↓
                ┌───────────────┐
                │    stapp01    │
                │  App Server 1 │
                │               │
                │    Tomcat     │
                │               │
                │    :6400      │
                │       │       │
                │       ↓       │
                │  webapps/     │
                │    ROOT.war    │
                │       │       │
                │       ↓       │
                │     ROOT/      │
                └───────┬───────┘
                        │
                        ↓
               http://stapp01:6400
                        │
                        ↓
                 Nautilus Java App
```

# 🎯 Success Criteria

The task is complete only when **all four** conditions are true:

```text
[✓] Tomcat installed on stapp01
[✓] Tomcat listening on port 6400
[✓] ROOT.war deployed
[✓] curl http://stapp01:6400 returns the application
```

The most important final validation is:

```bash
curl http://stapp01:6400
```

If that returns the application's webpage/HTML, the deployment requirement has been satisfied.