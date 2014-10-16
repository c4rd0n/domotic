domotic
=======

Le but de ce projet est d'hébeger un serveur domotique sur un RaspBerry Pi afin de suivre et contrôler le fonctionnement de sa chaudière.

Dans mon contexte particulier, j'utilise un Raspberry pi b+.
J'y ai installé domoticz en suivant le tutoriel ["Installing from source"](http://www.domoticz.com/wiki/Installing_and_running_Domoticz_on_a_Raspberry_PI).

Ma chaudière est une chaudière Viessman vitoladens 300c pilotée par la régulation vitotronic 200 et accompagnée d'une commande à distance vitotrol 200.
Pour communiquer avec la chaudière j'utilise le soft vcontrol fournit par la communauté openv. J'ai suivi ce [tutoriel](http://openv.wikispaces.com/vcontrold+mit+Raspberry+Pi).

Dans ce dépot vous trouverez les fichiers de configuration pour vcontrol ainsi que les scripts lua pour domoticz

Tester le bon fonctionnement du port UART ([sources](http://www.raspberry-projects.com/pi/programming-in-c/uart-serial-port/using-the-uart))
-----------------------------------------

__1__ - [Désactiver l'utilisation du port UART pour la console](http://www.raspberry-projects.com/pi/pi-operating-systems/raspbian/io-pins-raspbian/uart-pins)

__2__ - Installer minicom
> sudo apt-get install minicom

__3__ - Connecter les GPIO 8 et 10 (TX et RX) du Raspberry

__4__ - Ouvrir une session minicom
> minicom -b 115200 -o -D /dev/ttyAMA0

__5__ - Vérifier que minicom reçoit bien ce que l'on saisit.

Si cela ne fonctionne pas vous pouvez modifier les droits d'accès de la façon suivante :
> sudo chmod a+rw /dev/ttyAMA0
