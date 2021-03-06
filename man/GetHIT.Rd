\name{GetHIT}
\alias{GetHIT}
\alias{gethit}
\alias{hit}
\alias{HITStatus}
\alias{status}
\title{Get HIT}
\description{Retrieve various details of a HIT as a dataframe. What details are returned depend upon the requested ResponseGroup.}
\usage{
GetHIT(	hit, response.group = NULL, keypair = credentials(), print = TRUE, 
		browser = FALSE, log.requests = TRUE, sandbox = FALSE, 
		return.hit.dataframe = TRUE, return.qual.dataframe = TRUE)

HITStatus(	hit = NULL, hit.type = NULL, 
			keypair = credentials(), print = TRUE, 
			log.requests = TRUE, sandbox = FALSE)
}
\arguments{
  \item{hit}{An optional character string specifying the HITId of the HIT to be retrieved. Must specify \code{hit} xor \code{hit.type}.}
  \item{hit.type}{An optional character string specifying the HITTypeId of the HIT(s) to be retrieved. Must specify \code{hit} xor \code{hit.type}.}
  \item{response.group}{An optional character string (or vector of character strings) specifying what details of each HIT to return of: \dQuote{Request}, \dQuote{Minimal}, \dQuote{HITDetail}, \dQuote{HITQuestion}, \dQuote{HITAssignmentSummary}. For more information, see \url{http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_CommonParametersArticle.html}.}
  \item{keypair}{A two-item character vector containing an AWS Access Key ID in the first position and the corresponding Secret Access Key in the second position. Set default with \code{\link{credentials}}.}
  \item{print}{Optionally print the results of the API request to the standard output. Default is \code{TRUE}.}
  \item{browser}{Optionally open the request in the default web browser, rather than opening in R. Default is \code{FALSE}.}
  \item{log.requests}{A logical specifying whether API requests should be logged. Default is \code{TRUE}. See \code{\link{readlogfile}} for details.}
  \item{sandbox}{Optionally execute the request in the MTurk sandbox rather than the live server.  Default is \code{FALSE}.}
  \item{return.hit.dataframe}{A logical indicating whether the dataframe of HITs should be returned. Default is \code{TRUE}.}
  \item{return.qual.dataframe}{A logical indicating whether the list of each HIT's QualificationRequirements (stored as dataframes in that list) should be returned. Default is \code{TRUE}.}
}
\details{
\code{GetHIT} retrieves characteristics of a HIT. \code{HITStatus} is a wrapper that retrieves the Number of Assignments Pending, Number of Assignments Available, Number of Assignments Completed for the HIT(s), which is helpful for checking on the progress of currently available HITs. Specifying a \code{hit.type} causes the function to first search for avialable HITs of that HITType, then return the requested information for each HIT.

\code{gethit()} and \code{hit()} are aliases for \code{GetHIT}. \code{status()} is an alias for \code{HITStatus}.
}
\value{Optionally a dataframe containing the HITs and a list of each HIT's QualificationRequirements (stored as dataframes in that list in the order that HITs were retrieved.). The exact characteristics of each HIT returned depend upon the \code{response.group} parameter.}
\references{
\href{http://docs.amazonwebservices.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_GetHITOperation.html}{API Reference}
}
\author{Thomas J. Leeper}
%\note{}
\seealso{
\code{\link{GetHITsForQualificationType}}

\code{\link{GetReviewableHITs}}

\code{\link{SearchHITs}}
}
\examples{
\dontrun{
GetHIT("2MQB727M0IGF304GJ16S1F4VE3AYDQ")
HITStatus("2MQB727M0IGF304GJ16S1F4VE3AYDQ")
hits <- c("2MQB727M0IGF304GJ16S1F4VE3AYDQ","AM4DB727M0IGF304GJ16S1F4VE36JIQ")
HITStatus(hits)
}
}
\keyword{HITs}