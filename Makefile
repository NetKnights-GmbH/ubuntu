VERSION=3.0~dev3
SERIES=bionic

# Do not change this
BUILDDIR_PI=DEBUILD/privacyidea.orig
BUILDDIR_SERVER=DEBUILD/privacyidea-server.orig
DEBIAN_PI=debian_privacyidea
DEBIAN_SERVER=debian_server

GIT_VERSION=`echo ${VERSION} | sed -e s/\~//g`

clean:
	rm -fr DEBUILD

privacyidea:
	mkdir -p DEBUILD
	rm -fr ${BUILDDIR_PI}
	# Fetch the code from github
	(cd DEBUILD; git clone https://github.com/privacyidea/privacyidea.git privacyidea.orig)
	(cd ${BUILDDIR_PI}; git checkout v${GIT_VERSION})
	mkdir -p ${BUILDDIR_PI}/debian
	cp -r ${DEBIAN_PI}/* ${BUILDDIR_PI}/debian/
	cp -r deploy ${BUILDDIR_PI}/
	mv ${BUILDDIR_PI}/LICENSE ${BUILDDIR_PI}/debian/copyright
	sed -e s/"trusty) trusty; urgency"/"${SERIES}) ${SERIES}; urgency"/g ${DEBIAN_PI}/changelog > ${BUILDDIR_PI}/debian/changelog
	(cd DEBUILD; tar -zcf privacyidea_${VERSION}.orig.tar.gz --exclude=privacyidea.org/debian privacyidea.orig)
	(cd ${BUILDDIR_PI}; DH_VIRTUALENV_INSTALL_ROOT=/opt/ DH_VERBOSE=1 dpkg-buildpackage -us -uc)

server:
	mkdir -p ${BUILDDIR_SERVER}/debian
	cp -r ${DEBIAN_SERVER}/* ${BUILDDIR_SERVER}/debian/
	cp -r deploy ${BUILDDIR_SERVER}/
	#mv ${BUILDDIR}/LICENSE ${BUILDDIR}/debian/copyright
	sed -e s/"trusty) trusty; urgency"/"${SERIES}) ${SERIES}; urgency"/g ${DEBIAN_SERVER}/changelog > ${BUILDDIR_SERVER}/debian/changelog
	(cd DEBUILD; tar -zcf privacyidea-server_${VERSION}.orig.tar.gz --exclude=privacyidea-server.org/debian privacyidea-server.orig)
	(cd ${BUILDDIR_SERVER}; dpkg-buildpackage -us -uc)

all:
	make clean privacyidea server
