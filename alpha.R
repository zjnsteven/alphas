
PATH = "/sciclone/home00/zjn/wbproj/"
.libPaths( c( .libPaths(),paste(PATH,"R_lib/",sep="")))
library("rpart",lib.loc=paste(PATH,"R_lib/",sep=""))
library("rpart.plot",lib.loc=paste(PATH,"R_lib/",sep=""))
library("Rcpp",lib.loc=paste(PATH,"R_lib/",sep=""))
Sys.setenv("PKG_CXXFLAGS"="-fopenmp")
Sys.setenv("PKG_LIBS"="-fopenmp")
sourceCpp(paste(PATH,"CTHybrid/splitc.cpp",sep="")

db <- read.csv(paste(PATH,"CTHybrid/dbnoafter.csv"))
#db = db[1:1000,]
# fit1 = rpart (cbind(outcome,TrtBin,pscore,trans_outcome) ~ . ,
#                 db,
#                 control = rpart.control(cp = 0,minsplit = 10,minbucket  = 10),
#                 method=alist)
#   fit = data.matrix(fit1$frame)
#   index = as.numeric(rownames(fit1$frame))

#   tsize = dim(fit1$frame[which(fit1$frame$var=="<leaf>"),])[1]

#   alpha = 0
#   alphalist = 0
#   alphalist = cross_validate(fit, index,alphalist)
# res = rep(0,length(alphalist)-1)
#   if(length(alphalist) <= 2){
#     res = alphalist
#   }else{
#     for(j in 2:(length(alphalist)-1)){
#       res[j] = sqrt(alphalist[j]*alphalist[j+1])
#     }
#   }
  
  
#   alphacandidate = res
  

#	alphaset = rep(0,length(alphacandidate))
#	errset = rep(0,length(alphacandidate))

#	save(alphacandidate,file="/home/scratch/jzhao/wbproject/wb/supplement/alphacandidate")
load(file=paste(PATH,"CTHybrid/alphacandidate",sep=""))
readIn <- commandArgs(trailingOnly = TRUE)

l <- readIn[1]

timer1 <- proc.time()

#use defined split function
  ctev <- function(y, wt,parms) {
    out = node_evaluate(y)
    list(label= out[1], deviance=out[2])
  }

  ctsplit <- function(y, wt, x, parms, continuous) {
    if (continuous) {
      n = nrow(y)
      res = splitc(y)
      list(goodness=res[1:(n-1)], direction=res[n:(2*(n-1))])
    }
    else{
      res = splitnc(y,x)
      n=(length(res)+1)/2
      list(goodness=res[1:(n-1)], direction=res[n:(2*n-1)])
    }
  }


  ctinit <- function(y, offset, parms, wt) {
    sfun <- function(yval, dev, wt, ylevel, digits ) {
      print(yval)
      paste("events=", round(yval[,1]),
            ", coef= ", format(signif(yval[,2], digits)),
            ", deviance=" , format(signif(dev, digits)),
            sep = '')}
    environment(sfun) <- .GlobalEnv
    list(y =y, parms = 0, numresp = 1, numy = 4,
         summary = sfun)
  }


  alist <- list(eval=ctev, split=ctsplit, init=ctinit)
  # y : outcome, treatment(W), "pscore", tansformaed outcome

  dbb = db
  k = 10 
  n = dim(dbb)[1]
  crxvdata = dbb
  crxvdata$id <- sample(1:k, nrow(crxvdata), replace = TRUE)
  list = 1:k
  tsize = 0
  
alpha = alphacandidate[l]
error = 0
treesize = 0
for (i in 1:5){
	timeloopst = proc.time()
	trainingset <- subset(crxvdata, id %in% list[-i])
	testset <- subset(crxvdata, id %in% c(i))
	fit1 = rpart (cbind(outcome,TrtBin,pscore,trans_outcome) ~ . -id ,
	            trainingset,
	            control = rpart.control(cp = alpha,minsplit = 10),
	            method=alist)

	treesize = treesize + dim(fit1$frame[which(fit1$frame$var=="<leaf>"),])[1]
	pt = predict(fit1,testset,type = "matrix")
	y = data.frame(pt)
	val = data.matrix(y)
	idx = as.numeric(rownames(testset))
	dbidx = as.numeric(rownames(dbb))
	tempErr = 0
	for(pid in 1:(dim(y)[1])){
	  id = match(idx[pid],dbidx)
	  tempErr = tempErr + (dbb$trans_outcome[id] - val[pid])^2
	}
	timeloop = proc.time() - timeloopst
	write(paste("log info ","error #: ", l, "fold:  ", i, "error val: ", tempErr,"time per loop",timeloop[3]),file=paste(PATH,"CTHybrid/res/err_res1",sep=""),append=TRUE)
	error = error + tempErr
 }
print(paste("error:",error))
tsize = c(tsize,treesize/k)
if(error == 0){
  err_res = 1000000
}else{
  err_res = error/k
}
#msg = paste(l,": ",errset[l]*k,sep="")
#print(msg)

#tsize = tsize[-1]
#alpha_res = alphacandidate[which.min(errset)]
write(paste("log info ","error #: ", l, "error val avg: ", err_res),file=paste(PATH,"CTHybrid/res/err_res1",sep=""),append=TRUE)
#save(err_res,file=paste("/sciclone/home00/zjn/wbproj/CTHybrid/res/err",l,sep=""))
timer3 <- proc.time() - timer1
write(paste("time:",timer3[3], sep=" "),file=paste(PATH,"CTHybrid/res/err_res1",sep=""),append=TRUE)
