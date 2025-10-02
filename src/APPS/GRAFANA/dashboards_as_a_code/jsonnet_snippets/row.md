api docs:
[row](https://grafana.github.io/grafonnet/API/panel/row.html)

```
g.panel.row.new('This a row (not collapsed')
// if we are using util.grid.makeGrid() function withGridPos is not needed
//+ g.panel.row.withGridPos(0)
+ g.panel.row.withCollapsed(false)
```
