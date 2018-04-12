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
                                         0                                  0                                 0  -obj.E*obj.IOut*1i*(obj.kfOut(w)^3)      obj.E*obj.IOut*(obj.kfOut(w)^3)                                         0;
                                         0                                  0                                 0                                    0                                  0                -1i*obj.G*(obj.J)*obj.kr(w);
                                         0                                  0                                 0      obj.E*obj.IOut*(obj.kfOut(w)^2)    -obj.E*obj.IOut* (obj.kfOut(w)^2)                                         0;
                                         0    -obj.E*obj.IIn*(obj.kfIn(w)^2)    obj.E*obj.IIn* (obj.kfIn(w)^2)                                    0                                   0                                          0;];
        end
        function X = PhiNeg(obj,w)
            X = [ obj.E*obj.S*1i*obj.kt(w)                                  0                                 0                                  0                                  0                                        0;
                                         0   obj.E*obj.IIn*1i*(obj.kfIn(w)^3)   -obj.E*obj.IIn* (obj.kfIn(w)^3)                                  0                                  0                                        0;
                                         0                                  0                                 0  obj.E*obj.IOut*1i*(obj.kfOut(w)^3)     -obj.E*obj.IOut*(obj.kfOut(w)^3)                                       0;
                                         0                                  0                                 0                                  0                                  0                1i*obj.G*(obj.J)*obj.kr(w);
                                         0                                  0                                 0   obj.E*obj.IOut* (obj.kfOut(w)^2)     -obj.E*obj.IOut*(obj.kfOut(w)^2)                                       0;
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

        function Show(obj)
            
            X = [obj.nodeNeg.r(1) obj.nodePos.r(1)];
            Y = [obj.nodeNeg.r(2) obj.nodePos.r(2)];
            Z = [obj.nodeNeg.r(3) obj.nodePos.r(3)];
            
            p = plot3(X,Y,Z);   
            p.Color = 'k';
            
            hold on;
            
        end
        function ShowReferential(obj,scale)
            x = (obj.nodeNeg.r(1) + obj.nodePos.r(1))/2;
            y = (obj.nodeNeg.r(2) + obj.nodePos.r(2))/2;
            z = (obj.nodeNeg.r(3) + obj.nodePos.r(3))/2;
            
            X = [x];
            Y = [y];
            Z = [z];
            
            X = [X x + obj.e2(1) * ( 0.05 * scale * obj.L)] ;
            Y = [Y y + obj.e2(2) * ( 0.05 * scale * obj.L)] ;
            Z = [Z z + obj.e2(3) * ( 0.05 * scale *  obj.L)] ;
            
            X = [X x + obj.e1(1) * ( 0.15 * scale *  obj.L)] ;
            Y = [Y y + obj.e1(2) * ( 0.15 * scale *  obj.L)] ;
            Z = [Z z + obj.e1(3) * ( 0.15 * scale *  obj.L)] ;
            
            fill3(X,Y,Z,'g');
            
            X = [x];
            Y = [y];
            Z = [z];
            
            X = [X x + obj.e3(1) * ( 0.05 * scale *  obj.L)] ;
            Y = [Y y + obj.e3(2) * ( 0.05 * scale *  obj.L)] ;
            Z = [Z z + obj.e3(3) * ( 0.05 * scale *  obj.L)] ;
            
            X = [X x + obj.e1(1) * ( 0.15 * scale *  obj.L)] ;
            Y = [Y y + obj.e1(2) * ( 0.15 * scale *  obj.L)] ;
            Z = [Z z + obj.e1(3) * ( 0.15 * scale *  obj.L)] ;
            
            fill3(X,Y,Z,'r');
            
            hold on;
        end
        function ShowDeformated(obj,W,w)
            
            nDiv = obj.IdealNumberPlotPoints(w);
            
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
                u = abs(u(1:3)).*real(u(1:3))./abs(real(u(1:3)));
                
                X = [X ( s(1) + u(1) + obj.nodeNeg.r(1))];
                Y = [Y ( s(2) + u(2) + obj.nodeNeg.r(2))];
                Z = [Z ( s(3) + u(3) + obj.nodeNeg.r(3))];
                
            end
            
            p = plot3(X,Y,Z);   
            p.Color = 'k';
            hold on;
            
        end
        
        function x = DisplacementAtPoint(obj,W,w,s)
            if s > obj.L | s < 0
                error('Point not incluse in beam');
            end
            WPos = W(1:6);
            WNeg = W(7:12);
            u = real(obj.Rotation*obj.PsiPos(w)*obj.Delta(w,norm(s))*WPos + obj.Rotation*obj.PsiNeg(w)*obj.Delta(w,obj.L - norm(s))*WNeg);
            x = norm(u(1:3));
        end
        function x = IdealNumberPlotPoints(obj,w)
            
            % We chose here 13 points for showing one sinus half-period
            nIdealFlexIn  = ceil( 12 * (obj.L/((pi)/obj.kfIn(w)))) ;
            nIdealFlexOut = ceil( 12 * (obj.L/((pi)/obj.kfOut(w))));
            n = max([nIdealFlexIn nIdealFlexOut]);
            if n < 12
                x = 12;
                return
            end
            x = n;
            
        end
        function x = DisplacementMax(obj,W,w)
            
            nDiv = obj.IdealNumberPlotPoints(w);
            WPos = W(1:6);
            WNeg = W(7:12);
            U = [];
            for i=0:(nDiv-1)
                
                s = obj.e1 * obj.L * ( i / (nDiv - 1) );
                u = obj.Rotation*obj.PsiPos(w)*obj.Delta(w,norm(s))*WPos + obj.Rotation*obj.PsiNeg(w)*obj.Delta(w,obj.L - norm(s))*WNeg;
                u = norm(real(u(1:3)));
                U = [U u];
                
            end
            x = max(U,[],2);
            
        end
        
    end
    
end