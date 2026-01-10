#!/bin/bash

set -eu

SCRIPTDIR=$(dirname $(realpath $0))
FWKPROJNAME=$(basename $(dirname $(dirname $(dirname ${SCRIPTDIR}))))
FWKPROJNAME=$(echo ${FWKPROJNAME} | sed "s/_/-/g")

# Create skeleton code for Yocto configuration

mkdir -p cfg

for SRCFILE in ${SCRIPTDIR}/cfg-skel/*; do
    FNAME="cfg/$(basename ${SRCFILE})"
    if [ ! -f "${FNAME}" ]; then
        echo "Creating ${FNAME}"
        sed "s/fwkprojname/${FWKPROJNAME}/g" ${SRCFILE} > ${FNAME}
    else
        echo "Skipping ${FNAME}"
    fi
done

# Create skeleton code for Yocto HDF layer

METAHDFDIR="src/yocto-local/meta-hdf"
if [ -d "${METAHDFDIR}" ]; then
    echo "Skipping ${METAHDFDIR}"
    exit 0
fi

mkdir -p ${METAHDFDIR}

cp -a ${SCRIPTDIR}/meta-hdf-skel/{*,.gitignore} ${METAHDFDIR}/

echo -e "Template files copied. Replace hdfprojectname with the actual FWK FPGA name:\n"
grep -rn hdfprojectname ${METAHDFDIR}/
