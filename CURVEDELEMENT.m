classdef CURVEDELEMENT < handle
    
    properties
        R = inf
        center = [0 0 0];
        angle
        plane
        
        % Element's indentifier
        id
        
        % Extremities Nodes
        nodePos
        nodeNeg
        
        % Physical and Geometrical Properties
        rho
        S
        E
        G
        J
        IIn
        IOut
        L
        
        
    end
    methods
        
        function obj =  CURVEDELEMENT(id,nodeNeg,nodePos,rho,S,E,G,IIn,IOut,center,plane)
            
            obj.id = id;
            obj.rho = rho;
            obj.S = S;
            obj.E = E;
            obj.G = G;
            obj.J = IIn + IOut; %verificar
            obj.IIn = IIn;
            obj.IOut = IOut;
            obj.plane = plane/norm(plane);
            
            obj.nodeNeg = nodeNeg;
            obj.nodeNeg.addElement(obj);
            obj.nodePos = nodePos;
            obj.nodePos.addElement(obj);
            obj.center = center;            
            if (nodeNeg.r-nodePos.r)'*plane ~= 0
                error("Normal must be perpendicular to the beam's plane")
            end
            
            if norm(nodeNeg.r-center) ~= norm(nodePos.r-center)
                error('Not equidistant')
            end
            obj.R =  norm(nodeNeg.r-center);
            
            obj.angle = obj.setAngle();
            obj.L = obj.setL();
            
        end
        
        %Coupling
        function xi = Xi(obj,w,ind)
            kii = [obj.kt(w);obj.kfIn(w);-1i*obj.kfIn(w)];
            xi = [0;0;0];
            for j = 1:size(kii)
                k = kii(j);
                xi(j) = 1i*obj.E*obj.R*k*(obj.IIn*k^2 + obj.S)/(obj.rho*obj.R^2*obj.S*w^2 - (obj.E*obj.IIn*obj.R^2*k^4 + obj.E*obj.S));
            end
            xi = xi(ind);

        end
        function xo = Xo(obj,w,ind)
            koi = [obj.kr(w);obj.kfOut(w);-1i*obj.kfOut(w)]; %direction 3 out of plane
            xo = [0;0;0];
            for j = 1:size(koi)
                k = koi(j);
                xo(j) = (k*obj.R^2*(obj.G*obj.J + obj.E*obj.IOut))/(obj.rho*obj.R^2*obj.S*w^2 - (obj.E*obj.IOut*obj.R^2*k^4 + obj.G*obj.J*k^2));
            end
            xo = xo(ind);
        end
        
        function X = PsiPos(obj,w)
            X = [ 1                 1/obj.Xi(w,2)                1/obj.Xi(w,3)                0                  0      0;
                  obj.Xi(w,1)                 1                1                0                  0      0;
                  0                 0                0                1                  1      obj.Xo(w,1) ;
                  0                 0                0                1/obj.Xo(w,2)                  1/obj.Xo(w,3)      1;
                  0                 0                0    1i*obj.kfOut(w)       obj.kfOut(w)     obj.kr(w)*1i*obj.Xo(w,1);
                  -obj.kr(w)*1i*obj.Xi(w,1)    -1i*obj.kfIn(w)     -obj.kfIn(w)                0                 0      0;];
             X(isnan(X)) = 0;
             X
        end
        function X = PsiNeg(obj,w) 
            X = [ 1                 -1/obj.Xi(w,2)                -1/obj.Xi(w,3)                0                  0      0;
                  -obj.Xi(w,1)                 1                1                0                  0      0;
                  0                 0                0                1                  1      -obj.Xo(w,1) ;
                  0                 0                0                -1/obj.Xo(w,2)                  -1/obj.Xo(w,3)      1;
                  0                 0                0    -1i*obj.kfOut(w)       -obj.kfOut(w)     obj.kr(w)*1i*obj.Xo(w,1);
                  -obj.kr(w)*1i*obj.Xi(w,1)    1i*obj.kfIn(w)     obj.kfIn(w)                0                 0      0;];
        end
        function X = PhiPos(obj,w)
            A1 = -obj.E*obj.S*(1i*obj.kt(w) + obj.Xi(w,1)/obj.R);
            B1 = -obj.E*obj.S*(1i*obj.kfIn(w)/obj.Xi(w,2)+1/obj.R);
            C1 = -obj.E*obj.S*(obj.kfIn(w)/obj.Xi(w,3)+1/obj.R);
            A2 = obj.E*obj.IIn*(-obj.kt(w)^3*obj.Xi(w,1) + obj.kt(w)^2/obj.R); 
            B2 = -obj.E*obj.IIn*(1i*obj.kfIn(w)^3 - obj.kfIn(w)^2/(obj.R*obj.Xi(w,2)));
            C2 = -obj.E*obj.IIn*(-obj.kfIn(w)^3 + obj.kfIn(w)^2/(obj.R*obj.Xi(w,3)));  
            D3 = obj.E*obj.IOut*(-1i*obj.kfOut(w)^3 - 1i*obj.kfOut(w)/(obj.R*obj.Xo(w,2))) + obj.G*obj.J*(-1i*obj.kfOut(w)/(obj.R^2) - 1i*obj.kfOut(w)/(obj.R*obj.Xo(w,2)));
            
            E3 = obj.E*obj.IOut*(obj.kfOut(w)^3 - obj.kfOut(w)/(obj.R*obj.Xo(w,3))) + obj.G*obj.J*(-obj.kfOut(w)/(obj.R^2) - obj.kfOut(w)/(obj.R*obj.Xo(w,3)));
            F3 = obj.E*obj.IOut*(-1i*obj.kr(w)/obj.R - 1i*obj.kr(w)^3*obj.Xo(w,1)) + obj.G*obj.J*(-1i*obj.kr(w)/(obj.R) - 1i*obj.kr(w)*obj.Xo(w,1)/(obj.R^2));
 
            D4 = obj.G*obj.J*(-1i*obj.kfOut(w)/obj.R - 1i*obj.kfOut(w)/obj.Xo(w,2));
            E4 = obj.G*obj.J*(-obj.kfOut(w)/obj.R - obj.kfOut(w)/obj.Xo(w,3));
            F4 = obj.G*obj.J*(-1i*obj.kr(w) - 1i*obj.kr(w)*obj.Xo(w,1)/obj.R);
            D5 = obj.E*obj.IOut*(1/(obj.R*obj.Xo(w,2)) + obj.kfOut(w)^2);
            E5 = obj.E*obj.IOut*(1/(obj.R*obj.Xo(w,3)) - obj.kfOut(w)^2);
            F5 = obj.E*obj.IOut*(1/obj.R + obj.Xo(w,1)*(obj.kr(w)^2));
            A6 = -obj.E*obj.IIn*(obj.Xi(w,1)*obj.kt(w)^2 + 1i*obj.kt(w)/obj.R);
            B6 = -obj.E*obj.IIn*(obj.kfIn(w)^2 + 1i*obj.kfIn(w)/(obj.R*obj.Xi(w,2)));
            C6 = obj.E*obj.IIn*(obj.kfIn(w)^2 - obj.kfIn(w)/(obj.R*obj.Xi(w,3)));
           
            
            X = [ A1 B1 C1 0 0 0;
                A2 B2 C2 0 0 0;
                0 0 0 E3 D3 F3;
                0 0 0 E4 D4 F4;
                0 0 0 E5 D5 F5;
                A6 B6 C6 0 0 0];
        end
        function X = PhiNeg(obj,w)
            
            A1 = +obj.E*obj.S*(1i*obj.kt(w) + obj.Xi(w,1)/obj.R);
            B1 = -obj.E*obj.S*(1i*obj.kfIn(w)/obj.Xi(w,2)+1/obj.R);
            C1 = -obj.E*obj.S*(obj.kfIn(w)/obj.Xi(w,3)+1/obj.R);
            A2 = obj.E*obj.IIn*(-obj.kt(w)^3*obj.Xi(w,1) + obj.kt(w)^2/obj.R); 
            B2 = +obj.E*obj.IIn*(1i*obj.kfIn(w)^3 - obj.kfIn(w)^2/(obj.R*obj.Xi(w,2)));
            C2 = +obj.E*obj.IIn*(-obj.kfIn(w)^3 + obj.kfIn(w)^2/(obj.R*obj.Xi(w,3)));
            D3 = obj.E*obj.IOut*(1i*obj.kfOut(w)^3 - 1i*obj.kfOut(w)/(obj.R*obj.Xo(w,2))) + obj.G*obj.J*(1i*obj.kfOut(w)/(obj.R^2) - 1i*obj.kfOut(w)/(obj.R*obj.Xo(w,2)));
            
            E3 = obj.E*obj.IOut*(-obj.kfOut(w)^3 - obj.kfOut(w)/(obj.R*obj.Xo(w,3))) + obj.G*obj.J*((obj.kfOut(w)/(obj.R^2) - obj.kfOut(w)/(obj.R*obj.Xo(w,3))));
            F3 = obj.E*obj.IOut*(1i*obj.kr(w)/obj.R - 1i*obj.kr(w)^3*obj.Xo(w,1)) + obj.G*obj.J*(1i*obj.kr(w)/(obj.R) - 1i*obj.kr(w)*obj.Xo(w,1)/(obj.R^2));
            D4 = obj.G*obj.J*(1i*obj.kfOut(w)/obj.R - 1i*obj.kfOut(w)/obj.Xo(w,2));
            E4 = obj.G*obj.J*(obj.kfOut(w)/obj.R - obj.kfOut(w)/obj.Xo(w,3));
            F4 = obj.G*obj.J*(1i*obj.kr(w) - 1i*obj.kr(w)*obj.Xo(w,1)/obj.R);
            D5 = obj.E*obj.IOut*(-1/(obj.R*obj.Xo(w,2)) + obj.kfOut(w)^2);
            E5 = obj.E*obj.IOut*(-1/(obj.R*obj.Xo(w,3)) - obj.kfOut(w)^2);
            F5 = obj.E*obj.IOut*(1/obj.R - obj.Xo(w,1)*(obj.kr(w)^2));
            A6 = obj.E*obj.IIn*(obj.Xi(w,1)*obj.kt(w)^2 + 1i*obj.kt(w)/obj.R);
            B6 = -obj.E*obj.IIn*(obj.kfIn(w)^2 + 1i*obj.kfIn(w)/(obj.R*obj.Xi(w,2)));
            C6 = obj.E*obj.IIn*(obj.kfIn(w)^2 - obj.kfIn(w)/(obj.R*obj.Xi(w,3)));
           
            
            X = [ A1 B1 C1 0 0 0;
                A2 B2 C2 0 0 0;
                0 0 0 E3 D3 F3;
                0 0 0 E4 D4 F4;
                0 0 0 E5 D5 F5;
                A6 B6 C6 0 0 0];
            
        end
        
        % Referential e1,e2,e3 for a point of coordinates r
        function x = e1(obj,r)
            r1 = (r - obj.center)/norm(r - obj.center);
            x = cross(obj.plane,r1);
            if norm(x) - 1 >0.0001
                error('Referential not normalized')
            end
        end
        function x = e2(obj,r)
            e1 = obj.e1(r);
            x = cross(e1,obj.plane);
        end
        function x = e3(obj,r)
            x = obj.plane;
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
        
        %Set angle
        function angle = setAngle(obj)
            r1 = (obj.center - obj.nodeNeg.r);
            r2 = (obj.center - obj.nodePos.r);
            angle = acos(r1'*r2/(norm(r1'*r2)));
        end
      
        %Set length
        function L = setL(obj)
                r1 = obj.center - obj.nodeNeg.r;
                r2 = obj.center - obj.nodePos.r;
                if norm(r1) ~=  norm(r2)
                    error("Center of the element's curve must have the same distance from nodePos and nodeNeg")
                end
                L = obj.angle*obj.R;
        end
        
        % Displacement Operator
        function X = Delta(obj,w,s)
            X = diag( [exp(-1i*s*obj.kt(w)) exp(-1i*s*obj.kfIn(w)) exp(-s*obj.kfIn(w)) exp(-1i*s*obj.kfOut(w)) exp(-s*obj.kfOut(w)) exp(-1i*s*obj.kr(w))]);
        end
        
        % Rotation Operator
        function X = Rotation(obj,r)
            X = [inv([obj.e1(r) obj.e2(r) obj.e3(r)])                           zeros(3);
                                    zeros(3)        inv([obj.e1(r) obj.e2(r) obj.e3(r)])];                        
        end
        
        % Ploting the beam
        function show(obj)
            obj.plotCircle3D(obj.center,obj.plane,obj.R)
            hold on
            v = (obj.nodeNeg.r - obj.nodePos.r) ;
            v = v/norm(v);
            v = cross(obj.plane,v)*obj.R + obj.center;
            
            u = obj.e1(v)*obj.L;
            p = quiver3(v(1),v(2),v(3),u(1),u(2),u(3),.15);
            p.Color = 'red';
            
            u = obj.e2(v)*obj.L;
            p = quiver3(v(1),v(2),v(3),u(1),u(2),u(3),.15);
            p.Color = 'blue';
            
            u = obj.e3(v)*obj.L;
            p = quiver3(v(1),v(2),v(3),u(1),u(2),u(3),.15);
            p.Color = 'green';
               
            
        end
        
        function plotCircle3D(obj,center,normal,radius)
            v=null(normal');
            phase = atan((obj.nodePos.r - obj.nodeNeg.r)/norm(obj.nodePos.r - obj.nodeNeg.r)/v(:,1));
            phase = 0;
            theta=phase:0.01/(2*pi)*obj.angle:(phase+obj.angle);
            points=repmat(center,1,size(theta,2))+radius*(v(:,1)*cos(theta)+v(:,2)*sin(theta));
            plot3(points(1,:),points(2,:),points(3,:),'k');
        end
        
    end
end
    