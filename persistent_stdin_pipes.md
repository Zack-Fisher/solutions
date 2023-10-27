# making long-lasting stdin pipes in bash

## simple, with tail

tail -f follows the fifo file.
this does NOT work with a normal file.
it specifically needs to be a fifo named pipe for the connection to persist.

```bash
tail -f /tmp/myfifo | irb
```

## with nc

pipe the output of the netcat connection into the program.
this will persist the stdin, with the nice benefit of being over a proper network
connection, if that's useful.

start the server with:

```bash
nc -zv -p <port> | irb
```

and connect with: 

```bash
nc <host> <port>
```

just start typing things, and it should work on the other listener irb window.
