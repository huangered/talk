# talk

## env
build system
make >= 4.1

## dep
1. cowboy => web
2. jiffy => json

## command

| Method | Data | Return value | Action |
| ------| ------ | ------ | ------ |
| <<"00">> | | <<"ok">> | heartbeat | 
| <<"auth">> | {"username":"", "password":""} | <<"ok">> or <<"fail">> | auth |
| <<"disconnect">> | | <<"ok">> | disconnect |
| <<"search">> | {"query":""} | <<"ok">> | search user |
| <<"send">> | { "to_room":"", "msg":""} | <<"ok">> | send msg to group member |
| <<"add_room">> | {"name":"","user_ids":["id1","id2"]} | <<"ok">> or <<"fail">> | create a chat room |
| <<"del_room">> | {"id":""} | <<"ok">> or <<"fail">> | delete a chat room |
| <<"add_user_to_room">> | {"room_id":"","user_id":[""]} | <<"ok">> or<<"fail">>| add user to room |
| <<"del_user_to_room">> | {"room_id":"","user_id":[""]} | <<"ok">> or<<"fail">>| del user to room |
