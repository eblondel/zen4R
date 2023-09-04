# Change log

## [zen4R 0.9](https://github.com/eblondel/zen4R) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/package=zen4R)

**New features**

* [#121](https://github.com/eblondel/zen4R/issues/121) Get Zenodo record views/downloads statistics
* [#122](https://github.com/eblondel/zen4R/issues/122) Support `get_zenodo` shortcut method to get a Zenodo Record

**Enhancements**

* [#95](https://github.com/eblondel/zen4R/issues/95) Support progress when uploading files
* [#114](https://github.com/eblondel/zen4R/issues/114) Avoid re-downloading existing files
* [#117](https://github.com/eblondel/zen4R/issues/117) Support single (organisation) name argument in `addContributor`
* [#119](https://github.com/eblondel/zen4R/issues/119) Support sandbox argument for ZenodoManager for easy use
* [#118](https://github.com/eblondel/zen4R/issues/118) Support sandbox-based controls for license, grant, community management methods
* [#123](https://github.com/eblondel/zen4R/issues/123) Support curl fetch for Zenodo records to inherit stats directly
* [#124](https://github.com/eblondel/zen4R/issues/124) Align files listing / download on new method to fetch records
* [#126](https://github.com/eblondel/zen4R/issues/126) Make field `sandbox` public

**Bug fixes**

* [#125](https://github.com/eblondel/zen4R/issues/125) Ensure null stats with deposition decoding (regression that relates to #123)

## [zen4R 0.8](https://cran.r-project.org/package=zen4R) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/package=zen4R)

**Enhancements**

* [#106](https://github.com/eblondel/zen4R/issues/106) Quote DOIs in deposit/record search methods
* [#108](https://github.com/eblondel/zen4R/issues/108) `getFunders` additional `q` Elastic search argument
* [#109](https://github.com/eblondel/zen4R/issues/109) `getGrants` additional `q` Elastic search argument

**New features**

* [#110](https://github.com/eblondel/zen4R/issues/110) `getFundersByName` new method
* [#111](https://github.com/eblondel/zen4R/issues/111) `getGrantsByName` new method

## [zen4R 0.7-1](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.7-1.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.7-1.tar.gz)

**Bug fixes**

* [#98](https://github.com/eblondel/zen4R/issues/98) User-Agent related issue with `getRecordByDOI` - relates to #103
* [#102](https://github.com/eblondel/zen4R/issues/102) User-Agent related issue with `download_zenodo` - relates to #103
* [#103](https://github.com/eblondel/zen4R/issues/103) Change User-Agent to bypass Zenodo API server restrictions

## [zen4R 0.7](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.7.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.7.tar.gz)

**Bug fixes**

* [#84](https://github.com/eblondel/zen4R/issues/84) Error 500 with GET requests (Change in Zenodo server) -> Support `User-Agent` header

**New features**

* [#77](https://github.com/eblondel/zen4R/issues/77) Support `locations` metadata (not clear yet if actually supported by Zenodo UI)

**Enhancements**

* [#90](https://github.com/eblondel/zen4R/issues/90) Support optional `resource_type` for related identifiers
* [#91](https://github.com/eblondel/zen4R/issues/91) Add missing relations (for related identifiers) supported by Zenodo API
* [#92](https://github.com/eblondel/zen4R/issues/92) Add missing upload types supported by Zenodo API
* [#93](https://github.com/eblondel/zen4R/issues/93) Add missing publication types supported by Zenodo API

**Documentation**

* [#97](https://github.com/eblondel/zen4R/issues/97) Upgrade roxygen2 7.2.1 to fix html issues

## [zen4R 0.6-1](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.6-1.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.6-1.tar.gz)

**Bug fixes**

* [#76](https://github.com/eblondel/zen4R/issues/76) getDepositionByDOI() errors when Zenodo returns a 404 (due Zenodo reverting new path mentioned in #[#72](https://github.com/eblondel/zen4R/issues/72))


## [zen4R 0.6](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.6.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.6.tar.gz)

**New features**

* [#66](https://github.com/eblondel/zen4R/issues/66) Add record custom print method supporting various formats (internal + Zenodo supported export formats)
* [#71](https://github.com/eblondel/zen4R/issues/71) Add `export_zenodo` function 
* [#73](https://github.com/eblondel/zen4R/issues/73) Add mapping from published ZenodoRecord to [atom4R](https://github.com/eblondel/atom4R) DCEntry
* [#74](https://github.com/eblondel/zen4R/issues/74) Package github-pages with pkgdown

**Enhancements**

* [#72](https://github.com/eblondel/zen4R/issues/72) Zenodo has new path for GET request --> avoid permanent redirect done by Zenodo

**Bug fixes**

* [#70](https://github.com/eblondel/zen4R/issues/70) Fix setEmbargoDate record method
* [#74](https://github.com/eblondel/zen4R/issues/75) getRecords ElasticSearch query returns error if it includes spaces

## [zen4R 0.5-3](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.5-3.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.5-3.tar.gz)


**Enhancements**

* [#65](https://github.com/eblondel/zen4R/issues/65) Better handling of record versions
* [#67](https://github.com/eblondel/zen4R/issues/67) Rate limit for deleting files
* [#68](https://github.com/eblondel/zen4R/issues/68) Standardize R6-class R documentation


## [zen4R 0.5-2](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.5-2.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.5-2.tar.gz)

**Bug fixes**

* [#62](https://github.com/eblondel/zen4R/issues/62) Fix new file upload API - wrong filename spliting
* [#63](https://github.com/eblondel/zen4R/issues/63) Fix new file upload API - case with filename with spaces
* [#64](https://github.com/eblondel/zen4R/issues/64) Fix new file upload API - actual file upload

## [zen4R 0.5-1](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.5-1.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.5-1.tar.gz)

**Bug fixes**

* [#57](https://github.com/eblondel/zen4R/issues/57) Fix code cleaning in getDepositionById
* [#58](https://github.com/eblondel/zen4R/pull/58) Fix getDepositionByConceptDOI method
* [#60](https://github.com/eblondel/zen4R/issues/60) Fix old file upload API

## [zen4R 0.5](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.5.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.5.tar.gz)

**New features**

* [#50](https://github.com/eblondel/zen4R/issues/50) Allow to download record files subset
* [#53](https://github.com/eblondel/zen4R/issues/53) Support upload of large files via new Zenodo upload API
* [#56](https://github.com/eblondel/zen4R/issues/56) Consolidate deposit versioning & getVersions function

**Improvements**

* Set-up of Github actions CI for testing `zen4R` package
* [#42](https://github.com/eblondel/zen4R/issues/42) Use parallel package as suggests
* [#45](https://github.com/eblondel/zen4R/issues/45) Make ZenodoManager anonymous (token-less) calls keyring-free
* [#46](https://github.com/eblondel/zen4R/issues/46) Upgrade record getVersions to fit Zenodo html changes
* [#54](https://github.com/eblondel/zen4R/issues/54) Improve keyring backend use: keyring 'env' backend by default, changeable by user

**Bug fixes**

* [#47](https://github.com/eblondel/zen4R/issues/47) Fix record `addRelatedIdentifier` method
* [#54](https://github.com/eblondel/zen4R/issues/54) Folowwing keyring >= 1.2.0 - system password requested for Unix systems

**Documentation**

* [#48](https://github.com/eblondel/zen4R/issues/48) Document download features in wiki + refine package description
* [#49](https://github.com/eblondel/zen4R/issues/49) Add information on installation for Linux/OSX to documentation

## [zen4R 0.4-1](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.4-1.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.4-1.tar.gz)

**Improvements**

*[#41](https://github.com/eblondel/zen4R/issues/41) Make ZenodoManager raise an error if token is invalid

## [zen4R 0.4](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.4.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.4.tar.gz)

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

## [zen4R 0.3](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.3.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.3.tar.gz)

**New features**

* [#23](https://github.com/eblondel/zen4R/issues/23) Methods to search published records (other than own depositions)

**Corrections**

* [#24](https://github.com/eblondel/zen4R/issues/24) Exact search/matching with concept DOI doesn't work

## [zen4R 0.2](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.2.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.2.tar.gz)

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

## [zen4R 0.1](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.1.tar.gz) | [![CRAN_Status_Badge](https://img.shields.io/badge/CRAN-published-blue.svg)](https://cran.r-project.org/src/contrib/Archive/zen4R/zen4R_0.1.tar.gz)

First version
