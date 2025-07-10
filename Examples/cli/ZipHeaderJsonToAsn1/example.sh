#!/bin/sh

mkdir -p ./sample.d

ijson=./sample.d/dummy-input.json
oder=./sample.d/dummy-output.asn1.der.dat

der2jer(){
	xxd -ps |
  tr -d '\n' |
  python3 \
    -m asn1tools \
    convert \
    -i der \
    -o jer \
    ./zipheader.asn \
    FileHeader \
    -
}

der2fq(){
  fq \
    -d asn1_ber
}

jq \
	-c \
	-n '{
    "name": "my_file.txt",
    "comment": "This is a test file",
    "method": 0,
    "modified": {
      "timestamp": {
        "rfc3339": {"_0":"2023-01-01T00:00:00Z"},
      },
    },
    "crc32": 1234567890,
    "compressedSize64": 100,
    "uncompressedSize64": 200
  }' |
  dd \
    if=/dev/stdin \
    of="${ijson}" \
    bs=1048576 \
    status=none

cat "${ijson}" |
	./ZipHeaderJsonToAsn1 |
  dd \
    if=/dev/stdin \
    of="${oder}" \
    bs=1048576 \
    status=none

echo file size comparison
ls \
  -l \
  "${ijson}" \
  "${oder}"

echo
echo gzipped json size comparison
echo fast
cat "${ijson}" | gzip --fast | wc -c
echo best
cat "${ijson}" | gzip --best | wc -c

echo
echo converting der to jer using asn1tools...
cat "${oder}" |
  der2jer
  #der2fq
