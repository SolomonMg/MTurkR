GetHITsForQualificationType <-
gethitsbyqual <-
function (qual, response.group = NULL, return.all = TRUE, pagenumber = 1, 
    pagesize = 100, keypair = credentials(), print = TRUE, log.requests = TRUE, 
    sandbox = FALSE, return.hit.dataframe = TRUE) 
{
    if (!is.null(keypair)) {
        keyid <- keypair[1]
        secret <- keypair[2]
    }
    else stop("No keypair provided or 'credentials' object not stored")
    operation <- "GetHITsForQualificationType"
    if (return.all == TRUE) {
        pagesize <- "100"
        pagenumber <- "1"
    }
    if (as.numeric(pagesize) < 1 || as.numeric(pagesize) > 100) 
        stop("'pagesize' must be in range (1,100)")
    if (as.numeric(pagenumber) < 1) 
        stop("'pagenumber' must be > 1")
    GETparameters <- paste("&QualificationTypeId=", qual, "&PageSize=", 
        pagesize, sep = "")
    if (!is.null(response.group)) {
        if (!response.group %in% c("Minimal", "HITQuestion", 
            "HITDetail", "HITAssignmentSummary")) 
            stop("ResponseGroup must be in c(Minimal,HITQuestion,HITDetail,HITAssignmentSummary)")
        if (length(response.group) == 1) 
            GETparameters <- paste(GETparameters, "&ResponseGroup=", 
                response.group, sep = "")
        else {
            for (i in 1:length(response.group)) {
                GETparameters <- paste(GETparameters, "&ResponseGroup", 
                  i - 1, "=", response.group[i], sep = "")
            }
        }
    }
    batch <- function(pagenumber) {
        GETiteration <- paste(GETparameters, "&PageNumber=", 
            pagenumber, sep = "")
        auth <- authenticate(operation, secret)
        batch <- request(keyid, auth$operation, auth$signature, 
            auth$timestamp, GETiteration, log.requests = log.requests, 
            sandbox = sandbox)
        batch$total <- as.numeric(strsplit(strsplit(batch$xml, 
            "<TotalNumResults>")[[1]][2], "</TotalNumResults>")[[1]][1])
        batch$batch.total <- length(xpathApply(xmlParse(batch$xml), 
            "//HIT"))
        if (return.hit.dataframe == TRUE) {
            if (batch$total > 0) {
                hitlist <- HITsToDataFrame(xml = batch$xml)
                batch$HITs <- hitlist$HITs
                batch$QualificationRequirements <- hitlist$QualificationRequirements
            }
        }
        return(batch)
    }
    request <- batch(pagenumber)
    runningtotal <- request$batch.total
    pagenumber = 2
    while (request$total > runningtotal) {
        nextbatch <- batch(pagenumber)
        request$request.id <- c(request$request.id, nextbatch$request.id)
        request$valid <- c(request$valid, nextbatch$valid)
        request$xml.response <- c(request$xml, nextbatch$xml)
        if (request$valid == TRUE) {
            if (return.hit.dataframe == TRUE) {
                request$HITs <- rbind(request$HITs, nextbatch$HITs)
                request$QualificationRequirements <- rbind(request$QualificationRequirements, 
                  nextbatch$QualificationRequirements, sandbox = sandbox)
            }
        }
        request$pages.returned <- pagesize
        runningtotal <- runningtotal + request$batch.total
        pagenumber <- pagenumber + 1
    }
    request$batch.total <- NULL
    return.list <- list(HITs = request$HITs, QualificationRequirements = request$QualificationRequirements)
    if (print == TRUE) {
        cat(request$total, " HITs Retrieved\n", sep = "")
        if (request$total > 0) 
            return(return.list)
    }
    else {
        if (request$total > 0) 
            invisible(return.list)
    }
}
