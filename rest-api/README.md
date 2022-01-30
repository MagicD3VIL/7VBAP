##REST API curl requests documentation

#### Table of contents

- [REST API curl requests cheat-sheet](#rest-api-curl-requests-cheat-sheet)
    - [/login](#login)
        - [POST](#post)
    - [/logout](#logout)
        - [POST](#post)
    - [/users](#users)
        - [GET](#get)
        - [POST](#post)
        - [PUT](#put)
        - [DELETE](#delete)
    - [/tags](#tags)
        - [GET](#get)
        - [POST](#post)
        - [PUT](#put)
        - [DELETE](#delete)
    - [/threads](#threads)
        - [GET](#get)
        - [POST](#post)
        - [PUT](#put)
        - [DELETE](#delete)
    - [/threads/{thread_id}/posts](#threadsthread_idposts)
        - [GET](#get)
        - [POST](#post)
        - [PUT](#put)
        - [DELETE](#delete)


####/login
######POST
```json
curl -b cookie.txt -c cookie.txt -X POST 'https://127.0.0.1:6633/login' -k -v \
-H "Content-type: application/json" \
-d '{"login": "test_user2@sniper"}'
```

####/logout
######POST
```json
curl -b cookie.txt -c cookie.txt -X POST 'https://127.0.0.1:6633/logout' -k -v \
-H "Content-type: application/json" 
```

####/users
######GET
__To get all users:__
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/users' -k -v \
-H "Content-type: application/json"
```
__To get single user:__
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/users/99627209379020803' -k -v \
-H "Content-type: application/json"
```
or
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/users' -k -v \
-H "Content-type: application/json" \
-d '{"uuid": "99627209379020803"}'
```
######POST
```json
curl -b cookie.txt -c cookie.txt -X POST 'https://127.0.0.1:6633/users' -k -v \
-H "Content-type: application/json" \
-d '{"login": "test_user4@sniper", "nickname": "Test user 4", "email": "test4@example.com"}'
```
######PUT
_Uživatel může updatovat pouze sám sebe, tzn. stejného uživatele na kterého je aktuálně přihlášený_
```json
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/users/99627209379020803' -k -v \
-H "Content-type: application/json" \
-d '{"user": {"username": "test_user2", "nickname": "Test User 2", "email": "test2@example.com"}}'
```
or
```json
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/users' -k -v \
-H "Content-type: application/json" \
-d '{"uuid": "99627209379020803", "user": {"username": "test_user2", "nickname": "Test User 2", "email": "test2@example.com"}}'
```
######DELETE
_Uživatel může mazat pouze sám sebe, tzn. stejného uživatele na kterého je aktuálně přihlášený_
```json
curl -b cookie.txt -c cookie.txt -X DELETE 'https://127.0.0.1:6633/users/99627209379020832' -k -v \
-H "Content-type: application/json"
```
or
```json
curl -b cookie.txt -c cookie.txt -X DELETE 'https://127.0.0.1:6633/users' -k -v \
-H "Content-type: application/json" \
-d '{"uuid": "99627209379020832"}'
```

####/tags
######GET
__To get all tags:__
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/tags' -k -v \
-H "Content-type: application/json"
```
__To get single tag:__
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/tags/2' -k -v \
-H "Content-type: application/json"
```
or
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/tags' -k -v \
-H "Content-type: application/json" \
-d '{"id": 2}'
```
######POST
```json
curl -b cookie.txt -c cookie.txt -X POST 'https://127.0.0.1:6633/tags' -k -v \
-H "Content-type: application/json" \
-d '{"name": "Testing Tag"}'
```
######PUT
```json
# vytvoření nového tagu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/tags' -k -v \
-H "Content-type: application/json" \
-d '{"name": "Help"}'
```
or
```json
# replace tagu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/tags/2' -k -v \
-H "Content-type: application/json" \
-d '{"name": "Help"}'
```
or
```json
# replace tagu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/tags' -k -v \
-H "Content-type: application/json" \
-d '{"id": 2, "name": "Help"}'
```
######DELETE
```json
curl -b cookie.txt -c cookie.txt -X DELETE 'https://127.0.0.1:6633/tags/10' -k -v \
-H "Content-type: application/json"
```
or
```json
curl -b cookie.txt -c cookie.txt -X DELETE 'https://127.0.0.1:6633/tags' -k -v \
-H "Content-type: application/json" \
-d '{"id": 10}'
```

####/threads
######GET
__To get all threads:__
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/threads' -k -v \
-H "Content-type: application/json"
```
__To get single thread:__
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/threads/2' -k -v \
-H "Content-type: application/json"
```
or
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/threads' -k -v \
-H "Content-type: application/json" \
-d '{"id": 2}'
```
######POST
```json
curl -b cookie.txt -c cookie.txt -X POST 'https://127.0.0.1:6633/threads' -k -v \
-H "Content-type: application/json" \
-d '{"name": "Testing Thread"}'
```
######PUT
_Uživatel může updatovat pouze svoje Thready, tzn. nemůže editovat Thready ostatních uživatelů_
```json
# vytvoření nového threadu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/threads' -k -v \
-H "Content-type: application/json" \
-d '{"name": "Help"}'
```
or
```json
# replace threadu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/threads/2' -k -v \
-H "Content-type: application/json" \
-d '{"name": "Help"}'
```
or
```json
# replace threadu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/threads' -k -v \
-H "Content-type: application/json" \
-d '{"id": 2, "name": "Help"}'
```
######DELETE
_Uživatel může mazat pouze svoje Thready, tzn. nemůže mazat Thready ostatních uživatelů_
```json
curl -b cookie.txt -c cookie.txt -X DELETE 'https://127.0.0.1:6633/threads/10' -k -v \
-H "Content-type: application/json"
```
or
```json
curl -b cookie.txt -c cookie.txt -X DELETE 'https://127.0.0.1:6633/threads' -k -v \
-H "Content-type: application/json" \
-d '{"id": 10}'
```

####/threads/{thread_id}/posts
######GET
__To get all posts in thread:__
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/threads/1/posts' -k -v \
-H "Content-type: application/json"
```
__To get single post in thread:__
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/threads/1/posts/1' -k -v \
-H "Content-type: application/json"
```
or
```json
curl -b cookie.txt -c cookie.txt -X GET 'https://127.0.0.1:6633/threads/1/posts' -k -v \
-H "Content-type: application/json" \
-d '{"id": 1}'
```
######POST
```json
curl -b cookie.txt -c cookie.txt -X POST 'https://127.0.0.1:6633/threads/1/posts' -k -v \
-H "Content-type: application/json" \
-d '{"content": "Sorry, I have no idea how this works :/"}'
```
######PUT
_Uživatel může updatovat pouze svoje Posty, tzn. nemůže editovat Posty ostatních uživatelů_
```json
# vytvoření nového postu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/threads/1/posts/2' -k -v \
-H "Content-type: application/json" \
-d '{"content": "JK I do but I wont tell you lol\n\nEDIT: Sorry that was bit rude"}'
```
or
```json
# replace postu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/threads/1/posts/2' -k -v \
-H "Content-type: application/json" \
-d '{"content": "JK I do but I wont tell you lol\n\nEDIT: Sorry that was bit rude"}'
```
or
```json
# replace postu přes PUT
curl -b cookie.txt -c cookie.txt -X PUT 'https://127.0.0.1:6633/threads/1/posts' -k -v \
-H "Content-type: application/json" \
-d '{"id": 2, "content": "JK I do but I wont tell you lol\n\nEDIT: Sorry that was bit rude"}'
```
######DELETE
_Uživatel může mazat pouze svoje Posty, tzn. nemůže mazat Posty ostatních uživatelů_
```json
curl -b cookie.txt -c cookie.txt -X DELETE 'https://127.0.0.1:6633/threads/1/posts/3' -k -v \
-H "Content-type: application/json"
```
or
```json
curl -b cookie.txt -c cookie.txt -X DELETE 'https://127.0.0.1:6633/threads/1/posts' -k -v \
-H "Content-type: application/json" \
-d '{"id": 3}'
```


