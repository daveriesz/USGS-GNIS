#!/bin/bash

url="https://www.usgs.gov/core-science-systems/ngp/board-on-geographic-names/download-gnis-data"

curl "$url" \
| sed "s/{/fetch_left_bracket/g;;s/}/fetch_right_bracket/g" \
| sed "s/</{</g;;s/>/>}/g" \
| tr "{}" "\n\n" \
| sed "s/fetch_left_bracket/{/g;;s/fetch_right_bracket/}/g" \
| egrep -i "^<a href=\"https://geonames.usgs.gov/" \
| sed "s/^.*href=\"\([^\"]*\)\".*$/\1/g" \
| egrep -v "/index.html$" \
| while read suburl ; do
  outdir=`echo $suburl | sed "s,^https://\(.*\)/\([^/][^/]*\)$,dl/\1,g"`
  outfile=`echo $suburl | sed "s,^https://\(.*\)/\([^/][^/]*\)$,\2,g"`

  if [ ! -d "$outdir" ] ; then mkdir -p "$outdir" ; fi
  if [ -f zip/$outfile ] ; then
    echo "COPYING  $outdir/$outfile"
    mv zip/$outfile $outdir
  fi
  if [ ! -f $outdir/$outfile ] ; then
    echo "FETCHING $outdir/$outfile"
    curl -o $outdir/$outfile $suburl
  else
    echo "SKIPPING $outdir/$outfile"
  fi
done

