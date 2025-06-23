# Chapter 5: Backing Services

And now we need to talk about some of the backing services you are almost certainly going to need to connect to, to turn your application into an application.

### The Database
The beating heart of every modern web application is some kind of database.

It is the permanent store of information at the center of everything.

#### Database Authentication
Most commercial databases have a built-in authentication system. This authentication system is to authenticate access directly to the database itself - it's important not to confuse the database's authentication with your own application's authentication.

If people want to log in to your website, they'll be interacting with auth code that you wrote. Database Auth controls who is allowed to connect to the database and what they are allowed to do - so, pretty much, just your application, and you.

Some databases don't ship with any authentication at all - or, authentication is turned off by default. Everybody who can find the database on the network can do whatever they want with it. It's really important that - if you make a database accessible on a public network, you must authenticate access to it. Again, this feels so obvious that I'm embarrassed to say it, but, every year there are reports of hackers just cruising in to completely open systems with real production data on them.

#### Database Protocols
The way that you connect to your database is rarely simple HTTP requests. Instead, databases usually interact via some protocol of their own design - very often a binary protocol rather than a plaintext one.

Postgres, for example, communicates using the Postgres Wire Protocol. Mongo communicates using the Mongo Wire Protocol.

Communicating with these databases almost always involves finding someone's implementation of the database protocol for your language of choice. Very often, there are many competing implementations of the database libraries - you'll have to evaluate these and choose ones that work well for your purposes.

Remember when looking for database libraries, you're evaluating them based on

* How popular are they? Are lots of other people using these libraries?
* Are they maintained? When was the last time the library maintainers changed anything?
* Are they documented? Can you understand how to use the library?
* Do they use a programming model that makes sense in the language that you're working in?
* Do they support connection pooling? Reconnect logic?
* Do they have the official blessing of the database company, or are they officially published by the makers of the database?

#### Not Talking about SQL
The dominant way to interact with databases is using a Structured Query Language.

A full discussion of how modern SQL and NoSQL databases work is outside of the scope of this presentation. It's a big, big topic that deserves a whole presentation on its own.

Tl;dr: In your database, you have tables of data, and you'll issue queries that request and update rows against those tables. To learn more, read a database manual.

#### Normalization
_All problems in computer science can be solved by another level of indirection_

Okay, I need to talk about normalization a little.

Just to introduce the topic, let's imagine we have a table with some users in it:

| id | user  | country | ip            | type     | perms  |
|----|-------|---------|---------------|----------|--------|
| 1  | dave  | USA     | 203.22.44.55  | admin    | write  |
| 2  | chuck | CA      | 112.132.10.10 | admin    | write  |
| 3  | biff  | USA     | 203.22.44.55  | regular  | read   |

This table has an id, uniquely identifying the user, a username, a country code, an IP address, a user type, and user permissions.

Maybe you're looking at this and thinking: hey, this table has some problems.

Like - if all admins have "write" permissions, and all regular users just have "read" permissions, why not separate out the admin stuff into its own table. We can just store the ID of the rows we're referencing.

| id | user  | country | ip            | type_id  |
|----|-------|---------|---------------|----------|
| 1  | dave  | USA     | 203.22.44.55  | 1        |
| 2  | chuck | CA      | 112.132.10.10 | 1        |
| 3  | biff  | USA     | 203.22.44.55  | 2        |

--------

| id | type_name  | perms   |
|----|------------|---------|
| 1  | admin      | write   |
| 2  | normal     | read    |

Look, we did a normalization! Now if we want to update our admin permissions, or change a type, or add a new type, we only have to make that write one place, instead of hundreds of times across our entire table.

And the only expense was that we made our read a little more complicated - now in order to get all of the information we used to have in one table, we need to JOIN the type_id against the new table we've just created. Now our queries are against two tables instead of just the one.

Awesome! But... we can go further. Let's normalize harder. We can split out the country, and the IP data, too.

| id | user  | country_id | type_id  |
|----|-------|------------|----------|
| 1  | dave  | 1          | 1        |
| 2  | chuck | 2          | 1        |
| 3  | biff  | 1          | 2        |

---------


| id | type_name  | perms   |
|----|------------|---------|
| 1  | admin      | write   |
| 2  | normal     | read    |

---------

| id | country  | full-country-name        |
|----|----------|--------------------------|
| 1  | USA      | United States of America |
| 2  | CA       | Canada                   |


---------

| id | user_id       | ip_id        |
|----|---------------|--------------|
| 1  | 1             | 1            |
| 2  | 2             | 2            |
| 3  | 3             | 1            |

---------

| id | ip             |
|----|----------------|
| 1  | 203.22.44.55   |
| 2  | 112.132.10.10  |

Can you feel that? It's SO NORMALIZED. We've got a many-to-many relationship so that users can have lots of IP addresses, but those IP addresses live in their own table, just in case one of them changes.

We've also got our countries neatly organized into their own table, in case the country name changes.

We get all of this, and the only expense is that our queries get just a touch more complicated, because now they're querying not one but five different tables.

#### Denormalization
_except too many layers of indirection_

Uh, you might have noticed that that last example was a bit ridiculous.

It's possible that country codes don't need to be normalized into their own table.

In fact, country codes change very, very rarely, if at all - and - it turns out, doing a full-table find-and-replace once every 5-10 years might be less complicated than doing every single query for the entire lifetime of your application across two tables instead of just one.

That goes doubly for maintaining a whole extra table for IP address normalization, which I definitely just did as a joke.

The driving factor behind normalization comes from a good place, a place of good engineering that lives deep within your gut, but - it's really possible for the desire for properly normalized systems to lead us down paths that actually make our designs worse, and harder to maintain.

There's a lot of value in simplicity, honestly, the first table I showed you was probably the easiest of the lot to actually understand and work with.

When I worked at a major telecom over a decade ago, every single row in every single table was normalized - like in my second example, the joke example. It meant that no matter what sort of data you wanted to update, you were guaranteed that you'd only ever need to update it in one place at a time - or, more likely, you'd have to create a new row and write a reference to that new row. Individual SQL queries would often run 400, 500 lines, just to pull basic information out of the system.

Don't do that. It's bad.

#### Avoid Unnecesary Joins
Joins make reads slower, more complicated, and harder to distribute across machines.

Up until fairly recently, MongoDB just didn't allow joins at all. Google's first big cloud-scale database, BigTable, was so named because it just gave you one big table. No normalization, just table.

Normalization is still a enormously useful technique for how you design the layout of your data, but be aware: you probably need a lot less of it than you think.

### Locks
Each row in your database can only be written to once at a time. Your database provides its own concurrency control around records, so that you don't accidentally corrupt them by writing them simultaneously.

However, one thing to be aware of is _how and how much of your database locks with every write_.

There are modes, for example, of

### Indexes
"My queries are slow".

Again, database indexing is a huge, huge topic, more than I can cover here without going into just even significantly more detail.

But, I have a few things to say:

#### Running a Query from an Application Server on Production Without an Index: It's Never Okay
The only time it's really acceptable to run an unindexed query is when you're spelunking for data on your own, and even then, you're taking your life into your own hands. Letting an unindexed query into the hands of your users is a mistake - worst case scenario, malicious users will find that query and hit it again and again and again until your database server lights itself on fire and falls into the ocean.

#### Covered Queries are Great
If you _only_ request information out of the database's index, the database doesn't have to read anything from disk. This is a huge optimization - take advantage of it when you can.

#### Indexes Live in RAM
This is a bit of a broad generalization, but indexes are huge data structures that live in RAM. Every new index on a large database table fills up RAM on the database you're writing to.

Most systems accumulate data a lot faster than they delete data - many systems don't delete data at all, or only do it if required by law - what that means is that the indexes will only ever get bigger, bigger and bigger and bigger, until eventually they don't fit on one computer any more.

#### Every Index Slows Down Writes
When you write something, anything to your database, a huge number of indexes need to be updated as well.

Now, it might seem like I'm being a bit contradictory here - you should have indexes for every query, you should pull as much information from indexes as you can, but also, your indexes slow down writes and grow unbounded until they fill your database server's RAM and blow up prod. But yes, all of those things are true at the same time.

#### Schema Evolutions/Migrations
If you're using a SQL-based database, you are going to be asked to define your table layout up-front. This is your database schema, describing the shape of data in your database, as well as the indexes that must be created.

Once your table is live, the only way to make changes to that table is to write schema-changing ALTER queries against the table.

Many languages and environments provide a system that allows you to define a starting schema for a table, and then represent any changes to that schema in code. This means that the state of your table schema at any given time is fully represented in your codebase's history. These systems are usually called Evolutions or Migrations.

I honestly can't imagine operating software against a SQL database without using a tool like this. They're very useful.

### Mongo is Web Scale
There are a lot of database products out there! It's an exciting and interesting market and totally worth exploring to find the product that best fits the project that you're planning on building.

I'm fond of Mongo - because it doesn't enforce a schema on any of its documents.

One of the most important things to learn about when you're evaluating a new database is: what happens when I need more than one database server?

You don't need to distribute your data for scale up front. That is way premature optimization. Any database will get you to your first 10,000 users without needing to be distributed.

You do, however, need a failover plan, on day one. If your database goes down, what do you do? If your answer is "spend six hours loading a backup", that's fine - you just need A plan for this, because it will happen - and six hours of downtime is a lot of downtime.

#### Distributed Reads, Replication & Failover
One of the most basic and important ways to replicate data across servers - one that's available in just about every database - is replication to a secondary server.

This is a scheme where our primary server acts as a regular database, but it also streams all of its writes to backup servers. These backup servers cannot accept writes, except from the primary - if they did, there wouldn't be a way for any other servers to get those writes.

These backup servers are useful for two purposes - first of all, if something bad happens to your primary database, your primary database can fail over to one of the backup servers, which takes its place as the new primary.

The second thing that you can do here is perform slightly stale reads from the backup servers.

Most services do a _lot_ more reads than writes, so distributing reads to secondary servers is actually an enormously effective scaling strategy - and this is one of the simplest models for database replication, so it's win-win!

However - if you think about it - because every write is distributed, first to the primary, then to all of its secondaries, each database in the cluster is absorbing the full brunt of all of the writes being taken on by your databases - this strategy can't scale writes at all.

But - we're not scaling yet. We're just providing a failover strategy - so that if our database goes down, well, there's another one, right there, waiting to take on the load.

##### Primary and Secondary
Up until fairly recently, the accepted term for the Primary and Secondary servers in a replication scenario were "master" and "slave".

This... sucks, but you might still encounter the terminology when exploring database products. Prefer primary and secondary.

##### Whoops, I Distributed Too Much Read Load and Now I Don't Have a Failover Strategy

One concern - let's imagine you're distributing read load to all of your secondaries, and they're all operating at just under 100% load.

Then, something happens to your primary, or even one of the secondaries: there's nowhere for that load to go. So instead your servers start to fail.

Guess what! You just triggered a _cascading failure_.

##### Whoops, The Secondaries Aren't Able To Keep Up With Writes and Now I'm Reading Super Stale Data

The secondary servers _should_ be able to write exactly as fast as the primary server, but if they are dealing with so many reads that writes start to slow down, it's possible that they could start falling behind at processing their write load.

If the secondary servers start to fall behind, the data on these servers will start being more and more out-of-date. Things could get weird.

##### Whoops, I Read from Stale Data and then Wrote That Data Back To the Database, Overwriting Newer Data

Yeah, I've made a lot of mistakes with replication.

#### Distributed Writes (Sharding)
Replication can distribute read load, but how do we distribute write load? Since we're writing everything to every server in our cluster, write load is just going to grow and grow until our servers fall over - or we stop being popular.

One way is simply... not to write everything to every server.

If, for example, we have tables that don't join against other tables - say, EmployeeData joins against User, and ThumbnailFile joins against File, but these tables have no natural, in-database links.

There's nothing that stops us from simply hosting these tables on different databases. This is one of the strengths of databases that discourage joins - each individual collection can live on a totally different server cluster - it doesn't matter.

Beyond that, we can start looking at how even individual tables can be segmented across servers.

Take, for example, a UserPreferences table. Let's imagine that we have a whole bunch of user-id to user preference mappings in a big table.

| id | user_id | key             | value |
|----|---------|-----------------|-------|
| 1  | 12344   | darkMode        | on    |
| 2  | 12344   | fabricSoftening | off   |
| 3  | 34566   | darkMode        | off   |

Well, it would make a lot of sense to keep all of the data for a single user on a single database server - because all of our queries are going to query user preferences for a single user.

So our sharding might distribute users like this:
```
database A: users with an ID that starts with 1,2,3,4
database B: users with an ID that starts with 5,6,7,8
database C: users with an ID that starts with in 9,0
```

Then, whenever we write a user, we check which database to write it to, first, and only write to that database. Whenever we query userPreferences, well - we're only every querying userPrefences for one user at a time - so we'll run the query only against the server that matches the user we're querying for.

You'll note that both of the sharding schemes I've talked about here don't even require any cooperation from the database itself - you can literally just write your application to use a different database connection for different tables, or shard your data right at the application level. However - many database providers will give you tools to manage these strategies at the database level - which is convenient.

Let's look at some problems with our sharding strategy.

Lets look at how I distributed writes: using the first digit of the users' ID.  There are two different problems with this strategy - first of all, let's imagine our user IDs are monotonically increasing over time - a common strategy for allocating IDs is just to count up, so every ID is going to be one higher than the last ID. That means that when we're writing new users to our database, we'll be writing users like this:

```
10901 (Database A)
10902 (Database A)
10903 (Database A)
10904 (Database A)
10905 (Database A)
...
```

Well... that's not distributed at all. We've distributed all of our writes to Database A. Eventually, we'll write 10,000 users and start distributing all writes to Database B instead, and then Database C, and so on!

This is a common problem with monotonically increasing values and shard keys - and a common resolution is to either select non-monotonically increasing ID values, or hash the IDs before we use them as shard keys.

```
10901 - 220A2BA5 - (Database A)
10902 - FB2C68A8 - (Database B)
```

Here, 10901 hashes to 220A, and that's very different from the next value's FB2C, so they'll distribute evenly across databases - in fact, we could have just used these hash values as the key in the first place.

Back to our sharding strategy:

```
database A: users with an ID Hash that starts with 0,1,2,3,4,5,6
database B: users with an ID Hash that starts with 7,8,9,A
database C: users with an ID Hash that starts with B,C,D,E,F
```

It still has a problem, which is that the sharding rules are unevenly distributing load across the databases.  Database A in this scheme is always going to be working a little harder than the other databases. In fact, you'll note that you can't evenly divide the 16 characters of hex across 3 databases, because math - but this is resolvable by simply... using a longer shard key and sharding across ranges.

```
database A: users with an ID Hash from 0-33
database B: users with an ID Hash from 33-66
database C: users with an ID Hash from 66-99
```

Okay, now that we're at this point, how do we add a new server to the shard map?  The answer to that question is _it's a real pain in the ass._ Schemes like consistent hashing can help, but by and large this is the value that having a database that manages its own shards brings to the table: it can rebalance shards when new shards enter the pool, without you having to manage that yourself.

Okay, new problem: what happens when we want to query for all userPreferences that are darkMode, regardless of user ID. We just want to count all the darkMode users in our application.

Well - the only way to do that is to split up the query, make it against every server in the cluster, and then, once we've gathered results from every server in the set, we merge them together. This is, notably, very expensive - sharding starts to become a losing strategy when you are working with data that doesn't have queries that clearly divide across servers.

#### Distributed Writes (Multi-Primary)
The common thread in both replication and sharding is the idea that there's still only one server at a time responsible for writes to any given unit of data. This dramatically simplifies enforcement of consistency around your data - so long as there is one source of truth about any given record in your database, you can trust that you'll never have to deal with write conflicts. There can't be two different histories for any given item, because all of the writes are ultimately resolved in one place.

However, some products allow writes from any server in the cluster. This introduces the obvious problem: what if two different servers write the same record at the same time? They've introduced a conflict, and with no authoritative primary server, there's no simple way to resolve this conflict.

You could just give write preference to whichever write happened first, discarding any conflicting write that happens after the write it conflicts with - but that wanders into the problem of "well, now all of the servers have to agree about exactly what time it is" - which, if you have learned a bit about distributed systems, is near impossible.

For a really long time, nobody even attempted to write databases that depended on strict synchronized time guarantees because they are so hard to do effectively. Google actually announced that they had built a database that resolved conflicts using synchronized clocks - which they accomplished by building atomic clocks directly into their data centers and carefully routing network connections to those clocks to keep clock skew to an absolute minimum. If you are not Google, this solution may be impractical - however, they proved that time-synchronization-based-conflict resolution is, in fact, possible - and an open-source version of that same solution, CockroachDB, is available today. This ties the performance of your write system to the quality of clock synchronization that you're able to achieve - which, even with the inaccurate tools available to us atomic-clock-lacking plebs, is still good enough for most production systems.

I think that's funny because clock-synchronization based solutions were once dismissed as impractical in all of the distributed systems textbooks.

Other systems achieve multi-primary writes by sacrificing _consistency_ - at some point they'll just have to guess which write was the correct one, and you have to hope that the system guessed right.

Still other system achieve multi-primary writes by using specialized data structures - Conflict-Free Replicated Data Types, or CRDTs - these data structures contain complicated rules for how to resolve all possible conflicts in their writes. The data structues themselves are based on some very math-laden papers describing a system called Operational Transformation, and they were designed initially to resove conflicts in spaces where users would definitely and unavoidably be trying to write the same data at the same time - synchronized documents - Google Docs, essentially. The consistency offered by these rules is predictable - given the same set of inputs, the data will always come out the same way - but that doesn't necessarily mean that the automatic conflict resolution is always seamless or what a human would expect.

Systems offering multi-master replication - systems like Cassandra, CockroachDB, DynamoDB, BigTable, Google Cloud Spanner - are almost always the most scalable, full stop, no question - but, with that, they bring a lot of the additional complexity of managing cluster-first databases.

It's often much better to build your products on the comparatively simple primary/secondary databases we all know and love, and not move to a multi-primary database until you have lots of people and money to manage the extra complexity involved.

##### UUID
In many systems, its possible to know, when you do a write, what the highest ID value is in your database right now, and then, write to the next highest ID - if you're creating a user and the last user created was 19283, your next user can be 19284.

However, some databases - multi-master in particular - can't offer this guarantee - if you want to be able to tee up writes without that back and forth between you and the database, you'll have to be able to provide an ID that you can guarantee doesn't already exist in the system.

This is where the UUID comes in handy. They're long, and random, and look like this:

`6ead48e0-c795-49bd-9e28-bdee980caf87`

The magic of the UUID is just in _how random they are_. They're 128-bits of randomness - If you generate 2 UUIDs, they won't be the same. If you generate 1 million UUIDs, they won't be the same. The chance of a collision in the UUID space is so microscopic that you'd have to generate a billion UUIDs per second for about 85 years to see one.

UUIDs aren't totally collision-proof - collisions, though, are usually the fault of failures in the implementation of the randomness that goes into generating them rather than in the space that they occupy, which is unimaginably vast. This makes them an awesome choice for identifying any data that you want to have a non-monotonic, unique, well-distributed identifier for. This also makes them pretty excellent shard keys.
