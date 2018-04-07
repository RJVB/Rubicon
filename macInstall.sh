#!/bin/bash
################################################################################
#     PROJECT: Rubicon
#    FILENAME: macInstall.sh
#         IDE: AppCode
#      AUTHOR: Galen Rhodes
#        DATE: 6/15/17 9:39 AM
# DESCRIPTION: Bash Script
#
# Copyright (c) 2017 Galen Rhodes. All rights reserved.
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
#################################################################################

PDIR=$(dirname $(readlink -f "$0"))
PROJECT=`find "${PDIR}" -name "*.xcodeproj" -exec basename -s .xcodeproj {} \;`
DSTROOT="${HOME}"
INSTALL_PATH="Library/Frameworks"
FULL_FINAL_PATH="${DSTROOT}/${INSTALL_PATH}/${PROJECT}.framework"

echo "      Project Directory: \"${PDIR}\""
echo "           Project Name: \"${PROJECT}\""
echo "                DSTROOT: \"${DSTROOT}\""
echo "Frameworks Install Path: \"${DSTROOT}/${INSTALL_PATH}\""

rm -fr "${FULL_FINAL_PATH}"

xcodebuild -project "${PROJECT}.xcodeproj" -target "${PROJECT}" -configuration Release \
    clean build install DSTROOT="${DSTROOT}/" INSTALL_PATH="/${INSTALL_PATH}" SKIP_INSTALL=No \
    > "${PDIR}/Build.log"

res="$?"
ls -alhG "${FULL_FINAL_PATH}/Headers/"
exit "${res}"
