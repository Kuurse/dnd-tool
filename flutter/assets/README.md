# Open5e

This file comes from the Open5e API :

`
curl --location 'https://api.open5e.com/monsters/?limit=100000'
`

It has been included on GitHub to improve response time and alleviate workload on their servers.

Unfortunately, some of the data isn't formatted correctly and needs to be fixed manually. Namely :

```
4 . 4 should be 4 - 4 (search for other instances of ' . ' instead of ' - ')
"hit_dice": “Vertically” needs to be swapped for the actual hit dice
"hit_dice": "30d10+180, bloodied172" needs to be trimmed
1d4 1 (rat, frog, spider), swarm of quippers (seems to be fixed)
```

