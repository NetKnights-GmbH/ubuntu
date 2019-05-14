This is buildenvironment for privacyIDEA on Ubuntu 16.04 and 18.04.

How to proceed:

1. Adapt changelogs in ``debian_privacyidea/``, ``debian_server/`` and/or ``debian_radius``
2. Build the packages of your choice.
   When building you need to preceed a specific version number like:
   This version gets checked out from the git repository

Examples:

Build all devel packages and publish them to the repository:

    VERSION=3.0~dev10 make privacyidea server add-repo-devel push-lancelot

Only build specific RADIUS package version:

    VERSION=3.1~dev3 make radius
