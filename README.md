# zen4R

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
```

* Update my record on Zenodo deposit

```r
zenodo$depositRecord(myrec)
```
