Identity and Authentication
===========================

Users can be identified in any number of ways and carry with them
attributes that determine the entirety of "who they are". Typical needs
include identifying a person by username or email address, and building a
profile of attributes such as geographical region (as determined by IP address),
or University status (student, staff, etc.). The identifiers and attributes are
intrinsic to the user and do not, by themselves, grant any permissions within
an application. Likewise, these attributes cannot be granted within an
application, only inspected.

Authentication Terms
--------------------

There are many overlapping concepts and terms regarding identity, privacy,
security, and technology. These definitions give building blocks for the
discrete combination scenarios that require (or support) different business
rules.

* **Principal** -- TODO: explain what this is

There are three dimensions to consider. A user may
have only one status in a given dimension:

* **Identification** -- Anonymous, Unnamed, Named
* **Affiliation** -- Unaffiliated, Affiliated
* **Account Status** -- Non-member, Member

These statuses are defined below:

TODO: It's not clear to me why some of these are nouns and some are adjectives.
      This problem is easier to see when you start adding in all the statuses that
      were skipped, e.g. unaffiliated, non-member. Some terms appear to belong
      together as they describe a shared, implied subject. Other terms appear
      standalone.

* **Anonymous** -- individually indistinguishable from other people except
  circumstantially (e.g., visiting from the same IP address)
* **Identified** -- a person whose identity has been verified; importantly, the
  identity may not be known to all parties
* **Unnamed** -- identified, but only opaquely; that is, the person (principal)
  is not revealed to the application, though the affiliation (organizational
  role) is
* **Named** -- personally identified; that is, a resolvable identifier for the
  person (principal) is revealed, possibly along with name information
* **Session** -- a period of usage that is considered to be conducted by the
  same person
* **Partner** -- an organization with some agreement with the application
  providers, in order to authenticate its users and offer access on its behalf
* **Affiliate** -- a person with at least one affiliation relationship with a
  partner; asserted by the organization (e.g., a university asserts that a
  person is a faculty member)
* **Visitor** -- a person with no identification or affiliation whatsoever;
  effectively unrecognized by any means
* **Guest** -- a person with some identification or affiliation; recognized, but
  transient, that is, not holding an account of any sort
* **Member** -- a person with identification; recognized, holding an account
* **Non-Member** -- TODO: a person without identification; unrecognized, does not have an account
  or could they?

Not all combinations are sensible. For example,
membership requires some form of identification, so there cannot be an anonymous
member.

This table names all of the unique combinations that can be used by an application,
which are further defined below. It does not imply
that all applications should have seven user types, but that each combination
has unique characteristics that may need to be handled differently. A given
application may exclude certain types or treat different types the same.
For example, an application may completely disregard identification for
Guests, treating them all the same.

TODO: This table makes no sense to me at all. What are the headings and where did they come
      from? What happened to "identified"? I really expected to see the above terms
      combined together to form the below terms.

.. csv-table::
   :header: "", "Unaffiliated Non-member", "Unaffiliated Member", "Affiliated Non-member", "Affiliated Member"
   :stub-columns: 1

   "Anonymous", "Visitor (Public)", "--", "Unknown Guest", "--"
   "Unnamed", "--", "--", "Unnamed Guest", "Private Member"
   "Named", "--", "Local Account", "Named Guest", "Member"



Authentication Scenarios / User Types
-------------------------------------

Visitor
~~~~~~~

A person with no recognized identification or affiliation whatsoever. The user
is effectively unauthenticated by any means.

Anyone who can connect to the application (at the very least by obscuring their
identity and any affiliation) may act as a visitor, so there should be no
restrictions that apply to other users that do not apply to visitors. Entry or
modification of data should be permitted only under scrutiny, where vandalism
is of no concern and appropriate auditing and moderation are in place.

A visitor may have a session to enhance user experience, but all session data
should be transient and discarded after an appropriate inactivity period, if
stored server-side.

Visitor (Public)
................
All Visitors are anonymous and should be treated as "any public user".
TODO: Clarify whether this section is further describing the Visitor section or not.

Guest
~~~~~

A person with some recognized identification or affiliation. The user is
authenticated, but transient – that is, not holding an account of any sort.
This type of user is typically permitted access to restricted materials based
on agreements between organizations.

There may be useful distinctions applied or features available for different
types of Guest. For example, the text may be personalized for a Named Guest, or
additional features may be provided to Unnamed Guests with the "faculty"
designation.

Unknown Guest
.............
A user connecting from a recognized affiliate network, but with no
identification. All that can be asserted is that the user has some unspecified
affiliation (or a generic one implying that the person can access
organizational computing resources).

TODO: Isn't this what affiliated means?

Unnamed Guest
.............
A person with specified affiliation and a persistent identifier. The identifier
is opaque, but stable; that is, the same identifier presented over time implies
that the user is the same person. It is expressly not human-friendly and should
not be displayed.

Keycard calls this persistent ID the user_pid. Generally, the affiliate will
not present different identifiers for the same person, but that is outside of
the control and knowledge of the application. It should be assumed that
different IDs represent different people.

The affiliation may be multi-valued and is *scoped*, meaning that it applies
within a security domain. Common semantics assert that a person has roles like
member and staff, or member and student, scoped to the entire affiliate
organization. An example of one scoped affiliation would be
``faculty@umich.edu``.

TODO: Explain pid outside of these categories
TODO: Explain eid outside of these categories

Named Guest
...........
A person with specified affiliation and both persistent and enterprise
identifiers. The persistent identifier is as for Unnamed Guests. The enterprise
identifier is name-based, meaning that it based on some account name for the
person used within the affiliate organization. It is expressly personally
identifiable, and often human-friendly, meaning that other people may recognize
it and it would be suitable for display.

Keycard calls the enterprise ID the ``user_eid``. It is single-valued and
often, but not always, matches an email address for the person. Generally, this
ID is stable between sessions, but there is no guarantee that it will not be
reassigned at some point.

Member
~~~~~~

A person with recognized identification and an account for application features
such as content ownership. The user is authenticated and persistent.

The reasons to maintain Members may vary between application. For example,
those with a narrower audience may prefer the semantics that anyone
individually authenticated becomes a Member automatically to simplify data
modeling and reporting. Those with very broad audiences may choose to have many
Guests and only a few Members to reduce the number of dormant or single-use
accounts.

Local Account
.............
A user (person or machine user) that is only known the application, not an
identity authority. The application must manage any authentication directly.
This may not even be an interactive account, but used as a means to record
ownership or action by the system consistently alongside human users, for
example.

Some applications may have a dedicated super user with a special login
procedure, where others may manage those tasks by designating human Members as
administrative users.

Private Member
..............
A person with specified affiliation and a privacy-preserving, persistent
identifier. This Member is very similar to an Unnamed Guest, but has been given
an account for some application purpose. Some applications may choose to have
only Unnamed Guests or Private Members, not both types.

The authentication information does not include anything personally
identifiable, so the application must decide whether to ask the user to supply
items like a display name or email address, or to deal with the lack of
human-friendly information in another way. For example, an application that
only maintains a set of favorite items for the user may find no need to provide
meaningful display to that member others as to whose favorites they are. By
contrast, an application that tracks and attributes comments to a Member would
generally need some label for the commenter.

Member
......
A person with specified affiliation and both persistent and enterprise
identifiers. This Member is similar to a Named Guest, but has been given an
account for some application purpose. This Member fits the classical definition
of "named user"; that is, account and display information is maintained, likely
in order to grant individual permissions and display name information to other
users.

TODO: The top section seeks to define the terms, and then the bottom section wants
use those terms to describe some concepts. I think that would be better on separate
pages. It's also difficult to follow the relationship between the terms defined at
the top, and their use below. The eid and pid seem like they're the most important
thing, and as such they're super glossed over. If they're not that important, that
would be useful to know as well. Basically, what concrete things does keycard do
here that differs between the different types of users?
