local visibleItems = 5
local scrollOffset = 0

local items = {
    'Text1',
    'Text2',
    'Text3',
    'Text4',
    'Text5',
    'Text6',
    'Text7',
    'Text8',
    'Text9',
    'Text10',
}

local scroll = createScrollBar(756, 430, 8, 319, 8/2, visibleItems, #items)

scroll:onScroll(function(value)
    scrollOffset = value
end)

scroll:setProperty('smoothScroll', true)
scroll:setProperty('bgBarColor', {0, 0, 0})
scroll:setProperty('barColor', {180, 0, 20})

addEventHandler('onClientRender', root, function()
    local offsetY = 0
    for i = 1 + scrollOffset, math.min(#items, scrollOffset + visibleItems) do
        dxDrawText(items[i], 488, 430 + offsetY, 262, 104, tocolor(255, 255, 255))
        offsetY = offsetY + 70
    end
end)

addEventHandler('onClientKey', root, function(b, press)
    if (not press) then
        return
    end

    if (isCursorOnElement(488 + 8*2, 430, 262, 104 + (70*5))) then
        if (b == 'mouse_wheel_up') then
            scrollOffset = math.max(0, scrollOffset - 1)
            scroll:setScrollOffset(scrollOffset)
        elseif (b == 'mouse_wheel_down') then
            scrollOffset = math.min(#items - visibleItems, scrollOffset + 1)
            scroll:setScrollOffset(scrollOffset)
        end
    end
end)