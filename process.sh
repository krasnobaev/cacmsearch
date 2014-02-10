#!/bin/bash

## System/Software Requirements/Dependencies

https://lucene.apache.org/core/4_0_0/demo/overview-summary.html#Setting_your_CLASSPATH
http://stackoverflow.com/questions/9329650/java-classpath-linux
.bashrc:
$ echo $CLASSPATH
/opt/lucene/core/lucene-core-4.6.1.jar:/opt/lucene/queryparser/lucene-queryparser-4.6.1.jar:/opt/lucene/demo/lucene-demo-4.6.1.jar:/opt/lucene/analysis/common/lucene-analyzers-common-4.6.1.jar
export CLASSPATH
JAVA_HOME=/usr/lib/jvm/default-java/
export JAVA_HOME

# Query preparation:
# 1. extract questions
grep -Pzo "^[.]W(\n[^.][[:print:]]*)*" < ~/data/cacm/ir.dcs.gla.ac.uk/query.text | \
# 2. get rid of unnecessary line feeds
tr '\n' ' ' | \
# 3. split one query per line
awk '{ gsub(".W ", "\n") ; print $0 }' | \
# 4. remove double spaces and save results
awk '{ gsub(/^ */,"",$1) ; print $0 }' > ~/git/cacmsearch/queries.txt

# 1. Indexing
## Corpora: ~/data/cacm/search-engines-book.com/cacm.html/
$ java org.apache.lucene.demo.IndexFiles -docs ~/data/cacm/search-engines-book.com/cacm.html/ -index ~/data/index/lucene/cacm2/

# 2. Query construstion
## 2.1. extract questions
grep -Pzo "^[.]W(\n[^.][[:print:]]*)*" < ~/data/cacm/ir.dcs.gla.ac.uk/query.text | \
## 2.2. get rid of unnecessary line feeds
tr '\n' ' ' | \
## 2.3. split one query per line
awk '{ gsub(".W ", "\n") ; print $0 }' | \
## 2.4. remove double spaces and save results
awk '{ gsub(/^ */,"",$1) ; print $0 }' > queries.txt
## 2.5. removing some sysntactical parcing errors by hand
gvim cacm.queries > cacm.queries

# 3. Retrieval running / SERP catching
## SERP 10
java org.apache.lucene.demo.SearchFiles -index ~/data/index/lucene/cacm2/index -queries queries2.txt -paging 10 > cacm.lucene.serp.top10
## SERP 100
java org.apache.lucene.demo.SearchFiles -index ~/data/index/lucene/cacm2/index -queries queries2.txt -paging 100 > cacm.lucene.serp.top100
## SERP all
java org.apache.lucene.demo.SearchFiles -index ~/data/index/lucene/cacm2/index -queries queries2.txt -paging 4000 > cacm.lucene.serp

# 4. Rel preparations
## 4.1. SERP refine
$ awk 'BEGIN {cnt=0;}
	$1 ~ /Searching/ {cnt++;}
	$1 !~ /Searching/ && $2 !~ /total/ {
		gsub(". /usr/data/CACM/search-engines-book.com/cacm.html/", "; ");
		gsub(".html", "; ");
		print cnt"; "$0
	}' < cacm.lucene.serp.top10 > cacm.lucene.serp.top10
$ awk 'BEGIN {cnt=0;}
	$1 ~ /Searching/ {cnt++;}
	$1 !~ /Searching/ && $2 !~ /total/ {
		gsub(". /usr/data/CACM/search-engines-book.com/cacm.html/", "; ");
		gsub(".html", "; ");
		print cnt"; "$0
	}' < cacm.lucene.serp.top100 > cacm.lucene.serp.top100
$ awk 'BEGIN {cnt=0;}
	$1 ~ /Searching/ {cnt++;}
	$1 !~ /Searching/ && $2 !~ /total/ {
		gsub(". /usr/data/CACM/search-engines-book.com/cacm.html/", "; ");
		gsub(".html", "; ");
		print cnt"; "$0
	}' < cacm.lucene.serp > cacm.lucene.serp

$ tr ';' ' ' < cacm.lucene.serp.refined | awk 'BEGIN {cnt=0;} $1 ~ cnt {printf substr($3,6,4) " "} $1 > cnt {cnt++;print '\n'}' > cacm.lucene.serp.postings

# 5. Results/metrics calculation
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

# 6. Results comparing
$ 

