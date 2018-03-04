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
        Izz
        L
        
        
    end
    methods
        
        function obj =  CURVEDELEMENT(id,nodeNeg,nodePos,nodeCenter,material,section,nodeRef)
            
            obj.id = id;
            obj.rho = material.Density;
            obj.S = section.Area;
            obj.E = material.YoungModule;
            obj.G = ( material.YoungModule / ( 2 * ( 1 + material.PoissonCoef) ) );
            obj.IIn = section.SecondMomentIn;
            obj.IOut = section.SecondMomentOut;
            obj.J =  section.TorsionMoment;
            obj.Izz = obj.IIn + obj.IOut;
            obj.nodeNeg = nodeNeg;
            obj.nodeNeg.addElement(obj);
            obj.nodePos = nodePos;
            obj.nodePos.addElement(obj);
            obj.center = nodeCenter.r;
            obj.plane = obj.setPlane(nodeRef);
            if (nodeNeg.r-nodePos.r)'*obj.plane ~= 0
                error("Normal must be perpendicular to the beam's plane")
            end
            
            if norm(nodeNeg.r-obj.center) ~= norm(nodePos.r-obj.center)
                error('Not equidistant')
            end
            obj.R =  norm(nodeNeg.r-obj.center);
            
            obj.angle = obj.setAngle();
            obj.L = obj.setL();
            
        end
        
        %Coupling
        function xi = Xi(obj,w,ind)
            kii = obj.ki(w,ind);
            xi = 1i*obj.E*obj.R*kii*(obj.IOut*kii^2 + obj.S)/(obj.rho*obj.R^2*obj.S*w^2 - (obj.E*obj.IOut*obj.R^2*kii^4 + obj.E*obj.S));
        end
        function xo = Xo(obj,w,ind)
            koi = obj.ko(w,ind);
            xo = (koi*obj.R^2*(obj.G*obj.J + obj.E*obj.IIn))/(obj.rho*obj.R^2*obj.S*w^2 - (obj.E*obj.IIn*obj.R^2*koi^4 + obj.G*obj.J*koi^2));
        end
        
        function X = PsiPos(obj,w)
            ki1 = obj.ki(w,1);
            ki2 = obj.ki(w,2);
            ki3 = obj.ki(w,3);
            ko1 = obj.ko(w,1);
            ko2 = obj.ko(w,2);
            ko3 = obj.ko(w,3);
            Xi1 = obj.Xi(w,1);
            Xi2 = obj.Xi(w,2);
            Xi3 = obj.Xi(w,3);
            Xo1 = obj.Xo(w,1);
            Xo2 = obj.Xo(w,2);
            Xo3 = obj.Xo(w,3);
            
            X = [ 1                 1/Xi2                1/Xi3                0                  0      0;
                  Xi1                 1                1                0                  0      0;
                  0                 0                0                1                  1      Xo1 ;
                  0                 0                0                1/Xo2                  1/Xo3      1;
                  0                 0                0    1i*ko2      1i*ko3     1i*ko1*Xo1;
                  -1i*ki1*Xi1    -1i*ki2     -1i*ki3                0                 0      0;];
             
           X(isnan(X)) = 0;
        end
        function X = PsiNeg(obj,w) 
            ki1 = obj.ki(w,1);
            ki2 = obj.ki(w,2);
            ki3 = obj.ki(w,3);
            ko1 = obj.ko(w,1);
            ko2 = obj.ko(w,2);
            ko3 = obj.ko(w,3);
            Xi1 = obj.Xi(w,1);
            Xi2 = obj.Xi(w,2);
            Xi3 = obj.Xi(w,3);
            Xo1 = obj.Xo(w,1);
            Xo2 = obj.Xo(w,2);
            Xo3 = obj.Xo(w,3);
            
            X = [ 1                 -1/Xi2                -1/Xi3                0                  0      0;
                  -Xi1                 1                1                0                  0      0;
                  0                 0                0                1                  1      -Xo1 ;
                  0                 0                0                -1/Xo2                  -1/Xo3      1;
                  0                 0                0    -1i*ko2      -1i*ko3     1i*ko1*Xo1;
                  -1i*ki1*Xi1    +1i*ki2     +1i*ki3                0                 0      0;];
             
           X(isnan(X)) = 0;
        end
        function X = PhiPos(obj,w)
            E = obj.E;
            IIn = obj.IIn;
            IOut = obj.IOut;  %#ok<*PROPLC>
            ki1 = obj.ki(w,1);
            ki2 = obj.ki(w,2);
            ki3 = obj.ki(w,3);
            ko1 = obj.ko(w,1);
            ko2 = obj.ko(w,2);
            ko3 = obj.ko(w,3);
            Xi1 = obj.Xi(w,1);
            Xi2 = obj.Xi(w,2);
            Xi3 = obj.Xi(w,3);
            Xo1 = obj.Xo(w,1);
            Xo2 = obj.Xo(w,2);
            Xo3 = obj.Xo(w,3);
            S = obj.S;
            R = obj.R;
            G = obj.G;
            J = obj.J;
            
            A1 = -E*S*(1i*ki1 + Xi1/R);
            B1 = -E*S*(1i*ki2/Xi2 + 1/R);
            C1 = -E*S*(1i*ki3/Xi3 + 1/R);
            
            A2 = E*IOut*(-1i*ki1^3*Xi1 + ki1^2/R);
            B2 = + E*IOut*(ki2^2/(R*Xi2) - 1i*ki2^3);
            C2 = + E*IOut*(ki3^2/(R*Xi3) - 1i*ki3^3);
            
            D4 = G*J*(-1i*ko2/Xo2 - 1i*ko2/R);
            E4 = G*J*(-1i*ko3/Xo3 - 1i*ko3/R);
            F4 = G*J*(-1i*ko1 -1i*ko1*Xo1/R);
            
            D3 = E*IIn*(-1i*ko2^3 - 1i*ko2/(R*Xo2)) + D4/R;
            E3 = E*IIn*(-1i*ko3^3 - 1i*ko3/(R*Xo3)) + E4/R;
            F3 = E*IIn*(-1i*ko1^3*Xo1 -1i*ko1/R) + F4/R;            
 
            D5 = E*IIn*(1/(R*Xo2) + ko2^2);
            E5 = E*IIn*(1/(R*Xo3) + ko3^2);
            F5 = E*IIn*(1/R + Xo1*(ko1^2));
            
            A6 = -E*IOut*(Xi1*ki1^2 + 1i*ki1/R);
            B6 = -E*IOut*(ki2^2 + 1i*ki2/(R*Xi2));
            C6 = -E*IOut*(ki3^2 + 1i*ki3/(R*Xi3));
           
            
            X = [ A1 B1 C1 0 0 0;
                A2 B2 C2 0 0 0;
                0 0 0 E3 D3 F3;
                0 0 0 E4 D4 F4;
                0 0 0 E5 D5 F5;
                A6 B6 C6 0 0 0];
        end
        function X = PhiNeg(obj,w)
            
            E = obj.E;
            IIn = obj.IIn;
            IOut = obj.IOut;  %#ok<*PROPLC>
            ki1 = obj.ki(w,1);
            ki2 = obj.ki(w,2);
            ki3 = obj.ki(w,3);
            ko1 = obj.ko(w,1);
            ko2 = obj.ko(w,2);
            ko3 = obj.ko(w,3);
            Xi1 = obj.Xi(w,1);
            Xi2 = obj.Xi(w,2);
            Xi3 = obj.Xi(w,3);
            Xo1 = obj.Xo(w,1);
            Xo2 = obj.Xo(w,2);
            Xo3 = obj.Xo(w,3);
            S = obj.S;
            R = obj.R;
            G = obj.G;
            J = obj.J;
            
            A1 = + E*S*(1i*ki1 + Xi1/R);
            B1 = - E*S*(1i*ki2/Xi2 + 1/R); %same for phiNeg and phiPos
            C1 = - E*S*(1i*ki3/Xi3 + 1/R); %same for phiNeg and phiPos
            
            A2 = E*IOut*(-1i*ki1^3*Xi1 + ki1^2/R); %same for phiNeg and phiPos
            B2 = - E*IOut*(ki2^2/(R*Xi2) - 1i*ki2^3);
            C2 = - E*IOut*(ki3^2/(R*Xi3) - 1i*ki3^3);
            
            D4 = G*J*(-1i*ko2/Xo2 + 1i*ko2/R);
            E4 = G*J*(-1i*ko3/Xo3 + 1i*ko3/R);
            F4 = G*J*(+1i*ko1 -1i*ko1*Xo1/R);
            
            D3 = E*IIn*(+1i*ko2^3 - 1i*ko2/(R*Xo2)) + D4/R;
            E3 = E*IIn*(+1i*ko3^3 - 1i*ko3/(R*Xo3)) + E4/R;
            F3 = E*IIn*(-1i*ko1^3*Xo1 + 1i*ko1/R) + F4/R;            
 
            D5 = E*IIn*( - 1/(R*Xo2) + ko2^2);
            E5 = E*IIn*( - 1/(R*Xo3) + ko3^2);
            F5 = E*IIn*(1/R - Xo1*(ko1^2));
            
            A6 = + E*IOut*(Xi1*ki1^2 + 1i*ki1/R);
            B6 = - E*IOut*(ki2^2 + 1i*ki2/(R*Xi2)); %same for phiNeg and phiPos
            C6 = - E*IOut*(ki3^2 + 1i*ki3/(R*Xi3)); %same for phiNeg and phiPos
                      
            
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
            if dot(x,r1)>0.001
                error('e1 axis must be perpendicular to radial direction')
            end
        end
        function x = e2(obj,r)
            e1 = obj.e1(r);
            x = -cross(e1,obj.plane);
        end
        function x = e3(obj,r)
            x = obj.plane;
        end
        
         % Wave Numbers
        function x = ki(obj,w,id)
        E = obj.E;
        IOut = obj.IOut;
        R = obj.R;
        rho = obj.rho;
        S = obj.S;
            
        a3 = 1;
        a2 = - E*IOut*R^2*(R^2*rho*w^2 + 2*E)/(E^2*IOut*R^4);
        a1 = - E*(rho*R^2*w^2*(S*R^2 + IOut) - E*IOut)/(E^2*IOut*R^4);
        a0 = S*rho*R^2*w^2*(rho*R^2*w^2 - E)/(E^2*IOut*R^4);

        r = (9*a2*a1 - 27*a0 - 2*a2^3)/54;
        q = (3*a1 - a2^2)/9;

        s1 = (r + sqrt(q^3 + r^2))^(1/3);
        s2 = (r - sqrt(q^3 + r^2))^(1/3);

        z1 = -1/3*a2 + s1 + s2;
        z2 = -1/3*a2 - 1/2*(s1 + s2) + 1i*sqrt(3)/2*(s1 - s2);
        z3 = -1/3*a2 - 1/2*(s1 + s2) - 1i*sqrt(3)/2*(s1 - s2);
        z = [z3; z1; z2]; %ki1, ki2 and ki3 respectively
        z = sqrt(z);
        
        x = z(id);
        if imag(x)>0
            x = -x;
        end
        end
        function x = ko(obj,w,id)
        E = obj.E;
        IIn = obj.IIn; %Ix in Chouvion's Thesis
        Izz = obj.Izz;
        G = obj.G;
        J =  obj.J;
        R = obj.R;
        rho = obj.rho;
        S = obj.S;
            
        a3 = 1;
        a2 = -E*IIn*R^2*(R^2*rho*w^2*Izz + 2*G*J)/(E*IIn*R^4*G*J);
        a1 = - G*J*(rho*R^2*w^2*(S*R^2 + Izz) - E*IIn)/(E*IIn*R^4*G*J);
        a0 = S*rho*R^2*w^2*(rho*R^2*w^2*Izz - E*IIn)/(E*IIn*R^4*G*J);

        r = (9*a2*a1 - 27*a0 - 2*a2^3)/54;
        q = (3*a1 - a2^2)/9;

        s1 = (r + sqrt(q^3 + r^2))^(1/3);
        s2 = (r - sqrt(q^3 + r^2))^(1/3);

        z1 = -1/3*a2 + s1 + s2;
        z2 = -1/3*a2 - 1/2*(s1 + s2) + 1i*sqrt(3)/2*(s1 - s2);
        z3 = -1/3*a2 - 1/2*(s1 + s2) - 1i*sqrt(3)/2*(s1 - s2);
        z = [z3; z1; z2]; %ki1, ki2 and ki3 respectively
        z = sqrt(z);
        x = z(id);
        if imag(x)>0
            x = -x;
        end
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
            r1 = r1/norm(r1);
            r2 = (obj.center - obj.nodePos.r);
            r2 = r2/norm(r2);
            angle = real(acos(r1'*r2));
        end
        
        %from local coordinates to global coordinates
        function P = toGlobal(obj)
            e1 = obj.e1(obj.nodeNeg.r);
            e2 = obj.e2(obj.nodeNeg.r);
            e3 = obj.e3(obj.nodeNeg.r);
            P = [e1 e2 e3];
        end
        
        %rotate a point t degrees around e3 axis
        function R = rot(obj,t)
            R = [cos(t) sin(t) 0; -sin(t) cos(t) 0; 0 0 1];
        end
        
        function plane = setPlane(obj,nodeRef)
            r1 = obj.nodePos.r - obj.center;
            r2 = obj.nodeNeg.r - obj.center;
            plane = cross(r1,r2);
            if norm(plane) < 1e-3
                if nodeRef == NaN
                    error('Reference node not provided')
                end
                r1 = nodeRef.r - obj.nodePos.r;
                r2 = obj.nodeNeg.r - nodeRef.r;
                plane = cross(r1,r2);
            end                
            plane = plane/norm(plane);
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
            X = diag( [exp(-1i*s*obj.ki(w,2)) exp(-1i*s*obj.ki(w,1)) exp(-1i*s*obj.ki(w,3)) exp(-1i*s*obj.ko(w,1)) exp(-1i*s*obj.ko(w,3)) exp(-1i*s*obj.ko(w,2))]);
        end
        
        %from a length input returns coordinates in global coord system
        function r = getCoordFromDistance(obj,L)
            t =  L/obj.R; % angle
            r1 = inv(obj.toGlobal)*(obj.nodeNeg.r - obj.center); %node neg position in the local coordinates
            r = obj.rot(t)*r1; %rotation in the local coordinates around the circle center
            r = obj.toGlobal*r + obj.center; 
        end
        %Rotation, length as input
        function X = Rotation(obj,L)
            r = obj.getCoordFromDistance(L);
            X = [inv([obj.e1(r) obj.e2(r) obj.e3(r)])                           zeros(3);
                                    zeros(3)        inv([obj.e1(r) obj.e2(r) obj.e3(r)])];                        
            
        end
        
        
        % Rotation Operator, coordinates as input
        function X = RotationCoord(obj,r)
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
        
        %show structure
        function Show(obj,nDiv)
            dl = obj.L/(nDiv-1);
            y = ones(3,nDiv);
            for i = 0:nDiv
                y(:,i+1) = obj.getCoordFromDistance(dl*i);
            end
            plot3(y(1,:),y(2,:),y(3,:))
            p.Color = 'k';
            hold on;
        end
        
        %W wave coefficients, w frequency
        function ShowDeformated(obj,W,w,nDiv)
            obj.Show(nDiv)
            WPos = W(1:6);
            WNeg = W(7:12);
            
            X = [];
            Y = [];
            Z = [];
            
            dl = obj.L/(nDiv-1);
            for i=0:nDiv
                s = obj.getCoordFromDistance(dl*i);
                u = obj.Rotation(i*dl)*obj.PsiPos(w)*obj.Delta(w,i*dl)*WPos + obj.Rotation(i*dl)*obj.PsiNeg(w)*obj.Delta(w,obj.L - i*dl)*WNeg;
                u = real(u(1:3));
                
                X = [X ( s(1) + u(1))];
                Y = [Y ( s(2) + u(2))];
                Z = [Z ( s(3) + u(3))];
            end
            p = plot3(X,Y,Z);   
            p.Color = 'k';
            hold on;
            
        end
        
    end
end
    