
NOTE, the way I prefer to compose panels on a dashboard is with using utility
function [util.grid.makeGrid](https://grafana.github.io/grafonnet/API/util.html#fn-gridmakegrid)

```
makeGrid(panels, panelWidth, panelHeight, startY)
```
function wraps in a realy nice way rows and pannels

by setting `panelWidth` we decide how many panels we wanna have per row,

and `startY` sets the starting point of `Y`

tldr; my approach:
```
local panels_row_1 = [
// becasue panels are gonna be wrapped by makeGrid function
// skip withGridPos here
];

local panels_row_2 = [
];

local panels = g.util.grid.makeGrid(panels_row_1, 6, 4, 2)
             + g.util.grid.makeGrid(panels_row_2, 8, 4, 6);

g.dashboard.new('my-awesome-dashboard')
+ g.dashboard.withPanels(panels)
```
