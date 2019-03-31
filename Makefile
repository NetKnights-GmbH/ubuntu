VERSION=3.0~dev6

# Do not change this
SERIES=`lsb_release -c | cut -d: -f2 | sed -e s/"\s"//g`
BUILDDIR_PI=DEBUILD/privacyidea.orig
BUILDDIR_SERVER=DEBUILD/privacyidea-server.orig
DEBIAN_PI=debian_privacyidea
DEBIAN_SERVER=debian_server
MYDIR=.
REPO=communityrepo
SIGNKEY=09404ABBEDB3586DEDE4AD2200F70D62AE250082

GIT_VERSION=`echo ${VERSION} | sed -e s/\~//g`

clean:
	rm -fr DEBUILD

privacyidea:	
	mkdir -p DEBUILD
	rm -fr ${BUILDDIR_PI}
	# Fetch the code from github
	(cd DEBUILD; git clone https://github.com/privacyidea/privacyidea.git privacyidea.orig)
	(cd ${BUILDDIR_PI}; git checkout v${GIT_VERSION})
	(cd ${BUILDDIR_PI}; rm -fr tests)
	mkdir -p ${BUILDDIR_PI}/debian
	cp -r ${DEBIAN_PI}/* ${BUILDDIR_PI}/debian/
	cp -r deploy ${BUILDDIR_PI}/
	mv ${BUILDDIR_PI}/LICENSE ${BUILDDIR_PI}/debian/copyright
	sed -e s/"trusty) trusty; urgency"/"${SERIES}) ${SERIES}; urgency"/g ${DEBIAN_PI}/changelog > ${BUILDDIR_PI}/debian/changelog
	(cd DEBUILD; tar -zcf privacyidea_${VERSION}.orig.tar.gz --exclude=privacyidea.org/debian privacyidea.orig)
	(cd ${BUILDDIR_PI}; DH_VIRTUALENV_INSTALL_ROOT=/opt/ DH_VERBOSE=1 dpkg-buildpackage -us -uc -k${SIGNKEY})

server:
	mkdir -p ${BUILDDIR_SERVER}/debian
	cp -r ${DEBIAN_SERVER}/* ${BUILDDIR_SERVER}/debian/
	cp -r deploy ${BUILDDIR_SERVER}/
	#mv ${BUILDDIR}/LICENSE ${BUILDDIR}/debian/copyright
	sed -e s/"trusty) trusty; urgency"/"${SERIES}) ${SERIES}; urgency"/g ${DEBIAN_SERVER}/changelog > ${BUILDDIR_SERVER}/debian/changelog
	(cd DEBUILD; tar -zcf privacyidea-server_${VERSION}.orig.tar.gz --exclude=privacyidea-server.org/debian privacyidea-server.orig)
	(cd ${BUILDDIR_SERVER}; dpkg-buildpackage -us -uc -k${SIGNKEY})

all:
	@echo "Building for ${SERIES}"
	make clean privacyidea server

init-repo:
	mkdir -p $(MYDIR)/${REPO}/xenial/stable/conf
	mkdir -p $(MYDIR)/${REPO}/xenial/devel/conf
	mkdir -p $(MYDIR)/${REPO}/bionic/stable/conf
	mkdir -p $(MYDIR)/${REPO}/bionic/devel/conf
	cp distributions/xenial-devel communityrepo/xenial/devel/conf/distributions
	cp distributions/xenial-stable communityrepo/xenial/stable/conf/distributions
	cp distributions/bionic-devel communityrepo/bionic/devel/conf/distributions
	cp distributions/bionic-stable communityrepo/bionic/stable/conf/distributions
	reprepro -b $(MYDIR)/${REPO}/xenial/stable createsymlinks
	reprepro -b $(MYDIR)/${REPO}/xenial/devel createsymlinks
	reprepro -b $(MYDIR)/${REPO}/bionic/stable createsymlinks
	reprepro -b $(MYDIR)/${REPO}/bionic/devel createsymlinks

add-repo-devel:
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/devel -V include ${SERIES} DEBUILD/privacyidea-server_*.changes 
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/devel -V include ${SERIES} DEBUILD/privacyidea_*.changes 

repo-stable:
	@echo "Just copyiing the devel to stable"
	(cd ${REPO}; cp -rP devel/* stable/)

push-lancelot:	
	rsync -r ${REPO}/${SERIES}/* root@lancelot:/srv/www/nossl/community/${SERIES}

