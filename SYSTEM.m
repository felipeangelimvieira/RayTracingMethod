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
           obj.nodeList = [obj.nodeList NODE(id,r)];
        end
        function addElement(obj,idNodeNeg,idNodePos,rho,S,E,G,IIn,IOut)
            obj.elementList = [obj.elementList ELEMENT(obj.findNodeById(idNodeNeg),findNodeById(idNodePos),rho,S,E,G,IIn,IOut)];
        end
        
        function x = findNodeById(obj,id)
            for node = obj.nodeList
                if node.id == id
                    x = node;
                end
            end
            error('No node with such id');
        end
        
        
        
    end
    
end

    
