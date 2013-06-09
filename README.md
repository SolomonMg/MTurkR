# MTurkR
This is a fork of Thomas Leeper's excellent MTurkR package, which provides an R interface to
Amazon Mechanical Turk's Servers.

See http://www.thomasleeper.com/MTurkR/index.html for details. 

## HOW TO INSTALL:
To install, run the following:

    # install.packages("devtools")
    library(devtools)
    install_github(repo="MTurkR",
    	username = "solomonm")

## Examples (from Tom's website)
* Create and manage qualifications: http://www.thomasleeper.com/MTurkR/qualification_test_example.r, associated xml files: http://www.thomasleeper.com/MTurkR/questionform_example.xml and http://www.thomasleeper.com/MTurkR/answerkey_example.xml. 

## Fixes in this version:
* Up to date GetAssignment() function, which previously had to be loaded from Tom's website via source().
* I've made edits to the request() function that enables MTurkR to deal with free responses that contain non-ASCII input.
