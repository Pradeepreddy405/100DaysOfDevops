###  Day 2: Temporary User Setup with Expiry

### 1 Explanation 
 - This task is about temporary access management in Linux administration.
 - In real projects, contractors, vendors, interns, or temporary developers may need server access only for a fixed duration.
 - Instead of manually tracking and deleting accounts later, we create the user with an account expiry date using useradd -e.
 - This improves security, avoids stale accounts, and supports least-privilege access practices.”



### 2 Task : 
- As part of the temporary assignment to the Nautilus project, a developer named mariyam requires access for a limited duration. To ensure smooth access management, a temporary user account with an expiry date is needed. Here's what you need to do:

- Create a user named mariyam on App Server 3 in Stratos Datacenter. Set the expiry date to 2027-03-28, ensuring the user is created in lowercase as per standard protocol.




### 3 Solution

# Step 1: SSH into App Server 3
 - ssh banner@stapp03

# Step 2: Switch to root user
 - sudo su -


# Step 3: Check whether user already exists
 - id mariyam

#  Check passwd entry
 - grep mariyam /etc/passwd


# Step 4: Create the user with expiry date
 - useradd -e 2027-03-28 mariyam

# Step 5: Verify the expiry date
 - chage -l mariyam