# Library scrollbar
DX library that allows you to easily create scrollbar.

# License
#### This is library free, you can freely use and edit.

# About
This is a simple library for create scrollbars which allows easy creation of some resources

# How to use
You need download the file ```scrollbar.lua``` and put it in your project, but don't forget to load it in the meta.xml

# Functions
Create a new scrollbar
```lua
scrollbar = createScrollBar(x, y, width, height, radius, minValue, maxValue, postGUI)
```

Destroy the scrollbar
```lua
scrollbar:destroy()
```

| Syntax      | Description |
| ----------- | ----------- |
| Header      | Title       |
| Paragraph   | Text        |

```
{
  "scrollOffset": number value,
  "bgBarColor": table,
  "smoothScroll": boolen
}
```

Change a property of scrollbar
```lua
scrollbar:setProperty(property, value)
```

Set a new offset
```lua
scrollbar:setScrollOffset(value)
```

Get the current offset value
```lua
scrollbar:onScroll()
```

Get the output the scroll offset
```lua
scrollbar:onScrollEnd()
```
