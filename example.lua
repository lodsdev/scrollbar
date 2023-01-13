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
    'Text11',
    'Text12',
    'Text13',
    'Text14',
    'Text15',
    'Text16',
    'Text17',
    'Text18',
    'Text19',
    'Text20',
}

local scroll = Scrollbar:new({ x = 500, y = 500, width = 300, height = 10, maxValue = #items, minValue = visibleItems, orientation = 'horizontal' }, false)
scroll:setProperty('barColor', {255, 0, 0})
scroll:setProperty('barColorHover', {255, 175, 0})
scroll:setProperty('smooth', true)

scroll:onScroll(function(value)
    scrollOffset = value
end)

local function render()
    scroll:render()
    for i = 1 + scrollOffset, math.min(#items, visibleItems + scrollOffset) do
        dxDrawText(items[i], 400, 500 + (i - 1 - scrollOffset) * 40, 300, 140 + (i - 1 - scrollOffset) * 40, tocolor(255, 255, 255, 255), 1, 'default', 'left', 'top', false, false, false, false, false)
    end
end
addEventHandler('onClientRender', root, render)

local function click(button, state, abx, aby)
    scroll:click(button, state, abx, aby)

    if (button == 'mouse_wheel_down') then
        scrollOffset = scrollOffset + 1
        scroll:setScrollOffset(scrollOffset)
    elseif (button == 'mouse_wheel_up') then
        scrollOffset = scrollOffset - 1
        scroll:setScrollOffset(scrollOffset)
    end
end
addEventHandler('onClientClick', root, click)
