# Chapter 8: Connect & Config

The first thing your application will do when it boots up is to connect to a variety of services - databases and the like - and then set up its router and start routing requests.

This is an important step - building database connections is an expensive task, so your system definitely should not be building a fresh database connection for every request - instead, when your system boots up, that's when it builds all of the connections it's going to need for the lifetime of the process.

Because our servers are ephemeral - shared nothing - it's good to try to keep this connection step _fast_ - that way, if something bad happens, the servers can just quickly reboot, reconnect to its backing services, and go on their merry way - in fact, you can set up your application to just fail with an error code if it ever loses a critical connection - instead of building reconnection logic, your application's supervisor will just reboot the application again and again, until it eventually manages to reconnect properly.

If we're connecting to a lot of other services, though, we need their locations, their credentials.

Obviously, we shouldn't hard-code these locations into our product. I feel like that's such a basic observation that I almost feel silly saying it.

### Prefer URLs for Locating Resources, Uniformly
Have you ever seen a block of code that looks like this?
```
database_protocol = 'postgres';
database_host = 'localhost';
database_port = 1234;
database_user = 'gork';
database_password = 'mork';
database_name = 'application'
```
Yeah, that's a line of details that you'll need to connect to a database, and six whole different variables.

If only there were some sort of **uniform** way to represent the **location** of a **resource**.

Of course, what I'm leading you to is that this is another use of our old friend the URL.  We can take that whole set of connection details and squish it together into one neat, tidy URL:
```
postgres://gork:mork@localhost:1234/application
```
URLs are _great_ when it comes to providing the unambiguous, complete location for a resource somewhere on the internet - which is - exactly what you want to provide when you're connecting to backing services.

### Config Files
A common strategy for managing your configuration details on start-up is to maintain a set of reasonable defaults, then, parse a config file located somewhere in the system. The config file might be represented in INI, or XML, or JSON, or YAML, or TOML, really any user-editable serialization format should do the trick.

Of course, you don't necessarily want to hardcode the location of the config file - then you won't be able to run two copies of the same application on the same system - and you might want to change individual variables up when you boot up the application.

For this, we want something a little more flexible than config files.

### Environment Variables
So - and I'm biased here, I think this is the best way to set up configuration information for your app - you can just pass in all of the configuration as key-value arguments when you boot up the application.

You can either do this by setting up and parsing arguments passed to your server software when it boots up - like
```
>>> myserver --databaseUrl=postgres://blahblahblah
```

or, and this is extremely well supported on Linux systems, you can pass them in as environment variables:

```
>>> MYSERVER_POSTGRES_URL=postgres://blahblahblah myserver
```

One of the really nice things about environment variables is that you can set them permanently for a bash session - so if you're coding and you want to change the postgres environment for your next ten runs of the application, you can set that environment variable and it'll be passed, automatically, to your application.

A lot of testing frameworks, application supervisors and containerization solutions for deployment also give you fine-grained control over which environment variables are passed in to your application when it boots - making this a super well-supported way to handle flexible configuration for your application.

### Database Config
All of these solutions are well and good for taking hardcoded variables and instead passing them in when you boot up your application.

However - these values are locked at boot time. Your application is likely to be put up and left running for weeks or months at a time - you don't always want to have to reboot and rerun all of your servers to make a simple config change.

So, for variables that you want to be able to change frequently, I recommend storing that information in your database, in a configuration table. You probably shouldn't do this with database connection details, but for a lot of other things it's super useful - in particular, this supports feature flags really well.

One thing about config, though, is that these variables tend to be hit very, very frequently. I don't usually advocate keeping anything in your servers' local memory - but - because config is small - I think that the best way to maintain a fast, reliable config is to have every process in your entire cluster cache a full copy of the entire config object in local memory and refresh it periodically.

That might not be necessary, though - how you deal with config is up to you.

#### The Config Heirarchy

Okay, so, for every hardcoded variable in your system, there's a potential four-step heirarchy of where that value could come from, each overriding the next:

* Default
* Config File
* Environment Variable
* Database Config

And you don't need all of these for every application - I think that Config File _and_ Database Config are both a little heavyweight for little applications, and the Database Config doesn't necessarily need to be able to override everything in the Config File - especially connection urls.
