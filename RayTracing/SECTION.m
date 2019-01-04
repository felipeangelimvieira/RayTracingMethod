classdef SECTION < handle
    
    properties
        
        id %Integer identifying the section type
        
        %----Properties-----
        Area %Section's Area
        SecondMomentIn %Second Moment of Area in the referential plane
        SecondMomentOut %Second Moment of Area in the orthogonal direction of the referential plane
        TorsionMoment %Moment de Torsion de la section
        
        
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