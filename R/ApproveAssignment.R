approve <-
ApproveAssignment <-
ApproveAssignments <-
function (assignments, feedback = NULL, rejected = FALSE, keypair = credentials(), 
    print = FALSE, browser = FALSE, log.requests = TRUE, sandbox = FALSE) 
{
    if (!is.null(keypair)) {
        keyid <- keypair[1]
        secret <- keypair[2]
    }
    else stop("No keypair provided or 'credentials' object not stored")
    if (rejected == TRUE) 
        operation <- "ApproveRejectedAssignment"
    else operation <- "ApproveAssignment"
    if (!is.null(feedback)) {
        for (i in 1:length(feedback)) {
            if (!is.null(feedback[i]) && nchar(curlEscape(feedback[i])) > 
                1024) 
                warning("Feedback ", i, " is too long (1024 char max)")
        }
        if (length(feedback) == 1) 
            feedback <- rep(feedback[1], length(assignments))
        else if (!length(feedback) == length(assignments)) 
            stop("Number of feedback is not 1 nor length(assignmetns)")
    }
    batch <- function(assignment, feedback.batch = NULL) {
        GETparameters <- paste("&AssignmentId=", assignment, 
            sep = "")
        if (!is.null(feedback.batch)) {
            GETparameters <- paste(GETparameters, "&RequesterFeedback=", 
                curlEscape(feedback.batch), sep = "")
        }
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
            if (print == TRUE) {
                if (request$valid == TRUE) 
                  cat("Assignment ", assignment, " Approved\n", 
                    sep = "")
                else if (request$valid == FALSE) 
                  cat("Invalid Request for ", assignment, "\n", 
                    sep = "")
                return(request)
            }
            else invisible(request)
        }
    }
    Assignments <- data.frame(matrix(nrow = length(assignments), 
        ncol = 3))
    names(Assignments) <- c("AssignmentId", "Feedback", "Valid")
    for (i in 1:length(assignments)) {
        x <- batch(assignments[i], feedback[i])
        if (!is.null(feedback)) 
            Assignments[i, ] <- c(assignments[i], feedback[i], 
                x$valid)
        else Assignments[i, ] <- c(assignments[i], "", x$valid)
    }
    if (print == TRUE) 
        cat(sum(x$valid), " Assignments Approved\n", sep = "")
    invisible(Assignments)
}
