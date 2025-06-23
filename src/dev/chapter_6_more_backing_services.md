# Chapter 6: Other Backing Services

The database is such an important part of modern web applications that it would be silly not to talk about them. You, of course, can run web applications without databases - but few do. That shared nothing model means that you have to work around having essentialy no permanent memory between requests, so the utility of an application that can only remember the last 5 milliseconds is limited.

Databaseless applications might do something like perform a single task on every call - a random character generator for a game could split out a totally new and different random character every time you visit it without needing to remember anything. Proxy servers, being as they just forward requests to a third party and then get back to you, also don't need any permanent memory.

This variety of service, when it's useful, can be scaled very easily, which is nice.

But... well, most services require more stuff than that, and databases alone can't provide everything that the services require. You might need file storage, or message queues, or you might have data that doesn't fit cleanly into a tabular data storage system.

So, let's talk about some of the other things you might connect your web server to:

### Files
You're going to need to store more than just data in your web service. There's a chance that you'll also have to deal with files. User thumbnails are a particularly common type of file to have to deal with.

You'll also be backing up your database - presumably - and you'll need a place to keep those backups.

Most databases are configured to store a lot of very structured, little data, not a lot of very unstructured big data - they're more intended for user records than audio files.

Storing files can be very simple, or very complicated.

The simple way to store files is just to stash them on a server, making sure to back _them_ up to a secondary server, every now and again, and serving them using something like the NGINX web server.

You can get a little more complicated than that - sync the files to multiple servers, and load-balance access to those files using NGINX again.

These strategies start to tap out a little bit once you're storing more files than you can fit on a single server - somewhere in the 20-1000 gigabyte range you're gonna have to start thinking about infinite file storage.

A lot of cloud providers offer infinite file storage, with backups, and access-controls, and load-balanced hosting of those files - products like S3, Google Storage, or Wasabi - this is something you'll probably set up with them rather than running it in house, because it's a complicated thing to set up and manage.

There are also in-house protocols, like Ceph, you can use to set up this kind of thing on your own, but they're very complicated products - generally intended to be set up at the service provider level rather than by anybody who comes along and wants to spin up an individual product on their own.

### RAM
Databases, even multi-master ones- still have to write everything to disk, and back it all up.

There's some data that you don't need to do all of that for. Ephemeral data.

And there are databases out there that don't store anything. They just boot up, exist in your machine's RAM, and when you turn them off, they stop storing anything.

These databases are _stupidly fast_. I mean, obviously - they don't have to write any data, they just have to keep it floating around until you need it.

This is particularly useful for cache - when you have complicated procedures that take a lot of server time to complete and you want to save their result for a few seconds, or a few minutes, or a few days so that nobody else has to perform that complicated procedure again.

Some classes of data are legitimately pretty ephemeral and come with limited consequences if they get eaten in a server crash - user sessions are very temporary and need to be accessed on every single user interaction, so fast ephemeral storage is a good place for them.

This is the wheelhouse of services like Redis, and memcached.

It's important to note here that the gap between ephemeral services like Redis and multi-master database services like Cassandra has been narrowing over time. If you're configuring your database servers to perform most operations directly out of index anyways, you don't gain much speed by skipping the write step - I have a friend who just uses DynamoDB for everything because, correctly configured, it offers single-digit-millisecond response times. On the other side of the table, Redis can be configured to stream all of its writes to disk, giving users recovery options and backup options if their servers ever do go down.

So, fast databases can act like cache, and recoverable cache can act like a database.

### Queues
Your web servers should not be doing CPU intensive processes. Or long-running processes. Both of these interfere with their ability to do the one thing that they are supposed to be doing, all of the time: quickly responding to as many requests as humanly possible.

So, when we have a long-running or CPU intensive process, we need to do it somewhere else - which means that we need a way for our servers to queue up background tasks.

We can just use our databases or our cache to resolve this problem - but, there are, of course, products designed specifically for this use case - message queues. Products like RabbitMQ, designed to hold on to messages, and have lots of servers subscribe to those messages.

Messages, once enqueued, can be delivered just once, or redelivered until they're guaranteed to have been processed, eventually rolled into a dead letter queue if they fail repeatedly, there are lots of tools for managing these messages.

### Streams
Streams and Queues are only subtly different as data structures, but they serve different purposes.

A lot of data - logs, for example - can be streamed, just sort of written very quickly in order. Many different consumers can then keep a pointer to where they were reading on the stream, and just read whenever they want, updating the pointer as they go.

This data is still structured like a queue, like the message queues we just talked about, but there are no guarantees that data will be read out of the stream, or delivered at all.

Streams are more popular for things like structured log data, where lots of consumers might potentially read from a stream. Systems like Apache Kafka and Redis provide Streams.

### Time Series Database
An even more specialized instance of a streaming database is a time-series database. Time series databases are intended for the problem of analytic data - writing absolutely enormous amounts of information and then, compressing that data over time so that even more data can be stored - you are probably more interested, for example, in high-granularity diagnostic information for the last five minutes, and lower-granularity diagnostic information for the last five years.

Products like InfluxDB, Prometheus, and VictoriaMetrics provide time-series databases.

### Search Databases

Another specialized database type that you might add to your infrastructure is a search database.

These operate like a kind of specialized index server that provides extra indexes for your database. When you write to your database, you'll also write index updates to your search index provider. Then, when users search your data, they can use the more powerful search features in the search provider - this often produces faster and more accurate search results than the results that you'll be able to achieve with simple database queries.

Products like ElasticSearch provide search capabilities.

### I Love Redis
I just want to toss a little special extra love towards Redis - with relatively sane clustering, incredibly fast memory-based operation, optional backups, and support for queues, streams, and search, it can do a _lot_ of things, _pretty well_. You should probably not use Redis as your primary database - it's really not designed for that -but as a secondary database it can pull a lot of weight in your infrastructure.

### Some Sane Defaults
If you're looking for a sane set of defaults for a new product, consider
* Postgres for your primary database, expandable to CockroachDB if you need something much more scalable.
* Wasabi for your files and backups.
* Redis for your cache, streams, queue, and search.
* VictoriaMetrics for your metrics, as a time-series database.

Of course, you shouldn't introduce services until you know that you'll need them.

Also, by the very nature of time, this segment may be badly outdated by the time you're actually hearing it - so, before taking my word for it, you should absolutely go do this research yourself.