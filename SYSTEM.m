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
        function addCurvedElement(obj,id,idNodeNeg,idNodePos,rho,S,E,G,IIn,IOut,center,normal)
            obj.elementList = [obj.elementList CURVEDELEMENT(id,obj.findNodeById(idNodeNeg),obj.findNodeById(idNodePos),rho,S,E,G,IIn,IOut,center,normal)];
        end  
        function showStructure(obj)
            
            figure('Name','Structure Preview');
            
            for element = obj.elementList
                element.show();
            end
            
            for node = obj.nodeList
                node.show();
            end
            
            daspect([1 1 1]);
            hold off;
        end
        function showDeformatedStructure(obj,W,w,scale)
            W = W*scale;
            
            i = 1;
            j = 12;
            for element = obj.elementList
                element.showDeformated(W(i:j),w,20);
                i = i+12;
                j = j+12;
            end
            
            for node = obj.nodeList
                node.show();
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
            
            % 1st Line (Effort Continuity):
            
            % Element's Effort Contribution
            for element = node.elementList
                if isa(element,'CURVEDELEMENT')
                    if node.isPos(element)
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(node.r)*element.PhiPos(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(node.r)*element.PhiNeg(w);
                    else
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation(node.r)*element.PhiNeg(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(node.r)*element.PhiPos(w);
                    end 
                else
                    if node.isPos(element)
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PhiPos(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PhiNeg(w);
                    else
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation()*element.PhiNeg(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation()*element.PhiPos(w);
                    end 
                end
                j=j+1;      
            end
            
            % Mass, Stiffness and Damping
            j = j-1;
            MKC = node.K - i*w*node.C - w*w*node.M;
            if isa(element,'CURVEDELEMENT')
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation(node.r)*element.PsiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation(node.r)*element.PsiNeg(w);
                else
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation(node.r)*element.PsiNeg(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation(node.r)*element.PsiPos(w);
                end
            else
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation()*element.PsiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation()*element.PsiNeg(w);
                else
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation()*element.PsiNeg(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation()*element.PsiPos(w);
                end
            end
            
            % Other Lines (Displacement Continuity):
            % Sub Diagonal
            j = 0;
            i= 1;
            for element = node.elementList
                
                if n==1 % No Sub Diagonal (No equations)
                    break
                end
                
                if i==(n) %End of Sub-Diagonal
                    break
                end
                
                if isa(element,'CURVEDELEMENT')
                    if node.isPos(element)
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(node.r)*element.PsiPos(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(node.r)*element.PsiNeg(w);
                    else
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(node.r)*element.PsiNeg(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(node.r)*element.PsiPos(w);
                    end
                    
                else
                    if node.isPos(element)
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiPos(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiNeg(w);
                    else
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiNeg(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiPos(w);
                    end
                end
                i = i + 1;
                j = j + 1;
            end
            
            % Final Column
            for i = 1:n-1
                if n==1 % No Sub Diagonal (No equations)
                    break
                end
                if isa(element,'CURVEDELEMENT')
                    if node.isPos(element)
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation(node.r)*element.PsiPos(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(node.r)*element.PsiNeg(w);
                    else
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation(node.r)*element.PsiNeg(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(node.r)*element.PsiPos(w);
                    end
                else
                    if node.isPos(element)
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation()*element.PsiPos(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation()*element.PsiNeg(w);
                    else
                        MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation()*element.PsiNeg(w);
                        MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation()*element.PsiPos(w);
                    end
                end
                
            end
            
            % Blocked Case
            MInBlocked = zeros(6*n);
            MOutBlocked = zeros(6*n);
            i = 0;
            j = 0;

            for element = node.elementList
                if isa(element,'CURVEDELEMENT')
                    if node.isPos(element)
                        MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(node.r)*element.PsiPos(w);
                        MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(node.r)*element.PsiNeg(w);
                    else
                        MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(node.r)*element.PsiNeg(w);
                        MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(node.r)*element.PsiPos(w);
                    end
                else
                    if node.isPos(element)
                        MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiPos(w);
                        MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiNeg(w);
                    else
                        MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation()*element.PsiNeg(w);
                        MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation()*element.PsiPos(w);
                    end
                end
                
                i = i + 1;
                j = j + 1;
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
                if node.isNeg(elementI)
                    iAux = 0;
                else
                    iAux = 1;
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
                    
                    % Determines whether the arriving wave is positive or negative
                    if node.isPos(elementJ)
                        jAux = 0;
                    else
                        jAux = 1;
                    end
                    
                    % Place the block
                    obj.T ( ( 1 + 12*i + 6*iAux ) : ( 6 + 12*i + 6*iAux ) , ( 1 + 12*j + 6*jAux ) : ( 6 + 12*j + 6*jAux ) ) = Tn( ( 1 + iLocal*6 ) : ( 6 + iLocal*6 ) , ( 1 + jLocal*6 ) : ( 6 + jLocal*6 ) ); 
                       
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
            x = abs(det(eye(12*n) - obj.T*obj.D));
        end
        function X = associatedMode(obj,w)
            n = size(obj.elementList,2);
            obj.globalTransmission(w);
            obj.globalDispersion(w);
            [V,D] = eig(eye(12*n) - obj.T*obj.D);
            D = diag(D);
            [~,Min] = min(D);
            X = V(:,Min);
            X = X;
        end
    end
end

    
