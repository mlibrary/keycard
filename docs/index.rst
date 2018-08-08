.. title:: Keycard, authentication for Ruby applications

Keycard Documentation
=====================

Keycard is both a Ruby library and an abstract model for authentication and
directory information for users of an application.

Keycard is concerned with establishing identity and supplemental
attributes of users. It provides a data model for
user information and conveniences for building applications that are
deployed with reverse proxies and single sign-on systems. It is well-suited
to enterprise deployments where there are external login and directory systems.

Authorization needs are not covered by Keycard. See Checkpoint_ for a
library that can store grants based on the Keycard attributes and enforce
policies against them.

Table of Contents
-----------------

.. toctree::
    :maxdepth: 2

    authentication.rst
    runtime_context.rst

.. _Checkpoint: https://github.com/mlibrary/checkpoint
