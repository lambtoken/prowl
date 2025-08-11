local mold = require("libs.mold")
local test = require("src.test.tinytest")

local mold_tests = test.new("Mold tests")

mold_tests:add("basic percent", function()
    local root = mold.Container:new()
    :setRoot(1000, 1000)
    :setDirection("column")
    :setJustifyContent("start")
    :setAlignContent("start")

    local container1 = root:addContainer()
        :setWidth("50%")
        :setHeight("50%")

    local container2 = root:addContainer()
        :setWidth("100px")
        :setHeight("100px")

    root:resize()

    test.eq(root.cw, 1000)
    test.eq(root.ch, 1000)
    test.eq(container1.cw, 500)
    test.eq(container1.ch, 500)
    test.eq(container2.cw, 100)
    test.eq(container2.ch, 100)
end)


mold_tests:add("row auto dir height", function()
    local root = mold.Container:new()
    :setRoot(1000, 1000)
    :setDirection("column")
    :setJustifyContent("start")
    :setAlignContent("start")

    local row = root:addContainer()
    :setDirection("row")
    :setHeight("auto")

    local child1 = row:addContainer()
    :setWidth("100px")
    :setHeight("100px")

    local child2 = row:addContainer()
    :setWidth("100px")
    :setHeight("100px")

    root:resize()

    test.eq(row.ch, 100)
    test.eq(child1.ch, 100)
    test.eq(child2.ch, 100)
end)

mold_tests:add("row auto dir width", function()
    local root = mold.Container:new()
    :setRoot(1000, 1000)
    :setDirection("column")
    :setJustifyContent("start")
    :setAlignContent("start")

    local row = root:addContainer()
    :setDirection("row")
    :setWidth("auto")

    local child1 = row:addContainer()
    :setWidth("100px")
    :setHeight("100px")

    local child2 = row:addContainer()
    :setWidth("100px")
    :setHeight("100px")

    root:resize()

    test.eq(row.cw, 200)
    test.eq(child1.cw, 100)
    test.eq(child2.cw, 100)
end)

mold_tests:add("row of buttons auto dir width", function()
    local root = mold.Container:new()
    :setRoot(1000, 1000)
    :setDirection("column")
    :setJustifyContent("start")
    :setAlignContent("start")

    local row = root:addContainer()
    :setDirection("row")
    :setWidth("auto")
    :setHeight("auto")

    local button1 = row:addChild(mold.Button:new())
    :setWidth("100px")
    :setHeight("100px")

    local button2 = row:addChild(mold.Button:new())
    :setWidth("100px")
    :setHeight("100px")

    root:resize()

    test.eq(row.cw, 200)
    test.eq(button1.cw, 100)
    test.eq(button2.cw, 100)
end)

mold_tests:add("row of buttons auto dir height", function()
    local root = mold.Container:new()
    :setRoot(1000, 1000)
    :setDirection("column")
    :setJustifyContent("start")
    :setAlignContent("start")

    local row = root:addContainer()
    :setDirection("row")
    :setWidth("auto")
    :setHeight("auto")

    local button1 = row:addChild(mold.Button:new("Test"))
    local button2 = row:addChild(mold.Button:new("Test"))

    root:resize()

    -- 82 is a magic number here but that should be the height of the default
    -- button font size

    test.eq(row.ch, 82)
    test.eq(button1.ch, 82)
    test.eq(button2.ch, 82)
end)

mold_tests:add("simple button explicit width", function()
    local root = mold.Container:new()
        :setRoot(1000, 1000)
        :setDirection("column")

    local button = mold.Button("Test")
        :setWidth("200px")

    root:addChild(button)
    root:resize()

    test.eq(button.cw, 200)
    test.eq(button.ch, 82)
end)

mold_tests:add("bug reproduction", function()
    local root = mold.Container:new()
        :setRoot(1000, 1000)
        :setDirection("column")
        :setJustifyContent("start")
        :setAlignContent("start")

    local buttonContainer = root:addContainer()
        :setWidth("auto")
        :setHeight("auto")
        :setDirection("row")
        :setJustifyContent("center")
        :setAlignContent("center")
        :setMargin("40px", "top")

    local applyButton = mold.Button("Apply")
        :setWidth("200px")


    local backButton = mold.Button("Back")
        :setWidth("200px")

    buttonContainer:addChild(applyButton)
    buttonContainer:addChild(backButton)

    root:resize()

    test.eq(buttonContainer.ch, 82)
    test.eq(buttonContainer.cw, 400)
    test.eq(applyButton.ch, 82)
    test.eq(backButton.ch, 82)
    test.eq(root.ch, 1000)
end)

mold_tests:add("padding", function()
    local root = mold.Container:new()
    :setRoot(1000, 1000)
    :setDirection("column")
    :setJustifyContent("start")
    :setAlignContent("start")

    local container = root:addContainer()
    :setWidth("100%")
    :setHeight("auto")
    :setDirection("row")
    :setJustifyContent("start")
    :setAlignContent("start")
    :setPadding("30px")

    local child = container:addChild(mold.Container:new())
    :setWidth("100px")
    :setHeight("100px")

    root:resize()

    test.eq(container.cw, 1000)
    test.eq(container.ch, 100)
    test.eq(container.pw, 940)
    test.eq(container.ph, 40)
    test.eq(container.mw, 1000)
    test.eq(container.mh, 100)
end)

return mold_tests