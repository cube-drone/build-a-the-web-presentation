# Chapter 14: Seamless Operation

## Supervision
When you launch your application in the cloud, you... don't want it to turn off. In the even of a serious error, or even a reboot of the server that the application is running on - it doesn't matter what causes your system to stop running, you want it to try to restart itself.

In order to make sure that your system stays on, your application, when live, is paired up with a supervisor - a separate application that boots up with the server, and makes sure that your software is always, always running.

In the past, you might use something like `supervisord`  for this, or using the operating systems' built in `systemd`. That's less and less necessary nowadays because most containerization systems also function as supervisors for their containers - so if you have a `chunkyboy-app` container, you can instruct your container application to reboot `chunkyboy-app` if its main process ever dies for any reason.

The combination of supervision and shared-nothing in architectures is really powerful: your servers can respond to just about any serious error by simply pooping out a bunch of diagnostic information, then dying. They'll reboot themselves quickly and be back up and running in seconds. SELF HEALING ARCHITECTURE!

## Seamless Operations
It should go without saying, but, one of the big goals of your deploy process should be to make it totally invisible to users, and so easy for your development team that they have no qualms about deploying several times per day.

There are a lot of jokes out there about not doing big deploys on Friday - because if they go wrong, you're stuck debugging them on what was supposed to be, your weekend. I think, though, that that kind of cowardice should be met with a bit of healthy skepticism: if your systems aren't healthy enough for you to be confident to deploy on a Friday night, your systems aren't really that healthy at all.

There are a few different major philosophies that can be used to improve your ability to deploy with confidence:

### Just Don't Ship Bugs
Obviously, the best way to deploy code without having to worry about it is simply to deploy perfect code. If you don't write any bugs, or you catch them all before deployment with very careful QA, then rollouts are totally risk free.

You write everything in Rust to rule out type errors, and every line of code you write goes through intensive unit testing, integration testing, load testing, weeks of QA, a closed beta period, an open beta period, and down-to-the-individual line PR scrutiny from other developers on your team. Getting even simple features into production takes months of careful negotiation.

You're not just QA-ing one feature at a time, now - releases take so long to get through the process that they're starting to get big. Now you're not just QAing and shipping one feature, you're QA-ing and shipping 10 at the same time, and you're not checking on them individually, you're testing them as a unit.

And then... somehow, you ship a bug anyways. Prod goes down, you have no backup plan, and everyone gets fired - in no small part because your incredibly slow development process is lagging way behind the assholes like me who just deploy experimental code whenever we feel like it and have a plan to deal with the consequences of shipping imperfect code, rather than a plan to ship perfect code, which is, almost impossible.

### Blue/Green Deployments
In blue/green deployment systems, you maintain two full clusters - essentially, two entire copies of your entire web stack, each in a separate "bank" of servers. They can either share access to common databases or have the databases replicated across either bank.

When deploying, you take the bank that's not currently active and roll out your entire deployment. This can happen without anybody noticing the change, because the bank is completely inactive.

Then, you can poke your bank to make sure that everything is running smoothly, and then cut over traffic from your active bank to your inactive bank. The cut-over can be as quick or smooth as you want.

Watching error rates and the important charts and graphs across your backend, if something starts to go very wrong, you can panic, and cut immediately back to your last version of the code - which you know, should be stable, it's been in production for a while.

There's a lot to guard against cutting over to an invalid state here - if your servers won't boot up, you just never cut over to them.

This ability to immediately rollback to a safe, validated state can help you be bolder about trying things in production - worst case scenario, there is always a kill-switch you can pull if things start to go pear-shaped.

That being said - if your new code does something really dumb like knock over a database server - or, if you deploy a bunch of times, very quickly, over-top some code that takes hours to fail badly, it's still possible for you to get production into a difficult to recover state.

### Graduated Deployments

A modern technique, popular with the elastic and kubernetes crowd, is to deploy code a little bit at a time: let's say you have 100 servers that you're deploying to. Maybe we swap out the containers of the first 10 servers, check if there are any serious errors, and if everything looks good, we swap out the next 10 servers, and so on, until we've completely moved over to our new code.

This is more efficient than the blue/green solution: you only have one bank and you're just moving things over bit-by-bit, and checking as you go to make sure that error rates aren't spiking.

This can also somewhat rob you of your instant rollback - because rollout is gradual, and you clear out the containers you're not using when you're done, the only way to rollback after you've deployed is to re-deploy using the older code. Still - though - if your deploy is relatively quick it shouldn't be too onerous to wait for this.

### Which Technique to Use
The techniques of "Just Don't Ship Bugs" - I made fun of them, but you should still do a lot of those things - there are lots of times when they're useful - you really should do what you can not to ship bugs. Especially in financial or health-care systems, where bugs could cost people their lives or livelihoods, it's important to take quality control very seriously and, as a result, slow down your pace of development in order to do it responsibly - however, it's just as important to be aware of the ways that they slow down your development process and use them sparingly so as not to kill your throughput.

*Nobody*, not even NASA, ships perfect software, and trying to do so while neglecting your ability to detect that you've shipped imperfect software is a mistake. Slowing down your development process to ensure perfection also slows down your ability to discover and adapt to errors and fix them quickly. A company that ships every day is a company that can ship something broken, and discover how it's broken, and get it fixed _faster_ than a company that waits months to deliver that same functionality.

The other techniques of seamless operations we talked about focus instead on using your ops toolkit to be able to diagnose problems live, as they're happening - using your users and your production environment as live QA.  This is better for systems where failures can be easily caught by ops tooling. If your failures can be seen on graphs, then you can use these techniques to catch and remediate those failures very quickly.

These ... techniques are intended for web products - they don't work as well if the consequences of shipping bugs is very high - older video games, in particular, had to get everything right before they mastered their product on to permanent DVDs that went to everyone's homes. If Final Fantasy 6 shipped with a bug (and it did), that bug wasn't going anywhere. On the other hand, a web product can swap the code you're interacting with dozens of times an hour, and you may never notice.

Blue/Green is conceptually very simple, and much easier to write on your own - if you are piecing together your own infrastructure, I'd recomment blue/green because it's is something that you can build, very easily. The redundancy it offers, and the instant rollback are both very worthwhile.

On the other hand, if you are using a control plane like Elastic Container Service or Kubernetes, graduated rollout is often built right in to the platform - building Blue/Green is actually much harder in these systems because they don't expect you to use them that way.

## Redundancy and Single Points of Failure
Look at your architecture diagram. Are there any parts of it where there's just one server and if that server goes down you're completely boned?

That server is a SPOF, a single-point-of-failure, and when you're laying out your systems it is your responsibility to try your very best to make sure that that server doesn't exist. Servers disappear all of the time.

Databases can use replication and election to swap to secondary servers if their primaries disappear. Load balancers can be set up in parallel, and balance to many different servers, so there's no individual server that can cause your product to go down.

Taken to its extremes, this philosophy can also apply to entire data centers, or your organization. Is there any region of the united states that could disappear, taking your entire business with it? Hurricanes happen more often than you'd think.

Is there any employee of your company who could be hit a bus by surprise, taking your entire business offline because they're the only one who knew the password to unlock your front doors?

You can even test out your redunancy by randomly turning off servers and hitting your employees with buses, to see what happens. (You can also accomplish this somewhat with a generous vacation strategy, although that's less fun)
