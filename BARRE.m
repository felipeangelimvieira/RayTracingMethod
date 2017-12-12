classdef BARRE
    
    properties
        rho
        S
        E
        I
        L
        noeuds
    end
    
    methods
        
        function obj = BARRE(a,b,c,d,noeud1,noeud2)
         obj.rho = a;
         obj.S   = b;
         obj.E   = c;
         obj.I   = d;
         obj.L   = sqrt((noeud1.x - noeud2.x)^2 + (noeud1.y - noeud2.y)^2);
         obj.noeuds = [noeud1,noeud2];
        end
       
        function x = kt(obj,w)
            x = (w)*sqrt(obj.rho/obj.E);
        end
        
        function x = kf(obj,w)
            x = sqrt(w*sqrt((obj.rho*obj.S)/(obj.E*obj.I)));
        end
        
        function X = Delta(obj,w)
            X = diag( [exp( -1i * obj.L * obj.kt(w))  exp( -1i * obj.L * obj.kf(w))  exp( -1 * obj.L * obj.kf(w)) ] );
        end
        function npos = noeudPositive(obj)
            npos = obj.noeuds(1);
            if obj.noeuds(2).x > obj.noeuds(1).x
                npos = obj.noeuds(2);
            end
        end
        
        function nneg = noeudNegative(obj)
            nneg = obj.noeuds(1);
            if obj.noeuds(2).x < obj.noeuds(1).x
                nneg = obj.noeuds(2);
            end
        end
        
        function bool = isNoeudPositive(obj,noeud)
            bool = noeud== obj.noeudPositive;
        end
        
        function bool = equals(obj,barre)
            bool = and(obj.L == barre.L, obj.noeuds == barre.noeuds);
        end
                
        
    end
end