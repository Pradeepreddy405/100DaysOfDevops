## Day 10 : Workflow 

```
                    JUMP HOST
                       |
                       |
                 ssh tony@stapp01
                       |
                       ↓
                ┌──────────────┐
                │   stapp01    │
                │   User tony  │
                └──────┬───────┘
                       |
          ┌────────────┼───────────────┐
          ↓            ↓               ↓
       Check zip    Check beta      Check archives
          |            |               |
       which zip    ls -ld            ls -ld
                    /var/www/        /archives
                    html/beta
          |            |               |
          └────────────┼───────────────┘
                       ↓
                 Prerequisites OK
                       |
                       ↓
              Configure SSH key
                       |
                       ↓
          ssh-copy-id natasha@ststor01
                       |
                       ↓
              Enter password ONCE
                       |
                       ↓
              Public key installed
                       |
                       ↓
       Test: ssh natasha@ststor01
                       |
                       ↓
                No password ✓
                       |
                       ↓
       Test: scp test file to
             ststor01:/archives/
                       |
                       ↓
                 SCP works ✓
                       |
                       ↓
          Create /scripts/beta_archive.sh
                       |
                       ↓
                 Run the script
                       |
             ┌─────────┴──────────┐
             ↓                    ↓
       ZIP website             SCP archive
             ↓                    ↓
/var/www/html/beta       ststor01:/archives/
             |                    |
             ↓                    ↓
xfusioncorp_beta.zip     xfusioncorp_beta.zip
             |
             └─────────┬──────────┘
                       ↓
                  Verify both
                       |
                       ↓
                    DONE ✓
```