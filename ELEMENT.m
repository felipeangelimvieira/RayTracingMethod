classdef ELEMENT<handle
    
    properties
        
        % Identification de l'element
        id
        
        % Noeuds à l'extremité
        noeudPos
        noeudNeg
        
        % Propriétés Physiques et Geometriques
        rho
        S
        E
        G
        IIn
        IOut
        L
        
        % Repère de l'element
        e1
        e2
        e3
        
    end
    
    methods
        
        function obj =  ELEMENT(id,noeudNeg,noeudPos,rho,S,E,G,IIn,IOut)
            
            obj.id = id;
            obj.rho = rho;
            obj.S = S;
            obj.E = E;
            obj.G = G;
            obj.IIn = IIn;
            obj.IOut = IOut;
            
            posNoeudPos = [noeudPos.x ; noeudPos.y; noeudPos.z];
            posNoeudNeg = [noeudNeg.x ; noeudNeg.y; noeudNeg.z];
            
            obj.L = norm( posNoeudPos - posNoeudNeg );
            obj.e1 = ( posNoeudPos - posNoeudNeg ) / obj.L;
            
        end
        
        function x = kt(obj,w)
            x = w * sqrt( obj.rho / obj.E ) ;
        end
        function x = kr(obj,w)
            x = w * sqrt( obj.rho / obj.G ) ;
        end
        function x = kfIn(obj,w)
            x = sqrt( w * sqrt( (obj.rho*obj.S)/(obj.E*obj.IIn) ) ) ;
        end
        function x = kfOut(obj,w)
            x = sqrt( w * sqrt( (obj.rho*obj.S)/(obj.E*obj.IOut) ) ) ;
        end  
        
        function X = PsiPos(obj,w)
            X = [ 1                 0                0                0                  0      0;
                  0                 1                1                0                  0      0;
                  0                 0                0                1                  1      0;
                  0                 0                0                0                  0      1;
                  0                 0                0   1i*obj.kfOut(w)   1i*obj.kfOut(w)      0;
                  0    -1i*obj.kfIn(w)   -1i*obj.kfIn(w)                0                0      0;];
        end
        function X = PsiNeg(obj,w) 
            X = [ 1                 0                  0                0                 0       0;
                  0                 1                  1                0                 0       0;
                  0                 0                  0                1                 1       0;
                  0                 0                  0                0                 0       1;
                  0                 0                  0  -1i*obj.kfOut(w)  -1i*obj.kfOut(w)      0;
                  0     1i*obj.kfIn(w)    1i*obj.kfIn(w)                0                 0       0;];
        end
        function X = PhiPos(obj,w)
            X = [ -obj.E*obj.S*1i*obj.kt(w)                                0                                 0                                    0                                  0                                       0;
                                         0  obj.E*obj.IIn*1i*(obj.kfIn(w)^3)   -obj.E*obj.IIn* (obj.kfIn(w)^3)                                    0                                  0                                       0;
                                         0                                 0                                 0   obj.E*obj.IOut*1i*(obj.kfOut(w)^3)     -obj.E*obj.IIn*(obj.kfOut(w)^3)                                      0;
                                         0                                 0                                 0                                    0                                  0    obj.G*(obj.IIn + obj.IOut)*obj.kt(w);
                                         0                                 0                                 0     -obj.E*obj.IOut*(obj.kfOut(w)^2)    obj.E*obj.IIn* (obj.kfOut(w)^2)                                       0;
                                         0    -obj.E*obj.IIn*(obj.kfIn(w)^2)    obj.E*obj.IIn* (obj.kfIn(w)^2)                                    0                                  0                                       0;];
        end
        function X = PhiNeg(obj,w)
            X = [ obj.E*obj.S*1i*obj.kt(w)                                  0                                 0                                  0                                  0                                        0;
                                         0  -obj.E*obj.IIn*1i*(obj.kfIn(w)^3)    obj.E*obj.IIn* (obj.kfIn(w)^3)                                  0                                  0                                        0;
                                         0                                  0                                 0  -obj.E*obj.IOut* (obj.kfOut(w)^3)      obj.E*obj.IIn*(obj.kfOut(w)^3)                                       0;
                                         0                                  0                                 0                                  0                                  0    -obj.G*(obj.IIn + obj.IOut)*obj.kt(w);
                                         0                                  0                                 0  -obj.E*obj.IOut* (obj.kfOut(w)^2)      obj.E*obj.IIn*(obj.kfOut(w)^2)                                       0;
                                         0    -obj.E*obj.IIn* (obj.kfIn(w)^2)    obj.E*obj.IIn* (obj.kfIn(w)^2)                                  0                                  0                                        0;];
        end
        
        function X = Delta(obj,w,s)
            X = diag( [exp(-1i*s*obj.kt(w)) exp(-1i*s*obj.kfIn(w)) exp(-s*obj.kfIn(w)) exp(-1i*s*obj.kfOut(w)) exp(-s*obj.kfOut(w)) exp(-1i*s*obj.kr(w))]);
        end
        
        function setIInAxis(obj,v)
            if ( v' * obj.e1 )< .5 :
                e2 = v - ( v' * obj.e1 ) * e1;
            else
                e2 = False;
                print("Input error: Structure Plane not coherent with elements direction")
            end
        end
    end
end