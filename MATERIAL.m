classdef MATERIAL < handle
    
    properties
        
        id
        YoungModule
        PoissonCoef
        Density
        
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