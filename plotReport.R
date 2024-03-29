
reportPlot<-function(outputText,nc,nr){

  bg<-graphcolours$graphC
  margin=0.5
  colSpace=2.5
  
  font_size=labelSize
  characterWidth=font_size/14
  
  top=max(nr,14)
  if (usingShiny) {
    edge=100*characterWidth
  } else {
    edge=80*characterWidth
  }

  oT<-matrix(outputText,ncol=nc,byrow=TRUE)
  nT<-nchar(oT) # no of characters per cell
  nrT<-rowSums(nT) # no characters per row
  # now break into blocks separated by empty rows
  blockEnds<-c(0,which(nrT==0),nrow(nT))
  colX<-c()
  if (length(blockEnds)>1) {
  for (i in 2:length(blockEnds)){
    block<-nT[(blockEnds[i-1]+1):blockEnds[i],]
    if (is.null(dim(block))){
      # empty block
      colSize<-block+colSpace
      colOffset<-cumsum(c(0,colSize))
      colX<-c(colX,rep(colOffset[1:length(block)],1))
    }
    else     {
      colSize<-apply(block,2,max)+colSpace
      colOffset<-cumsum(c(0,colSize))
      colX<-c(colX,rep(colOffset[1:ncol(block)],nrow(block)))
    }
  }
  }
  x_gap1<-colX*characterWidth
  
  d<-expand.grid(x=1:nc,y=1:nr)

  boldlabels<-grepl("\b",outputText)
  outputText<-sub("\b","",outputText)
  rightlabels<-grepl("!j",outputText)
  outputText<-sub("!j","",outputText)
  
  redlabels<-grepl("\r",outputText)
  outputText<-sub("\r","",outputText)
  greenlabels<-grepl("!g",outputText)
  outputText<-sub("!g","",outputText)
  pts<-data.frame(x=x_gap1,y=d$y)
  g<-ggplot()

  for (i in 1:length(outputText)) {
    x<-x_gap1[i]+1
    y<-d$y[i]
    label<-outputText[i]
    parse<-FALSE
    switch(label,
           "Alpha"={label<-alphaChar},
           "pNull"={label<-deparse(Plabel)},
           "k"={label<-deparse(Llabel)},
           "p(sig)"={label<-deparse(pSigLabel)}
           )
    if (boldlabels[i]) fontface<-"bold" else fontface<-"plain"
    if (rightlabels[i]) hjust<- 1 else hjust<- 0
    if (rightlabels[i]) x<- x_gap1[i+1]+1-characterWidth
    fill<-bg
    if (redlabels[i]) fill="red"
    if (redlabels[i]) fill="green"
    
    mathlabel<-grepl("['^']{1}",label) || grepl("['[']{1}",label)
    if (any(mathlabel)) parse<-TRUE
    pts<-data.frame(x=x,y=top+1-y)
    g<-g+geom_label(data=pts,aes(x=x, y=y), label=label, 
                                         hjust=hjust, vjust=0, 
                                         size=font_size, 
                                         fill=fill,fontface=fontface,
                                         parse=parse,
                                         label.size=NA,label.padding=unit(0,"lines"))
  }
  
  g<-g+labs(x="  ",y="  ")+reportTheme+theme(legend.position = "none")
  g<-g+theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          panel.background = element_rect(fill=graphcolours$graphC, colour=graphcolours$graphC)
    )
  g+coord_cartesian(xlim = c(1-margin,edge+margin), ylim = c(1-margin,top+margin))
}
