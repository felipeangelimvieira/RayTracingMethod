classdef SYSTEM < handle
    
    properties
        
        % System's Nodes, Elements, Material and Section Lists
        materialList
        sectionList
        elementList
        nodeList
        
        % Global Matrix
        T
        D
        
    end
    
    methods
        
        function obj = SYSTEM()
            
            obj.elementList = {};
            obj.nodeList = {};
            obj.materialList = {};
            obj.sectionList = {};
            
            obj.T = [];
            obj.D = [];
            
        end
        
        function AddNode(obj,id,r)
            for node = obj.nodeList
                if node.id == id
                    error("Node's id conflict");
                end
            end
            obj.nodeList = [obj.nodeList  NODE(id,r)];
        end
        function AddElement(obj,id,idNodeNeg,idNodePos,idNodeRef,idMaterial,idSection)
            if idNodeNeg==idNodePos|idNodeRef==idNodePos
               error("Elements must be defined by three different nodes");
            end
            for element = obj.elementList
                element = element{1};
                if element.id == id
                    error("Elements' id conflict");
                end
            end
            nodeNeg  = obj.FindNodeById(idNodeNeg);
            nodePos  = obj.FindNodeById(idNodePos);
            nodeRef  = obj.FindNodeById(idNodeRef);
            material = obj.FindMaterialById(idMaterial);
            section  = obj.FindSectionById(idSection);
            obj.elementList = [obj.elementList  {ELEMENT(id,nodeNeg,nodePos,nodeRef,material,section)}];
        end
        function AddCurvedElement(obj,id,idNodeNeg,idNodePos,idNodeRef,Angle,idMaterial,idSection)
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
        function AddMaterial(obj,id,Young,Poisson,Density)
            for material = obj.materialList
                if material.id == id
                    error("Material's id conflict");
                end
            end
            obj.materialList = [obj.elementList  MATERIAL(id,Young,Poisson,Density)];
        end
        function AddSection(obj,id,A,IIn,IOut,J)
            for section = obj.sectionList
                if section.id == id
                    error("Section's id conflict");
                end
            end
            obj.sectionList = [obj.sectionList SECTION(id,A,IIn,IOut,J)]; 
        end
        
        function AddExternalForce(obj,idNode,F)
            node = obj.FindNodeById(idNode);
            node.ExternalForce(F);
        end
        function AddImposedDisplacement(obj,idNode,U)
            node = obj.FindNodeById(idNode);
            node.ImposedDisplacement(U);
        end
        
        function AddPonctualMass(obj,idNode,m)
            node = obj.FindNodeById(idNode);
            node.PonctualMass(m);
        end
        function AddSpring(obj,idNode,k,v)
            node = obj.FindNodeById(idNode);
            node.Spring(k,v);
        end
        function AddTorsionSpring(obj,idNode,k,v)
            node = obj.FindNodeById(idNode);
            node.TorsionSpring(k,v);
        end
        function AddDamper(obj,idNode,c,v)
            node = obj.FindNodeById(idNode);
            node.Damper(c,v);
        end
        function AddTorsionDamper(obj,idNode,c,v)
            node = obj.FindNodeById(idNode);
            node.TorsionDamper(c,v);
        end
        function BlockTranslationDirection(obj,idNode,v)
            node = obj.FindNodeById(idNode);
            node.BlockTranslation(v);
        end
        function BlockRotationDirection(obj,idNode,v)
            node = obj.FindNodeById(idNode);
            node.BlockRotation(v);
        end
        function BlockAllTranslation(obj,idNode)
            node = obj.FindNodeById(idNode);
            node.BlockAllTranslation();
        end
        function BlockAllRotation(obj,idNode)
            node = obj.FindNodeById(idNode);
            node.BlockAllRotation();
        end
        function BlockAll(obj,idNode)
            node = obj.FindNodeById(idNode);
            node.BlockAllTranslation();
            node.BlockAllRotation();
        end
        
        function x = FindNodeById(obj,id)
            for node = obj.nodeList
                if node.id == id
                    x = node;
                    return
                end
            end
            error('No node with such id');
        end
        function x = FindElementById(obj,id)
            for element = obj.elementList
                element = element{1};
                if element.id == id
                    x = element;
                    return
                end
            end
            error('No element with such id');
        end
        function x = FindMaterialById(obj,id)
            for material = obj.materialList
                if material.id == id
                    x = material;
                    return
                end
            end
            error('No material with such id');
        end
        function x = FindSectionById(obj,id)
            for section = obj.sectionList
                if section.id == id
                    x = section;
                    return
                end
            end
            error('No node with such id');
        end
        
        function ShowStructure(obj)
            
            figure('Name','Structure Preview','NumberTitle','off');
            
            LMed = 0;
            n = size(obj.elementList,2);
            
            for element = obj.elementList
                element = element{1};
                element.Show();
                LMed = LMed + element.L/n;
            end
            
            for element = obj.elementList
                element = element{1};
                scale = (LMed/element.L);
                element.ShowReferential(scale);
            end
            
            for node = obj.nodeList
                node.Show();
            end
            
            daspect([1 1 1]);
            hold off;
        end
        function ShowDeformatedStructure(obj,W,w)
            
            Name = strcat('Deformated Structure Preview ( ',num2str(w/(2*pi),'%.3f'),' Hz )');
            figure('Name',Name,'NumberTitle','off');
            
            % Scale Definition
            UMax = -1;
            i = 0;
            for element = obj.elementList
                element = element{1};
                WPos = W((i+1):(i+6));
                WNeg = W((i+7):(i+12));
                S = 0:(.05*element.L):element.L;
                for s = S
                    U = element.PsiPos(w)*element.Delta(w,s)*WPos + element.PsiNeg(w)*element.Delta(w,element.L-s)*WNeg;
                    U = real(U(1:3));
                    if norm(U)>UMax
                        UMax = norm(U);
                        LMax = element.L;
                    end
                end
                i = i+12;
            end 
            scale = .30 * (LMax/UMax);
            W = W*scale;
            
            
            i = 1;
            j = 12;
            for element = obj.elementList
                element = element{1};
                element.ShowDeformated(W(i:j),w,20);
                i = i+12;
                j = j+12;
            end
            
            for node = obj.nodeList
                node.Show();
            end
            
            daspect([1 1 1]);
            hold off;
            
        end
        
        function InitializeMatrix(obj)
            
            % Define Matrix size
            n = size(obj.elementList,1);
            obj.T = zeros(12*n);
            obj.D = zeros(12*n);
            
        end
        
        function LocalTransmission(obj,node,w)
            
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
        function GlobalTransmission(obj,w)
            for node = obj.nodeList
                n = size(node.elementList,2);
                if n ~= 0
                    obj.LocalTransmission(node,w);
                end
            end
        end
        function GlobalDispersion(obj,w)
            i = 0;
            for element = obj.elementList
                element = element{1};
                obj.D( 1+6*i : 6+6*i , 1+6*i : 6+6*i ) = element.Delta(w,element.L);
                i = i + 1;
                obj.D( 1+6*i : 6+6*i , 1+6*i : 6+6*i ) = element.Delta(w,element.L);
                i = i + 1;
            end
        end
        
        function M = ProblemMatrix(obj,w)
            n = 12*size(obj.elementList,2);
            obj.GlobalTransmission(w);
            obj.GlobalDispersion(w);
            M = (eye(n)-obj.T*obj.D);
        end
        
        function x = RandomWave(obj)
            n = 12*size(obj.elementList,2);
            x = rand(n,1);
            x = x/norm(x);
        end
        function x = RayleighProblemMatrix(obj,w,v)
            M = obj.ProblemMatrix(w);
            y = M\v;
            x = 1/norm(y);
            y = y/norm(y);
        end
        function x = FindModalFreqs(obj,fMin,fStep,fMax)
            
            v = obj.RandomWave();
            yAnt=obj.RayleighProblemMatrix(fMin*2*pi,v);
            options = optimset('TolX',.001);
            OldDiffIsNeg = 0;
            x = [];

            for f = fMin:fStep:fMax
            yNow = obj.RayleighProblemMatrix(f*2*pi,v);
            if yNow<yAnt
                NewDiffIsPos = 0;
            else
                NewDiffIsPos = 1;
            end
            if NewDiffIsPos & OldDiffIsNeg
                fp = fminbnd(@(t) obj.RayleighProblemMatrix(t*2*pi,v),f-fStep*3,f+fStep,options);
                x = [x fp];
            end
            yAnt = yNow;
            OldDiffIsNeg = 1 - NewDiffIsPos;
            end
        end
        function X = AssociatedMode(obj,w)
            [V,D] = eig(obj.ProblemMatrix(w));
            D = diag(D);
            [~,Min] = min(D);
            X = V(:,Min);
            X = X;
        end
        
        function X = GlobalInitialWave(obj,w)
            X = zeros(size(obj.elementList,2)*12,1);
            for node = obj.nodeList
                n = size(node.elementList,2);
                if n ~= 0
                    X = X + obj.LocalInitialWave(node,w);
                end
            end
        end
        function X = LocalInitialWave(obj,node,w)
            
            X = zeros(size(obj.elementList,2)*12,1);
            n = size(node.elementList,2);
            
            % Free Case
            MOutFree = zeros(6*n);
            
            i = 0;
            j = 0;
            
            % 1st Line (Effort Continuity):
            
            % Element's Effort Contribution
            for element = node.elementList
                element = element{1};
                if node.isPos(element)
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(element.L)*element.PhiNeg(w);
                else
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(0)*element.PhiPos(w);
                end 
            j=j+1;      
            end
            
            % Mass, Stiffness and Damping
            j = j-1;
            MKC = node.K - i*w*node.C - w*w*node.M;
            
            if node.isPos(element)
                 MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) + MKC*element.Rotation(element.L)*element.PsiNeg(w);
            else
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
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(element.L)*element.PsiNeg(w);
                else
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
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(element.L)*element.PsiNeg(w);
                else
                    MOutFree( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) = -element.Rotation(0)*element.PsiPos(w);
                end
                
            end
            
            % Blocked Case
            MOutBlocked = zeros(6*n);
            i = 0;
            j = 0;

            for element = node.elementList
                element = element{1};
                if node.isPos(element)
                    MOutBlocked( (1+6*i) : (6+6*i) , (1+6*j) : (6+6*j) ) =  element.Rotation(element.L)*element.PsiNeg(w);
                else
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
            
            MOut = IFreedom*MOutFree + IRestriction*MOutBlocked;
            
            % Construction of Ext
            Ext = zeros(6*n,1);
            Ext(1:6) = node.RestrictionInGlobal*node.UExt + node.FreedomInGlobal*node.FExt ;
            for i=1:(n-1)
                Ext((1 + 6*i) : (6 + 6*i)) = node.RestrictionInGlobal*node.UExt;
            end
            
            % System Solving
            W0 = MOut\Ext;
            
            % Local W0 placing in Global W0 Contribution
            iLocal = 0; 
            for elementI = node.elementList % W0i is broken
                elementI = elementI{1};
                
                % Search for corresponding W0 line
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
                
                % Place the block
                X( ( 1 + 12*i + 6*iAux ) : ( 6 + 12*i + 6*iAux ) ) = W0( ( 1 + iLocal*6 ) : ( 6 + iLocal*6 ) ); 
                
                iLocal = iLocal + 1; % Jump to next line in Tn
            end
        end
        function X = ForcedResponse(obj,w)
            W = obj.GlobalInitialWave(w);
            obj.GlobalDispersion(w);
            obj.GlobalTransmission(w);
            n = size(obj.elementList,2);
            X = obj.ProblemMatrix(w)\W;
        end
    end
    
end