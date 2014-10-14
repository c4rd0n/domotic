domotic
=======

Le but de ce projet est d'hébegé un serveur domotique sur un RaspBerry Pi afin de suivre et contrôler le fonctionnement de sa chaudière.

Dans mon contexte particulier, j'utilise un Raspberry pi b+.
J'y ai installé domoticz en suivant le tutoriel ["Installing from source"](http://www.domoticz.com/wiki/Installing_and_running_Domoticz_on_a_Raspberry_PI)

Ma chaudière est une chaudière Viessman vitoladens 300c pilotée par la régulation vitotronic 200 et accompagnée 'une commande à distance vitotrol 200.
Pour communiqué avec la chaudière j'utilise le soft vcontrold fournit par la communauté openv. J'ai suivi ce [tutoriel](http://openv.wikispaces.com/vcontrold+mit+Raspberry+Pi)

Dans ce dépot vous trouverez les fichier de configuration pour vcontrol ainsi que les scripts lua pour domoticz
