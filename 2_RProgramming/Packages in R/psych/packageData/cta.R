"cta" <- function(n=3,t=5000, cues = NULL, act=NULL, inhibit=NULL,expect = NULL, consume = NULL,tendency = NULL,tstrength=NULL, type="both",fast=2 ,compare=FALSE,learn=TRUE,reward=NULL) {
#simulation of the CTA reparamaterization of the dynamics of action
#note, this is all for operation in a constant environment - what is needed is wrap the world around this. 
#That is, actions actually change cues 
#this should be a function to do all the work. the rest is just stats and graphics.
#MODEL (dif equations from paper)

##here is the basic model
tf <- function(tendency,cues,step,expect,act,consume) {
	tf <-  tendency + cues %*%  step %*% expect   - act %*% step %*% consume }   #tendencies at t-t 
	
	
af <- function(act,tendency,step,tstrength,inhibit) {
		af  <- tendency %*% step %*% tstrength + act - act %*% step %*% inhibit} #actions at t-t
#the learning function 
ef <- function(expect,act,step,consume,reward) {if(learn) {
		which.act <- which.max(act) #counting which act has won 
	
		if(old.act!=which.act) { 
		diag(temp) <- act %*% reward  
      expect <- expect + temp 
	                          #learn but only if a new action
	  expect <- expect*1/tr(expect)    #standardize expectancies
	  old.act <- which.act}}

ef <- expect
}

		
##
temp <- matrix(0,n,n)
  

if(n > 4){ colours <- rainbow(n)} else {colours <- c("blue", "red", "black","green") }

stepsize <- .05
tendency.start <- tendency
act.start <- act
expect.start <- expect

if(is.null(cues)) {cues <- 2^(n-1:n)}   #default cue str - cue vector represents inate strength of stim (cake vs peanut)

if(is.null(inhibit)) {inhibit <-  matrix(1,ncol=n,nrow=n)   #loss matrix .05 on diag 1s off diag
                     diag(inhibit) <- .05}
                     
if(is.null(tstrength)) tstrength <- diag(1,n) 
#if(is.null(tstrength)) tstrength <- diag(c(1,.5,.25))

if(n>1) {colnames(inhibit) <- rownames(inhibit) <- paste("A",1:n,sep="")}
if(is.null(consume) ) {consume <- diag(.03,ncol=n,nrow=n) }
step <- diag(stepsize,n) #this is the n CUES x k tendencyDENCIES matrix for Cue-tendency excitation weights 
if(is.null(expect)) expect <- diag(1,n)  # a matrix of expectancies that cues lead to outcomes
#first run for time= t  to find the maximum values to make nice plots as well as to get the summary stats
if (is.null(tendency.start)) {tendency <- rep(0,n)} else {tendency <- tendency.start} #default tendency = 0
if(is.null(act.start) ) {act <- cues} else {act <- act.start} #default actions = initial cues

if(is.null(reward)) {reward <- matrix(0,n,n)
                     diag(reward) <- c(rep(0,n-1),.05) } else {temp1 <- reward
                     reward <- matrix(0,n,n)
                     diag(reward) <- temp1 }

#set up counters
maxact <- minact <-  mintendency <-  maxtendency <- 0
counts <- rep(0,n)
transitions <- matrix(0,ncol=n,nrow=n)
frequency <- matrix(0,ncol=n,nrow=n)
colnames(frequency) <- paste("T",1:n,sep="")
rownames(frequency) <- paste("F",1:n,sep="")
old.act <- which.max(act)


#MODEL (dif equations from paper)
for (i in 1:t) {
 

	tendency <- tf(tendency,cues,step,expect,act,consume)
	act <- af (act,tendency,step,tstrength,inhibit) 
	act[act<0] <- 0

#add learning
	  expect <- ef(expect,act,step,consume,reward)


#END OF MODEL



#STATS
	#calc max/min act/tendency
	maxact <- max(maxact,act)
	minact <- min(minact,act)
	maxtendency <- max(maxtendency,tendency)
	mintendency <- min(mintendency,tendency)
	
	#count
	which.act <- which.max(act) #counting which act has won 
	counts[which.act] <- counts[which.act]+1 #time table
	transitions[old.act,which.act] <- transitions[old.act,which.act] + 1 #frequency table
	if(old.act!=which.act) { frequency[old.act,which.act] <- frequency[old.act,which.act] + 1
	                         frequency[which.act,which.act] <- frequency[which.act,which.act] +1
	                       
	                         }  #learn but only if a new action
	old.act <- which.act
}

#PLOTS
#now do various types of plots, depending upon the type of plot desired
plots <- 1
action <- FALSE 
#state diagrams plot two tendencydencies agaist each other over time
if (type!="none") {if (type=="state") { 
	op <- par(mfrow=c(1,1))
	if (is.null(tendency.start)) {tendency <- rep(0,n)} else {tendency <- tendency.start}
	if(is.null(act.start) ) {act <- cues} else {act <- act.start}	
	plot(tendency[1],tendency[2],xlim=c(mintendency,maxtendency),ylim=c(mintendency,maxtendency),col="black", 
        main="State diagram",xlab="tendency 1", ylab="tendency 2") 
    
	for (i in 1:t) {
			tendency <- tf(tendency,cues,step,expect,act,consume)
	        act <- af (act,tendency,step,tstrength,inhibit) 
	        #expect <- ef(expect,act,step,consume)
	act[act<0] <- 0
			if(!(i %% fast)) points(tendency[1],tendency[2],col="black",pch=20,cex=.2)
			} 
	}  else {
			 
#the basic default is to plot action tendencydencies and actions in a two up graph			 
if(type=="both") {if(compare) {op <- par(mfrow=c(2,2))} else {op <- par(mfrow=c(2,1))}
		plots <- 2 } else {op <- par(mfrow=c(1,1))}



if (type=="action") {action <- TRUE} else {if(type=="tendencyd" ) action <- FALSE} 

for (k in 1:plots) {
	if (is.null(tendency.start)) {tendency <- rep(0,n)} else {tendency <- tendency.start}
	if(is.null(act.start) ) {act <- cues} else {act <- act.start}
	if(is.null(expect.start)) {expect <- diag(1,n)} else {expect <- expect.start}   # a matrix of expectancies that cues lead to outcomes
	
	if(action )   plot(rep(1,n),act,xlim=c(0,t),ylim=c(minact,maxact),xlab="time",ylab="action", main="Actions over time") else plot(rep(1,n),tendency,xlim=c(0,t),ylim=c(mintendency,maxtendency),xlab="time",ylab="action tendency",main="Action tendencies over time") 
		for (i in 1:t) {
		tendency <- tf(tendency,cues,step,expect,act,consume)
	act <- af (act,tendency,step,tstrength,inhibit) 
	
	act[act<0] <- 0
	
	###
	maxact <- max(maxact,act)
	minact <- min(minact,act)
	maxtendency <- max(maxtendency,tendency)
	mintendency <- min(mintendency,tendency)
	
	#count
	which.act <- which.max(act) #counting which act has won 
	counts[which.act] <- counts[which.act]+1 #time table
	transitions[old.act,which.act] <- transitions[old.act,which.act] + 1 #frequency table
	if(old.act!=which.act) { frequency[old.act,which.act] <- frequency[old.act,which.act] + 1
	#frequency[which.act,which.act] <- frequency[which.act,which.act] +1
	                       expect <- ef(expect,act,step,consume,reward)
	                         }  #learn but only if a new action
	old.act <- which.act
	
	##
	
	
	
			if(!(i %% fast) ) {if( action) points(rep(i,n),act,col=colours,cex=.2) else points(rep(i,n),tendency,col=colours,cex=.2) }}
action <- TRUE}
} }
results <- list(cues=cues,expectancy=expect,strength=tstrength,inihibition=inhibit,consumation=consume,reinforcement=reward, time = counts,frequency=frequency, tendency=tendency, act=act)
return(results)
}