### Please checkout this workflow


                ssh Username@Server
                           |
                           v
          Is PubkeyAuthentication enabled?
                     /           \
                   YES            NO
                    |              |
                    v              v
         Try SSH key login      Ask password
                    |
                    v
          Key valid in authorized_keys?
                  /      \
                YES       NO
                 |         |
                 v         v
             Login      Password auth