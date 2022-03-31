#! /bin/bash

# standard options
VERSION=master
DEBUG=0
TYPE=minimal
STABLE=0
# this has to be changed manually upon new release wich isn#t ideal!
LATEST_VERSION=v4.11.1

while getopts ":v:d:t:" options; do

    case "${options}" in
        v)
            VERSION=${OPTARG}
            ;;
        d)
            DEBUG=${OPTARG}
            ;;
        t)
            TYPE=${OPTARG}
            ;;
        :)                                    
            echo "Error: -${OPTARG} requires an argument."
            exit                       
            ;;
        *)
            echo "unsupported options"
            exit
            ;;
    esac

done

if [[ "$TYPE" != "minimal" ]] && [[ "$TYPE" != "full" ]] ; then
    echo "invalid argument for -t option"
    exit
fi

declare -A KNOWN_BRANCHES=(
    [master]=1 [stable-4.7]=1 [stable-4.8]=1 [stable-4.9]=1 [stable-4.10]=1 [stable-4.11]=1
)

declare -A KNOWN_RELEASES=(
    [v4.11.1]=1 [v4.11.0]=1 [v4.10.2]=1 [v4.10.1]=1 [v4.10.0]=1
)

if [[ "${VERSION: -7}" = "-latest" ]] || [[ $VERSION = "master" ]] ; then
    STABLE=0
    if [[ "${VERSION: -7}" = "-latest" ]] ; then
        echo "is latest"
        GAP_VERSION=stable-${VERSION/%-latest}
        echo "$GAP_VERSION"
    else 
        GAP_VERSION=master
    fi

    # make sure the branch is known
    if [[ -z "${KNOWN_BRANCHES[$GAP_VERSION]}" ]] ; then
        echo "version indicates branch in the GAP repository which does not exist"
        exit
    fi

    mkdir gap/inst
    #mkdir /home/gap/inst/ 
    #cd /home/gap/inst/ || exit 
    cd gap/inst/ || exit 
    git clone --depth=1 -b "${GAP_VERSION}" https://github.com/gap-system/gap gap-"${GAP_VERSION}" 
    cd gap-"${GAP_VERSION}" || exit 

else
    STABLE=1
    echo "stable!"
    GAP_VERSION=v${VERSION/%-latest}
    echo "$GAP_VERSION"

    # make sure the version is known
    if [[ -z "${KNOWN_RELEASES[$GAP_VERSION]}" ]] ; then
        echo "version indicates release which does not exist"
        exit
    fi

    mkdir gap/inst
    #mkdir /home/gap/inst/ 
    #cd /home/gap/inst/ || exit 
    cd gap/inst/ || exit
    wget https://github.com/gap-system/gap/releases/download/"${GAP_VERSION}"/gap-"${GAP_VERSION/#v}"-core.zip 
    unzip gap-"${GAP_VERSION/#v}"-core.zip 
    rm gap-"${GAP_VERSION/#v}"-core.zip 
    cd gap-"${GAP_VERSION/#v}" || exit
fi
 
./autogen.sh 

if [[ "$DEBUG" -eq 0 ]] ; then 
    ./configure ; 
else 
    ./configure --enable-debug ; 
fi

make -j 12
cp bin/gap.sh bin/gap

case $TYPE in
    minimal)
        echo "minimal"
        mkdir pkg 
        cd pkg || exit 
        #wget -q https://github.com/gap-system/gap/releases/download/v"${GAP_VERSION}"/packages-required-v"${GAP_VERSION}".zip 
        if [[ "$GAP_VERSION" = "$LATEST_VERSION" ]] ; then
        # HACK wont work in general!!!
            echo "latest_version"
            #wget https://files.gap-system.org/gap4pkgs/packages-required-"stable-${GAP_VERSION/%.1}".tar.gz
            wget https://files.gap-system.org/gap4pkgs/packages-required-"stable-4.11".tar.gz
            tar xzf packages-required-"stable-4.11".tar.gz 
            rm packages-required-"stable-4.11".tar.gz
        else 
            wget -q https://files.gap-system.org/gap4pkgs/packages-required-"${GAP_VERSION}".zip
            unzip packages-required-"${GAP_VERSION}".zip 
            rm packages-required-"${GAP_VERSION}".zip
        fi
        ;;
    full)
        echo "full"
        mkdir pkg 
        cd pkg || exit 
        #wget -q https://github.com/gap-system/gap/releases/download/v"${GAP_VERSION}"/packages-required-v"${GAP_VERSION}".zip 
        if [[ "$GAP_VERSION" = "$LATEST_VERSION" ]] ; then
        # HACK wont work in general!!!
            wget -q https://files.gap-system.org/gap4pkgs/packages-"stable-${GAP_VERSION/%.1}".zip
            unzip packages-"${GAP_VERSION}".zip 
            rm packages-"${GAP_VERSION}".zip
        else 
            wget -q https://files.gap-system.org/gap4pkgs/packages-"${GAP_VERSION}".zip
            unzip packages-"${GAP_VERSION}".zip 
            rm packages-"${GAP_VERSION}".zip
        fi
        ../bin/BuildPackages.sh --parallel
        ;;
esac