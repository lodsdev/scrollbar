
local Scrollbar = {}
Scrollbar.__index = Scrollbar
local private = {}
setmetatable(private, {__mode = 'k'})

local screenWidth, screenHeight = guiGetScreenSize()

local DEBUG_SCROLLBAR = 'disabled'

local function debugScrollbar(...)
    if (DEBUG_SCROLLBAR == 'enabled') then
        outputDebugString(...)
    end
end

local function rgba(r, g, b, a)
    return tocolor(r, g, b, a * 255)
end

function Scrollbar:new(x, y, width, height, minValue, maxValue, postGUI)
    if (not (x or y or width or height)) then 
        local outputErr = (not x and 'Define a X position to scrollbar') or (not y and 'Define a Y position to scrollbar') or (not width and 'Define a width to scrollbar') or (not height and 'Define a height to scrollbar')
        error(outputErr, 2)
    end

    assert(type(x) == 'number', 'X position must be a number, got ' .. type(x))
    assert(type(y) == 'number', 'Y position must be a number, got ' .. type(y))
    assert(type(width) == 'number', 'Width must be a number, got ' .. type(width))
    assert(type(height) == 'number', 'Height must be a number, got ' .. type(height))
    assert(type(minValue) == 'number', 'Min value must be a number, got ' .. type(minValue))
    assert(type(maxValue) == 'number', 'Max value must be a number, got ' .. type(maxValue))
    assert(type(postGUI) == 'boolean', 'Post GUI must be a boolean, got ' .. type(postGUI))
    
    local instance = {}
    
    instance.x = x
    instance.y = y
    instance.width = width or 1
    instance.height = height or 1
    instance.minValue = minValue or 0
    instance.maxValue = maxValue or 100
    instance.postGUI = postGUI
    
    local bar = (instance.height / maxValue) * instance.minValue
    local heightBar = (bar > 0) and bar or (instance.height / 2)

    private[self].alpha = 1
    private[self].barColor = {255, 255, 255, private[self].alpha} -- color bar
    private[self].barColorHover = {0, 0, 0, private[self].alpha} -- color bar when hover
    private[self].bgBarColor = {255, 255, 255, private[self].alpha} -- color background bar
    private[self].radius = 0
    private[self].smoothScroll = false
    private[self].scrolling = false
    private[self].scrollOffset = 0
    -- Events methods
    private[self].scrolling_event = false -- this event happens when the user is scrolling
    private[self].scrollEnd_event = false -- this event happens when the user stop scrolling

    setmetatable(instance, Scrollbar)
    return instance
end

function Scrollbar:render()
    dxDrawRectangle(self.x, self.y, self.width, self.height, rgba(unpack(private[self].bgBarColor)))
end