ExpireHIT <-
expire <-
function (hit = NULL, hit.type = NULL, keypair = credentials(), 
    print = TRUE, browser = FALSE, log.requests = TRUE, sandbox = FALSE) 
{
    if (!is.null(keypair)) {
        keyid <- keypair[1]
        secret <- keypair[2]
    }
    else stop("No keypair provided or 'credentials' object not stored")
    operation <- "ForceExpireHIT"
    if ((is.null(hit) & is.null(hit.type)) | (!is.null(hit) & 
        !is.null(hit.type))) 
        stop("Must provide 'hit' xor 'hit.type'")
    else if (!is.null(hit)) {
        hitlist <- hit
    }
    else if (!is.null(hit.type)) {
        hitsearch <- SearchHITs(keypair = keypair, print = FALSE, 
            log.requests = log.requests, sandbox = sandbox, return.qual.dataframe = FALSE)
        hitlist <- hitsearch$HITs[hitsearch$HITs$HITTypeId == 
            hit.type, ]$HITId
        if (length(hitlist) == 0) 
            stop("No HITs found for HITType")
    }
    HITs <- data.frame(matrix(ncol = 2))
    names(HITs) <- c("HITId", "Valid")
    for (i in 1:length(hitlist)) {
        GETiteration <- paste("&HITId=", hitlist[i], sep = "")
        auth <- authenticate(operation, secret)
        if (browser == TRUE) {
            request <- request(keyid, auth$operation, auth$signature, 
                auth$timestamp, GETiteration, browser = browser, 
                sandbox = sandbox)
        }
        else {
            request <- request(keyid, auth$operation, auth$signature, 
                auth$timestamp, GETiteration, log.requests = log.requests, 
                sandbox = sandbox)
            HITs[i, ] = c(hitlist[i], request$valid)
            if (request$valid == TRUE) {
                if (print == TRUE) 
                  cat(i, ": HIT ", hitlist[i], " Expired\n", 
                    sep = "")
            }
            else if (request$valid == FALSE & print == TRUE) 
                cat(i, ": Invalid Request for HIT ", hitlist[i], 
                  "\n", sep = "")
        }
    }
    return(HITs)
}
