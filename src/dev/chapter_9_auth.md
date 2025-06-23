# Chapter 9: Authentication

Now you've got your services all set up, you're booting up a web server, and you're connecting to them! Now what?

Well, now you have to write the same awful thing that constitues 90% of all web programming forever: authentication. That's what we do here, we tirelessly reinvent wheels, and this is a wheel you'll have to reinvent, too.

People are going to need to register to use your site, login, log out, recover their accounts, all of the basics.

### Passwords
So, a user creates an account by giving you a username and password.

Well, we already have a problem, just up front, we can't store a password in our database. What if someone gets access to our database? What if _we_ get access to our database? Aside from credit card numbers, passwords are some of the most sensitive user data we can get access to, so we have to be unusually careful with them. (As for credit card numbers: just don't store those - if you think you're in a position where you need to, you probably don't. )

There is an interesting property of hash functions that we take advantage of to store passwords without actually storing those passwords.

Let's imagine that we have a hash function, splorthash - when we get the user's password, we run splorthash on the password and then, we save the result of the hash function, not the password itself. Hash functions are irreversible - so the password hash can't be used to get the password - but, when the user logs in again, we can hash the password that they provide, and if the hashed output is the same as the hash that we have stored, we are good to go - the password must be the same.  So, since the 70's, every halfway reasonable system containing passwords has stored the passwords as hashes, rather than as the passwords themselves.

#### Reversing the Irreversible
Did I say that hash functions were irreversible? That's only partially true.  If I have the result of a hash function, I can simply try every possible password, until I get the hash that matches. If I've walked away with your entire database, I can start by hashing `aaaaaaaa`, testing if that matches any password hashes in the entire database, and then `aaaaaaab`, and so on and so forth, until I have cracked all of the passwords in the entire database. This ability to mass-guess passwords is tied to both my ability to test against the entire database at the same time, as well as my ability to run hash functions very, very quickly.

This means that we, as responsible siteowners, must guard against this scenario as best as we can, with two techniques.

First of all, the hash function that we use to test passwords should be slow-running. Modern GPUs can compute millions of hashes per second. It doesn't help at all that cryptocurrency also leans on hash computation and so a lot of people are very carefully optizing hash rates. The current top-of-the-line GPU can perform 133 million SHA-256 hashes per second. That's a lot of password tests. That GPU could try out every common name and last name and dictionary word, combined with every single year for the last 100 years, combined with all of the obvious character-to-number translations. It could test out all of these things in less than a second - so if your password happens to be `passw0rd1`, or `d0lph1n1998` that is not going to hold up.

We can slow down that process by selecting a hash that is computationally difficult to compute - and, it's important to know that there is a difference between cryptographically secure hashes - like SHA-256 - which are intended for use in cryptography but very fast and thus a bad choice for passwords - and cryptographically secure hashes intentionlly designed to be slow, like bcrypt, which are _intended to be used for passwords_.

We can also slow that process down by using a completely different hash function for every user in the table. This sounds incredibly labor intensive, _but_, all it takes to make a new hash function out of an existing hash function is to add some garbage data.

So, `bcrypt(password+garbage)` and `bcrypt(password+differentgarbage)` are two totally different hash functions that will produce different outputs. This extra block of garbage is called the "salt", it's randomly generated when you save the password the first time, and it's generally stored along with the hashed password.

With these techniques in place, you (and anyone with access to your database) should be unable to reverse engineer your users' passwords.

Unless they are using `passw0rd1`. Someone's gonna guess that.

Ultimately, with enough time, even these methods can't protect weak passwords from being cracked - just as personal advice, I'd recommend using a different long, complicated, generated password for every single service that you interact with, and you keep all of those passwords in a encrypted password manager so that you don't have to remember them all, and the encryption key for your password manager should be a good long complicated passphrase that you can still remember easily - like a favorite entire line of dialogue from a movie that you enjoy, smashed into a different entire line of dialogue, to make a much weirder line of dialogue.

#### Credential Stuffing
Some of your users are going to use the same email and password on every server they visit for their entire lives. This isn't out of stupidity, it's usually just out of laziness - they probably have a better password for their banking or personal email, but your website is just some stupid place where they download horse gifs. Why waste a good password remembering on that?

These people are dangerous. They come pre-hacked. Sure, you know how to do basic security, but do you trust that every single website this person has ever been to does basic security?

So, what attackers will do, is download huge torrent files containing mega lists of username and password combinations that have been breached. Then, they'll try all of these passwords, one at a time, against your login page. This gives them access to two things:

* huge numbers of accounts on your service, which you definitely do want them to have access to
* intel: this user is still using this compromised email and password combination. This means it's a good email and password combination to try elsewhere.

One thing you can do to fight this is automatically test a users' email and password hash against HaveIBeenPwned, a gigantic repository of hacked passwords. You can, of course, do this without revealing your users' email and password - it's a hash based solution, one that reveals nothing about your users to the service - but if a user's email-and-password combination is a hit in the database, you can ask them to try again, or apply additional security measures to their account.

Another thing you can do to fight this is to rate limit login attempts. That's only so effective - users who are mounting cred stuffing attacks are usually doing it from a whole network of IP addresses rather than just one - but it does help.

It's also useful to attempt to detect a lot of logins from the same IP address - if hundreds or thousands of people all log in from the same place, either someone is trying to run a botnet, or they're trying to run a large real-life event. Of course, if it's that second thing, your overzealously configured security mechanisms could ruin their day.

### Passwords Over The Wire
Wait, users are sending us their passwords? Can't someone just snoop on their web traffic and steal those passwords out of the open, plaintext HTTP protocol?

Well, yes, they could - if we were using HTTP. But what we're actually using is HTTPS, which is an encrypted protocol. Upgrading your HTTP to HTTPS is easy and cheap-to-free using tools like LetsEncrypt, so you should definitely do that.

A lot of early writing on the topic of HTTP authentication security was written before HTTPS was as popular and common as it is now: many protocols like digest authentication or OAuth 1.0 don't make as much sense if you're already communicating on an encrypted channel: it's safe for your users to send you their username and password over HTTPS.

### Sessions
Once your user has logged in once - well, you can't log them in, again, on _every single web request_.  That would be painfully inconvenient or insecure for them - either they'd have to enter their password hundreds of times or save it in their client, and both of these options would be bad.

So, once a user logs in we create a little block of data for them, a key, and every time they give us that key we'll check it and we'll know it's still them. This key is called a "session".

There are two primary ways that session information is stored:

#### On The Server Side
So, you give the user a long, unique token - and you write a temporary database record (this is a good use for Redis) connecting that token to a blob of data containing the user's ID, as well as any information about that user that you want to keep handy across all of that user's interactions with your system.

The user stores that token in a cookie.

Then, every time the user performs any request, they include the cookie, which contains the token, which you use to look up that blob of data identifying the user.

Poof, authentication!

#### With The User, As a JWT

Why not just let the user keep track of their user Id, display name, email, all of that stuff?

Well, because the users will lie. Users can't be trusted to accurately self-report their own user id. They'll pretend to be someone else!

We can fix this, though - by giving the users an object containing their own personal data, and then cryptographically signing it using a private key that only we have access to, we can render that data tamper-proof.  Whenever they pass us back the data and signature, we can check that the signature still matches the data that's been provided, and trust that the data hasn't been modified.

If you're not familiar with cryptographic signing, you can think of it an awful lot like... a regular hash function, with a private key as the random garbage data. If anything changes about the input, the hash output will change and the signature will become invalid - so users can't change the input. Users also can't regenerate the signature, because they don't know the private key, so they can't generate a hash that will match up with the server's hash.

This has upsides and downsides compared with simply storing sessions on the server side.

Using a JWT to store user sessions doesn't require any storage at all, and the data can be verified without a database lookup - but, every single request comes with all of the added overhead of the JWT object. If you're only storing a few small details about the user within every session this is pretty slick, but very large JWT objects will start to weigh down every request.

The other thing that needs to be managed with JWT authentication is _revocation_. There are events in the system that can cause a user's token to become invalid - maybe they've signed out, or maybe there's been a security breach and all of their tokens need to be cancelled. In these cases, the server needs to keep track of some state - the list of _seemingly valid tokens_ that exist in the wild but have been revoked - so, even with JWTs, a database check is still necessary.

That being said, using JWTs as a portable token that can carry state from service to service is pretty cool.

### Email & Password Recovery
The primary reason that we ask users for an email address, rather than just a username, is twofold:

* Email addresses make account recovery possible.
* Creating and verifying an email address takes a teeny tiny little bit of effort, which isn't much, but can slightly discourage people from creating loads and load of accounts.

You simply cannot operate a modern, authenticated web-service without accepting that users will forget their passwords. All the time. The "Forgot my password" flow is simple enough: users provide their email address, and you send to that email address a recovery link that can be used to change their password.  If they're malicious - if they don't control the email address - they won't be able to change the password.

This process is seemingly unavoidable, and yet, unfortunate. We would prefer not to have to validate and store the user's email address. For one thing: it's a process that is fraught with danger - it's really easy for email to disappear in the pipes, and, in doing so, lose you a user.

Validation is non-optional. If you don't validate email addresses, and users give you fake ones, you'll send a lot of email to the wrong place - and that's a good way to ruin your e-mail sending reputation and end up unable to send any email at all.

Rate limiting and caution are important here, for two reasons: first of all, you don't want malicious users to be able to spam legitimate users with password change requests, and second - any time a user can send email on behalf of your system, like, when trying to register fake accounts - they put you at risk of getting blackholed by spam traps.

You basically have to send email through a email backing service like SES or Mailgun at this point: while _technically_ email is an open protocol, practically, the barriers that have been erected in the industry to keep spam out are also significant technical roadblocks for all but the most dedicated of small system administators. If you can put up a mailing server on your own that can reliably get through to Hotmail and Gmail, well, I salute you. (note: fusl, I know **you** can)

### CAPTCHA
Of course, and inevitably, users will try to create thousands of accounts against your system. Maybe it'll be to post comments, try to evade bans, there are lots of reasons why it might benefit them to have hundreds of hand-made accounts.

Account creation, like many other parts of your system, should be rate limited - we're going to talk a little more about rate limiting later on, but here in authentication is one of its most important uses, because so many things about authentication need to be tightly locked down.

But also: when users interact with your system, they may need to prove that they're real humans, and not bots. One way to at least attempt this is with a CAPTCHA, a portable turing test that can be performed by your system.

You know, the things you encounter all the time on the internet where they make you pick out the pictures that have bicycles in them, or try to read squiggly words.

CAPTCHAs are ultimately kind of a losing game: AI is getting smarter faster than CAPTCHAs are getting harder, and it's starting to reach the point where AIs can outperform humans at almost any task that we can evaluate automatically. On top of that, services exist that allow users to simply pay a farm of humans to resolve CAPTCHAs on behalf of their bots.

With all of those things being said, it is _still_ really important to guard account creation with a CAPTCHA. It *is* an important line of defense against bots.

You'll need lots of different lines of defense against bots. They are pernicious and constant.

### Location-Aware Security
Your users will almost always log in from the same country - the same ISP.

You can purchase access to services that will allow you to map your users' IP address to location data. The granularity is low, but the information is useful.

In fact, if you're operating a relatively secure service - it can make sense to ask the user to perform a re-verification step against their email every time that they log in from an location that doesn't match their location history.

Because password recovery can always be performed from a users' email address, it makes sense to pin other security features to that same email address - if their email address is compromised, their whole account is going to be ruined anyways, so it makes some sense to think of it as the final authority when it comes to user verification.

### Two-Factor Authentication
I'm going to say it: I don't like two-factor authentication very much. It's very brittle.

In two-factor authentication schemes, you tie a user's ability to log in to both their password and a device that they're carrying. You can do this either by sending them a special login code via text message using a text message carrier like Twilio, or, by setting them up with a key generating shared secret, using a tool like Google Authenticator.

With this set up, a user's account security can't be breached with just their password: they also need a code that only their phone can generate.

The problem? Well, first of all, only a tiny fraction of your users will ever bother to engage with two-factor. It is too fussy for most people.

The other problem? Users lose their phones constantly, and need to reset their two-factor authentication. Which they do with their email address. Which makes Two-Factor Authentication inconvenient while also providing little more protection than Location-Aware Security. This **can** be resolved by forbidding users from resetting their two-factor authentication, but... in my experience, this ends in dramatically higher support load, because users ... _will_ lose their phones, and their recovery keys. Actually maintaining the viability of two-factor security with draconian methods _just costs you users_.

With that being said, for high value accounts, two-factor authentication is a good idea.

### Anonymous Access
All of this is describing how to know who is using your systems - however, it's also really useful to give users the ability to use your systems somewhat without having to go through your whole user account creation rigamarole. For one thing, actually creating an account in any modern web-service is a real barrier for most people: show them a registration form and they'll just bail.

If at all possible, make some of your system available to users who haven't logged in - or, implicitly log users in with an ephemeral throwaway account that can be upgraded to a full account.

Anonymous access helps to sell your product to people who haven't committed yet. It might be one of the most important features that I see left out of most products.

### OAuth and Third Party Login
Another road to getting users logged in quickly to your application is to piggyback off of the authentication systems of other large providers. This uses a protocol called OAuth 2.0, and - while OAuth2 is a bit of a bear to actually implement by hand, it's not too hard, and authentication libraries often provide plugins that automatically integrate with a handful of external auth providers - so you might be able to include this functionality in your application essentially _from a kit_.

Having a "log in with Google" or "log in with Twitter", or even "log in with Github" button in your login window - if users already have accounts on those services - is a much lower barrier to entry to your application then asking users to create yet another password for yet another service.

### Per-User Flags
This is just a lil' tip, but include an array row with your user table for per-user tags.

They're good for all kinds of things. Per-user feature flags. Permissions. You'd be surprised at the utility of a list of arbitrary strings.