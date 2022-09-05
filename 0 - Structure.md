# How to Build a Social Network

## Intro
Hi! This is a little microproject I want to do: I want to talk a little bit about every single topic that you'll need to know about on your path to building a WEB APPLICATION. 

## You
Here's about the skill level I'm targeting here: 
* You can program
* You know the basics
* You know some data structures and 
* You're starting to wonder how to tie those ideas together into a whole application.

That's what we're here to talk about! 

## Summary
We are going to be going through this very quickly. 

This is out of necessity - the last time I tried to put something like this together

I got stuck on character encoding and Unicode for like 8 pages. 

Character encoding is really neat, and someday I hope to turn those pages into a totally separate presentation, but there's no way we're going to make it through everything if I don't trim some details so that we can make it through this in less than 100,000 years. 

Here, I'm going to pop up the Table of Contents so you have an idea what we're going to cover - and we are going to go fast. 

----

# Act I: Dev

## Client & Server
The first thing to talk about is what a web application looks like. 

* You have a browser. 
* You type in cube-drone.com/hats. 
* It uses DNS, the Domain Name System, to resolve farts.org to an IP address. 
* It uses HTTP, the Hypertext Transfer Protocol to send a request to farts.org 
* There's a server on the other end. 
* It gets the request for "GET /hats" and responds with a page of HTML. 
* Now you're looking at a website.

So building web applications is largely about programming the parts that are happening on the server over here. 

### HTTP
HTTP, the Hypertext Transfer Protocol, it's all just a bunch of fancy stuff that sits on top of regular ol' TCP/IP.

#### What's In a URL
* Protocol (http, or https - or redis, or postgres, or gopher, or...)
* Hostname (and port, if necessary)
* Path & Query

This divides pretty nicely into "the server we plan to connect to", "the language we intend to speak to it", and "the thing we want that server to do for us"

#### GET & POST and some more esoteric codes
There are two primary kinds of message you'll send to the server - GETs and POSTs. When you GET a path, you're saying to the server- whatever is there, go get it for me. When you POST to a path, you're saying - here, server, I have something, take it and put it at the path I gave you. 

For example, imagine a theoretical comments section - you might GET /blogpost/1234/comments , and then send a POST to /blogpost/1234/comments containing some structured data that it would then add as a comment. 

GET and POST are the important ones - GETs are for getting data, POSTS are for changing data, and that's all you really need to know. There are some more esoteric ones, like DELETE, and PUT, and HEAD, and PATCH, but you mostly don't need to use them.

#### Headers 
Your GET or POST request don't travel alone - they can also bring a bunch of metadata with them. This metadata comes in key/value pairs called "Headers". 

Here are some of the HTTP headers that are included with a request to a website

Here are some of the Headers that that same header include as a response.

#### Cookies
Cookies are also a kind of header - they're a bit of extra data that you can include with a request to a website. 

The server can also, when it responds to you, ask you to hold on to a little bit of extra data along with your request, with an expiry date - so, for example, when I hit cube-drone.com, it might respond, saying

"hey, for the next week, every time you send me a request, could you also send me this fourteen digit number?"

That turns out to be wildly useful for authentication, which we'll talk more about later! 

#### Status Codes
Every HTTP response comes with not just text, but also a three digit number indicating how well the request went.

200 is the number that meant "everything went okay". Numbers in the 300 range mean "your data is somewhere else", Numbers in the 400 range means "you screwed up somehow", and numbers in the 500 range mean that the server that you've connected to has managed to light itself on fire somehow. 

So, for example, 301 - that's "moved permanently" - whatever you expected to find at this path, it actually lives somewhere else, and the response will tell you where to look. Your browser will helpfully follow this trail automatically.

That also means, you can set a 301 pointing to another 301, in hopes that your browser will follow that chain forever - but most unfortunately, most modern browsers won't fall for that and will stop following redirects after a while and simply give up. 

404 - that's "not found" - it means you screwed up, because you asked for something that just isn't there.

500, that's an "internal server error" - most servers are configured to spit out a 500 if something inside them breaks unexpectedly. It's almost always a sign that not only has something gone wrong, it's someone else's fault. Some programmer, somewhere. 

### Other Kinds of Software We Won't Be Talking About
So, this talk, is about client-server web applications, in specific. 

Here are some things we won't be talking about: 

#### Single User Applications or Video Games
These are just... programs that you give to people. There's no client, there's no server, you give them a program and they run it. 

#### P2P
More and more of the internet is running off of peer-to-peer protocols - bittorrent,  Tor, IPFS, Dat, and the very stupid world of blockchain are all capable of running entirely without a server - applications built using these protocols are incredibly powerful and increasing in popularity - but the model for developing them is significantly more complicated than the one for traditional client-server architectures. 

#### Play by Mail
It's possible to run the entire client/server communications network over mail, or - if you prefer- carrier pigeon. If you use a carrier pigeon to send me some mail with a HTTP request on it, I could easily respond with some more mail containing a HTTP response - however, this system is almost untenably slow and poop-laden, so we're going to leave it out for the sake of time.

#### Serverless
This one is worth a little bit more thought. So - various cloud products - Amazon, Google, Azure - they'll offer you whole programming interfaces abstracting away just about everything about web programming. Essentially - they'll write almost everything for you, and you just provide the application logic. Then, you give them the code and they run it in the cloud, they handle the scaling, and they charge you micropennies every time someone hits one of your endpoints.

If you connect this to one of their databases that also scales up automatically for you, your whole application can just exist "on demand", and for prices that are at least competitive with what you'd pay to host your application on a traditional server infrastructure. 

I'm not going to go into detail on my thoughts on serverless - it's pretty cool - but what we are going to talk about here are all of the components and practices that Amazon or Google would be replacing for you. If you do end up embracing serverless, it'll help you to know most of this stuff, at least at a high level, anyways.

### OS (Linux, Dummy)
So if we're not running our software on the gigantic mega-structure that is someone else's server, what are we running it on? 

Well, Linux. Something like 900% of all of the servers in the world are running some variety of Linux. It's free, it's powerful, it's stable, it's lightweight. 

### The Command Line
When I started with web programming in the mid oughts', I had just come off of a lot of Windows-driven application and even video game development and I was surprised - because a lot of Windows development is really heavily graphical user interface driven. 

I came in expecting tools like Visual Studio to handle all of the work of building web applications, with lots of buttons and toggles and bits - but no. Web application development is deeply, fundamentally tied to our old friend, the command line.

I thought this was some real regressive DOS-grade bullshit. But I learned. There a lot of reasons that the command line is the programmer's computer interface of choice - not so clumsy or random as graphical user interface, an elegant weapon, for a more civilized age.

* Writing command line programs is way easier than writing GUI programs
* Composing command line programs together is way easier than sharing data between GUI programs
* Learning command line programs, especially when you're used to them, is lightning quick

-----------

## Language
One of the the first questions that you'll probably come to when building a web application - any application, really - is "what language should I use"?

If you're learning everything from the ground up? The answer is probably Python or Javascript.

### Concurrency Model
The reason that your choice of language matters so much is because different languages have very different models when it comes to managing concurrency.  Now, when it comes to web applications, concurrency is non-optional. Imagine if, for example, a web server could only deal with one person at a time. It would be slow. 

Handling concurrency is also _really complicated_ - enough so that the concurrency model you choose effects every decision you make afterwards. It's a big deal. 

#### Remember, You're Not Writing A Database
Before we go into this section, I want to make a big big caveat.

The wrong decision here isn't picking something that's too slow. 

It's possible to write web applications in pretty much whatever language you like. The speed of your web application server isn't going to be your first scaling hurdle - and even PHP will cheerfully run a website for your first 10,000 users no problem.

Static languages, dynamic languages, they're both fine. Some people like type systems, some people don't, I've definitely seen some pretty compelling evidence that they don't affect your productivity too much either way. 

I'm pretty sure that most languages have fairly sane package management at this point - a good package manager where you can save a list of dependencies and automatically install it after pulling the repository - and most popular languages have libraries for just about everything you'll need. 

In fact, what you should probably be doing, is writing applications in whatever language you're most comfortable writing code in - because fast code is utterly worthless if you don't have any customers.

The actual wrong decision here is choosing a language with a concurrency model that's more complicated than you need for the task at hand, and wasting a bunch of time struggling with it.

#### Process Concurrency
"But languages like python, ruby, or PHP don't support concurrency"

Now, for those of you in the know, you know I'm sort-of lying about that - each of those languages has support for async or threads if you go spelunking in them - but let's pretend for just a moment you build a standard flask or django application in Python - that application can really, truly, only process one request at a time. It gets a request, and it has to respond to that request before it can move on to the next one. I've already said that this would be slow - but Python and PHP have been used to power some of the biggest websites on the internet? How do they do that? 

Well, your operating system has concurrency built in. When you're launching a Python program in production, you're actually launching dozens of processes, each containing an identical Python program with its own fully independent memory. Then, an external program - an http server - load balances requests to all of these internal processes. In many cases this external program will also manage the whole process lifecycle for these internal processes. This external program is almost always written by people who are very smart about writing high performance code, so you're leaning on them to do a lot of the heavy lifting for you. All of the actual concurrency is provided by your operating system's scheduler - which, thanks to the fact that the processes don't share anything, means that you barely have to think about it at all.

This process-based concurrency model is the simplest, the easiest to deal with. From the point of view of the program you're writing, there is no concurrency. You just have to respond to one request at a time.

If you are just learning, I strongly, strongly recommend a language that scales with a process-based concurrency model, like Python or Ruby. They are not the absolute fastest, but, remember: You're Not Writing a Database.

#### Async (Co-Operative Multitasking)
However, process-based concurrency is heavy. Each process demands its own space in memory. Ideally, you're writing your server programs to use very little memory on their own, but it is still a concern.

On top of that, a lot of time in web programming is spent waiting on network resources. One of your processes might send a query to a database, and then just wait ... for hundreds of milliseconds. In computer time, that's an eternity. Your operating system's scheduler will check in on that process every now and then, but most of the time it's just going to be waiting for the database to get back to it. 

What would be ideal, is, instead of jumping around from waiting process to waiting process, if we could find a way to get a single process to just be busy all the time. That means any time it has to wait on anything, it just remembers that it's waiting for that thing, and goes to do something else for a while.

Programming like this is hard. You have to relearn a lot of your habits to switch from thinking synchronously to thinking asynchronously - writing your software around the idea that it has to consciously give up control any time it's waiting on something to execute.

This also isn't really concurrency - it all still happens on a single thread of execution - but - this technique allows you to write a single process that stays white hot. Each individual process is able to deal with hundreds of simultaneous requests, because whenever it's waiting on something for request A, it can be working on something for request B, or C, or D, or E. If you have more than one CPU - if you want TRUE concurrency - you still have to scale out using the process model - one process per CPU - but only one process per CPU, because the process itself is handling the mechanics of keeping itself busy.

This is the scheme underlying modern web systems like node.js and Go. I love node.js. I... have complicated feelings about Go.

#### No Shared Memory
The process-based concurrency model is very powerful and flexible - but - if you think about it - it really, really limits the amount of memory available to each of your processes. Lets say you have a computer with four CPUS, and 16GB of RAM - if you're process scaling with Ruby, and you create 16 processes to jump between, each process only has access to 1 gigabyte of working memory. If you're process scaling with node, and so you only need to create four processes - one per CPU - each process only has 4GB of memory to work with. 

Now, one of the reasons this is important is because a lot of process-scaled languages are also garbage collected and very flexible. Which means - memory leaks can accumulate pretty easily in the code. Which means your program can eat all of its working memory, and then die. 

Also, and this is key: where do these programs keep everything? They can't keep stuff in working memory - if they do, only one of the many processes actually running on your computer would ever be able to see it.  You send a request to log in on this process and then you send another request but you're not logged in on *this* process, nightmare.

So, for this reason - amongst others - these servers are written according to something called a "Shared Nothing Architecture" - nothing that they need lives exclusively in their own working memory - all they do is connect to external databases that actually store all of the real, important information. If you reboot one of these processes, it ... doesn't matter. Because they aren't storing anything important. This also is super important for the resilience of your systems - it doesn't matter if you reboot any of these servers, they'll just wake up and start handling requests again, as if nothing happened.

####  Threads and Shared Memory
Remember when I said "we're not writing a database?" That's just - good life advice. Don't write a database. It's really hard. 

If we _were_ writing a database, we'd want both full concurrency and access to all of the shared memory the system has to offer. That's when we start to get into the realm of truly concurrent programming models - which means - threads. 

And where you have threads, you have synchronization issues. It's a fact of life - any time two CPUs have access to the same part of memory at the same time, you're only moments away from a whole raft of horrifying issues having to do with mutexes and semaphores and race conditions.

Java, Scala, C#, Elixir, Erlang, Rust, C++, and C are all languages that let you go to town with threads and shared memory.

One way to control that complexity is with immutable data structures and message passing - creating a bunch of little micro-systems that send messages to one another - they almost feel like little processes within the application itself - this is based on a technique from Erlang, although commonly it is called the Actor model - and you'll find versions of it in most of these languages.

Another way to control that complexity is just to... embrance the madness. Get deep into mutex town and hope to hell you don't make a mistake. This is a common tactic for C++ programmers, who are crazy, and Rust programmers, who have invented a compiler so complicated that if you can write programs for it, at all, they're probably safe to run.

Needless to say, unless you ARE writing a database, I don't recommend managing your own threaded concurrency and shared memory. In fact - if you're listening to me, an idiot, and learning things, you're probably not at the point in your career where you are ready to write database code yet. 

----

## Git
This deserves just one slide.

Your code... goes in git. On GitHub. If you're fussy and you want to use some other source control system, by all means - but, by default, your code goes in git. On GitHub.

-----

## Application Basics
So, now that you've chosen a language, it's time to decide on... a framework.

### Framework
Every language has a bunch of different web frameworks, each of them encompassing a single philosophy on how to build a web server. 

When I first started building web applications, I tended towards very minimal framewoks, like flask for python, because their simple operation required very little learning on my part, and I could just slam code together until something interesting happened. 

Then I started to tend towards more more maximal frameworks like Codeigniter for PHP, Django for Python, or Ruby on Rails for... Ruby - because they were very complete and opinionated and I learned a lot from how they wanted me to structure my code.

And.. now.. I'm back to preferring very minimal frameworks because now I'm very opinionated about how I want my code to go together, and I'd rather build everything, myself, from the ground up. 

So... I don't know - spend some time learning about the different philosophies behind some of the different frameworks, try some out, see what you like. 

### Routing and Request, Response
The one feature that I have never, ever seen a a web application framework leave out is routing. It feels like the minimum thing a web application framework needs to be .... is routing.

As we covered a little earlier, the role of a web server is to take HTTP requests and turn them into HTTP responses - and so, the beating heart of a lot of application code is a table that looks kinda like this:

```
* GET /          => fn home()
* GET /register  => fn register_page()
* POST /register => fn register()
* GET /login     => fn login_page()
* POST /login    => fn login()
```

Just... some kind of mapping between URL paths and the functions that are responsible for responding to requests for that path.

How these functions operate can vary wildly from environment to environment, but ultimately they are responsible for taking a request and converting it into a response.

Uh, PHP is kind of a funny special case in this sense, because, at least the way I remember it, PHPs routing is automatic - you have PHP files in a file tree and the server automatically routes requests to the file matching the query - so, if you have `GET /home/register.php` then it's going to look in your PHP folder for `/home/register.php` and execute whatever it finds there.  

As far as I know, PHP is the only "modern" language that does anything like this. It saves you the trouble of having to maintain a routing table, but at the cost of generating that routing table automatically in ways you may not approve of. 

### Local Environment Setup & Automation
Django and Rails won me over to this way of thinking, but I think it's great and it belongs everywhere: some frameworks provide a command line application with the framework that you use to run automations against your system.

So, you might type... `django run`  and it'll boot up your django application, or `django create potatoModel`  and it'll create an empty potato model for you.

I haven't written django in a really long time - probably almost a decade - but I'm still actively including little automation-focused command line applications with everything I write, because the convenience of being able to type `jake run`  and have my application set up all of its dependencies and boot itself up is huge. 

There is no space in my head for storing complicated setup arguments or scripts.  If I run my little command line app, it'll tell me all of the things it can do, and then I don't have to remember anything.  

The various `make` clones -  `make` classic, `rake`, `jake`,  and python's `invoke` - are all pretty good for this.

### Classic Websites vs. Progressively Enhanced Websites vs. Single-Page Applications

One of the earliest things you're going to need to decide about your application is whether it's going to operate as a classic web application or a Single-Page Application.

#### Website: Classic
The way that websites used to work, long ago, was that each individual page request would result in your getting a different HTML page. If you hit `/subscribers/jeremy`, the system would go find a subscriber named Jeremy in its database, build a HTML page for you, and return that HTML page. If you wanted to post a comment on `/blog/comments`, that page would have a HTML Form element on it, and that HTML Form element, after you filled it out, would trigger a HTTP POST request, followed by a full page reload. In fact, every single interaction would involve a full page reload.

This way of doing things often felt a little sluggish - think Craigslist, or PHPBB - and it is a terrible choice for a website with a lot of interaction - buut - it's a really powerful technique for websites that don't have a lot of complex interactions. If all your application needs to do is pull database records and display them neatly, this is the way to go.

#### Progressive Enhancement
Of course, you could take a classic website and include snippets of JavaScript functionality to liven things up, add basic application features, build buttons and menus that perform more interactive functionality. If you do this, while still keeping the site largely working like a Classic Website, you're engaged in Progressive Enhancement - you've got a classic website with some UI features, but everything still works like a regular website.  Old reddit worked this way, I _personally_ liked it better than the new reddit.

#### Single-Page Applications
Nowadays the most popular way to build complicated websites is to skip the "website" part entirely: when you go to any url under modern reddit.com, for example, the site doesn't engage in routing the way that we described it earlier, at all. Instead, reddit routes everything to the same result: the entire JavaScript source code for a complete application. 

This divides your web program into two programs: the Javascript client, which runs on your users' computer, in their browser, and your server, which provides the "Application Programming Interface", or API. 

The client application boots up and starts running immediately, then, it uses its own internal routing rules to determine what to display to you based on the URL that it can see. If that requires information from the servers, (it will), it'll get that information by performing remote procedure calls against API urls on the reddit servers. These calls will still communicate using HTTP, but they won't send HTML - instead, they'll communicate using a object serialization protocol like JSON.

#### It Doesn't Have to be JSON But It's Always JSON
There are literally no rules about what language the JavaScript application you've loaded needs to use to communicate with the backend server. It could send binary data, or plaintext, or XML - but in practice, the "Javascript Object Notation" is the de-facto standard for all non-HTML web communication. 

It became popular because it is just a subset of JavaScript, which means that JavaScript can parse it essentially for free - which means you don't have to send the user's computer a whole bunch of code for deserializing data. 

### Templating
Many web application frameworks include a templating system, which is a system for rendering arbitrary data into HTML. 

You'll note that in the "Single Page Application" style of web development, there's not actually too much need to engage with templates on the server side - all your server will be doing is sending the user an application, and then communicating with that application back and forth using Remote Procedure Calls - so... any HTML befingerpoking is gonna be happening inside the JavaScript application, not from your server code. 

Modern frameworks... don't bother themselves with templating nearly to the extend that older frameworks did. 

### Remote Procedure Calls (RPC) 
On the other hand, modern frameworks do a LOT of remote procedure calls over HTTP.

There are potentially countless different ways to do RPC over HTTP - more schemes than you can shake a stick at - but practically the most popular method is REST.

Let's talk about a few schemes: 

#### XML-RPC and SOAP
These were early standards for doing RPC calls over HTTP. They used a lot of XML rather than JSON, and tended to be very popular with Java programmers, which made them very unpopular with everyone else. We ... don't talk about them. 

#### REST (FIOH)
REST stands for "Representational State Transfer", and if you spend any time looking into the philosophies of Representational State Transfer you will be overwhelmed with a sudden desire to throw yourself into traffic. The ideas of Representational State Transfer don't actually map to API design, at all, really. REST is a philosophy about how hypermedia should work, so, if you're designing a new HTML, you should read about REST - but you're not designing a new HTML, because we already have HTML. Which is doing fine.

The name REST is all wrong if you're using it to describe doing RPC over HTTP, it should have been called FIOH. 

**"Fuck it, Overload HTTP".**

I've stolen this term from a [very good blog post](https://twobithistory.org/2020/06/28/rest.html) . 

The way that Fuck it, Overload HTTP works, is that you just map all of your HTTP paths to different things your system can do.

So, if you POST some JSON to `/register` with your email and password in it, it could create a user account. A POST to `/login` might log you in, and a GET from `/employees/12834` might retrieve the employee data from employee #12834. 

With a little bit of skill and thought you can map your entire application's programming model to HTTP calls against specific URLs. Lots of programs are written this way.

And remember those esoteric HTTP verbs from before, like DELETE and PUT and HEAD and PATCH? You can use those here, too, if you want. Or don't. It's totally up to you!

#### GraphQL 
One thing you will quickly discover writing apps in the FIOH style is that writing expressive queries in HTTP urls is really hard - and, for security reasons, you're not allowed to just pass structured query language directly through your web server into your database. 

So, some folks at Facebook built GraphQL, which is a whole query language that you can offer over HTTP, as part of your API.  If a lot of your API is devoted to queries, GraphQL can probably replace a lot of it with a query language.

I don't really have a lot of thoughts about GraphQL. If you need to write an API that's capable of processing really complicated queries, maybe it's the right tool for you!

#### Just Use FIOH
At least, for now, the dominant way to do things is REST - or, FIOH, if you'd prefer.

### Structure
Okay, jumping back to your web framework - one of the things that many web frameworks provide is a recommended structure for your codebase. 

### Middleware


## Config
### Environment Variables
### Database Config

## Database
### Disk
#### SQL
#### Consistency (ACID)
#### Distribution
#### Schema
* Schema Evolutions
### Binaries
### RAM
### Queues
### Task-Specific Databases 
* Streams
* Time-Series
* Search

## Authentication
### Passwords
### Email
### CAPTCHA
### Two-Factor
### Account & Password Recovery
### OAuth and Third Party Login


## Scheduling & Background Tasks

## Rate Limiting

## Logging

## Graphs & Charts

# Act II: Prod

## DNS

## Dev and Prod

## Automated Testing

## Separate Build and Deploy Steps

## Continuous Integration

## Seamless Operations

## Infrastructure as Code

## Redundancy and Single Points of Failure

## Backups

## Clouds & Control Planes

## Secrets Management

## Content Delivery Networks 

## Distributed Denial of Service


# Act III: Forever

## Alerting

## Admin 

## ChatOps

## Post Mortems

## Scaling

## Cost Control

## Security
* Principle of Least Access
* Zero-Trust

