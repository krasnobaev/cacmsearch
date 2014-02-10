# Introduction

## Status
In work

## Software/Data used / Licensing
Search engine - Apache Lucene (Java)
Calculations - Octave
Data Extraction - awk, grep, tr
Environment - bash, ubuntu/linux
Supplementary - gvim/vim or smilar

cacm corpora

## Environment
$ ls | sortcacm.*

README							
process.sh 						

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

# 4. Rel preparations
## 4.1. SERP refine

# 5. Results calculations


# 6. Results comparing
$ 


