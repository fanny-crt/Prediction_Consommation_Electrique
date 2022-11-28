# Prediction_Consommation_Electrique

Pour ce projet, nous avons analysé un jeu de données d'EDF R&D mesurant la consommation d'énergie électrique d'un ménage sur une période de 4 ans. Notre objectif est de prédire la tension électrique du ménage.

# Code 

- R 

# Data cleaning

On a une très grande quantité de données avec un taux d'échantillonnage par minute et beaucoup de bruit. Nous avons rééchantillonné par heure en utilisant la moyenne. Pour les valeurs manquantes, nous avons imputé les données de l'année précédente à nos mesures manquantes à l'aide de la fonction snaiv() du package forecast. 

# EDA 

- Stationnarité : tests ADF et KPSS 

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/test_ADF_KPSS.PNG)

Les tests se contredisent.

- Les autocorrélations empiriques

![alt text](https://github.com/fanny-crt/Fanny_Portfolio/blob/main/images/lagplot_multi.png)

![alt text](https://github.com/fanny-crt/Fanny_Portfolio/blob/main/images/ACF.JPG)

![alt text](https://github.com/fanny-crt/Fanny_Portfolio/blob/main/images/PACF.JPG)

Nous avons des corrélations au décalage 1 et 24. Le décalage en 1 semble "évident", la tension mesurée au temps t est naturellement proche de la tension mesurée 1 heure plus tôt. De plus, la série temporelle est périodique et non stationnaire, car nous observons un motif de période 24 (périodicité journalière). 

- Analyse des incréments saisonniers

![alt text](https://github.com/fanny-crt/Fanny_Portfolio/blob/main/images/increments_saisonniers.PNG)

- Analyse des incréments locaux et saisonniers

![alt text](https://github.com/fanny-crt/Fanny_Portfolio/blob/main/images/increments_locaux_saisonniers.PNG)
![alt text](https://github.com/fanny-crt/Fanny_Portfolio/blob/main/images/increments_locaux_saisonniers2.PNG)

