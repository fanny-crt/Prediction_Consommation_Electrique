#importer data
data <- read.csv(file = "donnees_nettoyees.csv", header = TRUE, sep = ",")
data$Voltage <- as.numeric(data$Voltage)
data$date_heure <- as.POSIXct(data$date_heure, format="%Y-%m-%d %H:%M:%S")
head(data)

# graph donn?es derni?re ann?e
library(dygraphs)
library(xts)
don <- xts(x = data$Voltage, order.by = data$date_heure)
p <- dygraph(don) %>%
  dyOptions(useDataTimezone = TRUE, fillGraph=TRUE, fillAlpha=0.1, drawGrid = FALSE, colors="#D8AE5A") %>%
  dyRangeSelector() %>%
  dyCrosshair(direction = "vertical") %>%
  dyHighlight(highlightCircleSize = 5, highlightSeriesBackgroundAlpha = 0.2, hideOnMouseOut = FALSE)  %>%
  dyRoller(rollPeriod = 1)
p

# Stationnarit? 

library(tseries)
adf.test(data$Voltage) # rejet de HO
kpss.test(data$Voltage) # rejet de HO

# ACF PACF

acf(data$Voltage, lag.max = 50) 
pacf(data$Voltage, lag.max = 50)

# Diff?renciation saisonni?re

VOLT_diff24 = diff(data$Voltage, lag=24) # d=0 et D=1

# graph incr?ments saisonniers
library(ggplot2)
index= 1 : 8738
df <- data.frame(index,VOLT_diff24)
ggplot(df,aes(x=index,y=VOLT_diff24))+geom_line(colour="steelblue")+ylab("Diff?renciation saisonnière")+xlab("x")

# Stationnarit? des incr?ments saisonniers
adf.test(VOLT_diff24) # rejet de HO
kpss.test(VOLT_diff24) 

# ACF et PACF (incr?ments saisonniers)

acf(VOLT_diff24)
pacf(VOLT_diff24)

# Diff?renciation locale et saisonni?re

VOLT_DIFF24D=diff(diff(data$Voltage,lag=24)) #d=1 et D=1

# graph 
index= 1 : 8737
df <- data.frame(index, VOLT_DIFF24D)
ggplot(df,aes(x=index,y=VOLT_DIFF24D))+geom_line(colour="steelblue")+ylab("Diff?renciation locale et saisonni?re saisonni?re")+xlab("x")

# Stationnarit?

adf.test(VOLT_DIFF24D) # rejet de HO
kpss.test(VOLT_DIFF24D)

# ACF et PACF 

acf(VOLT_DIFF24D)
pacf(VOLT_DIFF24D,ylim=c(-1,1))

# fonction check-up

checkupRes = function(Res){
  
  # Partitionnement de la fenetre graphique 
  layout(matrix(c(1,1,1,2:7), nrow=3, ncol=3, byrow=TRUE))
  
  # Serie des residus
  plot(Res, type="l", col="black", main="Évolution de la série", xlab="t", ylab=expression(epsilon[t]))
  
  # ACF/PACF
  acf(as.numeric(Res), lag.max=40, main="ACF", ylab="ACF", ylim=c(-0.1,0.1))
  pacf(as.numeric(Res), lag.max=40, main="PACF", ylab="PACF",ylim=c(-0.1,0.1))
  
  # Nuage de points avec dÃ©calage de 1 dans le temps
  n = length(Res)
  plot(Res[1:(n-1)], Res[2:n],main="Res[i] en fonction de Res[i-1]", type="p", col="black", xlab=expression(epsilon[t-1]), ylab=expression(epsilon[t]))
  
  # Histogramme
  hist(Res, breaks=sqrt(n), freq=FALSE, col="black", main="Histogramme", ylab="Dens")
  curve(dnorm(x, m=mean(Res), sd=sd(Res)), col="orange", lty=2, add=TRUE)
  
  # QQ plots
  qqnorm(Res, xlab="N(0,1)", ylab="Quant Emp", main="QQplot",col="black")
  qqline(Res, distribution=qnorm, lty=2,col="orange")
  
  # Nuage de points standardisÃ©
  plot((Res-mean(Res))/sd(Res), type="p",col="black", main="Série centrée/réduite", xlab="t", ylab=expression(paste("std ", epsilon[t])))
  abline(h=c(-1.96, 1.96), lty=2, col="orange")
}


# Les modèles 

library(forecast)
auto.arima(ts(data$Voltage,frequency=24), d=0, D=1, max.p=5, max.q=5, max.P=1, max.Q=1, allowdrift=TRUE, seasonal=TRUE, ic="bic")
auto.arima(ts(data$Voltage,frequency=24), d=1, D=1, max.p=5, max.q=5, max.P=1, max.Q=1, allowdrift=TRUE, seasonal=TRUE, ic="bic")

X = data$Voltage

# modèle issu de auto-arima avec d=0 et D=1
Mod1 <- Arima(X,order=c(1,0,0), seasonal=list(order=c(1,1,0),period=24)) # Mod_auto_arima2 (pre_analyse_donnees.R)

# issu de l'observation de l'ACF et la PACF 
Mod2 <- Arima(X, order=c(0,1,1), seasonal=list(order=c(0,1,1),period=24)) # Mod_obs (pre_analyse_donnees.R)

Mod3 <- Arima(X, order=c(3,1,1), seasonal=list(order=c(1,1,1),period=24)) # Mod_voisin1 (pre_analyse_donnees.R)

summary(Mod1)
summary(Mod2)
summary(Mod3)

# Modèle 1 
checkupRes(Mod1$residuals) 
shapiro.test(Mod1$residuals[0:5000]) # rejet normalite
Box.test(Mod1$residuals, lag =24, type = "Ljung-Box") # rejet bruit blanc

# Prédictions 

n=length(X)
XT = X[1:(n-24*7)] # prédiction sur une semaine

Mod1T <- Arima(XT, order=c(1,0,0), seasonal=list(order=c(1,1,0),period=24))
Pred1T = forecast(Mod1T, h=24*7)

Ntps = (n-24*7+1):n

plot(Ntps, X[Ntps], type='l',lwd=2,main="Prédiction du modèle 1 sur la dernière période",xlab="mois",ylab="tension")

lines(Ntps, Pred1T$mean, type="l", col="purple")
legend(x = "bottomright",          # Position
       inset = 0.05,
       legend = "Pred1T",  # Legend texts
       lty = 1,           # Line types
       col = "purple",           # Line colors
       lwd = 1)                 # Line width

# MSE
Ntps=(n-24*7+1):n
MSE1 = sum ((X[Ntps] - Pred1T$mean)**2)/(24*7)
MSE1

# Modèle 2 
checkupRes(Mod2$residuals) 
shapiro.test(Mod2$residuals[0:5000]) # rejet normalite
Box.test(Mod2$residuals, lag =24, type = "Ljung-Box") # rejet bruit blanc

# Prédictions 

n=length(X)
XT = X[1:(n-24*7)] # prédiction sur une semaine

Mod2T <- Arima(XT, order=c(0,1,1), seasonal=list(order=c(0,1,1),period=24))
Pred2T = forecast(Mod2T, h=24*7)

Ntps = (n-24*7+1):n

plot(Ntps, X[Ntps], type='l',lwd=2,main="Prédiction du modèle 2 sur la dernière période",xlab="mois",ylab="tension")

lines(Ntps, Pred2T$mean, type="l", col="purple")
legend(x = "bottomright",          # Position
       inset = 0.05,
       legend = "Pred2T",  # Legend texts
       lty = 1,           # Line types
       col = "purple",           # Line colors
       lwd = 1)                 # Line width

# MSE
Ntps=(n-24*7+1):n
MSE2 = sum ((X[Ntps] - Pred2T$mean)**2)/(24*7)
MSE2

# Modèle 3 
checkupRes(Mod3$residuals) 
shapiro.test(Mod3$residuals[0:5000]) # rejet normalite
Box.test(Mod3$residuals, lag =24, type = "Ljung-Box") # rejet bruit blanc

# Prédictions 

n=length(X)
XT = X[1:(n-24*7)] # prédiction sur une semaine

Mod3T <- Arima(XT, order=c(3,1,1), seasonal=list(order=c(1,1,1),period=24)) 
Pred3T = forecast(Mod3T, h=24*7)

Ntps = (n-24*7+1):n

plot(Ntps, X[Ntps], type='l',lwd=2,main="Prédiction du modèle 3 sur la dernière période",xlab="mois",ylab="tension")

lines(Ntps, Pred1T$mean, type="l", col="purple")
legend(x = "bottomright",          # Position
       inset = 0.05,
       legend = "Pred3T",  # Legend texts
       lty = 1,           # Line types
       col = "purple",           # Line colors
       lwd = 1)                 # Line width

# MSE
Ntps=(n-24*7+1):n
MSE3 = sum ((X[Ntps] - Pred3T$mean)**2)/(24*7)
MSE3

# RECAP 

BIC = data.frame(Mod1$bic,Mod2$bic,Mod3$bic)
BIC

MSE = data.frame(MSE1,MSE2,MSE3)
MSE


# Graph des prévisions de la dernière période tronquée 

n=length(data$Voltage)
XT = data$Voltage[1:(n-24*7)] # prédiction sur une semaine

plot(Ntps, X[Ntps], type='l',lwd=2,main="Prédiction des modèles sur la dernière période",xlab="mois",ylab="tension")
lines(Ntps, Pred1T$mean, type="l", col="purple")
lines(Ntps, Pred2T$mean, type="l", col="blue")
lines(Ntps, Pred3T$mean, type="l", col="red")
legend(x = "bottomright",          # Position
       inset = 0.05,
       legend = c("Pred1T","Pred2T","Pred3T"),  # Legend texts
       lty = 1,           # Line types
       col = c("purple","blue","red"),           # Line colors
       lwd = 1)                 # Line width

# On garde le modèle qui minimise le MSE, c'est-à-dire le modèle 2.

# Prédiction de la prochaine semaine

X = data$Voltage
Mod = Arima(X, order=c(0,1,1), seasonal=list(order=c(0,1,1),period=24)) 
Pred = forecast(Mod, h=24*2)

# Graph
X = data$Voltage
Tps=8500:8762
n=length(Tps)
NTps=(n+1):(n+24*2)
plot(X[Tps], type="l", lwd=2,xlim=c(0, 300),ylim=c(225,255), xlab="Mois",ylab="Tension",main="Prédiction sur 2 périodes")
polygon(c(NTps, rev(NTps)), c(Pred$upper[,1], rev(Pred$lower[,1])), col="grey", border=FALSE)
lines(NTps, Pred$mean, type="l", lwd=2, col="blue")
lines(NTps, Pred$lower[,1], type="l", lty=2, col="blue")
lines(NTps, Pred$upper[,1], type="l", lty=2, col="blue")
legend("bottomleft", legend=c("Pred", "IP 80%"), col="blue", lty=1:2, lwd=c(2,1))

