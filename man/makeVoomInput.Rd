% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PlotBarCodes.R
\name{makeVoomInput}
\alias{makeVoomInput}
\title{Make Voom transformed input for BarCodePlot and ROAST test}
\usage{
makeVoomInput(counts, design, bmGeneNames, name = "name")
}
\arguments{
\item{counts}{A tab-seperated file containing gene names followed by counts}

\item{design}{A tab-seperated file containing design information (colnames, condition).
colnames should correspond to columns in count file and condition could be
control/test or any set of factors.}

\item{bmGeneNames}{Optionally provide alternative gene symbols downloaded from biomart as a
tab-seperated file. The columns should be ("ensembl_gene_id","external_gene_id")}

\item{name}{File name to output filtering plots.}
}
\value{
A plot (as pdf) and a voom transformed output as list.
}
\description{
Make Voom transformed input for BarCodePlot and ROAST test
}
\examples{
makeVoomInput(counts,design,bmGeneNames,name="name")

}

