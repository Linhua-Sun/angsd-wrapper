#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# Load variables from supplied config file
source $1

#   Variables created from transforming other variables
#       The number of individuals in the taxon we are analyzing
N_IND=`wc -l < "${SAMPLE_LIST}"`
#       How many inbreeding coefficients are supplied?
N_F=`wc -l < "${SAMPLE_INBREEDING}"`
#   For ANGSD, the actual sample size is twice the number of individuals, since each individual has two chromosomes.
#   The individual inbreeding coefficents take care of the mismatch between these two numbers
N_CHROM=`expr 2 \* ${N_IND}`

#   Perform a check to see if number of individuals matches number of inbreeding coefficients
if [ "${N_IND}" -ne "${N_F}" ]
then
    echo "Mismatch between number of samples in ${SAMPLE_LIST} and ${SAMPLE_INBREEDING}"
    exit 1
fi

#   Create outdirectory
mkdir -p ${OUTDIR}

#   Now we actually run the command, this creates a binary file that contains the prior SFS
if [[ -f "${OUTDIR}/${PROJECT}_SFSOut.mafs.gz" ]] && [ "$OVERRIDE" = "false" ]
then 
    echo "maf already exists and OVERRIDE=false, skipping angsd -bam..."
else
    touch "${OUTDIR}"/"${PROJECT}"_SFSOut.saf
    if [[ "${REGIONS}" == */* ]]
    then
        "${ANGSD_DIR}"/angsd \
            -bam "${SAMPLE_LIST}" \
            -out "${OUTDIR}"/"${PROJECT}"_SFSOut \
            -indF "${SAMPLE_INBREEDING}" \
            -doSaf "${DO_SAF}" \
            -uniqueOnly "${UNIQUE_ONLY}" \
            -anc "${ANC_SEQ}" \
            -minMapQ "${MIN_MAPQ}" \
            -minQ "${MIN_BASEQUAL}" \
            -nInd "${N_IND}" \
            -minInd "${MIN_IND}"\
            -baq "${BAQ}" \
            -ref "${REF_SEQ}" \
            -GL "${GT_LIKELIHOOD}" \
            -doGlf "${DO_GLF}" \
            -P "${N_CORES}" \
            -doMajorMinor "${DO_MAJORMINOR}" \
            -doMaf "${DO_MAF}" \
            -doGeno "${DO_GENO}" \
            -rf "${REGIONS}"
    else
        "${ANGSD_DIR}"/angsd \
            -bam "${SAMPLE_LIST}" \
            -out "${OUTDIR}"/"${PROJECT}"_SFSOut \
            -indF "${SAMPLE_INBREEDING}" \
            -doSaf "${DO_SAF}" \
            -uniqueOnly "${UNIQUE_ONLY}" \
            -anc "${ANC_SEQ}" \
            -minMapQ "${MIN_MAPQ}" \
            -minQ "${MIN_BASEQUAL}" \
            -nInd "${N_IND}" \
            -minInd "${MIN_IND}" \
            -baq "${BAQ}" \
            -ref "${REF_SEQ}" \
            -GL "${GT_LIKELIHOOD}" \
            -doGlf "${DO_GLF}" \
            -P "${N_CORES}" \
            -doMajorMinor "${DO_MAJORMINOR}" \
            -doMaf "${DO_MAF}" \
            -r "${REGIONS}"
    fi
fi

"${ANGSD_DIR}"/misc/realSFS \
    "${OUTDIR}"/"${PROJECT}"_SFSOut.saf \
    "${N_CHROM}" \
    -P "${N_CORES}"\
    > "${OUTDIR}"/"${PROJECT}"_DerivedSFS