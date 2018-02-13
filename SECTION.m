classdef SECTION < handle
    
    properties
        
        id
        Area
        SecondMomentIn
        SecondMomentOut
        TorsionMoment
        
        
    end
    
    methods
        
        function obj = SECTION(id,A,IIn,IOut,J)
            obj.id = id;
            obj.Area = A;
            obj.SecondMomentIn = IIn;
            obj.SecondMomentOut = IOut;
            obj.TorsionMoment = J;
        end
         
    end
    
end