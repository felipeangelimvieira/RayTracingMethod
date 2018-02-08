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
        J
        
        % Element's referential
        e1
        e2
        e3
        
    end
    
    methods
        
        % Definition methods
        function obj =  ELEMENT(id,nodeNeg,nodePos,nodeRef,material,section)
            
            obj.id = id;
            obj.rho = material.Density;
            obj.S = section.Area;
            obj.E = material.YoungModule;
            obj.G = ( material.YoungModule / ( 2 * ( 1 + material.PoissonCoef) ) );
            obj.IIn = section.SecondMomentIn;
            obj.IOut = section.SecondMomentOut;
            obj.J =  section.TorsionMoment;
            
            obj.nodeNeg = nodeNeg;
            obj.nodeNeg.addElement(obj);
            obj.nodePos = nodePos;
            obj.nodePos.addElement(obj);
            
            obj.L = norm( nodePos.r - nodeNeg.r );
            obj.e1 = ( nodePos.r - nodeNeg.r ) / obj.L;
            
            obj.e2 = ( nodeRef.r - nodeNeg.r );
            obj.e2 = obj.e2 - (obj.e2'*obj.e1)*obj.e1;
            obj.e2 = obj.e2/norm(obj.e2);
            obj.e3 = cross(obj.e1,obj.e2);
            
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
                  0                 0                0    1i*obj.kfOut(w)       obj.kfOut(w)     0;
                  0    -1i*obj.kfIn(w)     -obj.kfIn(w)                0                 0      0;];
        end
        function X = PsiNeg(obj,w) 
            X = [ 1                 0                  0                0                 0       0;
                  0                 1                  1                0                 0       0;
                  0                 0                  0                1                 1       0;
                  0                 0                  0                0                 0       1;
                  0                 0                  0   -1i*obj.kfOut(w)     -obj.kfOut(w)      0;
                  0     1i*obj.kfIn(w)       obj.kfIn(w)                0                 0       0;];
        end
        function X = PhiPos(obj,w)
            X = [ -obj.E*obj.S*1i*obj.kt(w)                                 0                                 0                                    0                                  0                                          0;
                                         0  -obj.E*obj.IIn*1i*(obj.kfIn(w)^3)    obj.E*obj.IIn* (obj.kfIn(w)^3)                                    0                                  0                                          0;
                                         0                                  0                                 0  -obj.E*obj.IOut*1i*(obj.kfOut(w)^3)      obj.E*obj.IIn*(obj.kfOut(w)^3)                                         0;
                                         0                                  0                                 0                                    0                                  0    -1i*obj.G*(obj.J)*obj.kt(w);
                                         0                                  0                                 0      obj.E*obj.IOut*(obj.kfOut(w)^2)    -obj.E*obj.IIn* (obj.kfOut(w)^2)                                         0;
                                         0    -obj.E*obj.IIn*(obj.kfIn(w)^2)    obj.E*obj.IIn* (obj.kfIn(w)^2)                                    0                                   0                                          0;];
        end
        function X = PhiNeg(obj,w)
            X = [ obj.E*obj.S*1i*obj.kt(w)                                  0                                 0                                  0                                  0                                        0;
                                         0   obj.E*obj.IIn*1i*(obj.kfIn(w)^3)   -obj.E*obj.IIn* (obj.kfIn(w)^3)                                  0                                  0                                        0;
                                         0                                  0                                 0  obj.E*obj.IOut*1i*(obj.kfOut(w)^3)     -obj.E*obj.IIn*(obj.kfOut(w)^3)                                       0;
                                         0                                  0                                 0                                  0                                  0    1i*obj.G*(obj.J)*obj.kt(w);
                                         0                                  0                                 0   obj.E*obj.IOut* (obj.kfOut(w)^2)     -obj.E*obj.IIn*(obj.kfOut(w)^2)                                       0;
                                         0    -obj.E*obj.IIn* (obj.kfIn(w)^2)    obj.E*obj.IIn* (obj.kfIn(w)^2)                                  0                                  0                                        0;];
        end
        
        % Displacement Operator
        function X = Delta(obj,w,s)
            X = diag( [exp(-1i*s*obj.kt(w)) exp(-1i*s*obj.kfIn(w)) exp(-s*obj.kfIn(w)) exp(-1i*s*obj.kfOut(w)) exp(-s*obj.kfOut(w)) exp(-1i*s*obj.kr(w))]);
        end
        
        % Rotation Operator
        function X = Rotation(obj,s)
            X = [([obj.e1 obj.e2 obj.e3])                         zeros(3);
                                 zeros(3)        ([obj.e1 obj.e2 obj.e3])];
        end

        function show(obj)
            
            X = [obj.nodeNeg.r(1) obj.nodePos.r(1)];
            Y = [obj.nodeNeg.r(2) obj.nodePos.r(2)];
            Z = [obj.nodeNeg.r(3) obj.nodePos.r(3)];
            
            p = plot3(X,Y,Z);   
            p.Color = 'k';
            hold on;
            
            X = (obj.nodeNeg.r(1) + obj.nodePos.r(1))/2 ;
            Y = (obj.nodeNeg.r(2) + obj.nodePos.r(2))/2 ;
            Z = (obj.nodeNeg.r(3) + obj.nodePos.r(3))/2 ;
            
            U = obj.e1(1)*obj.L;
            V = obj.e1(2)*obj.L;
            W = obj.e1(3)*obj.L;
            
            p = quiver3(X,Y,Z,U,V,W,.15);
            p.Color = 'red';
            
            U = obj.e2(1)*obj.L;
            V = obj.e2(2)*obj.L;
            W = obj.e2(3)*obj.L;
            
            p = quiver3(X,Y,Z,U,V,W,.15);
            p.Color = 'blue';
            
            U = obj.e3(1)*obj.L;
            V = obj.e3(2)*obj.L;
            W = obj.e3(3)*obj.L;
            
            p = quiver3(X,Y,Z,U,V,W,.15);
            p.Color = 'green';
            
        end
        function showDeformated(obj,W,w,nDiv)
            
            X = [obj.nodeNeg.r(1) obj.nodePos.r(1)];
            Y = [obj.nodeNeg.r(2) obj.nodePos.r(2)];
            Z = [obj.nodeNeg.r(3) obj.nodePos.r(3)];
            
            p = plot3(X,Y,Z);   
            p.Color = 'k';
            p.LineStyle = '--';
            hold on;
            
            X = [];
            Y = [];
            Z = [];
            
            WPos = W(1:6);
            WNeg = W(7:12);
            
            for i=0:(nDiv-1)
                
                s = obj.e1 * obj.L * ( i / (nDiv - 1) );
                u = obj.Rotation*obj.PsiPos(w)*obj.Delta(w,norm(s))*WPos + obj.Rotation*obj.PsiNeg(w)*obj.Delta(w,obj.L - norm(s))*WNeg;
                u = real(u(1:3));
                
                X = [X ( s(1) + u(1) + obj.nodeNeg.r(1))];
                Y = [Y ( s(2) + u(2) + obj.nodeNeg.r(2))];
                Z = [Z ( s(3) + u(3) + obj.nodeNeg.r(3))];
                
            end
            
            p = plot3(X,Y,Z);   
            p.Color = 'k';
            hold on;
            
        end
        function showAnimatedDeformated(obj,W,w,time,nDiv)
            
            X = [obj.nodeNeg.r(1) obj.nodePos.r(1)];
            Y = [obj.nodeNeg.r(2) obj.nodePos.r(2)];
            Z = [obj.nodeNeg.r(3) obj.nodePos.r(3)];
            
            p = plot3(X,Y,Z);   
            p.Color = 'k';
            p.LineStyle = '--';
            hold on;
            
            X = [];
            Y = [];
            Z = [];
            
            WPos = W(1:6);
            WNeg = W(7:12);
            
            for i=0:(nDiv-1)
                
                s = obj.e1 * obj.L * ( i / (nDiv - 1) );
                u = obj.Rotation*obj.PsiPos(w)*obj.Delta(w,norm(s))*WPos + obj.Rotation*obj.PsiNeg(w)*obj.Delta(w,obj.L - norm(s))*WNeg;
                u = real(u(1:3));
                
                X = [X ( s(1) + time * u(1) + obj.nodeNeg.r(1))];
                Y = [Y ( s(2) + time * u(2) + obj.nodeNeg.r(2))];
                Z = [Z ( s(3) + time * u(3) + obj.nodeNeg.r(3))];
                
            end
            
            p = plot3(X,Y,Z);   
            p.Color = 'k';
            hold on;
            
        end
        
    end
    
end