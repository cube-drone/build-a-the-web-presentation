# Full Stack: How to Build a Social Network

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
When I started with web programming I had just come off of a lot of Windows-driven application and even video game development and I was surprised - because a lot of Windows development is really heavily graphical user interface driven. 

I came in expecting tools like Visual Studio to handle all of the work of building web applications, with lots of buttons and toggles and bits - but no. Web application development is deeply, fundamentally tied to our old friend, the command line.

20 years ago I thought this was some real regressive DOS-grade bullshit. The last time I'd used DOS was like 1996, and I wasn't intending to go back in time to develop software - but - like so many things 

## Language
### Concurrency Model & Shared Memory
#### Shared Nothing & Horizontal Scaling
#### Process
#### Async (Co-Operative Multitasking)
#### Threads
#### Actors
### Type System & Compilation
### Package Management
### Git 

## Application Basics
### Framework
### Local Environment Setup & Automation
### Routing
### Websites vs. Single-Page Applications
### Templating
### RPC 
#### REST (FIOH)
### Structure
### Serialization
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

