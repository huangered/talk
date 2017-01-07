%% user struct
-record(user, {id, name, password, email}). 
%% the tcp package
-record(package, {len, op, data}).
%% message
-record(message,{from,date,time,msg}).