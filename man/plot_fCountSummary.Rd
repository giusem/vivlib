% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/featureCounts_downstream.R
\name{plot_fCountSummary}
\alias{plot_fCountSummary}
\title{Plot the output of featureCounts summary}
\usage{
plot_fCountSummary(summaryFile, CutFromHeader, outFile = NULL)
}
\arguments{
\item{summaryFile}{featureCounts output.summary file}

\item{CutFromHeader}{unnecessory text to remove from the header}

\item{outFile}{Output file name}
}
\value{
A plot of featurecounts summary in a pdf file
}
\description{
Plot the output of featureCounts summary
}
\examples{
plot_fCountSummary(test.summary,"/long/path/to/cut")

}

