#!/usr/bin/env bash
# Purpose: upload directory/files to Azur
# Author: Narendranath Panda

_dir="$1" # Parent directory

# die if $_dir not found
[ $# -eq 0 ] && { echo "Usage: $0 dirname storage_account sas_token "; exit 1; }


# Get base and dir names from arg
_dn="$(dirname $_dir)"
_bn="$(basename $_dir)"


storageaccount=$2 # Give Storage account
sas_token=$3 # Give SAS token

rm -rf dir.txt
rm -rf files.txt


# Let us get started
if [ -d "$_dir" -o -e "$_dir" ]
then
  echo "Check file inside $_dir"
  ls  "$_dir" >dir.txt
fi

while read -r line;
do
 echo "$_bn/$line $_dn/$_bn/$line" >>files.txt ;
done < dir.txt

while read -r line;
do
  echo ${line}
  uPath=$(echo -n ${line} | awk '{printf $1}')
  lPath=$(echo -n ${line} | awk '{printf $2}')
# For directories
  if [ -d "${lPath}" ]; then
      ls "${lPath}" 2>/dev/null | while read -r fileName ; do
        echo curl -X PUT -T ${lPath}/${fileName} -H "x-ms-date: $(date -u)" -H "x-ms-blob-type: BlockBlob" "https://{storageaccount}.blob.core.windows.net/backups/${uPath}/${fileName}?{sas_token}"
      done
  fi

echo
# For files
  if [ -f "${lPath}" ]; then
    _fbn=$(basename $lPath)
    echo curl -X PUT -T ${lPath} -H "x-ms-date: $(date -u)" -H "x-ms-blob-type: BlockBlob" "https://{storageaccount}.blob.core.windows.net/backups/${uPath}/${_fbn}?{sas_token}"
  fi

echo

done < files.txt
