# Chapter 1: HTTP

## Client & Server: The Absolute Most Basic of Basics

The first thing to talk about is what a web application looks like.

* You have a browser.
* You type in `cube-drone.com/hats`.
* The browser automatically adds `http://` to the front of that
* It uses DNS, the Domain Name System, to resolve `cube-drone.com` to an IP address.
* It uses HTTP, the Hypertext Transfer Protocol to connect to port 80 on the IP address it got for  `cube-drone.com` requesting `GET /hats`.
* The server responds: with a 300 redirection, telling it that actually it should go look at `https://cube-drone.com/hats`, because we use encryption in this house young man.
* The browser tries again, with that new url.
* This time trying port `443`, the port for encrypted HTTP traffic.
* There's some web application server code on the other end of that connection. It gets the request for `GET /hats` and responds with a 200 OK and a page of HTML.
* The browser gets that page of HTML and renders it in glorious beautiful HTML style.
* Inside that HTML is a whole mess of JavaScript.
* That JavaScript executes code to take over the browser window, building and constructing a whole little application inside the browser.
* That in-browser application does a bunch of interesting stuff, up to and including sending remote procedure calls back to the `https://cube-drone.com`  server to perform commands and ask for more information.
* That's a web application!

So building web applications is largely about programming the parts that are happening on the server over here.

### HTTP

HTTP, the Hypertext Transfer Protocol, is all just a bunch of fancy stuff that sits on top of regular ol' TCP/IP.

#### What's In a URL

_put a diagram here, dummy_

* Protocol (http, or https - this doesn't have to be http - a url can identify a resource that you connect to with all sorts of different protocols - redis, or postgres, or gopher, or... whatever)
* Hostname (and port, if necessary)
* Path & Query

This divides pretty nicely into "the server we plan to connect to", "the language we intend to speak to it", and "the thing we want that server to get for us"

#### GET & POST and some more esoteric codes
There are two primary kinds of message you'll send to the server - GETs and POSTs. When you GET a path, you're saying to the server- whatever is there, go get it for me. When you POST to a path, you're saying - here, server, I have something, take it and put it at the path I gave you.

For example, imagine a theoretical comments section - you might GET `/blog/1234/comments` , which the server would respond to with all of the comments for a specific blog entry - and then you might send a POST to `/blogpost/1234/comments` containing some structured data that it would then add as a comment.

GET and POST are the important ones - GETs are for getting data, POSTS are for changing data, and that's all you really need to know. There are some more esoteric ones, like DELETE, and PUT, and HEAD, and PATCH, but you mostly don't need to use them. We will talk a little bit more about those later.

#### Headers
Your GET or POST request don't travel alone - they can also bring a bunch of metadata with them. This metadata comes in key/value pairs called "Headers".

Here are some of the HTTP headers that are included with a request to a website.

Here are some of the Headers that are sent back from the server in our HTTP response.

#### Cookies
Cookies are also a kind of header - they're a bit of extra data that you can include with a request to a website.

The server can also, when it responds to you, ask you to hold on to a little bit of extra data along with your request, with an expiry date - so, for example, when I hit cube-drone.com, it might respond, saying

"hey, for the next week, every time you send me a request, could you also send me this fourteen digit number?"

That turns out to be wildly useful for authentication, which we'll talk more about soon!

#### Status Codes
Every HTTP response comes with not just text, but also a three digit number indicating how well the request went.

200 is the number that means "everything went okay". Numbers in the 300 range mean "your data is somewhere else", Numbers in the 400 range mean "you screwed up somehow", and numbers in the 500 range mean that the server that you've connected to has managed to light itself on fire somehow.

So, for example, 301 - that's "moved permanently" - whatever you expected to find at this path, it actually lives somewhere else, and the response will tell you where to look. Your browser will helpfully follow this trail automatically.

That also means, you can set a 301 pointing to another 301, pointing back to the original 301, in hopes that your user's browser will follow that chain forever, trapping your end user in a hell from which there is no escape - but most unfortunately, most modern browsers won't fall for that and will stop following redirects after a while and simply give up.

404 - that's "not found" - it means you screwed up, because you asked for something that just isn't there.

500, that's an "internal server error" - most servers are configured to spit out a 500 if something inside them breaks unexpectedly. It's almost always a sign that not only has something gone wrong, it's someone else's fault. Some programmer, somewhere.

### Other Kinds of Software We Won't Be Talking About
So, this book is about client-server web applications, in specific.

Here are some things we won't be talking about:

#### Single User Applications or Video Games
These are just... programs that you give to people. There's no client, there's no server, you give them a program and they run it.

#### P2P
More and more of the internet is running off of peer-to-peer protocols - bittorrent, Tor, IPFS, Dat, and the very stupid world of blockchain are all capable of running entirely without a server - applications built using these protocols are incredibly powerful and increasing in popularity - but the model for developing them is significantly more complicated than the one for traditional client-server architectures.

#### Play by Mail
It's possible to run the entire client/server communications network over mail, or - if you prefer- carrier pigeon. If you use a carrier pigeon to send me some mail with a HTTP request on it, I could easily respond with some more mail containing a HTTP response - however, this system is almost untenably slow and poop-laden, so we're going to leave it out for the sake of time.

#### Serverless
This one is worth a little bit more thought. So - various cloud products - Amazon, Google, Azure - they'll offer you whole programming interfaces abstracting away just about everything about web programming. Essentially - they'll write almost everything for you, and you just provide the application logic. Then, you give them the code and they run it in the cloud, they handle the scaling, and they charge you micropennies every time someone hits one of your endpoints.

If you connect this to one of their databases that also scales up automatically for you, your whole application can just exist "on demand", and for prices that are at least competitive with what you'd pay to host your application on a traditional server infrastructure.

I'm not going to go into detail on my thoughts on serverless - it's pretty cool - but what we are going to talk about here are all of the components and practices that Amazon or Google would be replacing for you. If you do end up embracing serverless, it'll help you to know most of this stuff, at least at a high level, anyways.

### OS (Linux, Dummy)
So, in order to do the client/server thing, we need a server, then!

What's running on that server?

Well, Linux. Something like 900% of all of the servers in the world are running some variety of Linux. It's free, it's powerful, it's stable, it's lightweight.

### The Command Line
When I started with web programming in the mid oughts', I had just come off of a lot of Windows-driven application and even video game development and I was surprised - because a lot of Windows development is really heavily graphical user interface driven.

I came in expecting tools like Visual Studio to handle all of the work of building web applications, with lots of buttons and toggles and bits - but no. Web application development is deeply, fundamentally tied to our old friend, the command line.

I thought this was some real regressive DOS-grade bullshit. But I learned. There a lot of reasons that the command line is the programmer's computer interface of choice - not so clumsy or random as graphical user interface, an elegant weapon, for a more civilized age.

* Writing command line programs is way easier than writing GUI programs
* Composing command line programs together is way easier than sharing data between GUI programs
* Learning command line programs, especially when you're used to them, is lightning quick