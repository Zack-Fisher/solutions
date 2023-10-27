# splitting on a comma, or any character in vim

this isn't too bad.
nothing special, just sed smartness

### on commas
s/,/,\r/g

### in general
s/<delimiter>/<delimiter>\r/g

## application

```c
add(1,
 2,
 3,
 4,
 5);
```
