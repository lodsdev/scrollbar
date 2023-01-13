
Scrollbar = {}
local private = {}
setmetatable(private, { __mode = 'k' })

local screenWidth, screenHeight = guiGetScreenSize()

local scrollHover
local DEBUG_SCROLLBAR = 'disabled'

local function debugScrollbar(...)
    if (DEBUG_SCROLLBAR == 'enabled') then
        outputDebugString(...)
    end
end

local function rgba(r, g, b, a)
    return tocolor(r, g, b, a * 255)
end

local function isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
    return ((cursorX >= x and cursorX <= x + width) and (cursorY >= y and cursorY <= y + height))
end

local function warn(message)
    return error(message, 2)
end

local function clamp(number, min, max)
	if (number < min) then
		return min
	elseif (number > max) then
		return max 
	end
	return number
end

function Scrollbar:new(data, postGUI)
    if (not (data)) then
        warn('Define a table with the data to create a scrollbar')
    end

    assert(type(data) == 'table', 'Data must be a table, got ' .. type(data))
    
    if (not (data.x and data.y and data.width and data.height and data.minValue and data.maxValue and data.orientation)) then 
        local outputErr = (not data.x and 'Define a X position to scrollbar') or (not data.y and 'Define a Y position to scrollbar') or (not data.width and 'Define a width to scrollbar') or (not data.height and 'Define a height to scrollbar') or (not data.minValue and 'Define a min value to scrollbar') or (not data.maxValue and 'Define a max value to scrollbar') or (not data.orientation and 'Define a orientation to scrollbar')
        warn(outputErr)
    end

    assert(type(data.x) == 'number', 'X position must be a number, got ' .. type(data.x))
    assert(type(data.y) == 'number', 'Y position must be a number, got ' .. type(data.y))
    assert(type(data.width) == 'number', 'Width must be a number, got ' .. type(data.width))
    assert(type(data.height) == 'number', 'Height must be a number, got ' .. type(data.height))
    assert(type(data.minValue) == 'number', 'Min value must be a number, got ' .. type(data.minValue))
    assert(type(data.maxValue) == 'number', 'Max value must be a number, got ' .. type(data.maxValue))
    assert(type(postGUI) == 'boolean', 'Post GUI must be a boolean, got ' .. type(postGUI))
    
    local instance = {}
    setmetatable(instance, { __index = self })
    
    instance.x = data.x
    instance.y = data.y
    instance.width = data.width or 1
    instance.height = data.height or 1
    instance.minValue = data.minValue
    instance.maxValue = data.maxValue
    instance.orientation = data.orientation
    instance.postGUI = postGUI or false
    
    private[instance] = {}
    
    local sizeBar = (instance.orientation == 'vertical') and instance.height or instance.width
    local bar = (sizeBar / instance.maxValue) * instance.minValue
    private[instance].widthBar = (bar > 0) and bar or (instance.width / 2) -- width bar
    private[instance].heightBar = (bar > 0) and bar or (instance.height / 2) -- height bar
    
    private[instance].positionClick = {}
    private[instance].posBarX = instance.x
    private[instance].posBarY = instance.y
    private[instance].tickClick = false
    private[instance].smoothData = {
        active = false,
        positionI = 0,
        positionF = 0,
    }
    private[instance].mouseData = {
        clickBar = { x = 0, y = 0 },
        clickMoveBar = { x = 0, y = 0 }
    }
    private[instance].alpha = 1
    private[instance].barColor = {255, 255, 255} -- color bar
    private[instance].barColorHover = {0, 0, 0} -- color bar when hover
    private[instance].bgBarColor = {0, 0, 0} -- color background bar
    private[instance].radius = 0
    private[instance].smoothScroll = false
    private[instance].scrolling = false
    private[instance].scrollOffset = 0
    -- Events methods
    private[instance].scrolling_event = false -- this event happens when the user is scrolling
    private[instance].scrollEnd_event = false -- this event happens when the user stop scrolling
    
    return instance
end

function Scrollbar:render()
    scrollHover = nil

    if (isMouseInPosition(self.x, self.y, self.width, self.height)) then
        scrollHover = self
    end

    dxDrawRectangle(
        self.x, 
        self.y, 
        self.width, 
        self.height, 
        rgba(private[self].bgBarColor[1], private[self].bgBarColor[2], private[self].bgBarColor[3], private[self].alpha)
    )

    local barWidth = (self.orientation == 'horizontal') and private[self].widthBar or self.width
    local barHeight = (self.orientation == 'vertical') and private[self].heightBar or self.height

    dxDrawRectangle(
        private[self].posBarX,
        private[self].posBarY,
        barWidth,
        barHeight,
        (
            (isMouseInPosition(private[self].posBarX, private[self].posBarY, barWidth, barHeight) or private[self].scrolling)
            and rgba(private[self].barColorHover[1], private[self].barColorHover[2], private[self].barColorHover[3], private[self].alpha)
            or rgba(private[self].barColor[1], private[self].barColor[2], private[self].barColor[3], private[self].alpha)
        )
    )

    if (private[self].scrolling) then
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
        
        local valueOffset = 0
        if (self.orientation == 'vertical') then
            local cy = (cursorY - private[self].mouseData.clickMoveBar.y)
            private[self].posBarY = clamp(cy, self.y, self.y + (self.height - private[self].heightBar))
            valueOffset = math.ceil(clamp(((private[self].posBarY - self.y) / (self.height - private[self].heightBar)) * 100, 0, 100))
        else
            local cx = (cursorX - private[self].mouseData.clickMoveBar.x)
            private[self].posBarX = clamp(cx, self.x, self.x + (self.width - private[self].widthBar))
            valueOffset = math.ceil(clamp(((private[self].posBarX - self.x) / (self.width - private[self].widthBar)) * 100, 0, 100))
        end
        
        self:setScrollOffset(valueOffset)

        if (private[self].scrolling_event) then
            private[self].scrolling_event(self:getScrollOffset())
        end
    end
end

function Scrollbar:click(button, state, abx, aby)
    if (button == 'left' and state == 'down') then
        if (scrollHover == self) then
            if (abx >= private[self].posBarX and abx <= (private[self].posBarX + private[self].widthBar) and aby >= private[self].posBarY and aby <= (private[self].posBarY + private[self].heightBar)) then
                private[self].scrolling = true
                private[self].mouseData.clickMoveBar.x = abx - private[self].posBarX
                private[self].mouseData.clickMoveBar.y = aby - private[self].posBarY
                return
            end

            local valueOffset = 0
            private[self].mouseData.clickBar.x = abx - self.x
            private[self].mouseData.clickBar.y = aby - self.y

            if (private[self].smoothData.active) then
                private[self].tickClick = getTickCount()

                if (self.orientation == 'vertical') then
                    local newPosBar = math.ceil(aby - (private[self].heightBar / 2), self.y, self.y + (self.height - private[self].heightBar))
                    valueOffset = math.ceil(clamp(((newPosBar - self.y) / (self.height - private[self].heightBar)) * 100, 0, 100))
                    private[self].smoothData.positionI, private[self].smoothData.positionF = private[self].posBarY, newPosBar 
                end
            else
                if (self.orientation == 'vertical') then
                    self:setBarPosition('vertical', clamp(aby - (private[self].heightBar / 2), self.y, self.y + (self.height - private[self].heightBar)))
                    valueOffset = math.ceil(clamp(((private[self].posBarY - self.y) / (self.height - private[self].heightBar)) * 100, 0, 100))
                end
            end

            self:setScrollOffset(valueOffset)
            
            if (private[self].scrolling_event) then
                private[self].scrolling_event(self:getScrollOffset())
            end
        end
    elseif (button == 'left' and state == 'up') then
        private[self].scrolling = false
        if (private[self].scrollEnd_event) then
            private[self].scrollEnd_event(self:getScrollOffset())
        end
    end
end

function Scrollbar:setScrollOffset(value)
    if (not value) then
        warn('Define a value to set scroll offset')
        return false
    end
    private[self].scrollOffset = math.ceil((value / 100) * (self.maxValue - self.minValue))
    return true
end

function Scrollbar:getScrollOffset()
    return private[self].scrollOffset
end

function Scrollbar:onScroll(callback)
    if (not callback) then
        warn('Define a callback to onScroll event')
        return false
    end
    private[self].scrolling_event = callback
    return true
end

function Scrollbar:onScrollEnd(callback)
    if (not callback) then
        warn('Define a callback to onScrollEnd event')
        return false
    end
    private[self].scrollEnd_event = callback
    return true
end

function Scrollbar:setBarPosition(orientation, position)
    if (not orientation) then
        warn('Define a orientation to set bar position')
        return false
    end
    if (not position) then
        warn('Define a position to set bar position')
        return false
    end
    
    local orientations = {
        ['vertical'] = function(value)
            private[self].posBarY = value
        end,
        ['horizontal'] = function(value)
            private[self].posBarX = value
        end
    }

    if (not orientations[orientation]) then
        warn('Invalid orientation')
        return false
    end

    orientations[orientation](position)
    return true
end

function Scrollbar:setProperty(property, value)
    if (not property or not value) then
        local output = (not property and 'Define a property to set property') or (not value and 'Define a value to set property')
        warn(output)
        return false
    end

    if (not private[self][property]) then
        warn('Invalid property')
        return false
    end

    private[self][property] = value
    return true
end
