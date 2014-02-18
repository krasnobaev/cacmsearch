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
RELATIONS='relations.postings'
METRICS='metrics'

# Relevant Items Retrieved
RIR='relevant_items_retrieved'
# Relevant Items
REL=$RELATIONS'.sum'
# Retrieved Items
RET=$SERP_PREFIX'.sum'

#===  FUNCTION  ================================================================
# NAME : clean
# DESCRIPTION : cleaning generated files
#===============================================================================
function clean {
	read -p 'Clean index? ' -n 1 -r; printf '\n'
	if [[ -e $LUCENE_INDEX && ($REPLY =~ ^[Yy]$) ]]
	then
		rm "$LUCENE_INDEX/"*
	fi
	read -p 'Clean queries? ' -n 1 -r; printf '\n'
	if [[ -e $QUERIES && ($REPLY =~ ^[Yy]$) ]]
	then
		rm "$QUERIES"
	fi
	read -p 'Clean SERPs? ' -n 1 -r; printf '\n'
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rm "$SERP_PREFIX" "$SERP_PREFIX.top10" "$SERP_PREFIX.top100" \
			"$SERP_PREFIX.postings" "$SERP_PREFIX.top10.postings" \
			"$SERP_PREFIX.top100.postings"
	fi
	read -p 'Clean relations? ' -n 1 -r; printf '\n'
	if [[ -e $RELATIONS && ($REPLY =~ ^[Yy]$) ]]
	then
		rm "$RELATIONS"
	fi
	read -p 'Clean metrics? ' -n 1 -r; printf '\n'
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rm "$METRICS" "$RIR" "$RIR.top10" "$RIR.top100" "$REL" "$RET"
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
	QUERIES='queries'
	SERP_PREFIX='cacm.lucene.serp'

	# output folder/files
	# WORKFOLDER='~/git/cacmsearch'
	RELATIONS='relations.postings'
	METRICS='metrics'

	# Relevant Items Retrieved
	RIR='relevant_items_retrieved'
	# Relevant Items
	REL=$RELATIONS'.sum'
	# Retrieved Items
	RET=$SERP_PREFIX'.sum'
}

#===  FUNCTION  ================================================================
# NAME : f1
# DESCRIPTION : Indexing
#===============================================================================
function f1 {
	echo '1. Indexing from: ' $CACM_CORPUS ' to: ' $LUCENE_INDEX
	java org.apache.lucene.demo.IndexFiles -docs $CACM_CORPUS -index $LUCENE_INDEX

	read -p '1. Indexing completed. Continue? ' -n 1 -r; printf '\n'
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		exit 1
	fi
}

#===  FUNCTION  ================================================================
# NAME : f2
# DESCRIPTION : Query preparation
#===============================================================================
function f2 {
	echo '2. Query preparation'
	# 1. extract questions
	grep -Pzo "^[.]W(\n[^.][[:print:]]*)*" < $CACM_RAWQUERIES | \
	# 2. get rid of unnecessary line feeds and spaces
	awk '{gsub(/^ */,"",$1); printf "%s ", $0}' | \
	# 3. split one query per line
	awk '{ gsub(".W ", "\n") ; print $0 }' | \
	# 4. remove first line (it's empty) & line ending spaces
	awk '/./' | awk '{$1=$1}1' |
	# 5. remove syntactical errors
	awk '{
		gsub("/1;",   "\\/1)") ;
		gsub("\"\\?", "\"\\\?") ;
		gsub("*",     "\\*") ;
		gsub(":,",    "\",") ;
		gsub("/n",    "\\/n") ; print $0 }' > $QUERIES

	read -p '2. Query preparation completed. Continue? ' -n 1 -r; printf '\n'
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		exit 1
	fi
}

#===  FUNCTION  ================================================================
# NAME : f3
# DESCRIPTION : Retrieval running / SERP gathering
#===============================================================================
function f3 {
	echo '3. Retrieval running / SERP gathering'
	PARAMS="-index $LUCENE_INDEX -queries $QUERIES"
	## SERP 10
	java org.apache.lucene.demo.SearchFiles $PARAMS -paging 10 > $SERP_PREFIX.top10
	## SERP 100
	java org.apache.lucene.demo.SearchFiles $PARAMS -paging 100 > $SERP_PREFIX.top100
	## SERP all
	java org.apache.lucene.demo.SearchFiles $PARAMS -paging 4000 > $SERP_PREFIX

	read -p '3. SERPs collected. Continue? ' -n 1 -r; printf '\n'
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		exit 1
	fi
}

#===  FUNCTION  ================================================================
# NAME : f4
# DESCRIPTION : Data extraction from SERPs
#===============================================================================
function f4 {
	echo '4. Data extraction from SERPs'
	## 4.1. SERP refine
	awk '$2 ~ /total/ {printf $1" ";}
		$1 ~ /[[:digit:]]*\./ {gsub(/.*CACM-/, "");
		gsub(".html", " "); printf $0;}
		$1 ~ /Searching/ {printf "\n";}' < $SERP_PREFIX.top10 | \
		awk '/./' > $SERP_PREFIX.top10.postings

	awk '$2 ~ /total/ {printf $1" ";}
		$1 ~ /[[:digit:]]*\./ {gsub(/.*CACM-/, "");
		gsub(".html", " "); printf $0;}
		$1 ~ /Searching/ {printf "\n";}' < $SERP_PREFIX.top100 | \
		awk '/./' > $SERP_PREFIX.top100.postings

	awk '$2 ~ /total/ {printf $1" ";}
		$1 ~ /[[:digit:]]*\./ {gsub(/.*CACM-/, "");
		gsub(".html", " "); printf $0;}
		$1 ~ /Searching/ {printf "\n";}' < $SERP_PREFIX | \
		awk '/./' > $SERP_PREFIX.postings

	grep "total matching" $SERP_PREFIX | awk '{print $1}' > $RET

	read -p '4. Data extracted from SERPs. Continue? ' -n 1 -r; printf '\n'
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		exit 1
	fi
}

#===  FUNCTION  ================================================================
# NAME : f5
# DESCRIPTION : Relations preparing
#===============================================================================
function f5 {
	echo '5. Relations preparing'
	awk 'BEGIN {prev="";}
		prev !~ $1 {printf "\n"$1" ";}
		{printf $2" "; prev=$1;}' < $CACM_REL | \
	awk '/./' | \
	awk 'BEGIN {cnt=1;}
		{gsub("^0","");}
		{while (cnt<$1) {printf "\n";cnt++}}
		cnt ~ $1 {$1=""; print $0; cnt++;}' | \
	awk '{gsub("^ ",""); print;}' > $RELATIONS

	awk '{printf NF"\n"}' $RELATIONS > $REL

	read -p '5. Relations prepared. Continue? ' -n 1 -r; printf '\n'
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		exit 1
	fi
}

#===  FUNCTION  ================================================================
# NAME : f6
# DESCRIPTION : Results Comparing
#==============================================================================
function f6 {
	echo '6. Results comparing'

	# count number of intersected documents for each query
	for i in {1..64}; do
		cat <(head --lines=$i $SERP_PREFIX.top10.postings | \
				tail --lines=1 && \
			head --lines=$i $RELATIONS | \
				tail --lines=1) | \
		tr ' ' '\n' | awk /./ | sort | uniq -c | \
			grep " 2 " | wc -l;
	done > $RIR.top10

	for i in {1..64}; do
		cat <(head --lines=$i $SERP_PREFIX.top100.postings | \
				tail --lines=1 && \
			head --lines=$i $RELATIONS | \
				tail --lines=1) | \
		tr ' ' '\n' | awk /./ | sort | uniq -c | \
			grep " 2 " | wc -l;
	done > $RIR.top100

	for i in {1..64}; do
		cat <(head --lines=$i $SERP_PREFIX.postings | \
				tail --lines=1 && \
			head --lines=$i $RELATIONS | \
				tail --lines=1) | \
		tr ' ' '\n' | awk /./ | sort | uniq -c | \
			grep " 2 " | wc -l;
	done > $RIR

read -p '6. Results compared. Continue? ' -n 1 -r; printf '\n'
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		exit 1
	fi
}

#-------------------------------------------------------------------------------
# main()
#-------------------------------------------------------------------------------

f0

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

if [[ -e $LUCENE_INDEX/segments.gen ]]
then
	echo 'Index exists, skipping indexing'
else
	f1
fi

if [[ -s $QUERIES ]]
then
	echo 'Queries exist, query preparation skipping'
else
	f2
fi

if [[ -s $SERP_PREFIX && (-s $SERP_PREFIX.top10) && (-s $SERP_PREFIX.top100) ]]
then
	echo 'SERPs exist, SERP gathering skipping'
else
	f3
fi

if [[ -s $SERP_PREFIX.postings && (-s $SERP_PREFIX.postings) && (-s $SERP_PREFIX.postings) ]]
then
	echo 'SERP postings exist, SERP postings generation skipping'
else
	f4
fi

if [[ -s $RELATIONS ]]
then
	echo 'Relations exist, Relations postings generation skipping'
else
	f5
fi

f6

