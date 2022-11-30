# Prediction_Consommation_Electrique

Pour ce projet, nous avons analysé un jeu de données d'EDF R&D mesurant la consommation d'énergie électrique d'un ménage sur une période de 4 ans. Notre objectif est de prédire la consommation d'énergie électrique du ménage.

# Code 

- R 

# Data cleaning

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/data.PNG)

On a une très grande quantité de données avec un taux d'échantillonnage par minute et beaucoup de bruit. Nous avons rééchantillonné par heure en utilisant la moyenne. Pour les valeurs manquantes, nous avons imputé les données de l'année précédente à nos mesures manquantes à l'aide de la fonction snaiv() du package forecast. 

# EDA 

- Stationnarité : tests ADF et KPSS 

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/test_ADF_KPSS.PNG)

Les tests se contredisent.

- Les autocorrélations empiriques

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/lagplot_multi.png)

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/ACF.JPG)

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/PACF.JPG)

Nous avons des corrélations au décalage 1 et 24. Le décalage en 1 semble "évident", la tension mesurée au temps t est naturellement proche de la tension mesurée 1 heure plus tôt. De plus, la série temporelle est périodique et non stationnaire, car nous observons un motif de période 24 (périodicité journalière). 

- Analyse des incréments saisonniers

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/increments_saisonniers.PNG)

- Analyse des incréments locaux et saisonniers

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/increments_locaux_saisonniers.PNG)
![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/increments_locaux_saisonniers2.PNG)

# Model Building

L’étude des différenciations nous amène à explorer les modèles de type SARIMA(p,d,q)x(P,D,Q)_{24} où (d,D)=(0,1) et (d,D)=(1,1).
Nous nous sommes principalement appuyées sur la commande auto.arima afin de déterminer les ordres p, q, P et Q et sur les résultats de l'ACF et la PACF. Nous avons choisi le modèle qui minimise le critère BIC (Bayesian Information Criterion). 

- Modèle 1 : SARIMA(1,0,0)x(1,1,0)_{24}

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/modele_1_SARIMA.PNG)

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/coef_modele_1_SARIMA.PNG)

- Modèle 2 : SARIMA(0,1,1)x(0,1,1)_{24}

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/modele_2.PNG)

- Modèle 3 : SARIMA(3,1,1)x(1,1,1)_{24}

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/modele_3.PNG)

# Model performance

![alt text](https://github.com/fanny-crt/Prediction_Consommation_Electrique/blob/main/images/model_performance.PNG)

