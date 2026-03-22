# Container Styling

The Clik component system uses container queries for most of its CSS queries.

This allows us to apply styling based on a CSS var rather than classes in the HTML. For example, grids use a property called `grid-mode`.

By setting the container name to `grid` when can than apply styling so:

```css
@container grid ( style(--grid-mode:flex) ) {
	.gridInner {
		display: flex;
	}
}
```

Using this mechanism we are able to apply all our styling with CSS classes applied only to the outer element. Where a single setting needs to update other settings, we can now set them referring only to the CSS property.

```css
@container widget ( style(--setting:fancy) ) {
	.inner {
		subsetting:value;
		othersetting:value;
	}
}
```

Once complication is that the styling CAN'T be defined on the main container. All content sections have a "container" div to which the styling is applied and an inner div which uses the set values. E.g., a grid looks like


```html
<div class='grid' id='mygrid'>
	<div class='gridInner'>...</div>
</div>
```

While the user stylesheet would like this:

```css
#mygrid {
	--grid-mode: columns;
	--grid-template-columns: 40% 60%
}
```

The static css applies the styling using the inner container. 

```css
.gridInner {
	display:grid;
	grid-gap:var(--grid-gap);
	flex-direction: var(--flex-direction);
	align-content: var(--align-content);
	align-items: var(--align-items);
	justify-content: var(--justify-content);
	flex-wrap: var(--flex-wrap);
	grid-template-columns: var(--grid-template-columns);
	grid-template-rows: var(--grid-template-rows);
}
```

Often you will see properties set to inherit, e.g.

```
.gridInner {
	--grid-gap: inherit;
	--grid-width: inherit;
	--grid-columns: inherit;
	...
}
```

This is because we often define our properties to not inherit (especially for grids where you can have grids within grids), so if we want the value from the outer div, we have to set everything to explicitly inherit.

Usually, though we can use the container style query mechanism for most things.


