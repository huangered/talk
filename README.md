# talk

# env
build system
make >= 4.1

# dep
1. cowboy => web
2. jiffy => json

# command

| Method | Data | Return value | Action |
| ------| ------ | ------ | ------ |
| <<"00">> | | <<"ok">> | heartbeat | 
| <<"auth">> | {"username":"", "password":""} | <<"ok">> or <<"fail">> | auth |
| <<"disconnect">> | | <<"ok">> | disconnect |
| <<"send">> | {"from":"", "to":"", "msg":""} | <<"ok">> | send |
| <<"sendgroup">> | {"from","", "to":"", "msg":""} | <<"ok">> | send to group |
