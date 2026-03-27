# Settings Scripts

We previously converted the container based styling in grids.css to Lucee logic in grids.cfc 

The css method recreates the container based styling without the CSS vars.

I now want to create a component for each of the following with the same structure as grids.cfc (one component per item)

1. items - see items.css
2. tabs - see tabs.css
3. menus - see menus.css
4. images - see images.css

Please note the following Lucee styles:

-There is no need for the var keyword if you are sing localmode=true
-Always prefix the arguments variables with arguments.

Note that for the items, we don't need the inner div any more. For menus, we will keep the structure as the <ul> provides normal symantic markup.



