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
                
                v = (element.nodeNeg.r + element.nodePos.r)/2 ;
                u = element.e1*element.L;
                p = quiver3(v(1),v(2),v(3),u(1),u(2),u(3),.15);
                p.Color = 'red';
                u = element.e2*element.L;
                p = quiver3(v(1),v(2),v(3),u(1),u(2),u(3),.15);
                p.Color = 'blue';
                u = element.e3*element.L;
                p = quiver3(v(1),v(2),v(3),u(1),u(2),u(3),.15);
                p.Color = 'green';
                
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
            
            daspect([1 1 1]);
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
                if node.static
                    obj.localTransmission(obj,node,1);
                end
            end
        end % Define the size of D and T matrix, set all values to 0, and assemble T static parts
        
        function localTransmission(obj,node,w)
            
            n = size(node.elementList,2);
            
            % Free Case
            MInFree = zeros(6*n);
            MOutFree = zeros(6*n);
            
            i = 0;
            j = 0;
            
            % 1st Line (Effort Continuity)
            for element = node.elementList
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PhiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation()*element.PhiNeg(w);
                else
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation()*element.PhiNeg(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PhiPos(w);
                end
                j=j+1;      
            end
            % Mass, Stiffness and Damping
            MKC = node.K - i*w*node.C - w*w*M;
            if node.isPos(element)
                MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation()*element.PsiPos(w);
                MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation()*element.PsiNeg(w);
            else
                MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation()*element.PsiNeg(w);
                MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation()*element.PsiPos(w);
            end
            j = 0;
            i= i+1;
            % Other Lines (Displacement Continuity)
            % Sub Diagonal
            for element = node.elementList
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation()*element.PsiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation()*element.PsiNeg(w);
                else
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiNeg(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiPos(w);
                end
                i = i + 1;
                j = j + 1;
                if i==(n-1)
                    break
                end
            end
            % Final Column
            for i = 1:n
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiNeg(w);
                else
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation()*element.PsiNeg(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation()*element.PsiPos(w);
                end
            end
            
            % Blocked Case
            MInBlocked = zeros(6*n);
            MOutBlocked = zeros(6*n);
            i = 0;
            j = 0;
            for element = node.elementList
                if node.isPos(element)
                    MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiPos(w);
                    MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiNeg(w);
                else
                    MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation()*element.PsiNeg(w);
                    MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation()*element.PsiPos(w);
                end
            end
            
            % Tn Calcul
            MIn = node.FreedomInGlobal*MInFree + node.RestrictionInGlobal*MInBlocked;
            MOut = node.FreedomInGlobal*MOutFree + node.RestrictionInGlobal*MOutBlocked;
            Tn = inv(MOut)*MIn;
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

    
