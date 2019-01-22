# zen4R

[![Build Status](https://travis-ci.org/eblondel/zen4R.svg?branch=master)](https://travis-ci.org/eblondel/zen4R)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/zen4R)](https://cran.r-project.org/package=zen4R)
[![Github_Status_Badge](https://img.shields.io/badge/Github-0.1-blue.svg)](https://github.com/eblondel/zen4R)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2547036.svg)](https://doi.org/10.5281/zenodo.2547036)

R Interface to Zenodo REST API

## How to

* Install and Load ``zen4R``

```r
require(devtools)
install_github("eblondel/zen4R")
require(zen4R)
```

* Connect to Zenodo

```r
zenodo <- ZenodoManager$new(access_token = <your_token>, logger = "DEBUG")
```

* Create an empty Zenodo record on Zenodo deposit

```r
myrec <- zenodo$createEmptyRecord()
```

* Fill my record

```r
myrec$setTitle("My publication title")
myrec$setDescription("A description of my publication")
myrec$setUploadType("publication")
myrec$setPublicationType("article")
myrec$addCreator(firstname = "John", lastname = "Doe", affiliation = "Independent")
myrec$setLicense("mit")
```

* Update my record on Zenodo deposit

```r
zenodo$depositRecord(myrec)
```

There is no need to create an empty record with the function ``$createEmptyRecord()``
first on Zenodo and then fill it. You can create a record with ``ZenodoRecord$new()``,
fill it and then deposit it directly using the function ``$depositRecord(record)``.

* Upload a file

```r
zenodo$uploadFile("path_to_my_file", myrec$id) #upload a file
myrec_files <- zenodo$getFiles(myrec$id) #list files for the deposited record
```

* Publish a deposited record straigh online on Zenodo

Once the deposited record is fine for its publication online on Zenodo, you can publish it:

```r
zenodo$publishRecord(myrec$id)
```

The method ``depositRecord`` handles a shortcut to publish directly the record specifying ``publish = TRUE`` (default is ``FALSE``):

```r
zenodo$depositRecord(myrec, publish = TRUE)
```

This shortcut is to use with cautious, as this will publish straight online your record on Zenodo.
