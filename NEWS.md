## **_0.4-2_**

**Improvements**

*[#42](https://github.com/eblondel/zen4R/issues/42) Use parallel package as suggests
*[#45](https://github.com/eblondel/zen4R/issues/45) Make ZenodoManager anonymous (token-less) calls keyring-free

## **_0.4-1_**

**Improvements**

*[#41](https://github.com/eblondel/zen4R/issues/41) Make ZenodoManager raise an error if token is invalid

## **_0.4_**

**New features**

* [#26](https://github.com/eblondel/zen4R/issues/26) addCreator: allow to specify name, rather than firstname/lastname
* [#30](https://github.com/eblondel/zen4R/issues/30) simple way to supply token from envvar with ``zenodo_pat()``
* [#31](https://github.com/eblondel/zen4R/issues/31) Methods to list/download files from Zenodo record + wrapper
* [#33](https://github.com/eblondel/zen4R/issues/33) Secure API token with 'keyring'
* [#34](https://github.com/eblondel/zen4R/issues/34) Add wrapper function to get versions of a Zenodo record

**Improvements**

* [#32](https://github.com/eblondel/zen4R/issues/32) Remove dependency with rvest package (not stricly needed)
* [#36](https://github.com/eblondel/zen4R/issues/36) Small updates to the zen4R wiki

**Corrections**

* [#27](https://github.com/eblondel/zen4R/issues/27) Fix bugs in addCommunity 
* [#28](https://github.com/eblondel/zen4R/issues/28) Fix search by concept DOI
* [#38](https://github.com/eblondel/zen4R/issues/38) download_zenodo() issue with md5sum
* [#39](https://github.com/eblondel/zen4R/issues/39) getDepositionByConceptDOI / getRecordByConceptDOI doesn't return latest record

## **_0.3_**

**New features**

* [#23](https://github.com/eblondel/zen4R/issues/23) Methods to search published records (other than own depositions)

**Corrections**

* [#24](https://github.com/eblondel/zen4R/issues/24) Exact search/matching with concept DOI doesn't work

## **_0.2_**

**New features**

* [#7](https://github.com/eblondel/zen4R/issues/7) Function to get for a record the citation for a given format
* [#8](https://github.com/eblondel/zen4R/issues/8) Support function to create and list record version(s)
* [#10](https://github.com/eblondel/zen4R/issues/10) Add method to get concept DOI (generic DOI)
* [#11](https://github.com/eblondel/zen4R/issues/11) Support adding/removing references
* [#12](https://github.com/eblondel/zen4R/issues/12) Methods for journal metadata elements
* [#13](https://github.com/eblondel/zen4R/issues/13) Methods for conference metadata elements
* [#14](https://github.com/eblondel/zen4R/issues/14) Methods for 'imprint' metadata elements
* [#15](https://github.com/eblondel/zen4R/issues/15) Methods for 'partof' (book/chapter) metadata elements
* [#16](https://github.com/eblondel/zen4R/issues/16) Methods for 'thesis' metadata elements
* [#17](https://github.com/eblondel/zen4R/issues/17) Methods for 'grants' metadata elements + list supported grants/funders
* [#18](https://github.com/eblondel/zen4R/issues/18) Method for 'contributor' metadata elements
* [#20](https://github.com/eblondel/zen4R/issues/20) Enable methods to get deposition by DOI / concept DOI
* [#21](https://github.com/eblondel/zen4R/issues/21) Support edit operation for already submitted records
* [#22](https://github.com/eblondel/zen4R/issues/22) Add method to discard record changes

**Improvements**

* [#19](https://github.com/eblondel/zen4R/issues/19) Enable query 'q' Elasticsearch parameter in getDepositions / deleteRecords

**Corrections**

* [#4](https://github.com/eblondel/zen4R/issues/4) deleteRecords returns an error 
* [#5](https://github.com/eblondel/zen4R/issues/5) getDepositions returns always 10 records
* [#9](https://github.com/eblondel/zen4R/issues/9) uploadType "other" is not managed by setUploadType

**Miscs**

_No issues_

## **_0.1_**

First version
