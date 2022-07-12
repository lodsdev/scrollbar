--[[credits:
    author: LODS,
    description: "A simple scrollbar",
    version: "1."
]]--

-- small optimizations
local tblInsert = table.insert
local tblRemove = table.remove
local strFormat = string.format
local floor = math.floor
local ceil = math.ceil
local tblMax = table.maxn
local max = math.max
local min = math.min
local interpolate = interpolateBetween

local screenW, screenH = guiGetScreenSize()

local inputHover
local mouseOverBar
local posI, posF
local typeProgress, tickSmooth
local scrollBar = {}

scrollBar.inputs = {}

-- create the scroll input
---comment
---@param x number
---@param y number
---@param width number
---@param height number
---@param radius number
---@param minValue number
---@param maxValue number
---@param postGUI boolean
---@return table
function createScrollBar(x, y, width, height, radius, minValue, maxValue, postGUI)
    if (not (x or y)) then
        local input = (not x and "Error in argument #1. Define a position X") or (not y and "Error in argument #2. Define a position Y")
        warn(input)
    end
    if (not (width or height)) then
        local input = (not width and "Error in argument #3. Define a width") or (not height and "Error in argument #4. Define a height")
        warn(input)
    end
    if ((width == 0) or (height == 0)) then
        local input = ((width == 0) and "Error in argument #3. Define a width greater than 0") or ((height == 0) and "Error in argument #4. Define a height greater than 0")
        warn(input)
    end
    if (minValue > maxValue) then
        warn("Error in argument #5. The min value don't can't be greater than of max value.")
    end
    if (maxValue < minValue) then
        warn("Error in argument #6. The max value don't can't be smaller of the min value.")
    end

    width = width or 1
    height = height or 1
    radius = radius or 0

    local bar = (height / maxValue) * minValue
    local heightBar = (bar > 0) and bar or height/2

    local rawDataBgBar = strFormat([[
        <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg">
            <rect rx="%s" width="%s" height="%s" fill="#FFFFFF" />
        </svg>
    ]], width, height, radius, width, height)

    local rawDataBar = strFormat([[
        <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg">
            <rect rx="%s" width="%s" height="%s" fill="#FFFFFF" />
        </svg>
    ]], width, heightBar, radius, width, heightBar)

    local datas = {
        x = x,
        y = y,
        width = width,
        height = height,
        heightBar = heightBar,
        posBar = y,
        minValue = minValue or 0,
        maxValue = maxValue or 100,
        radius = radius,
        bgBarColor = {255, 255, 255},
        barColor = {255, 255, 255},
        barColorHover = {255, 255, 255},
        postGUI = postGUI or false,
        barInput = svgCreate(width, heightBar, rawDataBar),
        barScroll = svgCreate(width, height, rawDataBgBar),
        smoothScroll = false,
        changeColorBar = false,
        scrolling = false,
        scrollOffset = 0,
        -- Events Methods
        scroll_event = false,
        scrollEnd_event = false,
        -- Technicals
        endedScrolling = true
    }

    setmetatable(datas, {__index = scrollBar})
    tblInsert(scrollBar.inputs, datas)

    if (tblMax(scrollBar.inputs) == 1) then
        addEventHandler('onClientRender', root, renderScrollbar, false, 'low-5')
        addEventHandler('onClientClick', root, clickScrollBar, false, 'low-5')
    end
    return datas
end

-- create vector images for the scroll input
local function dxDrawSVG(svg, x, y, width, height, color, postGUI)
    if (not svg) then
        warn('Error in argument #1. Define a SVG element.')
    end
    if (not (width or height)) then
        local input = (not width and 'Error in argument #2. Define a width.') or (not height and 'Error in argument #3. Define a height')
        warn(input)
    end

    dxSetBlendMode('add')
    dxDrawImage(x, y, width, height, svg, 0, 0, 0, color, postGUI)
    dxSetBlendMode('blend')
end

-- render the scroll input
function renderScrollbar()
    if (not scrollBar.inputs or (not (#scrollBar.inputs > 0))) then
        return
    end

    mouseOverBar = nil
    inputHover = nil

    for _, self in ipairs(scrollBar.inputs) do
        local barColor = self.barColor

        if (typeProgress == 'in_progress') then
            local progress = (getTickCount()-tickSmooth)/250
            local posBar = interpolate(posI, 0, 0, posF, 0, 0, progress, 'Linear')

            if (progress >= 1) then
                typeProgress = nil
                tickSmooth = nil
                posI = nil
                posF = nil
            end

            self.posBar = posBar
        end

        if (isCursorOnElement(self.x, self.y, self.width, self.height)) then
            inputHover = self
        end
        
        if (isCursorOnElement(self.x, self.posBar, self.width, self.heightBar)) then
            if (self.changeColorBar) then
                barColor = self.barColorHover
            end
            mouseOverBar = self
            inputHover = self
        end

        if (self.scrolling) then
            local _, my = getCursorPosition()
            local cursorY = my * screenH

            self.posBar = clamp(cursorY - (self.heightBar/2), self.y, self.y + (self.height - self.heightBar))
            local value = ceil(clamp(((self.posBar - self.y) / (self.height - self.heightBar)) * 100, 0, 100))
            self.scrollOffset = ceil((value / 100) * (self.maxValue - self.minValue))

            if (self.scroll_event) then
                self.scroll_event(self.scrollOffset)
            end

            if (self.changeColorBar) then
                barColor = self.barColorHover
            end
        end

        dxDrawSVG(self.barScroll, self.x, self.y, self.width, self.height, tocolor(unpack(self.bgBarColor)), self.postGUI) -- background bar
        dxDrawSVG(self.barInput, self.x, self.posBar, self.width, self.heightBar, tocolor(unpack(barColor)), self.postGUI) -- bar scroll

        if (getKeyState('mouse1')) then
            if (isCursorOnElement(self.x, self.posBar, self.width, self.heightBar)) then
                self.scrolling = true
                if (self.endedScrolling) then
                    self.endedScrolling = false
                end
            end
        else
            if (not self.endedScrolling) then
                self.scrolling = false
                self.endedScrolling = true

                if (self.scrollEnd_event) then
                    self.scrollEnd_event(self.scrollOffset)
                end
            end
        end
    end
end

-- function to check if the cursor is on the element and change the position of circle
function clickScrollBar(b, s)
    if (not scrollBar.inputs or (not (#scrollBar.inputs > 0))) then
        return
    end

    if (b == 'left' and s == 'down') then
        if (inputHover and (not mouseOverBar)) then
            local _, my = getCursorPosition()
            local cursorY = my * screenH

            if (inputHover.smoothScroll) then
                local newPosBar = clamp(cursorY - (inputHover.heightBar / 2), inputHover.y, inputHover.y + (inputHover.height - inputHover.heightBar))
                local valueOffset = ceil(clamp(((newPosBar - inputHover.y) / (inputHover.height - inputHover.heightBar)) * 100, 0, 100))
                inputHover.scrollOffset = ceil(valueOffset / 100 * (inputHover.maxValue - inputHover.minValue))

                typeProgress = 'in_progress'
                tickSmooth = getTickCount()
                posI, posF = inputHover.posBar, newPosBar
            else
                inputHover.posBar = clamp(cursorY - (inputHover.heightBar / 2), inputHover.y + inputHover.radius, inputHover.y + (inputHover.height - inputHover.heightBar))
                local valueOffset = ceil(clamp(((inputHover.posBar - inputHover.y) / (inputHover.height - inputHover.heightBar)) * 100, 0, 100))
                inputHover.scrollOffset = ceil(valueOffset / 100 * (inputHover.maxValue - inputHover.minValue))
            end

            if (inputHover.scroll_event) then
                inputHover.scroll_event(inputHover.scrollOffset)
            end
        end
    end
end

-- function to destroy the scroll input
function scrollBar:destroy()
    if (not self) then
        warn("Erro no argumento #1. Defina um objeto.")
    end

    for i, v in ipairs(scrollBar.inputs) do
        if (v == self) then
            -- free memory
            if (isElement(v.circle)) then
                destroyElement(v.barScroll)
            end
            if (isElement(v.barInput)) then
                destroyElement(v.barInput)
            end
            tblRemove(scrollBar.inputs, i)
        end
    end

    if (not (tblMax(scrollBar.inputs) > 0)) then
        removeEventHandler('onClientRender', root, renderScrollbar)
        removeEventHandler('onClientClick', root, clickScrollBar)
    end
end

-- function to set scrolloffset
---comment
---@param value number
function scrollBar:setScrollOffset(value)
    if (not self) then
        warn("Error in argument #1. Define a object.")
    end

    if (not value) then
        warn("Error in argument #2. Define a value.")
    end

    if (self.smoothScroll) then
        self.scrollOffset = ceil((value * 100) / (self.maxValue - self.minValue))
        local newPosBar = self.y + (((self.height - self.heightBar) / 100) * self.scrollOffset)
        
        typeProgress = 'in_progress'
        tickSmooth = getTickCount()
        posI, posF = self.posBar, newPosBar
    else
        self.scrollOffset = ceil((value * 100) / (self.maxValue - self.minValue))
        self.posBar = self.y + (((self.height - self.heightBar) / 100) * self.scrollOffset)
    end
end

-- function to get the scroll input
---comment
---@param func function
function scrollBar:onScroll(func)
    self.scroll_event = func
end

-- function to get output the scroll input
---comment
---@param func function
function scrollBar:onScrollEnd(func)
    self.scrollEnd_event = func
end

local changeableProperties = {
    ['x'] = true,
    ['y'] = true,
    ['width'] = true,
    ['height'] = true,
    ['minValue'] = true,
    ['maxValue'] = true,
    ['scrollOffset'] = true,
    ['smoothScroll'] = true,
    ['changeColorBar'] = true,
    ['bgBarColor'] = true,
    ['barColor'] = true,
    ['barColorHover'] = true,
    -- ['buttonsVisible'] = true,
    ['postGUI'] = true,
}

-- function to change the property of scrollbar
---comment
---@param property string
---@param value any
---@return boolean
function scrollBar:setProperty(property, value)
    if (not self) then
        warn("No element were found")
    end

    if (not property or (type(property) ~= 'string')) then
        local input = (not property and "Error in argument #1. Define a property") or (type(property) ~= 'string' and "Error in argument #1. Define a valid property.")
        warn(input)
    end

    for propertyIndex, active in pairs(changeableProperties) do
        if (propertyIndex == property and active) then
            self[propertyIndex] = value
            break
        end
    end
end

-- function to send message in debugscript
function warn(message)
    return error(tostring(message), 2)
end

-- get the max and min of a value
function clamp(number, min, max)
	if (number < min) then
		return min
	elseif (number > max) then
		return max 
	end
	return number
end

-- function to get the mouse position on the element
function isCursorOnElement(x, y, w, h)
    if (not isCursorShowing()) then return end
    local cursorX, cursorY = getCursorPosition ()
    local mx, my = cursorX * screenW, cursorY * screenH
    return (mx >= x and mx <= x + w and my >= y and my <= y + h)
end
