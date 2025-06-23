# Chapter 13: Continuous Integration

## Dev and Prod
A common way to develop software is to have two deployment environments - a production environment, which is the actual live product, and a development environment, which is considered to be "prod-like, but smaller"

Dev is intended to be a more malleable test environment for faster iteration on new features - it can also a good environment to manually QA new features before they ship.

As I get older I'm becoming less and less convinced about the utility of a dev environment - when a lot of what it accomplishes could be buried behind feature flags or client UI branches in prod, instead, but ours keeps getting used for one thing or another, so, I guess it's still a useful thing to have.

## Separate Build and Deploy Steps
Every time the code is updated, a new master build candidate should be built for production, and the entire test suite should be run to make sure that everything is still working as intended.

Tools for this are varied and manifold - from the venerable and somewhat crusty Jenkins to the newly released Github Actions, there are loads of ways to do this.

Once the build is complete, if that build was for your master branch, the result should also be pretty much immediately deployed.

Leaving un-deployed code in master is a great way to set yourself up, down the road, for a deploy that fails badly with, like, five or six complicated new features in it. You won't know which of those five or six complicated new features caused prod issues, and you don't want to redeploy to try to find out. If you just keep deploying every time you put anything in master, you'll always know that: if something starts to throw alarm bells in production, it was definitely the last thing that you changed, because that was the only thing that you changed.

I, for one, like to have a separate build and deploy - even if every build against master should be immediately deployed, I like it when there's a concrete deploy _moment_ where you decide that it's time for master to go to production and Press The Deploy Button - and it can be useful to be able to deploy any build artifact to prod - even builds from the past or branch builds. That's _controversial_, though, a lot of people believe that every push to prod should just immediately build and then automatically and immediately deploy, and I think those people are _also probably right_.

### Containers
The most stupendously common way to deliver your web application in a tidy little self-contained package - at least, at the time of writing - is to have your build artifact be a fully constructed container. This is an executable virtual operating system that runs not just your application but also all of its dependencies.

A container is like a virtual machine image.

And- like virtual machine images - containers are completely independent operating system environments. However, virtual machines are run - like any other software - on top of the base operating system - which carries a performance penalty, even if it's increasingly small as virtualization technology gets better and better. Powerful virtualization technology is what allows us to have those VPS based server solutions I mentioned earlier.

Containers are different - they are based on a linux technology that allows them to sort of temporarily switch places with the host operating system, running their container operating system fully separate from the base operating system. The performance compared to virtual machines is superior, _but_ this technology only really operates within the linux ecosystem; running containers on Windows has to start with running a virtual linux, or it won't work.

The benefits of shipping build artifacts as containers is that they're very easy to run: any environment that can run containers will be able to run your container, and it will run exactly the same way there as on your computer. There's no dependency management: all of your dependencies are also shipped within the container. The operating systems you're running are usually stripped down to the barest essentials, so there's not a lot of surface for attackers - and even if they're successful at breaking in to your application, they're trapped in container jail, with extremely limited access to the outer operating system.

The problem with shipping build artifacts as containers is that they're kinda too big: because a container contains the entire operating system it's intending to run on, even stripped-down, minimalistic containers generally run in the hundreds of megabytes - which means if you're doing 10 builds a day, you're generating a gigabyte a day of build artifact. That can add up, although, storage is so cheap nowadays that it's not a huge concern.
