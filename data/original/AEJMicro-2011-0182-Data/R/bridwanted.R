z=read.table("bridewanted_for_r.txt",header=TRUE) 
d=read.table("char_maleadplacer_r_noh.txt",header=FALSE)

# center demo data so that mean of random-effects
# distribution can be interpretted as the average respondents
d[,1]=rep(1,nrow(d))
d[,2]=d[,2]-mean(d[,2])
d[,3]=d[,3]-mean(d[,3])
d[,4]=d[,4]-mean(d[,4])
d[,5]=d[,5]-mean(d[,5])
d[,6]=d[,6]-mean(d[,6])
d[,7]=d[,7]-mean(d[,7])
d[,8]=d[,8]-mean(d[,8])
hh=levels(factor(z$SI))
nhh=length(hh)

lgtdata=NULL

for (i in 1:nhh) {
	y=z[z[,1]==hh[i],2]
	nobs=length(y)
	X=as.matrix(z[z[,1]==hh[i],c(3:46)])
	lgtdata[[i]]=list(y=y,X=X)
		}
Z2=as.matrix(d)
Data=list(lgtdata=lgtdata,Z=Z2)
cat("Finished Reading data",fill=TRUE)
flush.console()

Mcmc=list(R=20000,sbeta=0.2,keep=10)

out=rhierBinLogit(Data=Data,Mcmc=Mcmc)

beta=apply(out$betadraw[,,1001:2000],c(1,2),mean)

delta=apply(out$Deltadraw[1001:2000,],c(1,2),mean)

sigma=apply(out$Vbetadraw[1001:2000,],c(1,2),mean)

plot(out$llike, type="l",xlab="Iterations/20", ylab=" ", main="Posterior Log Likelihood")

write.csv(beta,file="beta_bridewanted_withZ.csv")

write.csv(delta,file="delta_bridewanted_withZ.csv")

write.csv(sigma,file="sigma_bridewanted_withZ.csv")

