#!/bin/sh

prod=ZipHeaderToAsn1
numcpus=16
jobs=$((numcpus - 1))

docdir=./doc.d
mkdir -p "${docdir}"

swift \
	package \
	--jobs ${jobs} \
	--allow-writing-to-directory "${docdir}" \
	generate-documentation \
	--output-path "${docdir}" \
	--product "${prod}"
