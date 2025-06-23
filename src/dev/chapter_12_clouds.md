# Chapter 12: Clouds & Control Planes

You have a product! Congratulations!

Now it's time to try to deploy it somewhere!

## Infrastructure as Code
A guideline for keeping your infrastructure as understandable and manageable as possible is to have it, in its entirety, represented as scripted automations.

This is a lot of extra work up-front, but - the payoff is that you have a pretty in-depth audit trail of exactly what you've created, and where, including a git history explaining all of the things that you've changed over time.

## DNS
First of all, obviously, you're going to need a domain name.

What's a lot less obvious, though, is that once you have a domain name, you're going to want to consider moving your DNS nameservers away from the defaults provided by your domain registrar to a routing system that supports very low TTLs and high-speed changes, like the ones offered by Route53, BunnyCDN, or Cloudflare.

These are usually very cheap - like, I run them for personal projects cheap - and the difference between having DNS updates resolve in minutes rather than hours or days is _huge_. It is a noticeable improvement.

A cool tool for scripted management of DNS is OctoDNS.

## Clouds & Control Planes
Where are you going to host your software? I'm going to sort these from least to most expensive.

### Shared Hosting
Shared hosting is for scrubs and schmucks. If you've listened to my presentation for this long and I haven't scared you off, shared hosting is not for you.

### On Prem & Colo
I am just straight-up not qualified to talk about building on-prem and colocated server stacks. This is a skillset that some engineers have, and I am not one of those engineers - in fact, I'm not an engineer at all.  I think I have a math degree.

In exchange for a really significant capital expenditure as well as ongoing staff and maintenance costs, HVAC, plumbing, careful electrical layout, fire suppression systems, uninterruptible power supplies, generators, and unbelievably expensive network switches, **you can run your own servers**. Which I think technically is and will remain the most cost effective way to keep servers on the internet.

There are loads of downsides to this kind of arrangement - for one thing, it really is best if you know _exactly_ what your server load is going to look like for the next ten years - overprovisioning or underprovisioning in a scheme with such high capex costs can get really expensive.

### Dedicated
The next best bang for your server buck comes from dedicated servers. You rent the hardware and you can do whatever you like to it.

That cost savings, too, comes with inflexibility - each new dedicated server takes hours or days to provision, and if something happens to the dedicated server you're left holding the bag as the server gets repaired or replaced - you pay month to month, not minute to minute, and provisioning a new server usually comes with a setup fee.

Dedicated servers can be a touch on the fussy side. They break, like any other server class does - but when they do you're stuck with 'em - so, if your plans rotate around dedicated servers, I'd recommend fully automating their setup processes, replicating your data across quite a few of them, if possible in a few different geographical locations, and maintaining a plan where if one of them starts to get weird, instead of wasting a bunch of time trying to get their network ops to go poke it with a stick, you just tell them to decommission it and boot up a new one for you at the next available opportunity.

You will pay for this in setup fees and paying out the rest of the month for dedicated servers that you've decomissioned, but If you're working with a budget of like, a thousand to a few thousand dollars a month and you want to put up services that will punch way out of their weight class this isn't a bad strategy.

### Virtual Private Servers
They come at a price premium, but I love 'em.

Virtual Private Servers are virtual machines running inside of much beefier hardware. You pay N dollars per month, and in exchange you get a few dedicated virtual CPUs, a fixed amount of RAM, and root access to a complete virtual server.

VPS-s are a really popular learning and development environment, too - they're expensive compared to dedicated servers for _what you get_ - but - there's no _way_ you're getting your hands on a dedicated server for ten bucks a month. You can, however, get a 1 virtual CPU, 2 Gigabytes of RAM computer - about half as powerful as a Raspberry Pi - for that cost. As a bonus, that 1 CPU/2GB virtual machine is the ideal size for exactly one node.js process, which plays ball really well with our process scaling model.

The benefit here is that the VPSs charge by the minute, rather than by the month, and you can spin them up and shut them down in seconds. With even a little bit of automation at your side, debugging a VPS starts to become silly - why would you bother, if a server gives you trouble, you can kill it and replace it with a new one in an instant.

There's a term in DevOps - cattle, not pets. Dedicated servers are pets. They live a long time, you get to know them by name, you spend a lot of time caring deeply for their health and watching them, and if one of them dies you are going to have just the worst week. Virtual machines are cattle. You give them numbers, not names, and if they give you trouble, well... there's always another virtual machine.

It's a pretty good analogy although it leaves me closer than ever to considering the dubious ethics of my carnivorous lifestyle.

### Clouds
Beyond running your own infrastructure on heaps of disposable virtual private servers, you can start to engage with more well-formed cloud products.

Why run your own database, when AWS can run a managed database for you, including backups and failover that you don't have to manage yourself?

Why run your own load balancer? Why scale your own servers behind the load balancer? With Amazon's Elastic Container Service you can just hand Amazon a Docker container and tell them how many you want to run, and it'll handle all of the ugly details of building out that cluster for you. You want 20 containers? 40? 100? 600? It can make as many as you want, and it can automatically flex that number based on how busy your service is.

This computing model is so powerful that it's currently eating the entire world. Despite coming at a significant price premium, handing over all of your ops to Amazon is a really compelling way to scale your system up without having to worry too much about whether or not your ops can handle it. Their ops can handle it. What you need to worry about is whether or not your wallet can handle it.

If you have VC cash, or you're a well-established company with money to burn and SLAs to meet, clouds like AWS, Azure, and GCP are just non-negotiably the king of the heap. More and more of the job of backend engineering is slowly dripping into just understanding AWS, Azure, or GCP products really well.

Does that make me sad? Yes.
Does that stop me from running the entirety of my day-job out of AWS? No.

It turns out that the most valuable development tool at the time of writing isn't a code editor or a database product - it's a credit card.

### Kubernetes
Well, if clouds are so great, why not an open-source cloud that you can manage yourself?

Kubernetes allows you to take a bunch of boring ol' dedicated servers and run software on them to get an interface that's kind of like what you'd get from Amazon's ECS: a much more abstract system that can run all kinds of containers.

One big caveat, though - Kubernetes was designed to allow server teams to offer an AWS-like product. It is absolutely not designed for one person to launch and maintain. Instead, if you build software intending to deploy it to a Kubernetes cloud, you can then go to one of many Kubernetes providers and deploy it against their cloud - your deployment should be cross compatible with *any* Kubernetes provider.

This helps you avoid vendor lock-in somewhat - you can always take your software from one Kubernetes provider to another, expecting that they'll act pretty much the same. Also: a huge amount of software has sprung up around the Kubernetes ecosystem, which is cross-compatible with any Kubernetes cloud.

Those are the good things. The bad thing? Kubernetes providers are _expensive_. Like, as-expensive if not more expensive than proprietary cloud rollouts.

When I'm building software for myself, I don't consider Kubernetes or cloud products really viable solutions, because their costs can get so out of control so fast. Instead, I stick to dedicated servers or VPS solutions, because that's what I can afford. On the other hand, I work at a VC-backed startup and it would be, I think foolish of us not to be using big cloud tools to scale up as quickly and seamlessly as possible. All of these different solutions have their pros and cons depending on what you're trying to accomplish.

### More IaC
When automating rollouts against dedicated or VPS servers, automatic provisioning tools like Ansible or Chef are the standard.

On the other hand, when automating rollouts against Kubernetes or big cloud providers, the automation tools are tools like things like CloudFormation or Terraform.

I'm reluctant to admit it, but I'm much more experienced with Ansible than I am with Terraform. I'm getting more obsolescent every day.
