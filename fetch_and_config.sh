#!/bin/bash
###########################################################################
#    FILENAME: fetch_and_config.sh
#         IDE: AppCode
#      AUTHOR: Galen Rhodes
#        DATE: 7/26/16 4:27 PM
# DESCRIPTION: Bash Script
#
# Copyright (c) 2016 Project Galen. All rights reserved.
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
###########################################################################

BUILD_AFTER="N"
INSTALL_AFTER="N"

while [ "$#" -gt 0 ]; do
	case "$1" in
		"-b") BUILD_AFTER="Y";;
		"-i") BUILD_AFTER="Y"; INSTALL_AFTER="Y";;
		*) echo "Ignoring unknown argument \"$1\".";;
	esac
	shift
done

PDIR=$(dirname $(readlink -f "$0"))
PROJECT=`find "${PDIR}" -name "*.xcodeproj" -exec basename -s .xcodeproj {} \;`

if [ -n "${PROJECT}" ]; then
	_target="${HOME}/Projects/${PROJECT}"
	_source="grhodes@homer:Projects/${PROJECT}"
	rsync -avz --delete-before "${_source}/" "${_target}/" || exit "$?"
else
	echo "No project specified.  Nothing to do."
	exit 1
fi

if [ "${BUILD_AFTER}" = "Y" ]; then
	_buildd="${_target}/build"
	if [ -d "${_buildd}" ]; then
		sudo rm -fr "${_buildd}" 2>/dev/null
	fi
	mkdir -p "${_buildd}" || exit "$?"
	cd "${_buildd}"
	cmake -G "Unix Makefiles" -Wno-dev \
		-DCMAKE_BUILD_TYPE="Release" \
		-DCMAKE_LINKER="/usr/bin/ld.gold" \
		-DCMAKE_C_FLAGS_RELEASE="-Ofast -g0 -w" \
		-DCMAKE_CXX_FLAGS_RELEASE="-Ofast -g0 -w" \
		"${_target}" || exit "$?"
	make -j${PROCESSORS} || exit "$?"

	if [ "${INSTALL_AFTER}" = "Y" ]; then
		sudo -E make install || exit "$?"
	fi
fi

exit 0
