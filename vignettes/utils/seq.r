#' Test whether input is valid biological sequence
#' @param seq a character vector or \code{seq} object
valid_seq = function (seq)
    UseMethod('valid_seq')

valid_seq.default = function (seq) {
    valid = function (x)
        ! any(is.na(match(strsplit(x, '')[[1]], c('A', 'C', 'G', 'T'))))
    all(vapply(toupper(seq), valid, logical(1)))
}

valid_seq.seq = function (seq)
    TRUE

#' Create a biological sequence
#'
#' Create a nucleotide sequence consisting of \code{A}, \code{C}, \code{G} and
#' \code{T}
#' @param x character vector
#' @param validate logical to indicate whether to validate the input
#'  (default: \code{TRUE}), via \code{\link{valid_seq}}
#' @return Biological sequence equivalent to the input string
seq = function (x, validate = TRUE) {
    if (validate)
        stopifnot(valid_seq(x))
    structure(toupper(x), class = 'seq')
}

#' Print one or more biological sequences
#' @param seq biological sequences
print.seq = function (seq, columns = 60) {
    lines = strsplit(seq, sprintf('(?<=.{%s})', columns), perl = TRUE)
    print_single = function (seq, name) {
        if (! is.null(name))
            cat(sprintf('>%s\n', name))
        cat(seq, sep = '\n')
    }
    names = if (is.null(names(seq))) list(NULL) else names(seq)
    Map(print_single, lines, names)
    invisible(seq)
}

register_S3_method('print', 'seq', print.seq)

#' Reverse complement
#'
#' The reverse complement of a sequence is its reverse, with all bases
#' substituted by their base complement.
#' @param seq character vector of biological sequences
revcomp = function (seq) {
    rc = function (seq) {
        bases = strsplit(seq, '')[[1]]
        base_compl = function (x) switch(x, A = 'T', C = 'G', G = 'C', T = 'A')
        compl = vapply(bases, base_compl, character(1))
        paste(rev(compl), collapse = '')
    }
    `class<-`(setNames(vapply(seq, rc, character(1)), names(seq)), class = 'seq')
}

#' Tabulate nucleotides present in sequence
#' @param seq sequences
#' @return A \code{\link[base::table]{table}} for the nucleotides of each
#'  sequence in the input.
table = function (seq) {
    # In order to ensure that non-existing nucleotides appear as 0 in the table,
    # we append 'ACGT' to the string, and later subtract 1 from all counts.
    seq = vapply(seq, function (s) paste0(s, 'ACGT'), character(1))
    setNames(Map(function (t) t - 1, Map(base::table, strsplit(seq, ''))),
             names(seq))
}
