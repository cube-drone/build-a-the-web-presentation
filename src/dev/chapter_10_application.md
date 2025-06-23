# Chapter 10: Application

Finally, you've got a language up and running, backing services, automation, authentication, you're almost at the point where you can start building a real product! Hooray!

This part is, uh, largely up to you! Go build an application!

### Relationships Are n^2 And Must Be Restricted Somehow
Everything you manage in user-space is going to be fairly well contained within that user. This should shard fairly well, scale linearly - every new user is going to add one new user to your system.

There's a problem, though - your users interact with one another.

If you have N users, every connection point between a user and another user in your system is something that's going to have potentially n-squared values. This means that even with modest user counts, you can have tables with billions or trillions of entries. User relationships, messages, status updates grow incredibly quickly, and are very likely to be the first scaling barrier you encounter.

If you're wise, you'll consider restricting the number of relationships users can have up-front. Steam, for example, will provide you with the up-to-date status of no more than 250 friends at one time.

Or, you'll restrict the amount of information users have access to about all of their friends - twitter and facebook, for example, allow unlimited relationships, _but_ when you log in to their applications what they're showing you is not an up-to-date look at 100% of all of those relationship updates - they're showing you a curated selection of some of what your relationships are posting.

Unrestricted full status updates about an unlimited pool of users in a growing system will eventually lead to your system collapsing under its own weight. There is no technology solution that can sync that much data.

### Messaging
Most systems end up with a stack of messages or notifications that need to be delivered to the user at some point.

This invariably ends up happening either via

* **Polling**, which is awful because users can be left waiting for a message for whatever your poll interval is, or you set it too tight and DDoS yourself to death under the weight of your own users.
* **WebSockets**, which are awful because they're complex machinery that break down in many hard-to-reason about ways, leaving your users' with no messages at all.

I recommend a combination of both: send new messages along sockets as soon as they arrive, but give the user access to fallback polling endpoints, as well as endpoints that can be
used to sync the full state of the users' messages.

### Fan Out
Another common topic in application design is labelled "fan out" - let's imagine you have a twitter-like system where you can subscribe to updates from dozens or hundreds of people.

If you're able to subscribe to thousands of people, it doesn't necessarily make sense for you to follow thousands of separate data feeds - this can be very expensive - instead, when these people write updates, they'll write them into your data feed. This can mean that they'll perform thousands of writes when they tweet, but that your system's reads will be much faster, because you will be reading from just one feed, rather than thousands.

However, there's a problem with this: when a user has millions of people following them, every tweet that they produce is going to attempt to write to millions of feeds, which is ... slow, expensive, potentially disastrous for a system.

So, it makes more sense for users who have millions of followers to publish a feed that people periodically check, but it makes more sense for users who have tens of followers to write to people's feeds rather than maintaining a feed of their own.

### Thundering Herds
This is a fun problem! Let's imagine that you have a long, difficult to calculate computation that gets hit frequently in your system - obviously this is the sort of thing that you are going to want to cache, so that your servers don't have to struggle to re-do this calculation again and again, and again.

So you cache this thing, say, for 5 minutes every time it gets calculated, and it helps, but then your system's load starts to look like this: spiky, with a big spike every 5 minutes. And that spike keeps getting bigger and bigger, even though your heavyweight calculation isn't getting any harder to calculate.

What's happening is that every five minutes, the long, difficult to calculate computation is falling out the cache. Then, tens or hundreds of people all request the value at the same time. Now, not only is your server suddenly performing a difficult, expensive computation, but it's performing that same computation hundreds of times at once, slowing all of them down - especially if they're all sharing access to the same resource. Then, once all of these computations finally manage to get out of each other's hair, one of them finally writes the value to cache - which is going to stop new request from coming in, but each of our computations is also going to finish, and write to cache, also, hundreds of times. Now we're good, for another five minutes, until this whole rigamarole starts all over again.

This is... bad!

There are a few different ways to stop the herd:

* You can keep very hot cache data in cache forever, recalculating it periodically in the background.
* You can lock around expensive calculations, throwing an error if a user tries to recalculate something that's currently already being recalculated.
* You can engage in even more complex and esoteric schemes to make sure that your cached entry stays in cache and fresh, and only gets recalculated once at a time.

### Distributed Locks
If you are working with a key-value store shared amongst your entire backend, locking is pretty easy. Write your server's id to a time-bounded lock-specific key, failing if the key already exists, and you've created a situation where only one server at a time should be able to succeed at that call.

When you're done with whatever you're doing, delete the key.

Oh, I should make something clear: this is a simplified solution that values efficiency over correctness - it's possible for a server to die while holding a lock, and then whatever is being locked will just stay locked until the TTL expires - it's also possible for race conditions to occur here, causing your locked code to run more than once.

If what you are guarding with the lock is something where you need a correct locking scheme, this is not your solution. However, most of the time, and this is a common development motto of mine, _good enough is good enough_.

( [For more exploration of this topic: a discussion addressing a much more comprehensive locking scheme in Redis; and why it's not actually necessarily any better](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html) )

### Background Tasks & Scheduling
As we mentioned earlier, while we were talking about queues, sometimes work needs to be done in the background of your system.

You'll use queueing to tee up the work that needs to be completed, but you'll also need to set up servers that sit, and wait, and listen on the queue for work to come, completing that work as necessary.

On top of that, there are going :to be tasks that aren't triggered from user inputs, but instead need to happen on a fixed schedule. Say, for example, you're trying to solve a thundering herd problem by looping a cache renewal.

Scheduling has a lot to do with locking and the thundering herd problem - because, you probably only want scheduled items to execute once per time it appears in the schedule. If you have dozens of servers all attempting to execute the same schedule, you are going to create your own thundering herd.

There are lots of different ways to solve this - the most recent way I've solved this one is by having the worker servers hold a regular election to determine which one is going to be the keeper of the schedule.

The design of your scheduling system has to answer a lot of awkward questions: should scheduled items execute on the scheduler node, or should they be pushed into the queue to be executed by worker nodes? What happens if a ton of the same scheduled job go on the queue and waits for a while, then all execute at the same time? What happens if the entire schedule is being executed on one node and that node can't keep up with the scheduled tasks?

You don't necessarily need comprehensive answers to all of these questions up front: early on in your systems' life, you probably won't have too many scheduled tasks to run anyways.

### Integration Testing
Every integration point between your backend and your frontend is an API contract, and you should be testing that every single endpoint in your system holds up its side of the contract.

This testing is, in my opinion, overwhelmingly useful, as it manages to establish, validate, **and** explain the contract that your system intends to uphold.

Unit tests are useful for validating that individual components in your system are functioning exactly as expected - but don't sleep on the value of integration testing as an automated check that your system actually does what it says it does.

### Logging
Everything that your systems do could ultimately become useful while investigating errors, and so, most production systems log what they're doing pretty verbosely.

The most common way for systems to log their output is simply to log that output to STDOUT - to the console, essentially - pushing the responsibility of managing those logs off to the system that is running the application.

This is also one of those places where running the entire system from a single thread becomes a little more appealing: managing access to STDOUT across threads is in and of itself a bit of a pain in the ass compared to the simplicity of just using `print` or `console.log` everywhere.

Once your logs are in STDOUT, the next step, in production, is to send all of them to a centralized system that allows you to aggregate, search through, archive, and eventually delete all of the logs.

It's very common for systems to divide their logging up into log levels - `log` for informative, regular updates on the system's operation, `warn` for unusual errors and concerns, and `error` for really gnarly stuff.

Also: when you're running the system locally, in development, you'll probably want to hide almost all of the logs, only showing `warn`s and `error`s.

### Graphs & Charts
Once you've released a new feature, how do you know that it's doing anything at all? How do you know that it's working? How do you know how fast it actually is in a production scenario?

The answer to all of these questions and more is _in the graphs and charts_.

Well, where do graphs and charts come from?

Your application servers can emit all kinds of metrics while it's running, either pushing them directly into a time series database like InfluxDB, _or_ making them visible on a `/metrics` endpoint for a Prometheus scraper to hit regularly and gather data from. Either way, that data gets pulled into a big database for to be converted into charts and graphs.

Charts and graphs are pretty addictive. You can set them up for pretty much any functionality under the sun.

My personal favorite charts, the ones that I reference tirelessly, are:

* the charts for endpoint timings - how long are your endpoints taking to respond to queries? This has a direct relationship with the overall health of your system - if things are starting to slow down, you'll see them here first.
* the number of active users on your platform _right now_ - this one should ebb and flow with a very predictable pattern, and if you see a sudden sharp shock in the numbers - a sudden precipitious drop - something bad's happening
* the number of server reboots that are occurring - aside from during tumultuous events like deploys, these should be stable and quite low - if lots of servers start rebooting, something is probably wrong

### Feature Flagging
With database-modifiable config and per-user flags, we have a lot of toggles that we can use to switch features on and off while they're in development.

Simply turning a whole feature on or off with a `isSplartFeatureOn` flag in your config allows you to turn the feature on and off without tying that to a complete feature deployment on production, and allows you to ship partially complete features to master, allowing smaller, more frequent pushes. They're also great if you plan schedule a time to roll the feature out without having to do a deploy at a very specific moment in time.

Using user tags, you can also flag the feature on, giving the users a `splartFeature` tag if they're allowed to see the `splartFeature`  before it hits general availability. We can use this, for example, to give QA users or beta users advanced access to a feature that's not availble to everyone just yet.

A feature can also be rolled out gradually; in the global config you can set a `splartFeaturePercentage` - if the hash of a user's ID, modded by 100, is less than the `splartFeaturePercentage`, then they get to see the feature. If it's higher, they don't.
