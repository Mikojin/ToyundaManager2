##############################
##  Toyunda Manager 2 v1.4  ##
##############################


Execution :
===========
> ruby ToyundaManagerMain.rb [config_file]

Si config_file n'est pas donné, un fichier config.ini sera automatiquement créé à la
racine du dossier contenant ToyundaManagerMain.rb, si le fichier existe déjà, il sera simplement lu et écrasé (attention !)


Configuration config.ini :
==========================

log_file=debug.log
  => le chemin absolu ou relatif (à l'execution) du fichier de log
  
config_path=config/
  => le chemin absolu ou relatif (à l'execution) du dossier de profile de l'application.
  
debug=0
  => Le niveau de débug, 0 : pas de log ni débug, plus le nombre est grand, plus il y a de log.
  
debug_file=0
  => Le niveau de débug écrit dans le fichier de log


Configuration de MIO :
======================

La config se fait dans le fichier configMIO.csv. Il permet de définir le port du serveur, ainsi que le chemin du fichier de log. La config doit aller dans le dossier de config du toyundaManager.
