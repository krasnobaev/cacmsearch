#!/bin/bash

# Introduction

## Status
In work

## Software used
Search engine - Apache Lucene (Java)
Calculations - Octave
Data Extraction - awk, grep, tr
Environment - bash, ubuntu/linux
Supplementary - gvim/vim or smilar

## System/Software Requirements/Dependencies
$ echo $CLASSPATH
/opt/lucene/core/lucene-core-4.6.1.jar:/opt/lucene/queryparser/lucene-queryparser-4.6.1.jar:/opt/lucene/demo/lucene-demo-4.6.1.jar:/opt/lucene/analysis/common/lucene-analyzers-common-4.6.1.jar

## Environment
$ ls | sort
README							
stub.sh 						

cacm.queries 					
cacm.queries.refined 			

cacm.lucene.serp 				
cacm.lucene.serp.refined 		
cacm.lucene.serp.top100 		
cacm.lucene.serp.top10 			
cacm.lucene.serp.top100refined 	
cacm.lucene.serp.top10refined 	

cacm.lucene.serp.postings 		

## Lucene base usage
$ java org.apache.lucene.demo.IndexFiles --help
Usage: java org.apache.lucene.demo.IndexFiles [-index INDEX_PATH] [-docs DOCS_PATH] [-update]

This indexes the documents in DOCS_PATH, creating a Lucene indexin INDEX_PATH that can be searched with SearchFiles
$ java org.apache.lucene.demo.SearchFiles --help
Usage: java org.apache.lucene.demo.SearchFiles [-index dir] [-field f] [-repeat n] [-queries file] [-query string] [-raw] [-paging hitsPerPage]

cd ~/git/cacmsearch/

# 1. Indexing
## Corpora: ~/data/cacm/search-engines-book.com/cacm.html/
$ java org.apache.lucene.demo.IndexFiles -docs ~/data/cacm/search-engines-book.com/cacm.html/ -index ~/data/index/lucene/cacm2/

# 2. Query construstion
Some examples:
Q1: What articles exist which deal with TSS (Time Sharing System), an operating system for IBM computers?
Q2: I am interested in articles written either by Prieve or Udo Pooch
Q3: Intermediate languages used in construction of multi-targeted compilers; TCOLL
Q4: I'm interested in mechanisms for communicating between disjoint processes, possibly, but not exclusively, in a distributed environment.  I would rather see descriptions of complete mechanisms, with or without implementations, as opposed to theoretical work on the abstract problem.  Remote procedure calls and message-passing are examples of my interests.

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

# 5. Results calculations


# 6. Results comparing
$ 


