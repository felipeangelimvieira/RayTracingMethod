classdef ELEMENT < handle
    
    properties
        
        % Element's indentifier
        id
        
        % Extremities Nodes
        nodePos
        nodeNeg
        
        % Physical and Geometrical Propoerties
        rho
        S
        E
        G
        IIn
        IOut
        L
        
        % Element's referential
        e1
        e2
        e3
        
    end
    
    methods
        
        % Definition methods
        function obj =  ELEMENT(id,nodeNeg,nodePos,rho,S,E,G,IIn,IOut)
            
            obj.id = id;
            obj.rho = rho;
            obj.S = S;
            obj.E = E;
            obj.G = G;
            obj.IIn = IIn;
            obj.IOut = IOut;
            
            obj.nodeNeg = nodeNeg;
            obj.nodeNeg.addElement(obj);
            obj.nodePos = nodePos;
            obj.nodePos.addElement(obj);
            
            obj.L = norm( nodePos.r - nodeNeg.r );
            obj.e1 = ( nodePos.r - nodeNeg.r ) / obj.L;
            
        end
        
        % Wave Numbers
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
        
        % Position and Effort Operators
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
            X = [ -obj.E*obj.S*1i*obj.kt(w)                                 0                                 0                                    0                                  0                                       0;
                                         0  -obj.E*obj.IIn*1i*(obj.kfIn(w)^3)    obj.E*obj.IIn* (obj.kfIn(w)^3)                                    0                                  0                                       0;
                                         0                                  0                                 0  -obj.E*obj.IOut*1i*(obj.kfOut(w)^3)      obj.E*obj.IIn*(obj.kfOut(w)^3)                                      0;
                                         0                                  0                                 0                                    0                                  0    obj.G*(obj.IIn + obj.IOut)*obj.kt(w);
                                         0                                  0                                 0      obj.E*obj.IOut*(obj.kfOut(w)^2)    -obj.E*obj.IIn* (obj.kfOut(w)^2)                                       0;
                                         0    -obj.E*obj.IIn*(obj.kfIn(w)^2)    obj.E*obj.IIn* (obj.kfIn(w)^2)                                    0                                   0                                       0;];
        end
        function X = PhiNeg(obj,w)
            X = [ obj.E*obj.S*1i*obj.kt(w)                                  0                                 0                                  0                                  0                                        0;
                                         0   obj.E*obj.IIn*1i*(obj.kfIn(w)^3)   -obj.E*obj.IIn* (obj.kfIn(w)^3)                                  0                                  0                                        0;
                                         0                                  0                                 0   obj.E*obj.IOut* (obj.kfOut(w)^3)     -obj.E*obj.IIn*(obj.kfOut(w)^3)                                       0;
                                         0                                  0                                 0                                  0                                  0    -obj.G*(obj.IIn + obj.IOut)*obj.kt(w);
                                         0                                  0                                 0   obj.E*obj.IOut* (obj.kfOut(w)^2)     -obj.E*obj.IIn*(obj.kfOut(w)^2)                                       0;
                                         0    -obj.E*obj.IIn* (obj.kfIn(w)^2)    obj.E*obj.IIn* (obj.kfIn(w)^2)                                  0                                  0                                        0;];
        end
        
        % Displacement Operator
        function X = Delta(obj,w,s)
            X = diag( [exp(-1i*s*obj.kt(w)) exp(-1i*s*obj.kfIn(w)) exp(-s*obj.kfIn(w)) exp(-1i*s*obj.kfOut(w)) exp(-s*obj.kfOut(w)) exp(-1i*s*obj.kr(w))]);
        end
        
        % Rotation Operator
        function X = Rotation(obj)
            X = [inv([e1 e2 e3])            zeros(3);
                        zeros(3)    inv([e1 e2 e3])];
        end
        
        % Post-Treatment Methods
        function setElementPlane(obj,v)
            if ( v' * obj.e1 ) < .05 
                obj.e3 = v - ( v' * obj.e1 ) * obj.e1;
                obj.e3 = obj.e3 / norm(obj.e3);
                obj.e2 = cross(obj.e3,obj.e1);
            else
                error('Input error: Structure Plane not coherent with elements direction')
            end
        end
        
    end
    
end