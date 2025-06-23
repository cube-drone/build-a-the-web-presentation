# Chapter 15: Miscellaneous

## Backups
Of course you have backups of everything. Even with all of your resiliency plans, your servers can still be hit by a comet.

Every once in a while you should recreate your entire production environment from scratch, using nothing but backups and your infrastructure code. In fact- this is a good way to get an up-to-date dev environment, so long as you anonymize or delete your user data before using it in dev.

## Secrets Management
As your web service and all of its backing services grow, the set of secrets - critical passwords and the like - that you need access to in order to deploy these services to production grows and grows.

Where do you keep all of this information? Well, the answer is: as securely as possible. If it's on a post-it-note stuck to your fridge, that's probably bad. While you're small, just keeping them in encrypted storage, accessible to only a few members of your team is probably sufficient. As you grow, you'll probably move towards a secrets manager, like Hashicorp Vault or AWS Secrets Manager, where you have more granular control of who and what has access to those encrypted secrets.

## Rate Limiting
Moving from software as a service to video games has been a bit of a culture shock for me. You have to be very well-established as a business to see even an tiny fraction of the level of casual abuse that video game servers (and employees) get from their users.

All services need security and hardening against all manner of attacks, mind you - there are baddies out there targeting just about everyone. Working in video games, though, gave me a harder education, faster, than anywhere else I've worked.

One of the quick things that you'll learn is that you cannot have any interface to your application that is not rate limited in some way.  Even if the rate is set to something that seems insanely high, you need that rate limit in place because someone will attempt to hit that endpoint ten million times per second.

Rate limiting can be provided within your application, or by your load balancer - basically any proxy in between your application and the internet can be configured to provide some level of rate limiting - however, there are different levels of rate limiting that you'll need to consider.

Rate limiting simple requests at the HTTP level is a good start - but you'll also need to consider application-level limiting of any resource that you give the user access to: someone will find a way to use way, way too much of that resource. If you have user-actions that can trigger emails, or messages to other users, or any slow-running process? Rate limit.

## Distributed Denial of Service & Content Delivery Networks

The first time I got hit by a Distributed Denial of Service attack was two weeks after the public launch of the game that I work on - we had less than 100 concurrent users at the time, but that was enough for one of them to have some beef with us.

Our provider at the time - I don't want to say their name, that could embarass them, but it rhymes with Migital Mocean - their DDoS prevention strategy is to find the customer that's getting attacked, and disconnect them from the internet. This protects _their other customers_.

So, if you don't want to get laser-beamed off of the internet, you'll need some kind of DDoS protection. The way that DDoS protection works is kind of - like a DDoS protection racket - a whole bunch of companies get together and fund an absolute buttload of server resources that proxy connections to all of their services. They may be able to knock over one of us, but they can't knock over all of us. It's Distributed Denial of Denial of Service.

The thing is - the tools that you use to bounce DDoS attacks- a globe-spanning network of proxy servers - that's also a content delivery network. If your services and files are cached in locations around the world, access to that cache is very very fast, no matter where you are. It does dual-duty, facetanking bulk attacks and also just making your cached assets very very fast to load.

## DevOps
You'll hear the term "DevOps" a lot.

It used to be that the skillset required to develop software and the skillset required to run that software on linux were two distinct specialties - with operators treated with a lot less valor than developers. Which sucked.

Modern ops, though, has grown in complexity, and a lot of developing startups run so much of their ops with complicated tooling and Infrastructure-as-Code that the job of ops is very much like the job of a dev. On top of that, developers, when writing their software, should be keeping the needs of ops in mind. It makes a lot of sense to just have the backend team do _both_ - they write the software and they operate the software. Dev... Ops. DevOps.

If you combine Dev, Ops, and Frontend knowledge into one unfortunate subject you end up with the rare "Full Stack Developer", a mythical beast that mostly only exists because most startups can't afford to hire three separate subject matter experts.

Even as something of a Full Stack Developer myself, I have to point out that being a little bit good at a lot of things is more valuable in a small company where there are more jobs than people to do them, and it grows steadily less valuable as you start to grow large enough to have a person who's just really, really good at, like, _data science_, or _iOS programming_, or _shaders_.

The idea that everybody at your company should be able to do everything all the time is maybe a bit naive - sometimes people are better at things than others. Specialization may be for insects, but it's also for companies.

One useful piece of advice that I've heard is to try to consider your own skillset T-shaped: you broadly understand enough things to ship an entire project, but there's one thing that you care about very deeply and your skillset in that matter is rich and deep.

## ChatOps
Chat tools like Slack, Discord, and Microsoft Teams - and their open-source alternatives like IRC and Matrix - are becoming de-facto communications standards for coordinating teams. I can't imagine a modern tech company _not_ coalescing around a chat client.

Which makes that chat client a really obvious point of coordination for ops stuff. Automatic ops alerts, charts, graphs, deployment information, dump it all in your chat! Gonna change something in prod? Mention it in chat! If things are neatly divided into channels you have the ability to opt in and out of stuff as you like, it's great.

One thing to be a little extra aware of is how easily bot chatter can render a chat channel completely unusable for human communication. You'll either want to sequester automatic updates into their own channels or tune their output to fire only when it's important for humans to see.

It's also pretty useful to have a dedicated high-alert channel where you only post if something has gone extremely wrong. If you see pings coming in for you on #red-alert you know it's time to get to a terminal.

## Post Mortems and a Culture of Blameless Ops
Do you know what's worse than prod going down?

Prod going down and the person who knows exactly why prod went down doing everything they can to conceal that from the team, because they're worried about people learning what they've done and possibly getting fired.

But what they've done isn't just "bringing down prod", they've unveiled an exciting new way to make prod more resilient going forward.

After outages, you'll need to compile a report to determine exactly what happened and what your plan is to prevent that from happening again in the future, and then you're going to have to implement that plan - finding people to point fingers at accomplishes exactly none of that.

## Autoscaling, Infinite Scale, and Cost Control
With tools like ECS and Kubernetes it's possible to have parts of your stack that scale up automatically when certain parameters, like CPU, start to spike heavily on your servers.

With other cloud tools, like S3 or automatically scaling load balancers, they will simply expand to fill all load automatically.

That's wondeful, right? Well, to a point.

Scaling up is only the solution to a production problem, like, half of the time - and the presence of infinite resources gives your systems a lot of leeway to accidentally start using all of those resources.

Say, for example, you accidentally have a loop in your job system that re-introduces completed jobs into the stack, or an error that never lets jobs complete - the job queue will fill up, possibly your autoscaling will create more workers to try to deal with all of the jobs, and that won't fix anything, so the queue will fill up more, faster, and so you'll scale up even more.

Infinite scaling also gives you all of the rope you need to hang yourself with infinitely large bills, if you aren't careful about setting tight boundaries around how large your system is allowed to scale.

Some providers that provide this kind of tooling offer you rich, detailed, powerful tools to see day-by-day breakdowns of exactly how much you're spending, which are critical, and you should take full advantage of them.  Some other providers, and I'm not going to name names, but, CLOUDFLARE, will just fully ride out the month and then blindside you with a bill for enough money to put a down payment on a house, and then use that to muscle you into an expensive enterprise contract.

This is the most concrete advice you're going to get from this entire document. Don't enable pay-per-request Cloudflare features. Ever.

## The Enduring Utility of Vertical Scaling
A lot of what we've talked about when it comes to scaling focuses on flexibility, replication, horizontal scaling, and infinitely scalable backing services - _but_ - it's important to remember that you are not Google.

Servers got really, really powerful. It's not unreasonable to be able to set up a server with 128 CPUs and a terabyte of RAM. That's enough power for an entire mid-sized company - easily enough to handle your first million customers.

A lot of the orthodoxy about how to super-scale up comes from companies that have had to scale to enormous, world-spanning sizes - and - they've done that over decades, with huge teams of engineers - while it's useful to know some details of how they managed to do that, and how you might do the same - vertical scaling - simply moving to bigger and bigger computers - will serve you for way longer than you'd imagine.