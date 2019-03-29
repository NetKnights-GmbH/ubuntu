This is buildenvironment for privacyIDEA on Ubuntu 16.04 and 18.04.

How to proceed:

1. Adapt changelogs in ``debian_privacyidea/``, ``debian_server/`` and/or ``debia_radius``
2. Adapt the version number in the Makefile
3. Build the packages of your choice.
4. When building you can preceed a specific version number.
   This version gets checked out from the git repository

Examples:

Build all devel packages and publish them to the repository:

    make all add-repo-devel push-lancelot

Only build specific RADIUS package version:

    VERSION=3.1dev3 make radius
