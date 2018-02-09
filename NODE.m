
classdef NODE < handle
    
    properties
       
        % Node's Identifier
        id
        
        % Node's Position
        r
        
        % Node's Element List
        elementList
        
        % Mass, Stiffness and Damping
        M
        K
        C
        
        % Node's freedom of movement
        DeltaFree
        t1
        t2
        t3
        r1
        r2
        r3
        
        % External Excitation
        FExt
        UExt
        
    end
    
    methods
        
        % Definition
        function obj = NODE(id,r)
           
            % User inputs the node's position and id
            obj.id = id;
            obj.r = r;
            
            % Mass, Stiffness and Damping set nulls by default
            obj.M = zeros(6);
            obj.K = zeros(6);
            obj.C = zeros(6);
            
            % Element's List empty by default
            obj.elementList = {};
            
            % Node initialised as free
            obj.DeltaFree = eye(6);
            obj.t1 = [1;0;0];
            obj.t2 = [0;1;0];
            obj.t3 = [0;0;1];
            obj.r1 = [1;0;0];
            obj.r2 = [0;1;0];
            obj.r3 = [0;0;1];
            
            % External Forces and Displacements 
            obj.FExt = zeros(6,1);
            obj.UExt = zeros(6,1);
            
            
        end
        function addElement(obj,element)
            obj.elementList = [obj.elementList {element}];
        end
        
        % Main Methods
        function bool = isPos(obj,element)
            if element.nodePos == obj
                bool = true;
                return
            end
            if element.nodeNeg == obj
                bool = false;
                return
            end
            error('Element not linked to node')
        end
        function bool = isNeg(obj,element)
            if element.nodeNeg == obj
                bool = true;
                return
            end
            if element.nodePos == obj
                bool = false;
                return
            end
            error('Element not linked to node')
        end
        function X = FreedomInGlobal(obj)
            X = obj.Rotation*obj.DeltaFree;
        end
        function X = RestrictionInGlobal(obj)
            X = obj.Rotation*(eye(6)-obj.DeltaFree);
        end
        function X = Rotation(obj)
            X = [inv([obj.t1 obj.t2 obj.t3])                           zeros(3);
                                    zeros(3)        inv([obj.r1 obj.r2 obj.r3])];
        end
        
        % Post-Treatment Methods
        function PonctualMass(obj,m)
            obj.M(1:3,1:3) = m*eye(3);
        end
        function BlockTranslation(obj,v)
            
            % No direction already blocked
            if obj.DeltaFree(1,1)==1
                obj.DeltaFree(1,1)=0;
                obj.t1 = v / norm(v);
                obj.t2 = rand(3,1);
                obj.t2 = obj.t2 - (obj.t1' * obj.t2)*obj.t1;
                obj.t2 = obj.t2 / norm(obj.t2);
                obj.t3 = cross( obj.t1 , obj.t2 );
                return
            end
            
            % 1 direction already blocked
            if obj.DeltaFree(2,2)==1
                obj.DeltaFree(2,2)=0;
                obj.t2 = v - (obj.t1' * v)*obj.t1;
                obj.t2 = obj.t2 / norm(obj.t2);
                obj.t3 = cross( obj.t1 , obj.t2 );
                return
            end
            
            % 2 directions already blocked
            if obj.DeltaFree(3,3)==1
                obj.DeltaFree(3,3)=0;
                return
            end
            
            % All directions already blocked
            if obj.DeltaFree(3,3)==0
                return
            end
            
        end
        function BlockAllTranslation(obj)
            obj.DeltaFree(1:3,1:3) = eye(3);
            obj.t1 = [1;0;0];
            obj.t2 = [0;1;0];
            obj.t3 = [0;0;1];
        end
        function BlockRotation(obj,v)
            
            % No direction already blocked
            if obj.DeltaFree(4,4)==1
                obj.DeltaFree(4,4)=0;
                obj.r1 = v / norm(v);
                obj.r2 = rand(3,1);
                obj.r2 = obj.r2 - (obj.r1' * obj.r2)*obj.r1;
                obj.r2 = obj.r2 / norm(obj.r2);
                obj.r3 = cross( obj.r1 , obj.r2 );
                return
            end
            
            % 1 direction already blocked
            if obj.DeltaFree(5,5)==1
                obj.DeltaFree(5,5)=0;
                obj.r2 = v - (obj.r1' * v)*obj.r1;
                obj.r2 = obj.r2 / norm(obj.r2);
                obj.r3 = cross( obj.r1 , obj.r2 );
                return
            end
            
            % 2 directions already blocked
            if obj.DeltaFree(6,6)==1
                obj.DeltaFree(6,6)=0;
                return
            end
            
            % All directions already blocked
            if obj.DeltaFree(6,6)==0
                return
            end
            
        end
        function BlockAllRotations(obj)
            obj.DeltaFree(4:6,4:6) = eye(3);
            obj.r1 = [1;0;0];
            obj.r2 = [0;1;0];
            obj.r3 = [0;0;1];
        end
        function ExternalForce(obj,F)
            obj.FExt = F;
        end
        function ImposedDisplacement(obj,U)
            obj.UExt = U;
        end
        
        function Show(obj)
            
            if size(obj.elementList,1)==0
                return
            end
            
            p = plot3(obj.r(1),obj.r(2),obj.r(3));   
            p.Color = 'k';
            p.Marker = 'o';
            p.MarkerFaceColor = 'k';
            hold on;
                
            text(obj.r(1),obj.r(2),obj.r(3),char('  ' + string(obj.id)));
            hold on;
                
        end

    end
         
end

