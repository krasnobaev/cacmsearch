#!/bin/bash

# Query preparation:
# 1. extract questions
grep -Pzo "^[.]W(\n[^.][[:print:]]*)*" < ~/data/cacm/ir.dcs.gla.ac.uk/query.text | \
# 2. get rid of unnecessary line feeds
tr '\n' ' ' | \
# 3. split one query per line
awk '{ gsub(".W ", "\n") ; print $0 }' | \
# 4. remove double spaces and save results
awk '{ gsub(/^ */,"",$1) ; print $0 }' > ~/git/cacmsearch/queries.txt

#Base metrics calculation
## 1. calc Relevant items
$ awk 'BEGIN {cnt=0;}
	$1 ~ /Searching/ {cnt++;}
	$1 !~ /Searching/ && $2 !~ /total/ {
		gsub(". /usr/data/CACM/search-engines-book.com/cacm.html/", "; ");
		gsub(".html", "; ");
		print cnt"; "$0
	}' < cacm.rel > base_metrics.txt

## 2. 
$ awk 'BEGIN {cnt=0;}
	$1 ~ /Searching/ {cnt++;}
	$1 !~ /Searching/ && $2 !~ /total/ {
		gsub(". /usr/data/CACM/search-engines-book.com/cacm.html/", "; ");
		gsub(".html", "; ");
		print cnt"; "$0
	}' < serp_top10.txt &> base_metrics.txt


