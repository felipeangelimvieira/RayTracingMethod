
classdef NODE<handle
    
    properties
       
        % Identification du noeud
        id
        
        % Position du noeud
        x
        y
        z
        
        % Masse, Raideur et Amortissement
        M
        K
        C
        
        % Liaisons du noeud
        DeltaFree
        e1
        e2
        e3
        
        % Optimisation de Calcul
        static
        
    end
    
    methods
        

    end
end
