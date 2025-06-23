# Conclusion

Wow. You... actually read the whole thing.  Or you skipped ahead to the conclusion. Either way, I'm impressed.

Let's summarize some of the takeaways of our ~~talk~~ book:

* Understand your language's concurrency model and how it affects your scale-up plan.
* Choose your databases with an understanding of how they're going to manage replication.
* There are lots of task-specific backend services, and you'll probably need a few of them.
* Configure your application by passing URLs to backend services through environment variables.
* Store passwords using a slow, secure password hash designed explicitly for the task of hashing passwords.
* Don't try to send your own emails, you need to use a service for that.
* Use HTTPS. There's not an authentication model out there that can't be rendered insecure by trying to run it over HTTP. Encrypted transit by default makes a lot of authentication schemes possible.
* Rate limit everything, especially authentication.
* Make sure to provide password recovery options for your users.
* If something seems a little suspicious about a user's login, check in with their email address before letting them log all the way in.
* Allow anonymous access to your service using either unauthenticated endpoints or temporary ephemeral accounts - it will drive adoption of your service.
* Allow login from external providers to convert users without requiring an email and password.
* Use feature flags to launch functionality without actually launching it, show test features to only specific users, and turn that functionality off if something goes wrong.
* Cache and autoscaling are not one-size-fits-all solutions for performance problems - learn to use them wisely.
* You're going to become extremely familiar with logs, charts and graphs.
* Don't DDoS yourself.
* Automate setup of your local and production environments.
* Use a tool that allows for fast DNS updates.
* Continuously and automatically produce shippable build artifacts from your codebase.
* Deploy seamlessly, using blue/green or gradual deploys.
* Have your servers die and reboot quickly rather than letting them get into weird states.
* Accept that you'll ship production-breaking bugs and embrace strategies that allow you to quickly identify and roll back to known good system states.
* Don't let a single server failure take down production.
* Test that you can peform a full restore from your backups.
* Use a CDN, not just for DDoS protection but also for lightning fast content delivery.
* Be a full stack engineer, or specialize, or do both. Your career is in your own hands!
* Take advantage of your work's chat client, it's a central communications hub for a reason.
* Don't get shitty when things go pear-shaped. It's a bad time for everyone and there's no better time to be patient and compassionate, even if you're white-knuckling a full tumbler of cheap whiskey.
* Uncontrolled autoscaling can cost you an arm and a leg, and can be fired by bugs that would otherwise trigger production outages. Watch it carefully and set limits on everything.
* Horizontal scaling, autoscaling, and infinitely-scaling managed services will scale up as big as your budget will allow, but do not underestimate the power of one great big goddamned server.

That's it! That's all the tips!

Thanks so much for reading!
