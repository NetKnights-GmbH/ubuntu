# Do not change this
SERIES=`lsb_release -c | cut -d: -f2 | sed -e s/"\s"//g`
BUILDDIR_PI=DEBUILD/privacyidea.orig
BUILDDIR_SERVER=DEBUILD/privacyidea-server.orig
BUILDDIR_RADIUS=DEBUILD/privacyidea-radius.orig
BUILDDIR_APPLIANCE=DEBUILD/pi-appliance.orig
DEBIAN_PI=debian_privacyidea
DEBIAN_SERVER=debian_server
DEBIAN_RADIUS=debian_radius
DEBIAN_APPLIANCE=debian_appliance
MYDIR=.
COMMUNITYREPO=communityrepo
ENTERPRISEREPO=enterpriserepo
SIGNKEY=09404ABBEDB3586DEDE4AD2200F70D62AE250082

GIT_VERSION=`echo ${VERSION} | sed -e s/\~//g`
# If this is a devel version
DEVEL_VERSION=`echo ${VERSION} | grep "dev"`
PI_VERSION=$(VERSION)
# If the version has two dots like 3.5.1
MINOR_VERSION=`echo ${VERSION} | sed -e s/[0-9]//g | grep '\.\.'`

ifdef DEVEL_VERSION
	BRANCH="devel"
else
	BRANCH="stable"
endif

ifndef REPO
  REPO=${COMMUNITYREPO}
endif

ifndef VERSION
  $(error VERSION not set. Set VERSION to build like VERSION=3.0.1~dev7)
endif


privacyidea:
	mkdir -p DEBUILD
	rm -fr ${BUILDDIR_PI}
	# Fetch the code from github with its submodules
	(cd DEBUILD; git clone --recurse-submodules https://github.com/privacyidea/privacyidea.git privacyidea.orig)
	(cd ${BUILDDIR_PI}; git checkout v${GIT_VERSION})
	#(cd ${BUILDDIR_PI}; git submodule init; git submodule update --recursive --remote)
	(cd ${BUILDDIR_PI}; rm -fr tests)
	mkdir -p ${BUILDDIR_PI}/debian
	cp -r ${DEBIAN_PI}/* ${BUILDDIR_PI}/debian/
	cp -r deploy ${BUILDDIR_PI}/
	mv ${BUILDDIR_PI}/LICENSE ${BUILDDIR_PI}/debian/copyright
	sed -e s/"trusty) trusty; urgency"/"${SERIES}) ${SERIES}; urgency"/g ${DEBIAN_PI}/changelog > ${BUILDDIR_PI}/debian/changelog
	(cd DEBUILD; tar -zcf privacyidea_${PI_VERSION}.orig.tar.gz --exclude=debian/* privacyidea.orig)
	# copy existing tgz from repository and overwrite the one we just created!
	scp root@lancelot:/srv/www/nossl/community/${SERIES}/${BRANCH}/pool/main/p/privacyidea/privacyidea_${PI_VERSION}.orig.tar.gz DEBUILD/ || true
	(cd ${BUILDDIR_PI}; DH_VIRTUALENV_INSTALL_ROOT=/opt/ DH_VERBOSE=1 dpkg-buildpackage -us -uc -k${SIGNKEY})

appliance:
	echo ${DEVEL_VERSION}
	mkdir -p DEBUILD
	rm -fr ${BUILDDIR_APPLIANCE}
	# Fetch the code from github
	(cd DEBUILD; git clone https://github.com/NetKnights-GmbH/privacyidea-appliance pi-appliance.orig)
	(cd ${BUILDDIR_APPLIANCE}; git checkout v${GIT_VERSION})
	(cd ${BUILDDIR_APPLIANCE}; git submodule init; git submodule update --recursive --remote)
	# Remove the tests
	(cd ${BUILDDIR_APPLIANCE}; rm -fr test debian; find authappliance/lib/ -name test_\*.py -delete)
	mkdir -p ${BUILDDIR_APPLIANCE}/debian
	cp -r ${DEBIAN_APPLIANCE}/* ${BUILDDIR_APPLIANCE}/debian/
	mv ${BUILDDIR_APPLIANCE}/LICENSE ${BUILDDIR_APPLIANCE}/debian/copyright
	sed -e s/") xenial; urgency"/") ${SERIES}; urgency"/g ${DEBIAN_APPLIANCE}/changelog > ${BUILDDIR_APPLIANCE}/debian/changelog
	(cd DEBUILD; tar -zcf pi-appliance_${PI_VERSION}.orig.tar.gz --exclude=debian/* pi-appliance.orig)
	(cd ${BUILDDIR_APPLIANCE}; DH_VIRTUALENV_INSTALL_ROOT=/opt/ DH_VERBOSE=1 dpkg-buildpackage -us -uc -k${SIGNKEY})

radius:
	mkdir -p DEBUILD
	rm -fr ${BUILDDIR_RADIUS}
	(cd DEBUILD; git clone https://github.com/privacyidea/FreeRADIUS.git privacyidea-radius.orig)
	(cd ${BUILDDIR_RADIUS}; git checkout v${GIT_VERSION})
	mkdir -p ${BUILDDIR_RADIUS}/debian
	cp -r ${DEBIAN_RADIUS}/* ${BUILDDIR_RADIUS}/debian/
	# copy e.g. privacyidea_radius.install and postinstall, which depends on the series
	cp ${BUILDDIR_RADIUS}/debian/${SERIES}/* ${BUILDDIR_RADIUS}/debian/
	sed -e s/"trusty) trusty; urgency"/"${SERIES}) ${SERIES}; urgency"/g ${DEBIAN_RADIUS}/changelog > ${BUILDDIR_RADIUS}/debian/changelog
	(cd DEBUILD; tar -zcf privacyidea-radius_${PI_VERSION}.orig.tar.gz --exclude=debian/* --exclude=.git/* privacyidea-radius.orig)
	(cd ${BUILDDIR_RADIUS}; dpkg-buildpackage -us -uc -k${SIGNKEY})

server:
	mkdir -p ${BUILDDIR_SERVER}/debian
	cp -r ${DEBIAN_SERVER}/* ${BUILDDIR_SERVER}/debian/
	cp -r deploy ${BUILDDIR_SERVER}/
	#mv ${BUILDDIR}/LICENSE ${BUILDDIR}/debian/copyright
	sed -e s/"trusty) trusty; urgency"/"${SERIES}) ${SERIES}; urgency"/g ${DEBIAN_SERVER}/changelog > ${BUILDDIR_SERVER}/debian/changelog
	(cd DEBUILD; tar -zcf privacyidea-server_${PI_VERSION}.orig.tar.gz --exclude=debian/* privacyidea-server.orig)
	# copy existing tgz from repository and overwrite the one we just created!
	scp root@lancelot:/srv/www/nossl/community/${SERIES}/${BRANCH}/pool/main/p/privacyidea-server/privacyidea-server_${PI_VERSION}.orig.tar.gz DEBUILD/ || true
	(cd ${BUILDDIR_SERVER}; dpkg-buildpackage -sa -us -uc -k${SIGNKEY})

all:
	@echo "Building for ${SERIES}"
	make clean privacyidea server radius

init-repo:
	mkdir -p $(MYDIR)/${REPO}/xenial/stable/conf
	mkdir -p $(MYDIR)/${REPO}/xenial/devel/conf
	mkdir -p $(MYDIR)/${REPO}/bionic/stable/conf
	mkdir -p $(MYDIR)/${REPO}/bionic/devel/conf
	mkdir -p $(MYDIR)/${REPO}/focal/stable/conf
	mkdir -p $(MYDIR)/${REPO}/focal/devel/conf
	cp distributions/xenial-devel ${REPO}/xenial/devel/conf/distributions
	cp distributions/xenial-stable ${REPO}/xenial/stable/conf/distributions
	cp distributions/bionic-devel ${REPO}/bionic/devel/conf/distributions
	cp distributions/bionic-stable ${REPO}/bionic/stable/conf/distributions
	cp distributions/focal-devel ${REPO}/focal/devel/conf/distributions
	cp distributions/focal-stable ${REPO}/focal/stable/conf/distributions
	reprepro -b $(MYDIR)/${REPO}/xenial/stable createsymlinks
	reprepro -b $(MYDIR)/${REPO}/xenial/devel createsymlinks
	reprepro -b $(MYDIR)/${REPO}/bionic/stable createsymlinks
	reprepro -b $(MYDIR)/${REPO}/bionic/devel createsymlinks
	reprepro -b $(MYDIR)/${REPO}/focal/stable createsymlinks
	reprepro -b $(MYDIR)/${REPO}/focal/devel createsymlinks

add-repo-devel:
	cp ${MYDIR}/${REPO}/${SERIES}/devel/pool/main/p/privacyidea-server/privacyidea-server_${PI_VERSION}.orig.tar.gz DEBUILD/ || true
	cp ${MYDIR}/${REPO}/${SERIES}/devel/pool/main/p/privacyidea/privacyidea_${PI_VERSION}.orig.tar.gz DEBUILD/ || true
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/devel -V include ${SERIES} DEBUILD/privacyidea-server_*.changes || true
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/devel -V include ${SERIES} DEBUILD/privacyidea_*.changes || true
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/devel -V include ${SERIES} DEBUILD/privacyidea-radius_*.changes || true
ifeq ($(REPO), $(ENTERPRISEREPO))
	@echo "**** Adding Appliance to enterprise repo ****"
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/devel -V include ${SERIES} DEBUILD/pi-appliance_*.changes || true
endif

add-repo-stable:
ifneq ($(BRANCH), "stable")
	@echo "You can only push stable versions to the stable repository!"
	false
endif
ifeq ($(REPO), $(ENTERPRISEREPO))
ifneq ($(MINOR_VERSION), "")
	@echo "Only patch versions like 3.5.1 are allowed in enterprise repo!"
	false
endif
endif
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/stable -V include ${SERIES} DEBUILD/privacyidea-server_*.changes  || true
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/stable -V include ${SERIES} DEBUILD/privacyidea_*.changes  || true
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/stable -V include ${SERIES} DEBUILD/privacyidea-radius_*.changes  || true
ifeq ($(REPO), $(ENTERPRISEREPO))
	@echo "**** Adding Appliance to enterprise repo ****"
	reprepro -b ${MYDIR}/${REPO}/${SERIES}/stable -V include ${SERIES} DEBUILD/pi-appliance_*.changes  || true
endif

push-lancelot:
ifeq ($(REPO),$(COMMUNITYREPO))
	@echo "**** Pushing to community repo ****"
	rsync -r ${REPO}/${SERIES}/* root@lancelot:/srv/www/nossl/community/${SERIES}
endif
ifeq ($(REPO),$(ENTERPRISEREPO))
	@echo "**** Pushing to ENTERPRISE repo ****"
	# Pushing the complete repo for bionical or xenial
	rsync -r ${REPO}/${SERIES}/* root@lancelot:/srv/www/enterprise/${SERIES}
endif

clean:
	rm -fr DEBUILD
