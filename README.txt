##############################
##  Toyunda Manager 2 v1.4  ##
##############################


Execution :
===========
> ruby ToyundaManagerMain.rb [config_file]

Si config_file n'est pas donn�, un fichier config.ini sera automatiquement cr�� � la
racine du dossier contenant ToyundaManagerMain.rb, si le fichier existe d�j�, il sera simplement lu et �cras� (attention !)


Configuration config.ini :
==========================

log_file=debug.log
  => le chemin absolu ou relatif (� l'execution) du fichier de log
  
config_path=config/
  => le chemin absolu ou relatif (� l'execution) du dossier de profile de l'application.
  
debug=0
  => Le niveau de d�bug, 0 : pas de log ni d�bug, plus le nombre est grand, plus il y a de log.
  
debug_file=0
  => Le niveau de d�bug �crit dans le fichier de log


Configuration de MIO :
======================

La config se fait dans le fichier configMIO.csv. Il permet de d�finir le port du serveur, ainsi que le chemin du fichier de log. La config doit aller dans le dossier de config du toyundaManager.
