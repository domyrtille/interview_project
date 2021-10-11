############################################################################################################
## LITECOIN NODE Mutli-stage build
## Using Muti-stage build allow us to keep a small footprint and limit attack vector on our image
##
## Few parts of the Dockerfile are inspired from
## https://github.com/uphold/docker-litecoin-core/blob/master/0.18/Dockerfile
## 
## BUILDKIT=1 is used to build this image
## From https://www.cloudsavvyit.com/12441/what-is-dockers-buildkit-and-why-does-it-matter/
## BUILDKIT focuses on improving build performance, storage management and other things by using parallel processing, 
## more advanced caching and automatic garbage collection. 
## These combine into a build system that’s more efficient and more extensible than the original engine.
## For example: COPY --chmod=0450 xx xx, is not available without BUILDKIT
############################################################################################################

# Latest version pinned to avoid issues by using latest
FROM alpine:3.13.6 as base

LABEL maintainer="Ben Cyril"
# ARG are used for build and won't be present in the final container
# Latest litecoin version / October 2021
ARG LITECOIN_VERSION=0.18.1
ARG VERIF="GOODSIG"
# Fingerpint given by Litecoin dev to check authenticity
ARG FINGERPRINT_LTC="FE3348877809386C"
ARG FINGERPRINT_LTC2="59CAF0E96F23F53747945FD4FE3348877809386C"
# List of PGP servers to retrieve key and avoid timeout
ARG PGP_SERVERS_LIST="keyserver.ubuntu.com ha.pool.sks-keyservers.net keyserver.pgp.com pgp.mit.edu"

# Update, upgrade and install packages
RUN apk --update add --no-cache gnupg=2.2.31-r0 curl=7.79.1-r0

# We download the litecoin LITECOIN_VERSION release and it's signature to check if everything is valid
RUN curl -SLO https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz \
    && curl -SLO https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-linux-signatures.asc

# As gpg servers are known to have some availability issues
# This part allows to search and retrieve the key from different servers
RUN for server in ${PGP_SERVERS_LIST}; \
    do gpg --keyserver "$server" --recv-keys ${FINGERPRINT_LTC} && break; done;

# Verify the signature (exit if it fails)
RUN gpg --verify litecoin-${LITECOIN_VERSION}-linux-signatures.asc || exit 1

# Verify the tar.gz via the signature
# Will use the sha256 of the tar.gz and check if it's in the linux signature file (exit if it fails)
# SHELL is used and needed due to the complex command
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN grep -q "$(sha256sum litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz | awk '{ print $1 }')" litecoin-${LITECOIN_VERSION}-linux-signatures.asc || exit 1

# We untar the gzip file and put all binaries in /tmp
# --strip=2 allows to only extract what's inside the second folder from root (here: bin). 
# -C is where to extract
RUN tar --strip=2 -xzvf \
    litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz \
    -C /tmp

#################
## Final Image ##
#################
# We use Ubuntu to have a container with all necessary libs and less important CVE than debian or more recently Alpine
# Ubuntu Focal release allows for End of Support on April 2025
FROM ubuntu:focal-20210921

LABEL maintainer="Ben Cyril"
ENV LITECOIN_DATA=/litecoin/.litecoin
ARG LITECOIN_USER="litecoin"
ARG LITECOIN_GROUP="litecoin"
ARG LITECOIN_USER_UID="10001"
ARG LITECOIN_GROUP_GID="10001"

# Update to patch any released security issues
RUN apt-get update && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the user litecoin
# For security reason we remove the login and /etc/passwd informations(--gecos)
RUN mkdir /litecoin \
    && adduser --home /litecoin --shell /sbin/nologin --gecos '' --no-create-home --disabled-password --uid 10001 litecoin \
    && chown -R litecoin /litecoin 

# We copy the binaries from the other build to /usr/local/bin/ with specific permissions
COPY --chown=root:${LITECOIN_GROUP} --chmod=0450 --from=base /tmp/ /usr/local/bin/

WORKDIR /litecoin

# Run as the "litecoin" user, not root
USER litecoin

CMD ["litecoind"]
