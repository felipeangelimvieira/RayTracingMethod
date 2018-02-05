
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
        e1
        e2
        e3
        
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
            obj.elementList = [];
            
            % Node initialised as free
            obj.DeltaFree = eye(6);
            obj.e1 = [1;0;0];
            obj.e2 = [0;1;0];
            obj.e3 = [0;0;1];
            
        end
        function addElement(obj,element)
            obj.elementList = [obj.elementList element];
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
            X = [inv([obj.e1 obj.e2 obj.e3])                           zeros(3);
                                    zeros(3)        inv([obj.e1 obj.e2 obj.e3])];
        end
        
        % Post-Treatment Methods
        function ponctualMass(obj,m)
            obj.M(1:3,1:3) = m*eye(3);
        end
        
        function show(obj)
            
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
