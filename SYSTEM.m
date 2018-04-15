classdef SYSTEM < handle
    
    properties
        
        % System's Nodes, Elements, Material and Section Lists
        materialList
        sectionList
        elementList
        nodeList
        freqList
        deformatedList
        deformatedAnsys
        
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
            obj.deformatedList = {};
            
            obj.freqList = [];
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
        function AddCurvedElement(obj,id,idNodeNeg,idNodePos,idNodeCenter,idMaterial,idSection,idNodeRef)
            if idNodeNeg==idNodePos|idNodeCenter==idNodePos
               error("Elements must be defined by three different nodes");
            end
            if nargin<8
                nodeRef = NaN;
            else
                nodeRef = obj.FindNodeById(idNodeRef);
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
            nodeCenter = obj.FindNodeById(idNodeCenter);
            material = obj.FindMaterialById(idMaterial);
            section  = obj.FindSectionById(idSection);
            obj.elementList = [obj.elementList  {CURVEDELEMENT(id,nodeNeg,nodePos,nodeCenter,material,section,nodeRef)}];
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
            error('No section with such id');
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
            
            i = 1;
            j = 12;
            for element = obj.elementList
                element = element{1};
                element.ShowDeformated(W(i:j),w);
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
        

        function x = FindModalFreqs(obj,fMin,fStep,fMax)
            tol = 0.0000001;
            options = optimset('TolX',tol);
            OldDiffIsNeg = 0;
            x = [];
            yAnt=abs(det(obj.ProblemMatrix(fMin*2*pi)));
            for f = (fMin+fStep):fStep:fMax
            yNow = abs(det(obj.ProblemMatrix(f*2*pi)));
            if yNow<yAnt
                NewDiffIsPos = 0;
            else
                NewDiffIsPos = 1;
            end
            if NewDiffIsPos & OldDiffIsNeg
                fp = fminbnd(@(t) abs(det(obj.ProblemMatrix(t*2*pi))),f-fStep*3,f+fStep,options);
                [~,D] = eig(obj.ProblemMatrix(fp*2*pi));
                nbOfModes = (sum(abs(diag(D))<tol));
                for k = 1:nbOfModes
                x = [x fp];
                end
            end
            yAnt = yNow;
            OldDiffIsNeg = 1 - NewDiffIsPos;
            end
        end
        
        %find modal freqs. nb = desired number of modes
        function x = FindModalFreqs2(obj,nb,fStep)
            fMin =  fStep;
            tol = 0.0000001;
            options = optimset('TolX',tol);
            OldDiffIsNeg = 0;
            x = [];
            yAnt=abs(det(obj.ProblemMatrix(fMin*2*pi)));
            f = (fMin+fStep);
            while (size(x,2) < nb)
            yNow = abs(det(obj.ProblemMatrix(f*2*pi)));
            if yNow<yAnt
                NewDiffIsPos = 0;
            else
                NewDiffIsPos = 1;
            end
            if NewDiffIsPos & OldDiffIsNeg
                fp = fminbnd(@(t) abs(det(obj.ProblemMatrix(t*2*pi))),f-fStep*3,f+fStep,options);
                [~,D] = eig(obj.ProblemMatrix(fp*2*pi));
                nbOfModes = (sum(abs(diag(D))<tol));
                for k = 1:nbOfModes
                x = [x fp];
                end
            end
            yAnt = yNow;
            OldDiffIsNeg = 1 - NewDiffIsPos;
            f = f + fStep;
            end
        end
        function X = AssociatedMode(obj,w)
            
            M = obj.ProblemMatrix(w);
            [V,D] = eig(M);
            D = diag(D);
            [~,I] = min(D);
            W = V(:,I);
            N = size(M,1);
            
            % Scale Definition
            RU = [];            
            i = 0;
            for element = obj.elementList
                element = element{1};
                WLocal = W((i+1):(i+12));
                UMax = element.DisplacementMax(WLocal,w);
                ru = UMax/element.L;
                RU = [RU ru];
                i = i+12;
            end 
            scale = .15 * (1 / max(max(RU)));
            W = W*scale;
            X = W;
            
        end
        
        %no scaling
        function X = AssociatedMode2(obj,w,number)
            
            M = obj.ProblemMatrix(w);
            [V,D] = eig(M);
            D = diag(D);
            [~,I] = min(D);
            if nargin >2
            sortedD = sort(D);
            I = find(D == sortedD(number)); 
            end
            X = V(:,I);
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

        function X = FrequencyResponse(obj,F,idElement,s)
            element = obj.FindElementById(idElement);
            for i=1:size(obj.elementList)
               if element==obj.elementList(i)
                   break
               end
            end
            X = [];
            for f=F
                w = f*2*pi;
                W = obj.ForcedResponse(w);
                W = W(( i*12 - 11 ):( i*12 ));
                X = [X element.DisplacementAtPoint(W,w,s)];
            end
        end
        
        function ModalAnalysis(obj,nb,fStep)
            
            obj.freqList = obj.FindModalFreqs2(nb,fStep);

            freqList = obj.freqList;
            
            k = 1;
            
            %on fait parcourir la liste de freq du d�but jusqu'� la fin
            while size(freqList,2)+1>k
                
                %la fr�quence analis�e
                f = freqList(k);
                nbOfModes = sum(freqList == f);

                for nb = 1:nbOfModes
                    w = f*2*pi;
                    W = obj.AssociatedMode2(w,nb);

                    i = 1;
                    j = 12;
                    elNumb = 1; %nombre de l'�l�ment
                    deformatedMode = {};
                    
                    for element = obj.elementList
                        element = element{1};
                        [X0,Y0,Z0,X,Y,Z] = element.GetDeformated(W(i:j),w);
                        el.x0 = X0;
                        el.y0 = Y0;
                        el.z0 = Z0;
                        el.x = X;
                        el.y = Y;
                        el.z = Z;
                        i = i+12;
                        j = j+12;
                        deformatedMode{elNumb} = el;
                        elNumb =  elNumb + 1;
               
                    end
                    obj.deformatedList{k} = deformatedMode;
                    k = k + 1;
                end
            end
            
        end
        
        %plot a vibration mode
        function PlotMode(obj,number,scale)
            if size(obj.freqList,2) == 0
                error('Please call Modal Analysis first');
            end
            
            if nargin < 3
               scale = 1; 
            end
            
            mode = obj.deformatedList{number};
%             maxDisplacement = 0;
%             for element = 1:size(mode,2)
%                for subelement = size(mode{element}.x,2)
%                    displacement =  abs(mode{element}.x(subelement) + mode{element}.y(subelement) + mode{element}.z(subelement));
%                    if displacement > maxDisplacement
%                        maxDisplacement = displacement;
%                    end
%                end
%             end
%             

            displacement = [];
            for element = 1:size(mode,2)
               for subelement = size(mode{element}.x,2)
                   displacement =  [displacement abs(mode{element}.x(subelement) + mode{element}.y(subelement) + mode{element}.z(subelement))];
               end
            end
            
            unityFactor = sqrt(norm(displacement));
            unityFactor = 1;
            %Name = strcat('Deformated Structure Preview ( ',num2str(obj.freqList(number),'%.3f'),' Hz )');
            %figure('Name',Name,'NumberTitle','off');
            
            
            for element = 1:size(mode,2)
                dispX = mode{element}.x/unityFactor*scale;
                dispY = mode{element}.y/unityFactor*scale;
                dispZ = mode{element}.z/unityFactor*scale;
                plot3(mode{element}.x0 + dispX,mode{element}.y0 + dispY,mode{element}.z0 + dispZ,'k')
                hold on
                plot3(mode{element}.x0,mode{element}.y0,mode{element}.z0,'--k')
                hold on
            end     
            
            for node = obj.nodeList
                node.Show();
            end
            
            daspect([1 1 1]);
        end
        
        function PlotFromAnsysList(obj,path)
            
            fid = fopen(path);
            dataTxt = textscan(fid, '%s', 'Delimiter', '\n');
            dataTxt = dataTxt{1};

            elMode = 0;
            elements = {};
            nodes = {};
            for k = 1:size(dataTxt,1)
                line = dataTxt{k};
                words = split(line,["          ","         ","        ","       ","      ","     ","    ","   ","  "," "]);
                if strcmp(words{1},"ELEM")
                   elMode = 1;
                end
                if strcmp(words{1},"NODE")
                   elMode = 0; 
                end
                if elMode && size(words{1},1)>0 && all(ismember(words{1}, '0123456789+-.eEdD'))
                   id = str2num(words{1});
                   node1 = str2num(words{7});
                   node2 = str2num(words{8});
                   el.node1 = node1;
                   el.node2 = node2;
                   elements{id} = el;
                end
                if ~elMode && size(words{1},1)>0 && all(ismember(words{1}, '0123456789+-.eEdD'))
                   id = str2num(words{1});
                   x = str2num(words{2});
                   y = str2num(words{3});
                   z = str2num(words{4});
                   node.x = x;
                   node.y = y;
                   node.z = z;
                   nodes{id} = node;
                end
            end
            hold on
            for element = 1:size(elements,2)
                node1 = nodes{elements{element}.node1};
                node2 = nodes{elements{element}.node2};
                X = [node1.x node2.x];
                Y = [node1.y node2.y];
                Z = [node1.z node2.z];
                plot3(X,Y,Z,'b')
                hold on
            end
        end
        
        function StructureFromAnsys(obj,path)
            fid = fopen(path);
            dataTxt = textscan(fid, '%s', 'Delimiter', '\n');
            dataTxt = dataTxt{1};
            X0 = [];
            Y0 = [];
            Z0 = [];
            
            elMode = 0;
            elements = {};
            nodes = {};
            for k = 1:size(dataTxt,1)
                line = dataTxt{k};
                words = split(line,["          ","         ","        ","       ","      ","     ","    ","   ","  "," "]);
                if strcmp(words{1},"ELEM")
                   elMode = 1;
                end
                if strcmp(words{1},"NODE")
                   elMode = 0; 
                end
                if elMode && size(words{1},1)>0 && all(ismember(words{1}, '0123456789+-.eEdD'))
                   id = str2num(words{1});
                   node1 = str2num(words{7});
                   node2 = str2num(words{8});
                   el.node1 = node1;
                   el.node2 = node2;
                   elements{id} = el;
                end
                if ~elMode && size(words{1},1)>0 && all(ismember(words{1}, '0123456789+-.eEdD'))
                   id = str2num(words{1});
                   x = str2num(words{2});
                   y = str2num(words{3});
                   z = str2num(words{4});
                   node.x = x;
                   node.y = y;
                   node.z = z;
                   nodes{id} = node;
                end
            end
            F = size(elements,2);
            for element = 1:F
               elements{element}.node1 = nodes{elements{element}.node1};
               elements{element}.node2 = nodes{elements{element}.node2};
               obj.deformatedAnsys{element}.x0 = [elements{element}.node1.x elements{element}.node2.x];
               obj.deformatedAnsys{element}.y0 = [elements{element}.node1.y elements{element}.node2.y];
               obj.deformatedAnsys{element}.z0 = [elements{element}.node1.z elements{element}.node2.z];
            end           
        end
        
        function DeformatedFromAnsys(obj,path)
            fid = fopen(path);
            dataTxt = textscan(fid, '%s', 'Delimiter', '\n');
            dataTxt = dataTxt{1};
            X = [];
            Y = [];
            Z = [];
            
            elMode = 0;
            elements = {};
            nodes = {};
            for k = 1:size(dataTxt,1)
                line = dataTxt{k};
                words = split(line,["          ","         ","        ","       ","      ","     ","    ","   ","  "," "]);
                if strcmp(words{1},"ELEM")
                   elMode = 1;
                end
                if strcmp(words{1},"NODE")
                   elMode = 0; 
                end
                if elMode && size(words{1},1)>0 && all(ismember(words{1}, '0123456789+-.eEdD'))
                   id = str2num(words{1});
                   node1 = str2num(words{7});
                   node2 = str2num(words{8});
                   el.node1 = node1;
                   el.node2 = node2;
                   elements{id} = el;
                end
                if ~elMode && size(words{1},1)>0 && all(ismember(words{1}, '0123456789+-.eEdD'))
                   id = str2num(words{1});
                   x = str2num(words{2});
                   y = str2num(words{3});
                   z = str2num(words{4});
                   node.x = x;
                   node.y = y;
                   node.z = z;
                   nodes{id} = node;
                end
            end
            
            F = size(elements,2);
            for element = 1:F
               elements{element}.node1 = nodes{elements{element}.node1};
               elements{element}.node2 = nodes{elements{element}.node2};
               
               obj.deformatedAnsys{element}.x = [elements{element}.node1.x - obj.deformatedAnsys{element}.x0(1),elements{element}.node2.x - obj.deformatedAnsys{element}.x0(2)];
               obj.deformatedAnsys{element}.y = [elements{element}.node1.y - obj.deformatedAnsys{element}.y0(1),elements{element}.node2.y - obj.deformatedAnsys{element}.y0(2)];
               obj.deformatedAnsys{element}.z = [elements{element}.node1.z - obj.deformatedAnsys{element}.z0(1),elements{element}.node2.z - obj.deformatedAnsys{element}.z0(2)];
               
%                obj.deformatedAnsys{element}.x = [elements{element}.node2.x - obj.deformatedAnsys{element}.x0;
%                obj.deformatedAnsys{element}.y = [elements{element}.node2.y - obj.deformatedAnsys{element}.y0;
%                obj.deformatedAnsys{element}.z = [elements{element}.node2.z - obj.deformatedAnsys{element}.z0;
            end
            
        end
        
        function PlotFromAnsys(obj,scale)
            if size(obj.deformatedAnsys,2) == 0
                error('Please call  "Structure from Ansys" first');
            end
            
            if nargin < 2
               scale = 1; 
            end
            
            
            mode = obj.deformatedAnsys;
            displacement = [];
            for element = 1:size(mode,2)
               for subelement = size(mode{element}.x,2)
                   displacement =  [displacement abs(mode{element}.x(subelement) + mode{element}.y(subelement) + mode{element}.z(subelement))];
               end
            end
            
            unityFactor = sqrt(norm(displacement));
            unityFactor = 1;
            %Name = strcat('Deformated Structure Preview ( ',num2str(obj.freqList(number),'%.3f'),' Hz )');
            %figure('Name',Name,'NumberTitle','off');
            
            
            for element = 1:size(mode,2)
                dispX = mode{element}.x./unityFactor.*scale;
                dispY = mode{element}.y./unityFactor.*scale;
                dispZ = mode{element}.z./unityFactor.*scale;
                plot3(mode{element}.x0 + dispX,mode{element}.y0 + dispY,mode{element}.z0 + dispZ,'b')
                hold on
            end     
            
            daspect([1 1 1]);
        end
        
        function CompareToAnsys(obj,number,scale)
            
            if size(obj.freqList,2) == 0
                error('Please call Modal Analysis first');
            end
            
            if nargin < 3
               scale = 1; 
            end
            
            mode = obj.deformatedList{number};
%             maxDisplacement = 0;
%             for element = 1:size(mode,2)
%                for subelement = size(mode{element}.x,2)
%                    displacement =  abs(mode{element}.x(subelement) + mode{element}.y(subelement) + mode{element}.z(subelement));
%                    if displacement > maxDisplacement
%                        maxDisplacement = displacement;
%                    end
%                end
%             end
%             

            displacement = [];
            for element = 1:size(mode,2)
               for subelement = size(mode{element}.x,2)
                   displacement =  [displacement abs(mode{element}.x(subelement) + mode{element}.y(subelement) + mode{element}.z(subelement))];
               end
            end
            unityFactor = sqrt(norm(displacement));
            
            displacementAnsys = [];
            for element = 1:size(obj.deformatedAnsys,2)
               displacementAnsys =  [displacementAnsys abs(obj.deformatedAnsys{element}.x(1) + obj.deformatedAnsys{element}.y(1) + obj.deformatedAnsys{element}.z(1)) abs(obj.deformatedAnsys{element}.x(2) + obj.deformatedAnsys{element}.y(2) + obj.deformatedAnsys{element}.z(2))];
            end
            unityFactorAnsys = sqrt(norm(displacementAnsys));
            
           
            unityFactor = sqrt(norm(displacement));
             
            
            
            
            scale = max(displacementAnsys)/max(displacement)*scale;
            
            for element = 1:size(mode,2)
                dispX = mode{element}.x*scale;
                dispY = mode{element}.y*scale;
                dispZ = mode{element}.z*scale;
                
                plot3(mode{element}.x0 + dispX,mode{element}.y0 + dispY,mode{element}.z0 + dispZ,'k')
                hold on
                plot3(mode{element}.x0,mode{element}.y0,mode{element}.z0,'--k')
                hold on
            end     
            
            for node = obj.nodeList
                node.Show();
            end
            
            
            
            daspect([1 1 1]);
 
            
        end        
    end
    
end