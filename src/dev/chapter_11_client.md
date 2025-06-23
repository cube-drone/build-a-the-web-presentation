# Chapter 11: Client

There are two sides to the website: the backend API and the frontend single-page-application.

I'm a lot less talented with frontends than I am with backends, but I know one or two useful tips:

### Bundling and Packaging
One of the biggest components of any client-side javascript stack is the bit that takes hundreds of files and libraries and compresses them all into one big wad of javascript that the user can download and execute.

If possible, try to keep this big bundle as small as possible: don't pull in a whole bunch of unnecessary libraries if you don't have to. I mean, that's good advice in general, but extra good advice if you're trying to fit your entire application into an object that you're going to be distributing to every single person who visits your website.

### Swappable Client Implementations
Because the bundle that contains all of the javascript that runs your site is just another file, it's possible to set things up such that your site is capable of loading any compiled version of your website.

At work I set it up so that any time anybody pushes a branch to github, it uploads a new version of the bundle, and then anybody with an admin flag on their account can swap at any time between any branch's most recent version of the website code, and ... I think that's been one of my better ideas in the past few years. It was a bit of extra effort, but it makes showing off in-development features within the team very easy, and testing new features in production also very easy.

### Stop Hitting Yourself
If you control your client, you can end up being your own worst enemy. Let's imagine you write a function that requests a resource from your server, and if it doesn't get that resource, just turns around and tries again.

Now, let's imagine on your server side, you introduce a small bug - the code performs a difficult, slow computation, and then just before it hands it off to the user, it does something stupid and throws a 500 instead.

Let's say you have 10000 active users - now you have 10000 clients endlessly looping a difficult, slow computation against your backend. Your logs show endpoint timings starting to slow down, your autoscaling systems start to fire, it's like you're being hit by a distributed denial of service attack. Because you are. From your own users, running the client you wrote. Great job. Stop hitting yourself.

When you're writing code that deals with errors, consider increasing the amount of time on every retry, prompting the user before retrying, or, simply showing an error to the user to let them know that something weird happened.