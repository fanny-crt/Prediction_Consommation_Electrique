
#1) GESTION DES DATA

#importer data
df_household <- read.csv(file = ("data.csv"), header = TRUE, sep = ",")

#on extrait les colonnes qui nous interesse
df_extrait_household = df_household[,c(2,3,6)]
head(df_extrait_household)


#On recupere les dernieres annees, pour completer les valeurs manquantes. 
#On prend toutes les donnees entre les dates : 
#- 26/11/2007 00:00:00 (ligne = 495757)
#- 26/11/2010 00:00:00 (ligne = 2073997)
df_extrait_date_household = df_extrait_household[495757:2073997,]
df_extrait_date_household$Voltage <- as.numeric(df_extrait_date_household$Voltage)
head(df_extrait_date_household)
tail(df_extrait_date_household)
 


#2) GESTION DES DATES 

#on echantillonne en fonction des heures et plus des minutes 
date_heure = cut(as.POSIXct(paste(df_extrait_date_household$Date, df_extrait_date_household$Time), format="%d/%m/%Y %H:%M:%S"), breaks="hour")

#on met dans un nouveau data frame et on converti voltage en numeric 
df_extrait_date2_household = cbind(date_heure,df_extrait_date_household)

#on fait une moyenne du voltage sur en focntion des heures 
df_moyenne_household <- aggregate(Voltage ~ date_heure, df_extrait_date2_household, mean)
head(df_moyenne_household)
tail(df_moyenne_household)

#Il y a des valeurs manquantes, on rajoute les dates dont le releve est manquant 
library(tidyverse)
df_moyenne_household$date_heure <- as.POSIXct(df_moyenne_household$date_heure)

datetime_begin="2007-11-26 00:00:00"
datetime_end="2010-11-26 00:00:00"
# création d'une liste avec touts les dates du 14/11/09 au 26/11/10 échantillonné à 1h
ts <- seq.POSIXt(as.POSIXct(datetime_begin,'%y/%m/%d %H:%M:%S'), as.POSIXct(datetime_end,'%y/%m/%d %H:%M:%S'), by="hour")
df_ts <- data.frame(date_heure=ts)

df_moyenne_allDate_household <- full_join(df_moyenne_household, df_ts, by="date_heure")
head(df_moyenne_allDate_household)
tail(df_moyenne_allDate_household)



#3) Imputer les valeurs manquantes : avec snaive() pour les plages de plusieurs jours et en utilisant la valur precedente si c'est un cas isole 
library(xts)
library(tidyverse)
library(dygraphs)
library(lubridate)

df_moyenne_allDate_household$date_heure <- ymd_hms(df_moyenne_allDate_household$date_heure)

#on affiche le graphique pour reperer les plages de donnees manquantes
don <- xts(x = df_moyenne_allDate_household$Voltage, order.by = df_moyenne_allDate_household$date_heure)
p <- dygraph(don) %>%
  dyOptions(useDataTimezone = TRUE, fillGraph=TRUE, fillAlpha=0.1, drawGrid = FALSE, colors="#D8AE5A") %>%
  dyRangeSelector() %>%
  dyCrosshair(direction = "vertical") %>%
  dyHighlight(highlightCircleSize = 5, highlightSeriesBackgroundAlpha = 0.2, hideOnMouseOut = FALSE)  %>%
  dyRoller(rollPeriod = 1)
p


#Toutes les valeurs manquantes sont a la fin du dataframe, on ordonne les mesures en fonction de la date
df_moyenne_allDate_household$date_heure <- as.POSIXct( df_moyenne_allDate_household$date_heure , format = "%y/%m/%d %H:%M:%S")
ordre_df <- df_moyenne_allDate_household[ order(df_moyenne_allDate_household$date_heure),]

#remttre un index de 1 a 26306 propre (car en changeant l'ordre l'index etait mis n'importe comment)
rownames(ordre_df) <- 1:nrow(ordre_df) 
tail(ordre_df)





#On utilise snaive sur les periodes ou il y a des valeurs manquantes. 
library(forecast)
#----du 12 juin 2009 au 15 juin 2009 
df_pour_1 <- ordre_df[0:13560,] #on recupere toutes les data avant la premiere valeur manquante


#on creer un objet ts
firstHour <- 24*(as.Date("2007-11-25 23:00:00")-as.Date("2007-1-1 00:00:00"))
ts_pour_1<-ts(df_pour_1$Voltage, start=c(2007,firstHour), frequency=365*24)

#snaiv()
pred1 = snaive(ts_pour_1, h=54)


v = pred1$mean #recuperer seulement les "valeurs predites"

for (i in 13561:13614){
  ordre_df[i,2] <- v[i-13560]
}
ordre_df[13559:13616,]
 

#-----du 12 janvier au 14 janvier 2010

df_pour_2 <- ordre_df[0:18687,] 
#head(df_pour_2)
#tail(df_pour_2)


#on creer un objet ts
firstHour <- 24*(as.Date("2007-11-25 23:00:00")-as.Date("2007-1-1 00:00:00"))
ts_pour_2<-ts(df_pour_2$Voltage, start=c(2007,firstHour), frequency=365*24)

#snaiv()
pred2 = snaive(ts_pour_2, h=52) 


v = pred2$mean 


for (i in 18688:18739){
  ordre_df[i,2] <- v[i-18687]
}
ordre_df[18688:18739,]
 

#---du 17 aout au 22 aout 2010

df_pour_3 <- ordre_df[0:23901,] #on recupere toutes les data avant la premiere valeur manquante
#head(df_pour_3)
#tail(df_pour_3)


#on creer un objet ts
firstHour <- 24*(as.Date("2007-11-25 23:00:00")-as.Date("2007-1-1 00:00:00"))
ts_pour_3<-ts(df_pour_3$Voltage, start=c(2007,firstHour), frequency=365*24)

#snaiv()
pred3 = snaive(ts_pour_3, h=119) 


v = pred3$mean 


for (i in 23902:24020){
  ordre_df[i,2] <- v[i-23901]
}
 

#---du 25 sept au 28 sept 2010

df_pour_4 <- ordre_df[0:24819,] #on recupere toutes les data avant la premiere valeur manquante
#head(df_pour_4)
#tail(df_pour_4)


#on creer un objet ts
firstHour <- 24*(as.Date("2007-11-25 23:00:00")-as.Date("2007-1-1 00:00:00"))
ts_pour_4<-ts(df_pour_4$Voltage, start=c(2007,firstHour), frequency=365*24)

#snaiv()
pred4 = snaive(ts_pour_4, h=87) 


v = pred4$mean 

for (i in 24820:24906){
  ordre_df[i,2] <- v[i-24819]
}
 


#on assigne la valeur precedente (car pour certaine dates ont a pas la valeur de l'annee precedente)
  
#on recupere les lignes ou il y a des NA
indligneNA <- which(is.na(ordre_df),arr.ind=TRUE)[,1]
indligneNA

for (i in indligneNA){
  ordre_df[i,2] <- ordre_df[(i-1),2]}

##on recupere les lignes ou il y a des NA (verification)
#indligneNA <- which(is.na(ordre_df),arr.ind=TRUE)[,1]
#indligneNA
 
  
#on affiche la serie avec les valeurs imputees
ordre_df$date_heure <- ymd_hms(ordre_df$date_heure)

don <- xts(x = ordre_df$Voltage, order.by = ordre_df$date_heure)
p <- dygraph(don) %>%
  dyOptions(useDataTimezone = TRUE, fillGraph=TRUE, fillAlpha=0.1, drawGrid = FALSE, colors="#D8AE5A") %>%
  dyRangeSelector() %>%
  dyCrosshair(direction = "vertical") %>%
  dyHighlight(highlightCircleSize = 5, highlightSeriesBackgroundAlpha = 0.2, hideOnMouseOut = FALSE)  %>%
  dyRoller(rollPeriod = 1)
p
 



  
#ON EXTRAIT NOS DONNEEES DANS UN NOUVEAUX DATA FRAME (en prenant du 26 nov 2009 au 26 dec 2009)
df_household_VF <- ordre_df[17546:26306,]
rownames(df_household_VF) <- 1:nrow(df_household_VF)
 

df_household_VF$date_heure <- ymd_hms(df_household_VF$date_heure)

don <- xts(x = df_household_VF$Voltage, order.by = df_household_VF$date_heure)
p <- dygraph(don) %>%
  dyOptions(useDataTimezone = TRUE, fillGraph=TRUE, fillAlpha=0.1, drawGrid = FALSE, colors="#D8AE5A") %>%
  dyRangeSelector() %>%
  dyCrosshair(direction = "vertical") %>%
  dyHighlight(highlightCircleSize = 5, highlightSeriesBackgroundAlpha = 0.2, hideOnMouseOut = FALSE)  %>%
  dyRoller(rollPeriod = 1)
p
 