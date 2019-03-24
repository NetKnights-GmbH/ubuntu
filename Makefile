BUILDDIR=DEBUILD/privacyidea.orig
VERSION=3.0~dev3
SERIES=bionic

GIT_VERSION=`echo ${VERSION} | sed -e s/\~//g`

clean:
	rm -fr DEBUILD

builddeb:
	make clean
	mkdir DEBUILD
	(cd DEBUILD; git clone https://github.com/privacyidea/privacyidea.git privacyidea.orig)
	(cd ${BUILDDIR}; git checkout v${GIT_VERSION})
	cp -r debian ${BUILDDIR}/
	cp -r deploy ${BUILDDIR}/
	mv ${BUILDDIR}/LICENSE ${BUILDDIR}/debian/copyright
	sed -e s/"trusty) trusty; urgency"/"${SERIES}) ${SERIES}; urgency"/g debian/changelog > ${BUILDDIR}/debian/changelog
	(cd DEBUILD; tar -zcf privacyidea_${VERSION}.orig.tar.gz --exclude=privacyidea.org/debian privacyidea.orig)
	(cd ${BUILDDIR}; DH_VIRTUALENV_INSTALL_ROOT=/opt/ DH_VERBOSE=1 dpkg-buildpackage -us -uc)
#	(cd ${BUILDDIR}; debuild --no-lintian)

