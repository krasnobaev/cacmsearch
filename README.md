# Introduction

## Status
Latest release - v0.2

### Supported Search Engines
	* org.apache.lucene.demo.IndexFiles (Apache Lucene)

### Supported corpora
	* CACM

## Internals

### Dependencies
Calculations - trec_eval (v9.0), octave
Data Extraction - awk, grep, tr
Environment - bash, ubuntu/linux
Supplementary - gvim/vim or smilar

### Usage
./process [-ac]
-a - Yes on each prompt
-c - clean files

### Output
<Corpora>.<Search Engine>.metrics.csv - 
<Corpora>.<Search Engine>.results.* - 
<Corpora>.<Search Engine>.returned.* - 
<Corpora>.<Search Engine>.serp - 
<Corpora>.queries - 
<Corpora>.relevant - 

### Process

#### 1. Indexing

#### 2. Query preparation

#### 3. Retrieval running / SERP catching

#### 4. Data extraction from SERPs

#### 5. Relations preparing

#### 6. Results comparing

