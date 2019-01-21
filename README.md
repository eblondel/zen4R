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
