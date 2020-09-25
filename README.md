# Covid 19 en Belgique : Shiny dashboard

Ce petit projet a pour objectif de montrer que l'on peut réaliser très simplement une application shiny dashboard sur une sujet aussi complexe que le Coronavirus en Belgique avec des notions de base en R.

Un étudiant un peu curieux qui a suivi le cours [Science des données biologiques I ](http://biodatascience-course.sciviews.org/sdd-umons/) et qui a lu les ressources ci-dessous est tout à fait capable de faire ce type d'application. Il est même plus que certain qu'il serait capable de faire 1000 fois mieux. 

- <https://mastering-shiny.org>
- <https://rstudio.github.io/shinydashboard/index.html>


## Workflow idéal

Afin de suivre la logique de dévelopement de ce projet, je vous conseille de commencer par lire les documents se trouvant dans le dossier `docs`. Avant de se lancer dans la création d'une application shiny, il faut 

- trouver des données utilisables sur le sujet d'intérêt
- analyser ces données (réaliser quelques graphiques, calculer des indices pertinents,...)
- réaliser une prototype de l'app shiny (le faire à la main sur une feuille de papier est tout aussi bien que de le dessiner sur un ordinateur)
- réaliser l'app shiny

**Ce que j'explique est bien beau mais j'avoue ne pas avoir respecté les étapes scrupuleusement.**

## Contexte

Ce projet a été initié avant que Sciensano ne propose son dashboard. Entre temps, ils ont développé un [dashboard](https://datastudio.google.com/embed/u/0/reporting/c14a5cfc-cab7-4812-848c-0369173148ab/page/ZwmOB) afin de transmettre l'évolution de la situation épidémiologique. Il faut croire que mon idée n'etait pas si bête que cela.

J'ai tout d'abord réalisé un premier dashboard que vous pouvez retrouver dans le dossier `app`. Fin septembre 2020, j'ai décidé de me relancer sur ce projet. Mon premier dashboard s'intéressait à la situation dans les hopitaux (j'explique dans le dossier docs, la raison de mon intérêt pour les hopitaux.). Ce dernier n'est plus en accord avec la situation épidémiologique et ne me permet plus de suivre l'évolution de la situation. J'ai donc décider de proposer un nouveau dashboard `app02`.


