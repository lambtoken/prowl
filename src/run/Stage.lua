local pretty = require 'libs.batteries.pretty'
local class = require 'libs.middleclass'
local stageConfig = require 'src.run.stageConfig'
local Match = require 'src.run.MatchNode'
local Node = require 'src.run.Node'

local function tableContains(table, value) 
    for _, v in ipairs(table) do
        if v[2] == value then
            return true
        end
    end
end

local Stage = class("Stage")

function Stage:initialize(level)
    self.level = level
    self.nodes = {}
    self.currentNode = {1, 1}
    self.screenX = 0
    self.screenY = 0
end

function Stage:generateNodes()
    for i, _ in ipairs(stageConfig.format) do
        
        table.insert(self.nodes, {})

        for j = 1, _ do
                        
            if i == 1 then
                local startNode = Node:new('start')
                startNode.spriteName = 'start_node'
                startNode.x = i
                startNode.y = j
                table.insert(self.nodes[i], startNode)

            elseif i == #stageConfig.format then
                table.insert(self.nodes[i], Match:new())
                self.nodes[i][j]:bossRoom(self.level)
                self.nodes[i][j].x = i
                self.nodes[i][j].y = j
               
            else
                table.insert(self.nodes[i], Match:new())
                self.nodes[i][j]:random()
                self.nodes[i][j].x = i
                self.nodes[i][j].y = j
            end
        end
    end
end

function Stage:getNeighborNode(row1Size, row2Size, j)
    -- Handle edge cases with size 1
    if row1Size == 1 or row2Size == 1 then return {1} end

    -- Special case for mapping to size 2
    if row2Size == 2 and row1Size > 2 then
        if j == math.ceil(row1Size / 2) then return {1, 2} end
    end

    -- Calculate proportional position
    local pos = (j-1) * (row2Size-1)/(row1Size-1) + 1

    -- Determine neighbors based on mapping direction
    if row1Size < row2Size then  -- Expansion
        return handleExpansion(pos, row2Size)
    elseif row1Size > row2Size then  -- Compression
        return handleCompression(pos, row2Size)
    else  -- Equal sizes
        return handleEqualCase(pos, row2Size)
    end
end

function handleExpansion(pos, row2Size)
    if math.abs(pos - math.floor(pos)) < 1e-6 then
        -- Exact position: return surrounding nodes
        local exact = math.floor(pos)
        return getClampedNodes(exact-1, exact+1, row2Size)
    else
        -- Non-exact: return two closest nodes
        return {
            math.max(1, math.floor(pos)),
            math.min(row2Size, math.ceil(pos))
        }
    end
end

function handleCompression(pos, row2Size)
    local rounded = math.floor(pos + 0.5)
    if math.abs(pos - rounded) < 1e-6 then
        return {rounded}
    end
    
    local n1 = math.floor(pos)
    local n2 = math.ceil(pos)
    n1 = clamp(n1, 1, row2Size)
    n2 = clamp(n2, 1, row2Size)
    
    local d1 = math.abs(pos - n1)
    local d2 = math.abs(pos - n2)
    
    if d1 < d2 then return {n1}
    elseif d1 > d2 then return {n2}
    else return {n1, n2} end
end

function handleEqualCase(pos, row2Size)
    local base = math.floor(pos + 0.5)
    return getClampedNodes(base-1, base+1, row2Size)
end

-- Helper functions
function getClampedNodes(start, finish, row2Size)
    local nodes = {}
    for i = math.max(1, start), math.min(row2Size, finish) do
        table.insert(nodes, i)
    end
    return nodes
end

function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end


function Stage:connectNodes()

    math.randomseed(os.time())

    -- i am sorry uncle bob...
    local function getValidEdges(row1, row2, rowNumber, forward)
        local edges = {}

        local rowAdvance

        if forward then
            rowAdvance = 1
        else rowAdvance = -1
        end

        -- offsets based on row lengths
        local iOffset, jOffset = 0, 0
        if #row1 > #row2 then
            jOffset = -1
        elseif #row1 < #row2 then
            jOffset = 1
        end
    
        for i, node1 in ipairs(row1) do
            edges[i] = {}
            for j = -1, 1, 1 do
                local adjustedI = i + iOffset
                local adjustedJ = i + j + jOffset
    
                if adjustedI <= 0 or adjustedI > #row1 or adjustedJ <= 0 or adjustedJ > #row2 then
                    goto continue
                end

                if j == 1 then
                    local topLeft = adjustedI + 1
                    local topRight = adjustedJ - 1
                    if topLeft > 0 and topLeft <= #row1 and topRight > 0 and topRight <= #row2 then
                        if forward then
                            if not tableContains(row1[topLeft].to, topRight) then
                                table.insert(edges[i], {rowNumber + rowAdvance, adjustedJ})
                            end
                        else
                            if not tableContains(row1[topLeft].from, topRight) then
                                table.insert(edges[i], {rowNumber + rowAdvance, adjustedJ})
                            end
                        end
                    else
                        table.insert(edges[i], {rowNumber + rowAdvance, adjustedJ})
                    end
                elseif j == 0 then
                        table.insert(edges[i], {rowNumber + rowAdvance, adjustedJ})
                elseif j == -1 then
                    local bottomI = adjustedI - 1
                    local bottomJ = adjustedJ + 1
                    if bottomI > 0 and bottomI <= #row1 and bottomJ > 0 and bottomJ <= #row2 then
                        if forward then
                            if not tableContains(row1[bottomI].to, bottomJ) then
                                table.insert(edges[i], {rowNumber + rowAdvance, adjustedJ})
                            end
                        else
                            if not tableContains(row1[bottomI].from, bottomJ) then
                                table.insert(edges[i], {rowNumber + rowAdvance, adjustedJ})
                            end
                        end
                    else
                        table.insert(edges[i], {rowNumber + rowAdvance, adjustedJ})
                    end
                end
                ::continue::

            end

            local randomEdge = edges[i][math.random(#edges[i])]
            if randomEdge then

                if forward then
                    table.insert(self.nodes[rowNumber][i].to, {randomEdge[1], randomEdge[2]})
                    table.insert(self.nodes[randomEdge[1]][randomEdge[2]].from, {rowNumber, i})
                else
                    table.insert(self.nodes[randomEdge[1]][randomEdge[2]].to, {rowNumber, i})
                    table.insert(self.nodes[rowNumber][i].from, {randomEdge[1], randomEdge[2]})
                end

            end
        end
        return edges
    end

    for i = 2, #self.nodes - 1 do
        local currentRow = self.nodes[i]
        local nextRow = self.nodes[i + 1]

        getValidEdges(currentRow, nextRow, i, true)
       end

    for i = #self.nodes - 2, 2, -1 do
        local currentRow = self.nodes[i]
        local nextRow = self.nodes[i - 1]

        getValidEdges(currentRow, nextRow, i, false)
    end

    -- connect ramaining nodes
    -- this shit needs a refactor...whatever. one day. as long as it doesn't break
    for i = #self.nodes - 1, 2, -1 do
        local currentRow = self.nodes[i]
        local previousRow = self.nodes[i - 1]

        for j, node in ipairs(currentRow) do
            if #node.from == 0 then
                local potentialPreviousNodes = self:getNeighborNode(#currentRow, #previousRow, j)
                
                if #potentialPreviousNodes == 0 then
                    goto continue
                end

                for index, value in ipairs(potentialPreviousNodes) do
                    local previousNode = previousRow[value]
                    if #node.from == 0 or #previousNode.to == 0 then
                        table.insert(node.from, {i - 1, value})
                        table.insert(previousNode.to, {i, j})
                    end
                end
            end
            ::continue::
        end
    end

    for i = 2, #self.nodes - 1, 1 do
         local currentRow = self.nodes[i]
         local nextRow = self.nodes[i + 1]

        for j, node in ipairs(currentRow) do
            if #node.to == 0 then
                local potentialNextNodes = self:getNeighborNode(#currentRow, #nextRow, j)
                
                if #potentialNextNodes == 0 then
                    goto continue
                end

                for _, nextNodeIndex in ipairs(potentialNextNodes) do
                    local nextNode = nextRow[nextNodeIndex]
                    if #node.to == 0 then
                        table.insert(node.to, {i + 1, nextNodeIndex})
                        table.insert(nextNode.from, {i, j})
                    end
                end
            end
            ::continue::
        end
    end
end

function Stage:generate()
    self:generateNodes()
    self:connectNodes()
end

return Stage 