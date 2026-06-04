#!/bin/bash
# SPDX-License-Identifier: Unlicense

set -xeu

URL='https://www.motor-comm.com/Cn/Skippower/downloadFile.html?id=1817'

rm -vf ./*.tar.gz ./*.zip ./*.b2sum src/ || true
find . -mindepth 1 -maxdepth 1 -name '*.sh' -a \! -name 'import.sh' -delete
wget --content-disposition "$URL"

count=0
for f in yt6801-linux-driver-*.zip; do
	if [ -f "$f" ]; then
		ver_part="${f#yt6801-linux-driver-}"
		ver_part="${ver_part%.zip}"

		if ! echo "$ver_part" | grep -Eq '^[0-9]+(\.[0-9]+)*$'; then
			continue
		fi

		zip_file="$f"
		version="$ver_part"
		count=$((count + 1))
	fi
done

if [ "$count" -ne 1 ]; then
	echo "Error: Expected exactly 1 matching zip file, found $count." >&2
	exit 1
fi

unzip "$zip_file"

b2sum "$zip_file" >"$zip_file".b2sum

tar_file="yt6801-$version.tar.gz"

if [ ! -f "$tar_file" ]; then
	echo "Error: Expected tarball '$tar_file' was not found after unzipping." >&2
	exit 1
fi

mkdir -p src
tar xvf "$tar_file" -C src
