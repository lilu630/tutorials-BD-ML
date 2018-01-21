#! /bin/bash -l
#            ^^
#         Mandatory for loading the modules
################################################################################
# bootstrap.sh - Bootstrap Java, eventually with Easybuild
# Time-stamp: <Sun 2018-01-21 08:11 svarrette>
################################################################################

DO_EASYBUILD=
INSTALL_JAVA7=
INSTALL_JAVA8=
INSTALL_MAVEN=

### Java 7u80
#ARCHIVE_JAVA7_URL='http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz'
ARCHIVE_JAVA7_URL='http://ftp.osuosl.org/pub/funtoo/distfiles/oracle-java/jdk-7u80-linux-x64.tar.gz'
ARCHIVE_JAVA7=$(basename "${ARCHIVE_JAVA7_URL}")
JAVA7_EB='Java-1.7.0_80.eb'


### Java 8u152
ARCHIVE_JAVA8_URL='http://ftp.osuosl.org/pub/funtoo/distfiles/oracle-java/jdk-8u152-linux-x64.tar.gz'
ARCHIVE_JAVA8=$(basename "${ARCHIVE_JAVA8_URL}")
JAVA8_EB='Java-1.8.0_152.eb'

# Latest Maven
MAVEN_EB='Maven-3.5.2.eb'

# Hadoop
HADOOP_EB='Hadoop-2.6.0-cdh5.12.0-native.eb'

EB_PROFILE='/etc/profile.d/easybuild.sh'

# Source the Easybuild profile
if [ -f "${EB_PROFILE}"  ]; then
    . ${EB_PROFILE}
fi

###
# Usage: eb_install <filename>.eb
##
function eb_install() {
    local ebconfig=$1
    [ -z "$ebconfig" ] && return || true
    cmd="eb $ebconfig --robot-paths=$PWD: "
    echo "==> running '${cmd} -D'"
    ${cmd} -D
    echo "==> running '${cmd}'"
    ${cmd}
}

##########################################################
# Check for options
while [ $# -ge 1 ]; do
    case $1 in
        -e  | -eb | --eb | --easybuild) DO_EASYBUILD=$1;;
        -a  | --all)
            INSTALL_JAVA7=$1
            INSTALL_JAVA8=$1
            INSTALL_MAVEN=$1
            ;;
        -7  | -java7 | --java7)   INSTALL_JAVA7=$1;;
        -8  | -java8 | --java8)   INSTALL_JAVA8=$1;;
        -m  | --maven)            INSTALL_MAVEN=$1;;
        -ha | -hadoop | --hadoop) INSTALL_HADOOP=$1;;
    esac
    shift
done

if [ -n "${DO_EASYBUILD}" ]; then
    # mu
    module use $GLOBAL_MODULES
    module use $LOCAL_MODULES
    module load tools/EasyBuild
fi

# Download and eventually install Java 7
if [ -n "${INSTALL_JAVA7}" ]; then
    if [ ! -f "${ARCHIVE_JAVA7}" ]; then
        echo "==> Downloading Java 7 archive '${ARCHIVE_JAVA7}'"
        # curl -OL -H "Cookie: oraclelicense=accept-securebackup-cookie" "${ARCHIVE_JAVA7_URL}"
        wget ${ARCHIVE_JAVA7_URL}
    fi
    [ -n "${DO_EASYBUILD}" ] && eb_install "${JAVA7_EB}"
fi

# Download and eventually install Java 8
if [ -n "${INSTALL_JAVA8}" ]; then
    if [ ! -f "${ARCHIVE_JAVA8}" ]; then
        echo "==> Downloading Java 8 archive '${ARCHIVE_JAVA8}'"
        # curl -OL -H "Cookie: oraclelicense=accept-securebackup-cookie" "${ARCHIVE_JAVA8_URL}"
        wget ${ARCHIVE_JAVA8_URL}
    fi
    [ -n "${DO_EASYBUILD}" ] && eb_install "${JAVA8_EB}"
fi

# eventually install Maven
if [ -n "${INSTALL_MAVEN}" ] && [ -n "${DO_EASYBUILD}" ]; then
    eb_install "${MAVEN_EB}"
fi

# eventually install Hadoop
if [ -n "${INSTALL_HADOOP}" ] && [ -n "${DO_EASYBUILD}" ] && [ -f "${HADOOP_EB}" ]; then
    eb_install "${HADOOP_EB}"
fi
