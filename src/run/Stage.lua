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
    -- Handle edge cases where either size is 1
    if row1Size == 1 or row2Size == 1 then
        return {1}
    end

    -- Calculate the exact proportional position in row2
    local exactPos = (j - 1) * (row2Size - 1) / (row1Size - 1) + 1
    local base = math.floor(exactPos + 1e-6) -- fuck you IEEE 754

    -- Collect potential neighbors (base-1, base, base+1)
    local neighbors = {}
    for i = -1, 1 do
        local index = base + i
        if index >= 1 and index <= row2Size then
            table.insert(neighbors, index)
        end
    end

    -- Special case when mapping to size 2
    if row2Size == 2 and row1Size > 2 then
        if j == math.ceil(row1Size / 2) then
            return {1, 2}
        end
    end

    -- Handle expansion case (row1Size < row2Size)
    if row1Size < row2Size then
        -- For expansion, we should only return the closest 2 neighbors when not exactly on a node
        if math.abs(exactPos - math.floor(exactPos + 0.5)) > 1e-6 then
            table.sort(neighbors, function(a, b)
                return math.abs(a - exactPos) < math.abs(b - exactPos)
            end)
            -- Return the two closest neighbors
            return {neighbors[1], neighbors[2]}
        else
            -- Exactly on a node, return just that node
            return {math.floor(exactPos + 0.5)}
        end
    end

    -- Handle compression case (row1Size > row2Size)
    if row1Size > row2Size then
        return self:getClosestNeighbors(neighbors, exactPos)
    end

    -- For equal sizes, return all potential neighbors (base-1, base, base+1)
    return neighbors
end

-- helper function to select closest neighbor(s) during compression
function Stage:getClosestNeighbors(neighbors, exactPos)
    -- If exactly on a node, return just that node
    if math.abs(exactPos - math.floor(exactPos + 0.5)) < 1e-6 then
        return {math.floor(exactPos + 0.5)}
    end

    -- Sort by distance to exact position
    table.sort(neighbors, function(a, b)
        return math.abs(a - exactPos) < math.abs(b - exactPos)
    end)

    -- If two neighbors are equally close, return both
    if #neighbors > 1 and 
       math.abs(math.abs(neighbors[1] - exactPos) - math.abs(neighbors[2] - exactPos)) < 1e-6 then
        return {neighbors[1], neighbors[2]}
    end

    return {neighbors[1]}
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

    print("size",#self.nodes,#self.nodes[1])

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