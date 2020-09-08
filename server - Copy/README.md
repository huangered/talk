# talk

# env
build system
make >= 4.1

# dep
cowboy => web
jiffy => json

# command

Method | Data | Action
<<"00">> | heartbeat
<<"auth">> | {username:"",password:""}
<<"send">> | {from:"",to:"",msg:""}