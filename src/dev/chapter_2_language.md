# Chapter 2: Language
One of the the first questions that you'll probably come to when building a web application - any application, really - is "what language should I use"?

If you're learning everything from the ground up? The answer is probably Python or Javascript.

### Concurrency Model
The reason that your choice of language matters so much is because different languages have very different models when it comes to managing concurrency.

When it comes to web applications, concurrency is non-optional. Imagine if, for example, a web server could only deal with one person at a time. It would be slow.

Handling concurrency is also _really complicated_ - enough so that the concurrency model you choose effects every decision you make afterwards. It's a big deal.

#### Remember, You're Not Writing A Database
There's a common misconception when it comes to programming languages - the best one is the one that's fastest, right?

Well, not necessarily.

It's possible to write web applications in pretty much whatever language you like. The speed of your web application server isn't going to be your first scaling hurdle - and even PHP will cheerfully run a website for your first 10,000 users, no problem.

Static languages, dynamic languages, they're both fine. Some people like type systems, some people don't, I've definitely seen some pretty compelling evidence that they don't affect your productivity too much either way.

I'm pretty sure that most languages have fairly sane package management at this point - a good package manager where you can save a list of dependencies and automatically install it after pulling the repository - and most popular languages have libraries for just about everything you'll need.

In fact, what you should probably be doing, is writing applications in whatever language you're most comfortable writing code in - fast code is utterly worthless if you don't have any users, and the best way to get some users is with something - anything - that works.

The actual wrong decision here is choosing a language that's more complicated than you need for the task at hand, and wasting a bunch of time struggling with it.

#### Process Concurrency
"But languages like python, ruby, or PHP don't support concurrency"

Now, for those of you in the know, you know I'm sort-of lying about that - each of those languages has support for async and threads if you go spelunking in them - but let's pretend for just a moment you build a standard flask or django application in Python - that application can really, truly, only process one request at a time. It gets a request, and it has to respond to that request before it can move on to the next one. I've already said that this would be slow - but Python and PHP have been used to power some of the biggest websites on the internet.
How do they do that?

Well, your operating system has concurrency built in. When you're launching a Python program in production, you're actually launching dozens of processes, each containing an identical Python program with its own fully independent memory. Then, an external program - an http server - load balances requests to all of these internal processes. In many cases this external program will also manage the whole process lifecycle for these internal processes. This external program is almost always written by people who are very smart about writing high performance code, so you're leaning on them to do a lot of the heavy lifting for you. All of the actual concurrency is provided by your operating system's scheduler - which, thanks to the fact that the processes don't share anything, means that you barely have to think about concurrency at all.

This process-based concurrency model is the simplest, the easiest to deal with. From the point of view of the program you're writing, there is no concurrency. You just have to respond to one request at a time.

If you are just learning, I strongly, strongly recommend a language that scales with a process-based concurrency model, like Python or Ruby. They are not the absolute fastest, but, remember: You're Not Writing a Database.

#### Async (Co-Operative Multitasking)
However, process-based concurrency is heavy. Each process demands its own space in memory. Ideally, you're writing your server programs to use very little memory on their own, but it is still a concern.

On top of that, a lot of time in web programming is spent waiting on network resources. One of your processes might send a query to a database, and then just wait ... for hundreds of milliseconds. In computer time, that's an eternity. Your operating system's scheduler will check in on that process every now and then, but most of the time it's just going to be waiting for the database to get back to it.

What would be ideal, is, instead of jumping around from waiting process to waiting process, if we could find a way to get a single process to just be busy all the time. That means any time it has to wait on anything, it just remembers that it's waiting for that thing, and goes to do something else for a while.

This is asynchronous programming - a style of programming where you have to intentionally indicate within the code "oop, this bit might take a while, don't come back to this until the thing is done".

Programming like this is hard. You have to relearn a lot of your habits to switch from thinking synchronously to thinking asynchronously - writing your software around the idea that it has to consciously give up control any time it's waiting on something to execute.

This also isn't really concurrency - it all still happens on a single thread of execution - but - this technique allows you to write a single process that stays white hot. Each individual process is able to deal with hundreds of simultaneous requests, because whenever it's waiting on something for request A, it can be working on something for request B, or C, or D, or E. If you have more than one CPU - if you want TRUE concurrency - you still have to scale out using the process model - one process per CPU - but only one process per CPU, because the process itself is handling the mechanics of keeping itself busy.

This is the scheme underlying node.js, or some of python's newer frameworks.

##### No Shared Memory
The process-based concurrency model is very powerful and flexible - but - if you think about it - it really limits the amount of memory available to each of your processes. Lets say you have a computer with four CPUS, and 16GB of RAM - if you're process scaling with Ruby, and you create 16 processes to jump between, each process only has access to 1 gigabyte of working memory. If you're process scaling with node, and so you only need to create four processes - one per CPU - each process only has 4GB of memory to work with.

Now, one of the reasons this is important is because a lot of process-scaled languages are also garbage collected and very flexible. Which means - memory leaks can accumulate pretty easily in the code. Which means your program can eat all of its working memory, and then die.

Also, and this is key: where do these programs keep everything? They can't keep stuff in working memory - if they do, only one of the many processes actually running on your computer would ever be able to see it.  You send a request to log in on this process and then you send another request but you're not logged in on *this* process, nightmare.

So, for this reason - amongst others - these servers are written according to something called a "Shared Nothing Architecture" - nothing that they need lives exclusively in their own working memory - all they do is connect to external databases that actually store all of the real, important information. If you reboot one of these processes, it ... doesn't matter. Because they aren't storing anything important. This also is super important for the resilience of your systems - it doesn't matter if you reboot any of these servers, they'll just wake up and start handling requests again, as if nothing happened.

####  Threads and Shared Memory
Remember when I said "we're not writing a database?" That's just - good life advice. Don't write a database. It's really hard.

If we _were_ writing a database, we'd want both full concurrency and access to all of the shared memory the system has to offer. That's when we start to get into the realm of truly concurrent programming models - which means - threads.

And where you have threads, you have synchronization issues. It's a fact of life - any time two CPUs have access to the same part of memory at the same time, you're only moments away from a whole raft of horrifying issues having to do with mutexes and semaphores and race conditions.

Go, Java, Scala, C#, Elixir, Erlang, Rust, C++, and C are all languages that let you go to town with threads and shared memory. Many of them ALSO have access to async coding primitives. You can mix and match.

One way to control that complexity of managing access to mutable shared memory is with immutable data structures and message passing. Immutable data is an enormously powerful technique for concurrent systems, because you don't have to manage access to it - it's always safe to read - the only thing that needs to be consistent is its lifecycle - that data has to be readable as long as there are still threads that might want to read it. A very common pattern for creating stable, manageable concurrent systems is by creating a bunch of little micro-systems that send immutable messages to one another - each thread almost feeling like a little processes within the application itself - this is based on a technique from Erlang, although commonly it is called the Actor model - and you'll find versions of it in many of these languages.

Another way to control the complexity of shared mutable state is with clever data structures. Using tools like atomic operations and copy-on-write, it's possible to build data structures that are highly resistant to being used in ways that will corrupt data.

Another way to control that complexity is just to... embrace the madness. Get deep into mutex town and hope to hell you don't make a mistake. This is a common tactic for C++ programmers, who are crazy, and Rust programmers, who have invented a compiler so complicated that _if_ you can write programs for it, at all, they're probably safe to run.

Needless to say, unless you ARE writing a database, I don't necessarily recommend managing your own threaded concurrency and shared memory. In fact - if you're listening to me, an idiot, and learning things, you're probably not at the point in your career where you are ready to write database code yet.
