create <-
CreateHIT <-
createhit <-
function (hit.type = NULL, question = NULL, validate.question = FALSE,
	expiration, assignments = "1", 
    assignment.review.policy = NULL, hit.review.policy = NULL, 
    annotation = NULL, unique.request.token = NULL, title = NULL, 
    description = NULL, reward = NULL, duration = NULL, keywords = NULL, 
    auto.approval.delay = NULL, qual.req = NULL, hitlayoutid = NULL, 
    hitlayoutparameters = NULL, response.group = NULL, keypair = credentials(), 
    print = TRUE, browser = FALSE, log.requests = TRUE, sandbox = FALSE) 
{
    if (!is.null(keypair)) {
        keyid <- keypair[1]
        secret <- keypair[2]
    }
    else stop("No keypair provided or 'credentials' object not stored")
    operation <- "CreateHIT"
    if (!is.null(hit.type)) {
        if (!is.null(hit.type) & (!is.null(title) || !is.null(description) || 
            !is.null(reward) || !is.null(duration))) 
            warning("HITType specified, HITType parameters (title, description, reward, duration) ignored")
        GETparameters <- paste("&HITTypeId=", hit.type, sep = "")
    }
    else {
        if (is.null(title) || is.null(description) || is.null(reward) || 
            is.null(duration)) 
            stop("Must specify HITType xor HITType parameters (title, description, reward, duration)")
        else {
            register <- RegisterHITType(title, description, reward, 
                duration, keywords = keywords, auto.approval.delay = auto.approval.delay, 
                qual.req = qual.req, keypair = keypair, print = print, 
                log.requests = log.requests, sandbox = sandbox)
            if (register$Valid == FALSE) 
                stop("Could not RegisterHITType(), check parameters")
            else GETparameters <- paste("&HITTypeId=", register$HITTypeId, 
                sep = "")
        }
    }
    if (is.null(question)) {
        if (!is.null(hitlayoutid)) {
            GETparameters <- paste(GETparameters, "&HITLayoutId=", 
                hitlayoutid, sep = "")
            if (!is.null(hitlayoutparameters)) 
                GETparameters <- paste(GETparameters, hitlayoutparameters, 
                  sep = "")
        }
        else
			stop("Must specify QuestionForm, HTMLQuestion, or ExternalQuestion for 'question' parameter; or a 'hitlayoutid'")
    }
    else {
		if(validate.question==TRUE){
			if(!is.null(xmlChildren(xmlParse(question))$QuestionForm))
				namespace <- xmlNamespace(xmlChildren(xmlParse(question))$QuestionForm)[1]
			else if(!is.null(xmlChildren(xmlParse(question))$HTMLQuestion))
				namespace <- xmlNamespace(xmlChildren(xmlParse(question))$HTMLQuestion)[1]
			else if(!is.null(xmlChildren(xmlParse(question))$ExternalQuestion))
				namespace <- xmlNamespace(xmlChildren(xmlParse(question))$ExternalQuestion)[1]
			else
				stop("No Namespace specified in 'question'")
			validation <- xmlSchemaValidate(namespace, question)
			if(!validation$status==0){
				warning("'question' object does not validate against MTurk schema")
				return(validation)
			}
		}
		GETparameters <- paste(GETparameters, "&Question=", curlEscape(question), sep = "")
	}
    if (is.null(expiration)) 
        stop("Must specify HIT LifetimeInSeconds for expiration parameter")
    else if (as.numeric(expiration) < 30 | as.numeric(expiration) > 
        31536000) 
        stop("HIT LifetimeInSeconds/expiration must be between 30 and 31536000 seconds")
    else GETparameters <- paste(GETparameters, "&LifetimeInSeconds=", 
        expiration, sep = "")
    if (is.null(assignments)) 
        stop("Number of Assignments must be specified")
    else if (as.numeric(assignments) < 1 | as.numeric(assignments) > 
        1e+09) 
        stop("MaxAssignments must be between 1 and 1000000000")
    else GETparameters <- paste(GETparameters, "&MaxAssignments=", 
        assignments, sep = "")
    if (!is.null(response.group)) {
        if (!response.group %in% c("Request", "Minimal", "HITDetail", 
            "HITQuestion", "HITAssignmentSummary")) 
            stop("ResponseGroup must be in c(Request,Minimal,HITDetail,HITQuestion,HITAssignmentSummary)")
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
    if (!is.null(assignment.review.policy)) 
        GETparameters <- paste(GETparameters, "&AssignmentReviewPolicy=", 
            curlEscape(assignment.review.policy), sep = "")
    if (!is.null(hit.review.policy)) 
        GETparameters <- paste(GETparameters, "&HITReviewPolicy=", 
            curlEscape(hit.review.policy), sep = "")
    if (!is.null(annotation) && nchar(curlEscape(annotation)) > 
        255) 
        stop("Annotation must be <= 255 characters")
    else if (!is.null(annotation)) 
        GETparameters <- paste(GETparameters, "&RequesterAnnotation=", 
            curlEscape(annotation), sep = "")
    if (!is.null(unique.request.token) && nchar(curlEscape(unique.request.token)) > 
        64) 
        stop("UniqueRequestToken must be <= 64 characters")
    else if (!is.null(unique.request.token)) 
        GETparameters <- paste(GETparameters, "&UniqueRequestToken=", 
            curlEscape(unique.request.token), sep = "")
    HITs <- data.frame(matrix(ncol = 3))
    names(HITs) <- c("HITTypeId", "HITId", "Valid")
    if (is.null(hit.type)) 
        type <- NA
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
        if (request$valid == TRUE) {
            hit <- strsplit(strsplit(request$xml, "<HITId>")[[1]][2], 
                "</HITId>")[[1]][1]
            if (is.null(hit.type)) 
                type <- strsplit(strsplit(request$xml, "<HITTypeId>")[[1]][2], 
                  "</HITTypeId>")[[1]][1]
            HITs[1, ] <- c(type, hit, request$valid)
            if (print == TRUE) {
                if (!is.null(hit.type)) 
                  cat("HIT ", hit, " created\n", sep = "")
                else if (is.null(hit.type)) 
                  cat("HIT ", hit, " created (of type ", type, 
                    ")\n", sep = "")
            }
        }
        else if (request$valid == FALSE) {
            if (print == TRUE) 
                cat("Invalid Request\n")
        }
        if (print == TRUE) 
            return(HITs)
        else invisible(HITs)
    }
}
