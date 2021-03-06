

#' A wrapper over SPIA pathway perturbation analysis for mouse and human
#'
#' @param DESeqOutput Tab-seperated DESeq2 output file
#' @param organism select from "mmu" (mouse) or "hsa" (human)
#' @param padjCutoff FDR cutoff for the genes to include in the list
#' @param outFile output file to write affected pathways
#' @param outPlot output SPIA two-way evidence plot + output summary (pdf)
#'
#' @return a txt file and a pdf file
#' @export
#'
#' @examples
#'
#'
spia_wrapper <- function(DESeqOutput, organism = "mmu", padjCutoff, outFile, outPlot = NULL){
        df <- read.table(DESeqOutput, sep= "\t", header = TRUE, quote = "" )
        # load corresponding lib
        orgmap <- data.frame(org = c("mmu","hsa"), db = c("org.Mm.eg.db","org.Hs.eg.db"),stringsAsFactors = FALSE)
        assertthat::assert_that(organism %in% orgmap$org)
        db <- orgmap[grep(organism,orgmap$org),2]
        library(db,character.only = TRUE)

        # get ENTREZ id
        if(db == "org.Hs.eg.db"){
                ensToEntrez <- AnnotationDbi::select(org.Hs.eg.db,as.character(df$Row.names),"ENTREZID",
                                                     keytype = "ENSEMBL" )
        } else {
                ensToEntrez <- AnnotationDbi::select(org.Mm.eg.db,as.character(df$Row.names),"ENTREZID",
                                                     keytype = "ENSEMBL" )
        }

        df <- merge(df,ensToEntrez,by = 1)
        df.dg <- dplyr::filter(df, padj < padjCutoff,!(is.na(ENTREZID)),!(duplicated(ENTREZID)))
        df.map <- df.dg$log2FoldChange
        names(df.map) <- df.dg$ENTREZID
        allgenes <- na.omit(as.character(df$ENTREZID)) # can take from any df. it's the universe

        # SPIA
        spia.degenes <- SPIA::spia(df.map,allgenes,organism = organism, nB = 2000)
        spia.degenes$Name <- substr(spia.degenes$Name,1,20)
        spia.degenes = spia.degenes[order(spia.degenes$pGFWER),]
        top <- head(spia.degenes[c(1:5,7,9,11)])
        colnames(top) <- c("TOP PATHWAYS : NAME",colnames(top[2:7]))

        # Write output
        if(!is.null(outFile)) pdf(outPlot)
        SPIA::plotP(spia.degenes)
        gplots::textplot(top)
        if(!is.null(outFile)) dev.off()

        write.table(spia.degenes,outFile, sep = "\t", quote = FALSE, row.names = FALSE)
}


#' Make a bubblePlot for SPIA pathway output
#'
#' @param SPIAout output from spia_wrapper
#' @param outfileName output pdf file name for plot
#' @param top How many top pathways to plot (by pGFdr value)
#' @param plotType Which kind of bubble plot to make. options are :
#'                      1 (activated and inactivated pathways together) or
#'                      2 (activated and inactivated pathways split by a horizontal line).
#'                      Note that in type 2 the p values appear as negative for inactivated pathways.
#' @param title Title of the plot
#'
#' @return plot A bubbleplot in pdf format
#' @import ggplot2
#' @export
#'
#' @examples
#' spia_plotBubble(spia_wrapper_output, outfileName = "test.out, top = 20, title = "test plot)
#'

spia_plotBubble <- function(SPIAout,outfileName = NULL, top = 20, plotType = 1, title = NULL){
        path <- read.delim(pipe(paste0("cut -f1,3,6,9,11 ",SPIAout)), header = TRUE)
        path$pGFdr <- -log10(path$pGFdr)
        path <- path[order(path$pGFdr,decreasing = TRUE),]
        path <- path[1:top,]

        func <- function(path){
                p <- ggplot(path,aes(Name,pGFdr,fill = Status, size = pSize, label = Name)) +
                geom_point(alpha = 0.7, shape = 21) +
                scale_size_area(max_size = 15) + theme_bw(base_size = 15) +
                theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
                scale_fill_manual(values = c("forestgreen","Red")) +
                labs(x = "Pathways", y = "-log10(p-value)",fill = "Status", title = title)

                return(p)
        }

        if(plotType == 1) {
                p <- func(path)
        } else {
                warning("The scale of p-value has been converted to negative for inhibited pathways")
                path[path$Status == "Inhibited",'pGFdr'] = -path[path$Status == "Inhibited",'pGFdr']
                p <- func(path)
                p <- p + coord_cartesian() + theme(axis.text.x = element_blank()) +
                        geom_hline(aes(yintercept=0)) +
                        geom_text(size = 4,check_overlap = TRUE, angle = 10, nudge_y = -1.5)
        }

        if(!is.null(outfileName)) pdf(outfileName)
        print(p)
        if(!is.null(outfileName)) dev.off()
}
