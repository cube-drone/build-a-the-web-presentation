# Chapter 4: Framework

So, now that you've chosen a language, it's time to decide on... a framework.

### Framework
Every language has a bunch of different web frameworks, each of them encompassing a single philosophy on how to build a web server.

When I first started building web applications, I tended towards very minimal framewoks, like flask for python, because their simple operation required very little learning on my part, and I could just slam code together until something interesting happened.

Then I started to tend towards more more maximal frameworks like Codeigniter for PHP, Django for Python, or Ruby on Rails for... Ruby - because they were very complete and opinionated and I learned a lot from them about what components actually need to go into a full-fledged product.

And.. now.. I'm back to preferring very minimal frameworks because now I'm very opinionated about how I want my code to go together, and I'd rather build everything, myself, from the ground up.

So... I don't know - spend some time learning about the different philosophies behind some of the different frameworks, try some out, see what you like.

### Routing and Request, Response
The one feature that I have never, ever seen a a web application framework leave out is routing. It feels like, almost, the minimum thing a web application framework needs to be .... is routing.

As we covered a little earlier, the role of a web server is to take HTTP requests and turn them into HTTP responses - and so, the beating heart of a lot of application code is a table that looks kinda like this:

```
* GET /          => fn home()
* GET /register  => fn register_page()
* POST /register => fn register()
* GET /login     => fn login_page()
* POST /login    => fn login()
```
Just...  a mapping between URL paths and the functions that are responsible for responding to requests for that path.

How these functions operate can vary wildly from environment to environment, but ultimately they're responsible for taking a request and converting it into a response.

Uh, PHP is kind of a funny special case in this sense, because, at least the way I remember it, PHPs routing is automatic - you have PHP files in a file tree and the server automatically routes requests to the file matching the query - so, if you have `GET /home/register.php` then it's going to look in your PHP folder for `/home/register.php` and execute whatever it finds there.

As far as I know, PHP is the only "modern" language that does anything like this. It saves you the trouble of having to maintain a routing table, but at the cost of generating that routing table automatically in ways you may not approve of.

### Local Environment Setup & Automation
Django and Rails won me over to this way of thinking, but I think it's great and it belongs everywhere: some frameworks provide a command line application with the framework that you use to run automations against your system.

So, you might type... `django run`  and it'll boot up your django application, or `django create potatoModel`  and it'll create an empty potato model for you.

I haven't written django in a really long time - probably almost a decade - but I'm still actively including little automation-focused command line applications with everything I write, because the convenience of being able to type `jake run`  and have my application set up all of its dependencies and boot itself up is huge.

There is no space in my head for storing complicated setup arguments or scripts.  If I run my little command line app, it'll tell me all of the things it can do, and then I don't have to remember anything.

The various `make` clones -  `make` classic, `rake`, `jake`,  and python's `invoke` - are all pretty good for this.

### Classic Websites vs. Single-Page Applications

One of the earliest things you're going to need to decide about your application is whether it's going to operate as a classic web application or a Single-Page Application.

#### Website: Classic
The way that websites used to work, long ago, was that each individual page request would result in your getting a different HTML page. If you hit `/subscribers/jeremy`, the system would go find a subscriber named Jeremy in its database, build a HTML page for you, and return that HTML page. If you wanted to post a comment on `/blog/comments`, that page would have a HTML Form element on it, and that HTML Form element, after you filled it out, would trigger a HTTP POST request, followed by a full page load of whatever HTML came back from that POST request. In fact, every single interaction would involve a full page reload.

This way of doing things often felt a little sluggish - think Craigslist, or PHPBB - and it is a terrible choice for a website with a lot of interaction - buut - it's a really powerful technique for websites that don't have a lot of complex interactions. If all your application needs to do is pull database records and display them neatly, this is easily the best way to go.

The simple nature of websites that are just websites also plays particularly well with search engines, which find this kind of content the easiest to index.

#### Progressive Enhancement
Of course, you could take a classic website and include snippets of JavaScript functionality to liven things up, add basic application features, and build buttons and menus that perform more interactive functionality. If you do this, while still keeping the site largely working like a Classic Website, you're engaged in Progressive Enhancement - you've got a classic website with some UI features, but everything still works like a regular website.  Old reddit worked this way, I _personally_ liked it better than the new reddit.

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

Modern frameworks... don't bother themselves with templating nearly to the extent that older frameworks did.

### Remote Procedure Calls (RPC)
On the other hand, modern frameworks do a LOT of remote procedure calls over HTTP.

There are potentially countless different ways to do RPC over HTTP - more schemes than you can shake a stick at - but practically the most popular method is REST.

Let's talk about a few schemes:

#### XML-RPC and SOAP
These were early standards for doing RPC calls over HTTP. They used a lot of XML rather than JSON, and tended to be very popular with Java programmers, which made them very unpopular with everyone else. We ... don't talk about them much anymore.

#### REST (FIOH)
REST stands for "Representational State Transfer", and if you spend any time looking into the philosophies of Representational State Transfer you will be overwhelmed with a sudden desire to throw yourself into traffic. The ideas of Representational State Transfer don't actually map to API design, at all, really. REST is a philosophy about how hypermedia should work, so, if you're designing a new HTML, you should read about REST - but you're not designing a new HTML, because we already have HTML. Which is doing fine.

The name REST is all wrong if you're using it to describe doing RPC over HTTP, it should have been called FIOH.

**"Fuck it, Overload HTTP".**

I've stolen this term from a [very good blog post](https://twobithistory.org/2020/06/28/rest.html).

The way that Fuck it, Overload HTTP works, is that you just map all of your HTTP paths to different things your system can do.

So, if you POST some JSON to `/register` with your email and password in it, it could create a user account. A POST to `/login` might log you in, and a GET from `/employees/12834` might retrieve the employee data from employee #12834.

With a little bit of skill and thought you can map your entire application's programming model to HTTP calls against specific URLs. Lots of programs are written this way.

And remember those esoteric HTTP verbs from before, like DELETE and PUT and HEAD and PATCH? You can use those here, too, if you want. Or don't. It's totally up to you!

#### GraphQL
One thing you will quickly discover writing apps in the FIOH style is that writing expressive queries in HTTP urls is really hard - and, for security reasons, you're not allowed to just pass structured query language directly through your web server into your database.

So, some folks at Facebook built GraphQL, which is a whole query language that you can offer over HTTP, as part of your API.  If a lot of your API is devoted to queries, GraphQL can probably replace a lot of it with a query language.

I don't really have a lot of thoughts about GraphQL. If you need to write an API that's capable of processing really complicated queries, maybe it's the right tool for you!

#### WebSockets
This is something that Single Page Applications can do that classic websites definitely can't: they can open a WebSocket against the backend server.

Unlike HTTP request/response, where every interaction with the server is going to involve a request and response, a WebSocket is a full bidirectional communication pathway between the client and server - the connection stays open, and either side of the transaction can send messages whenever they want.

This is most useful when programming real time systems - chat clients, for example. Building a chat client using request response would require that your client application regularly poll the server - do you have any new information for me yet? What about now? What about now? Using a websocket, the server can wait, and push messages to the client when it actually has something to send.

There are drawbacks to this, though - maintaining a WebSocket connection on the server side is much more heavyweight than just responding to simple http requests.

On top of that, remember our shared-nothing process scaling model? This significantly complicates that, because our websocket connection represents a permanent connection to a server. The socket needs to stay connected to the same process each time it connects to your backend, and that process needs to be able to simultaneously manage connections to hundreds of different clients.

This is really hard without services that can manage some concurrency - you know, these guys (node, elixir, rust, C++, etc). So, socket-heavy architectures tend towards more consolidation and more concurrency - larger servers, using threads and shared memory - which is why backends in Elixir or Rust are often popular for real-time systems.

#### WebRTC
Another way for Single Page Applications to communicate is with WebRTC - or Web Real-Time-Communication, a protocol that allows clients to communicate amongst themselves in a peer-2-peer fashion, useful for exchanging high speed audio and video data.

We're not talking about p2p today. Like I said before, that's out of the scope of this presentation.

#### Just Use FIOH
At least, for now, the dominant way to do things is REST - or, FIOH, if you'd prefer.

### MVC
Okay, jumping back to our web framework - one of the things that many web frameworks provide is a recommended structure for your codebase.

Django and Rails, for example, are built around Model-View-Controller architectures, where your code is divided into
* Models, responsible for mapping database tables to application objects
* Views, responsible for mapping application objects to HTML using templates, and
* Controllers, which are the parts that actually handle the request/response, and tie Models and Views together to build the application's functionality

### Pipelines and Middleware

Rust's warp and Node's express are built around more of a Pipeline model - a request is passed in and then the request and response are successively modified in stages until the response is ready to give back to the user.

A very common concept in web frameworks is the idea of "middleware" - once you build a pipeline stage that does something like "rate limiting" or "checking authentication", it's easy to roll it out across dozens of different endpoints.
