# Library scrollbar
DX library that allows you to easily create scrollbar.

# About
This is a simple library for create scrollbars which allows easy creation of some resources

# How to use
You need download the file ```scrollbar.lua``` and put it in your project, but don't forget to load it in the meta.xml

# Instantiating
Create a new scrollbar using the methdo `new`, the method takes a table with the following properties: x, y, width, height, maxValue, minValue, orientation. The orientation can be "vertical" or "horizontal". 

```lua
local myScrollbar = Scrollbar:new({ x = 200, y = 200, width = 20, height = 200, maxValue = 100, minValue = 0, orientation = "vertical" })
```
Now, for use the methods of the scrollbar, you need to use the variable `myScrollbar`

Change a property of scrollbar
```lua
myScrollbar:setProperty(property, value)
```

Set a new offset
```lua
myScrollbar:setScrollOffset(value)
```

Get the current offset value
```lua
myScrollbar:onScroll()
```

Get the output the scroll offset
```lua
myScrollbar:onScrollEnd()
```

Get offset value
```lua
myScrollbar:getScrollOffset()
```

# License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/lodsdev/scrollbar/LICENSE.txt) file for details
