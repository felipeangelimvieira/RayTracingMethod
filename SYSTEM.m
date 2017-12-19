classdef SYSTEM < handle
    
    properties
        
        % System's Nodes and Elements
        elementList
        nodeList
        
        % Matrix Emplacements
        T
        D
        
        % System's Charges and Initial Wave Vector
        Eff
        W0
        
        % Final Wave Vector
        W
        
    end
    
    methods
        
        % Definition Methods
        function obj = SYSTEM()
            
            obj.elementList = [];
            obj.nodeList = [];
            
            obj.T = [];
            obj.D = [];
            
            obj.Eff = [];
            obj.W0 = [];
            obj.W = [];
            
        end
        function addNode(obj,id,r)
           obj.nodeList = [obj.nodeList  NODE(id,r)];
        end
        function addElement(obj,id,idNodeNeg,idNodePos,rho,S,E,G,IIn,IOut)
            obj.elementList = [obj.elementList  ELEMENT(id,obj.findNodeById(idNodeNeg),obj.findNodeById(idNodePos),rho,S,E,G,IIn,IOut)];
        end
        function showStructure(obj)
            
            figure('Name','Structure Preview');
            
            for element = obj.elementList
                v = [element.nodeNeg.r element.nodePos.r];
                p = plot3(v(1,:),v(2,:),v(3,:));
                
                p.Color = 'k';
                hold on;
                
            end
            
            for node = obj.nodeList
                v = node.r;
                p = plot3(v(1),v(2),v(3));
                
                p.Color = 'k';
                p.Marker = 'o';
                p.MarkerFaceColor = 'k';
                hold on;
                
                text(v(1),v(2),v(3),char('  ' + string(node.id)));
                hold on;
                
            end
            hold off;
        end
        
        function x = findNodeById(obj,id)
            for node = obj.nodeList
                if node.id == id
                    x = node;
                    return
                end
            end
            error('No node with such id');
        end
        function x = findElementById(obj,id)
            for element = obj.elementList
                if element.id == id
                    x = element;
                    return
                end
            end
            error('No element with such id');
        end
        
        function InitializeMatrix(obj)
            
            % Define Matrix size
            n = size(obj.elementList,1);
            T = zeros(12*n);
            D = zeros(12*n);
            
            %Calculates static contributions to T (w is set to 1 to shorten
            %calculation)
            for node = obj.nodeList
                if element.static
                    obj.localTransmission(obj,node,1);
                end
            end
        end % Define the size of D and T matrix, set all values to 0, and assemble T static parts
        
        function localTransmission(obj,node,w)
        end
        function globalTransmission(obj,w)
            for node = obj.nodeList
                if ~element.static
                    obj.localTransmission(obj,node,w);
                end
            end
        end
        function globalDispersion(obj,w)
            i = 0;
            for element = obj.elementList
                obj.D( 1+6*i : 6+6*i , 1+6*i : 6+6*i ) = element.Delta(w,element.L);
                i = i + 1;
                obj.D( 1+6*i : 6+6*i , 1+6*i : 6+6*i ) = element.Delta(w,element.L);
                i = i + 1;
            end
        end
        
    end
end

    
