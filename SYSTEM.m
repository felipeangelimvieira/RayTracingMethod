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
            obj.T = zeros(12*n);
            obj.D = zeros(12*n);
            
            %Calculates static contributions to T (w is set to 1 to shorten
            %calculation)
            for node = obj.nodeList
                if node.static
                    obj.localTransmission(node,1);
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
            j = j-1;
            MKC = node.K - i*w*node.C - w*w*node.M;
            if node.isPos(element)
                MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation()*element.PsiPos(w);
                MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation()*element.PsiNeg(w);
            else
                MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation()*element.PsiNeg(w);
                MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation()*element.PsiPos(w);
            end
            j = 0;
            i= 1+1;
            % Other Lines (Displacement Continuity)
            % Sub Diagonal
            for element = node.elementList
                
                if n==1 % No Sub Diagonal (No equations)
                    break
                end
                
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiNeg(w);
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
                
                if n==1 % No Sub Diagonal (No equations)
                    break
                end
                
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
                    MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiNeg(w);
                    MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiPos(w);
                end
            end
            
            % Tn Calcul
            IFreedom = zeros(6*n);
            IRestriction = zeros(6*n);
            for i=0:(n-1)
                IFreedom( (1 + 6*i) : (6 + 6*i) , (1 + 6*i) : (6 + 6*i) ) = node.FreedomInGlobal;
                IRestriction( (1 + 6*i) : (6 + 6*i) , (1 + 6*i) : (6 + 6*i) ) = node.RestrictionInGlobal;
            end
            
            MIn = IFreedom*MInFree + IRestriction*MInBlocked;
            MOut = IFreedom*MOutFree + IRestriction*MOutBlocked;
            
            Tn = MOut\MIn;
            
            % Tn placing in T
            
            iLocal = 0; 
            for elementI = node.elementList % Tn is broken in Lines
                
                % Search for corresponding T line
                i = 0;
                for element = obj.elementList 
                    if element == elementI
                        break
                    end
                    i = i+1;
                end
                
                % Determines whether the leaving wave is positive or negative
                if node.isPos(elementI)
                    iAux = 1;
                else
                    iAux = 0;
                end
                
                jLocal = 0;
                for elementJ = node.elementList % The Line is broken into its blocks   
                    
                    % Search for corresponding T line
                    j = 0;
                    for element = obj.elementList 
                        if element == elementJ
                            break
                        end
                        j = j+1;
                    end
                    
                    % Determines whether the leaving wave is positive or negative
                    if node.isPos(elementI)
                        jAux = 1;
                    else
                        jAux = 0;
                    end
                    
                    % Place the block
                    obj.T ( ( 1 + 12*i + 6*iAux ) : ( 6 + 12*i + 6*iAux ) , ( 1 + 12*j + 6*jAux ) : ( 6 + 12*j + 6*jAux ) ) = Tn ( ( 1 + iLocal ) : ( 6 + iLocal ) , ( 1 + jLocal ) : ( 6 + jLocal ) ); 
                       
                    jLocal = jLocal + 1; % Jump to nex block in Tn
                end
            iLocal = iLocal + 1; % Jump to next line in Tn
            end
        end
        function globalTransmission(obj,w)
            for node = obj.nodeList
                if ~node.static
                    obj.localTransmission(node,w);
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
        function x = Determinant(obj,w)
            n = size(obj.elementList,2);
            obj.globalTransmission(w);
            obj.globalDispersion(w);
            x = det(eye(12*n) - obj.T*obj.D);
        end
        
    end
end

    
