# Prediction_Consommation_Electrique

Pour ce projet, nous avons analysé un jeu de données d'EDF R&D mesurant la consommation d'énergie électrique d'un ménage sur une période de 4 ans. Notre objectif est de prédire la tension électrique du ménage.

# Code 

- R 

# Data cleaning

On a une très grande quantité de données avec un taux d'échantillonnage par minute et beaucoup de bruit. Nous avons rééchantillonné par heure en utilisant la moyenne. Pour les valeurs manquantes, nous avons imputé les données de l'année précédente à nos mesures manquantes à l'aide de la fonction snaiv() du package forecast. 

# EDA 

- Stationnarité : tests ADF et KPSS 
