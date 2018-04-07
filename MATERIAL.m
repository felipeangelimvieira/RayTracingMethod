classdef MATERIAL < handle
    
    properties
        
        id %Integer identifying the material type
        
        %----Properties-----
        YoungModule %Young's Module of material
        PoissonCoef %Poisson's Coeficient of material
        Density %Volumetric Mass Density of material
        
    end
    
    methods
        
        function obj = MATERIAL(id,Y,P,D)
            obj.id = id;
            obj.YoungModule = Y;
            obj.PoissonCoef = P;
            obj.Density = D;
        end
         
    end
    
end