
classdef NOEUD<handle
    
    properties
        x
        y
        liste_barres
        liste_angles
        liste_liaisons % 0: libre ; 1: encastrement
        state % verifie si le noeud a été déjà calculé par la matrice T
    end
    
    methods
        
      function obj = NOEUD(x1,y1)
         obj.liste_barres = [];
         obj.liste_angles = [];
         obj.liste_liaisons = [];
         obj.x = x1;
         obj.y = y1;
         obj.state = 0;
      end
      
      %ajouter un pair [barre,angle] à la liste de barres qui sont liées au
      %noeud
      function obj = addBarre(obj,barre,liaison)
          %chaque barre a deux noeuds
          for i = 1:2
              if not(obj.equals(barre.noeuds(i)))
                  %angle par rapport l'axe x   
                  angle = atan((barre.noeuds(i).y - obj.y)/(barre.noeuds(i).x - obj.x));
                  if angle<0 %si besoin de l'angle positif, faire if < 0, angle+=180
                      angle = angle + pi;
                  end
                  
              end
          end
          obj.liste_barres = [obj.liste_barres barre];
          obj.liste_angles = [obj.liste_angles angle];
          obj.liste_liaisons = [obj.liste_liaisons liaison];
      end
      
      %verifie si deux noeuds sont égals
      function egalite = equals(obj,comparateur)
          egalite = and(comparateur.x == obj.x, comparateur.y == obj.y);
      end
    
      
      function nbarres = countBeams(obj)
          nbarres = size(obj.liste_barres,2);
      end
      
      function bool = isBoundary(obj)
          bool = (obj.countBeams == 1);
      end
      
      function obj = setStateAsTrue(obj)
          obj.state = true;
      end
      
      function obj = setStateAsFalse(obj)
          obj.state = false;
      end
      
      function ang = getAngle(obj)
          if obj.countBeams == 2
              ang = abs(obj.liste_angles(2) - obj.liste_angles(1));
          else
              ang = 0;
          end
      end
      
      
      
                  
                  
              
          
          
      
      
      
    end
end
