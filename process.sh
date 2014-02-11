#!/bin/bash
#===============================================================================
# FILE : process.sh
# USAGE : ./process.sh
#
# DESCRIPTION : ---
#
# OPTIONS :---
# REQUIREMENTS :---
# AUTHOR : Aleksey Krasnobaev (https://github.com/krasnobaev)
# COMPANY : ---
# VERSION : 0.1 / 02/10/2014 10:38:53 PM MSK
# LICENSE : 
#===============================================================================

# Globals

# Corpora
# CACM1DIR='ftp://ftp.cs.cornell.edu/pub/smart/cacm/'
# CACM2='http://ir.dcs.gla.ac.uk/resources/test_collections/cacm/cacm.tar.gz'
# CACM2DIR='http://ir.dcs.gla.ac.uk/resources/test_collections/cacm/'
# CACM3='http://dg3rtljvitrle.cloudfront.net/cacm.tar.gz'
# CACM3DIR='http://www.search-engines-book.com/collections/'

# input
CACM_CORPUS='/usr/data/cacm/search-engines-book.com/cacm.html/'
CACM_RAWQUERIES='/usr/data/cacm/ftp.cs.cornell.edu/query.text'
CACM_REL='/usr/data/cacm/ftp.cs.cornell.edu/qrels.text'

# mediate folder/files
LUCENE_INDEX='/usr/data/index/lucene/cacm2/'
QUERIES='queries.txt'
SERP_PREFIX='cacm.lucene.serp'

# output folder/files
# WORKFOLDER='~/git/cacmsearch'
METRICS='metrics'

#===  FUNCTION  ================================================================
# NAME : clean
# DESCRIPTION : cleaning generated files
#===============================================================================
function clean {
	read -p 'Clean index? ' -n 1 -r; printf '\n'
	if [[ -e $LUCENE_INDEX && ($REPLY =~ ^[Yy]$) ]]
	then
		rm $LUCENE_INDEX/*
	fi
	read -p 'Clean queries? ' -n 1 -r; printf '\n'
	if [[ -e $QUERIES && ($REPLY =~ ^[Yy]$) ]]
	then
		rm $QUERIES
	fi
	read -p 'Clean SERPs? ' -n 1 -r; printf '\n'
	if [[ -e $SERP_PREFIX && ($REPLY =~ ^[Yy]$) ]]
	then
		rm $SERP_PREFIX*
	fi
	read -p 'Clean metrics? ' -n 1 -r; printf '\n'
	if [[ -e $METRICS && ($REPLY =~ ^[Yy]$) ]]
	then
		rm $METRICS
	fi
}

#===  FUNCTION  ================================================================
# NAME : f0
# DESCRIPTION : Environment check
#        System/Software Requirements/Dependencies
#        https://lucene.apache.org/core/4_0_0/demo/overview-summary.html#Setting_your_CLASSPATH
#        http://stackoverflow.com/questions/9329650/java-classpath-linux
#        .bashrc
#===============================================================================
function f0 {
	echo '0. Environment check'
#	JAVA_HOME=/usr/lib/jvm/default-java/
#	export JAVA_HOME	echo 'Current CLASSPATH: ' $CLASSPATH
#	CLASSPATH=$CLASSPATH:/usr/local/bin/lucene/core/lucene-core-4.6.1.jar
#	CLASSPATH=$CLASSPATH:/usr/local/bin/lucene/queryparser/lucene-queryparser-4.6.1.jar
#	CLASSPATH=$CLASSPATH:/usr/local/bin/lucene/demo/lucene-demo-4.6.1.jar
#	CLASSPATH=$CLASSPATH:/usr/local/bin/lucene/analysis/common/lucene-analyzers-common-4.6.1.jar
#	JAVA_HOME=/usr/lib/jvm/default-java/
	echo 'Following files must be contained in CLASSPATH:'
	echo '   lucene/core/lucene-core-4.6.1.jar'
	echo '   lucene/queryparser/lucene-queryparser-4.6.1.jar'
	echo '   lucene/demo/lucene-demo-4.6.1.jar'
	echo '   lucene/analysis/common/lucene-analyzers-common-4.6.1.jar'
#	export CLASSPATH
}

#===  FUNCTION  ================================================================
# NAME : f1
# DESCRIPTION : Indexing
#===============================================================================
function f1 {
	echo '1. Indexing'
	java org.apache.lucene.demo.IndexFiles -docs $CACM_CORPUS -index $LUCENE_INDEX
}

#===  FUNCTION  ================================================================
# NAME : f2
# DESCRIPTION : Query preparation
#===============================================================================
function f2 {
	echo '2. Query preparation'
	# 1. extract questions
	grep -Pzo "^[.]W(\n[^.][[:print:]]*)*" < $CACM_RAWQUERIES | \
	# 2. get rid of unnecessary line feeds
	tr '\n' ' ' | \
	# 3. split one query per line
	awk '{ gsub(".W ", "\n") ; print $0 }' | \
	# 4. remove double spaces and save results
	awk '{ gsub(/^ */,"",$1) ; print $0 }' > $QUERIES
	
	# 5. removing some syntactical errors
	awk '{ gsub("", "") ; print $0 }' $QUERIES
}

#===  FUNCTION  ================================================================
# NAME : f3
# DESCRIPTION : Retrieval running / SERP gathering
#===============================================================================
function f3 {
	echo '3. Retrieval running / SERP gathering'
	PARAMS='-index '$LUCENE_INDEX' -queries $QUERIES'
	## SERP 10
	java org.apache.lucene.demo.SearchFiles $PARAMS -paging 10 > $SERP_PREFIX.top10
	## SERP 100
	java org.apache.lucene.demo.SearchFiles $PARAMS -paging 100 > $SERP_PREFIX.top100
	## SERP all
	java org.apache.lucene.demo.SearchFiles $PARAMS -paging 4000 > $SERP_PREFIX
}

#===  FUNCTION  ================================================================
# NAME : f4
# DESCRIPTION : Data extraction from SERPs
#===============================================================================
function f4 {
	echo '4. Data extraction from SERPs'
	## 4.1. SERP refine
	awk 'BEGIN {cnt=0;}
		$1 ~ /Searching/ {cnt++;}
		$1 !~ /Searching/ && $2 !~ /total/ {
			gsub(". $CACM_CORPUS", "; ");
			gsub(".html", "; ");
			print cnt"; "$0}' < $SERP_PREFIX.top10 > $SERP_PREFIX.top10.refined

	awk 'BEGIN {cnt=0;}
		$1 ~ /Searching/ {cnt++;}
		$1 !~ /Searching/ && $2 !~ /total/ {
			gsub(". $CACM_CORPUS", "; ");
			gsub(".html", "; ");
			print cnt"; "$0}' < $SERP_PREFIX.top100 > $SERP_PREFIX.top100.refined

	awk 'BEGIN {cnt=0;}
		$1 ~ /Searching/ {cnt++;}
		$1 !~ /Searching/ && $2 !~ /total/ {
			gsub(". $CACM_CORPUS", "; ");
			gsub(".html", "; ");
			print cnt"; "$0}' < $SERP_PREFIX > "$SERP_PREFIX".refined

	tr ';' ' ' < $SERP_PREFIX.refined | \
		awk 'BEGIN {cnt=0;}
			$1 ~ cnt {printf substr($3,6,4) " "}
			$1 > cnt {cnt++;print "\n"}' > $SERP_PREFIX.postings
}

#===  FUNCTION  ================================================================
# NAME : f5
# DESCRIPTION : Metrics Calculation
#===============================================================================
function f5 {
	echo '5. Metrics Calculation'
	## 1. calc Relevant items
	awk 'BEGIN {cnt=0;}
		$1 ~ /Searching/ {cnt++;}
		$1 !~ /Searching/ && $2 !~ /total/ {
			gsub(". $CACM_CORPUS", "; ");
			gsub(".html", "; ");
			print cnt"; "$0}' < $CACM_REL > $METRICS
	## 2. 
	awk 'BEGIN {cnt=0;}
		$1 ~ /Searching/ {cnt++;}
		$1 !~ /Searching/ && $2 !~ /total/ {
			gsub(". $CACM_CORPUS", "; ");
			gsub(".html", "; ");
			print cnt"; "$0}' < $SERP_PREFIX.top10 &> $METRICS
}

#===  FUNCTION  ================================================================
# NAME : f6
# DESCRIPTION : Results Comparing
#==============================================================================
function f6 {
	echo '6. Results comparing'
	true;
}

#-------------------------------------------------------------------------------
# main()
#-------------------------------------------------------------------------------
while getopts ":c" o; do
	case "$o" in
	c)
		echo 'Cleaning out . . .' >&2
		clean
		exit 0
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	esac
done

f0

if [[ -e $LUCENE_INDEX/segments.gen ]]
then
	echo 'Index exists, skipping indexing'
else
	echo 'Indexing from: ' $CACM_CORPUS ' to: ' $LUCENE_INDEX
	f1
fi
f2
f3
f4
f5
f6

