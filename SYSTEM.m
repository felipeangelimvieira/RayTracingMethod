classdef SYSTEM < handle
    
    properties
        
        % System's Nodes and Elements
        materialList
        sectionList
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
        
        function obj = SYSTEM()
            
            obj.elementList = {};
            obj.nodeList = {};
            obj.materialList = {};
            obj.sectionList = {};
            
            obj.T = [];
            obj.D = [];
            obj.Eff = [];
            obj.W0 = [];
            obj.W = [];
            
        end
        
        function addNode(obj,id,r)
            for node = obj.nodeList
                if node.id == id
                    error("Node's id conflict");
                end
            end
            obj.nodeList = [obj.nodeList  NODE(id,r)];
        end
        function addElement(obj,id,idNodeNeg,idNodePos,idNodeRef,idMaterial,idSection)
            if idNodeNeg==idNodePos|idNodeRef==idNodePos
               error("Elements must be defined by three different nodes");
            end
            for element = obj.elementList
                element = element{1};
                if element.id == id
                    error("Elements' id conflict");
                end
            end
            nodeNeg  = obj.findNodeById(idNodeNeg);
            nodePos  = obj.findNodeById(idNodePos);
            nodeRef  = obj.findNodeById(idNodeRef);
            material = obj.findMaterialById(idMaterial);
            section  = obj.findSectionById(idSection);
            obj.elementList = [obj.elementList  {ELEMENT(id,nodeNeg,nodePos,nodeRef,material,section)}];
        end
        function addCurvedElement(obj,id,idNodeNeg,idNodePos,idNodeRef,Angle,idMaterial,idSection)
            if idNodeNeg==idNodePos|idNodeRef==idNodePos
               error("Elements must be defined by three different nodes");
            end
            for element = obj.elementList
                element = element{1};
                if element.id == id
                    error("Elements' id conflict");
                end
            end
            nodeNeg  = obj.findNodeById(idNodeNeg);
            nodePos  = obj.findNodeById(idNodePos);
            nodeRef  = obj.findNodeById(idNodeRef);
            material = obj.findMaterialById(idMaterial);
            section  = obj.findSectionById(idSection);
            obj.elementList = [obj.elementList  {CURVEDELEMENT(id,nodeNeg,nodePos,nodeRef,Angle,material,section)}];
        end
        function addMaterial(obj,id,Young,Poisson,Density)
            for material = obj.materialList
                if material.id == id
                    error("Material's id conflict");
                end
            end
            obj.materialList = [obj.elementList  MATERIAL(id,Young,Poisson,Density)];
        end
        function addSection(obj,id,A,IIn,IOut,J)
            for section = obj.sectionList
                if section.id == id
                    error("Section's id conflict");
                end
            end
            obj.sectionList = [obj.sectionList SECTION(id,A,IIn,IOut,J)]; 
        end
        
        function showStructure(obj)
            
            figure('Name','Structure Preview');
            
            for element = obj.elementList
                element = element{1};
                element.show();
            end
            
            for node = obj.nodeList
                node.show();
            end
            
            daspect([1 1 1]);
            hold off;
        end
        function showDeformatedStructure(obj,W,w)
            
            
            i = 1;
            j = 12;
            for element = obj.elementList
                element = element{1};
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
                element = element{1};
                if element.id == id
                    x = element;
                    return
                end
            end
            error('No element with such id');
        end
        function x = findMaterialById(obj,id)
            for material = obj.materialList
                if material.id == id
                    x = material;
                    return
                end
            end
            error('No material with such id');
        end
        function x = findSectionById(obj,id)
            for section = obj.sectionList
                if section.id == id
                    x = section;
                    return
                end
            end
            error('No node with such id');
        end
        
        function InitializeMatrix(obj)
            
            % Define Matrix size
            n = size(obj.elementList,1);
            obj.T = zeros(12*n);
            obj.D = zeros(12*n);
            
        end
        
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
                element = element{1};
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(element.L)*element.PhiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(element.L)*element.PhiNeg(w);
                else
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation(0)*element.PhiNeg(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(0)*element.PhiPos(w);
                end 
            j=j+1;      
            end
            
            % Mass, Stiffness and Damping
            j = j-1;
            MKC = node.K - i*w*node.C - w*w*node.M;
            
            if node.isPos(element)
                 MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation(element.L)*element.PsiPos(w);
                 MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation(element.L)*element.PsiNeg(w);
            else
                 MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) - MKC*element.Rotation(0)*element.PsiNeg(w);
                 MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation(0)*element.PsiPos(w);
            end
            
            % Other Lines (Displacement Continuity):
            % Sub Diagonal
            j = 0;
            i = 1;
            for element = node.elementList
                element = element{1};
                
                if n==1 % No Sub Diagonal (No equations)
                    break
                end
                
                if i==(n) %End of Sub-Diagonal
                    break
                end
                
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(element.L)*element.PsiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(element.L)*element.PsiNeg(w);
                else
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(0)*element.PsiNeg(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(0)*element.PsiPos(w);
                end
                
                i = i + 1;
                j = j + 1;
                
            end
            
            % Final Column
            for i = 1:n-1
                if n==1 % No Sub Diagonal (No equations)
                    break
                end
                if node.isPos(element)
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation(element.L)*element.PsiPos(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(element.L)*element.PsiNeg(w);
                else
                    MInFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  =  element.Rotation(0)*element.PsiNeg(w);
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(0)*element.PsiPos(w);
                end
                
            end
            
            % Blocked Case
            MInBlocked = zeros(6*n);
            MOutBlocked = zeros(6*n);
            i = 0;
            j = 0;

            for element = node.elementList
                element = element{1};
                if node.isPos(element)
                    MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(element.L)*element.PsiPos(w);
                    MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(element.L)*element.PsiNeg(w);
                else
                    MInBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) )  = -element.Rotation(0)*element.PsiNeg(w);
                    MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(0)*element.PsiPos(w);
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
                elementI = elementI{1};
                
                % Search for corresponding T line
                i = 0;
                for element = obj.elementList 
                    element = element{1};
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
                    elementJ = elementJ{1};
                    
                    % Search for corresponding T line
                    j = 0;
                    for element = obj.elementList 
                        element = element{1};
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
                n = size(node.elementList,2);
                if n ~= 0
                    obj.localTransmission(node,w);
                end
            end
        end
        function globalDispersion(obj,w)
            i = 0;
            for element = obj.elementList
                element = element{1};
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
            M = (eye(n*12)-obj.T*obj.D);
            x = min(abs(eig(M)));
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