#!/bin/sh

python3 -c 'import asn1tools; zhead=asn1tools.compile_files("./zipheader.asn")'
