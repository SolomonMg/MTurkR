GrantQualification <-
GrantQualifications <-
grantqual <-
function (qual.requests, values, keypair = credentials(), print = TRUE, 
    browser = FALSE, log.requests = TRUE, sandbox = FALSE) 
{
    if (!is.null(keypair)) {
        keyid <- keypair[1]
        secret <- keypair[2]
    }
    else stop("No keypair provided or 'credentials' object not stored")
    operation <- "GrantQualification"
    if (!length(qual.requests) == length(values)) {
        if (length(values) == 1) 
            values <- rep(values[1], length(qual.requests))
        else stop("Number of QualificationRequests is not 1 or number of Values")
    }
    for (i in 1:length(values)) {
        if (!is.numeric(as.numeric(values))) 
            warning("Non-numeric Qualification Value requested for request ", 
                qual.requests[i], "\n", sep = "")
    }
    QualificationRequests <- data.frame(matrix(ncol = 3))
    names(QualificationRequests) <- c("QualificationRequestId", 
        "Value", "Valid")
    for (i in 1:length(qual.requests)) {
        GETparameters <- paste("&QualificationRequestId=", qual.requests[i], 
            "&IntegerValue=", values[i], sep = "")
        auth <- authenticate(operation, secret)
        if (browser == TRUE) {
            request <- request(keyid, auth$operation, auth$signature, 
                auth$timestamp, GETparameters, browser = browser, 
                sandbox = sandbox)
        }
        else {
            request <- request(keyid, auth$operation, auth$signature, 
                auth$timestamp, GETparameters, log.requests = log.requests, 
                sandbox = sandbox)
            QualificationRequests[i, ] <- c(qual.requests[i], 
                values[i], request$valid)
            if (request$valid == TRUE) {
                if (print == TRUE) 
                  cat(i, ": Qualification (", qual.requests[i], 
                    ") Granted\n", sep = "")
            }
            else if (request$valid == FALSE) {
                if (print == TRUE) 
                  cat(i, ": Invalid Request for QualificationRequest ", 
                    qual.requests[i], "\n", sep = "")
            }
        }
    }
    if (print == TRUE) 
        return(QualificationRequests)
    else if (print == FALSE) 
        invisible(QualificationRequests)
}
