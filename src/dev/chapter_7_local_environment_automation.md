# Chapter 7: Local Environment Automation

Now that you've selected language for your web service to run in, and a suite of technologies for your web-service to connect to, your next step is to painstakingly and by hand install and configure all of those technologies on your computer one at a time - wup, no, that's not it.

Your actual first step is to use your local automation framework to set up and tear down your entire local environment.

Here, tools like virtual machines and docker containers are your friend.

I used to do this with invoke and Vagrant, now I do it with jake and Docker Compose. You can do it with pretty much whatever you want - so long as you can open your project on an arbitrary computer and have it set up its environment for you, you're good to go.

As a freebie, you are allowed to expect that your language and virtualization tools already exist on the target computer. Make sure to call out those local installation dependencies in your repository's README.
