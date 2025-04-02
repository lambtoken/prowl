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

function getNeighborNode(row1Size, row2Size, j)
    if row1Size > row2Size then
        return math.ceil(j / row2Size - 1)
    else
        return math.ceil(j / row1Size - 1)
    end
end

function Stage:connectNodes()

    math.randomseed(os.time())

    -- uncle bob i am sorry...
    local function getValidEdges(row1, row2, rowNumber, forward)
        local edges = {}

        local rowAdvance

        if forward then
            rowAdvance = 1
        else rowAdvance = -1
        end

        -- Determine offsets based on row lengths
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
                    -- print(rowNumber, i, randomEdge[1], randomEdge[2])
                    -- pretty.print(self.nodes[randomEdge[1]][randomEdge[2]].from)
                    table.insert(self.nodes[randomEdge[1]][randomEdge[2]].from, {rowNumber, i})
                else
                    table.insert(self.nodes[randomEdge[1]][randomEdge[2]].to, {rowNumber, i})
                    -- print(rowNumber, i, randomEdge[1], randomEdge[2])
                    -- pretty.print(self.nodes[randomEdge[1]][randomEdge[2]].from)
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
    -- for i = #self.nodes - 1, 2, -1 do
    --     local currentRow = self.nodes[i]
    --     local previousRow = self.nodes[i - 1]

    --     for j, node in ipairs(currentRow) do
    --         if #node.from == 0 then
    --             local previousNodeIndex = getNeighborNode(#previousRow, #currentRow, j)
    --             local previousNode = previousRow[previousNodeIndex]
                
    --             table.insert(node.from, {i - 1, previousNodeIndex})
    --             table.insert(previousNode.to, {i, j})
    --         end
    --     end
    -- end

end

function Stage:generate()
    self:generateNodes()
    self:connectNodes()
end

return Stage