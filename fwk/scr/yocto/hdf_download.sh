#!/bin/bash

while [ 1 ]; do
    case $1 in
        "--instance")
            shift
            JENKINS_INSTANCE="$1"
            shift
            ;;
        "--branch")
            shift
            JENKINS_JOB_BRANCH="$1"
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ -z "${JENKINS_INSTANCE}" ]; then
    JENKINS_INSTANCE="https://jenkins-fw.msktools.desy.de"
fi

if [ -z "${JENKINS_JOB_BRANCH}" ]; then
    JENKINS_JOB_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
fi

set -eu

TMPFILE=$(mktemp)
PWD=$(pwd)

JENKINS_JOB_URL=$(sed -nE "s/.*upstream:[[:space:]]*'([^']*)'.*/\1/p" ${PWD}/Jenkinsfile.yocto | sed 's,/,/job/,g')
JENKINS_ART_URL="${JENKINS_INSTANCE}${JENKINS_JOB_URL}${JENKINS_JOB_BRANCH}/lastSuccessfulBuild/artifact/*zip*/archive.zip" 

wget "${JENKINS_ART_URL}" -O ${TMPFILE}
unzip -d ${PWD} ${TMPFILE}
rm ${TMPFILE}

mkdir -p ${PWD}/out
mv ${PWD}/archive/out/* ${PWD}/out
