# Class Styling

Container styling works fine on the latest versions of Chromium based browsers. It doesn't work well on Safari, even the latest versions.

Alternative class based styling is available for most of the styles. This works up to a point but doesn't lend itself well to responsive design. E.g. a grid with `.fixed` will still be `.fixed` in mobile.

The complications of attempting any class-based system for responsive design are too onerous to bother with. Instead, you can code the various classes directly.

Often, variables can still be used for behaviours. E.g. for a fixed column grid (`#testfix.grid.fixed`), this will work:


```css
	#testfix {
		--grid-columns:3;
	}
	@media screen and (max-width: 800px) {
		#testfix  {
			--grid-columns:1;
		}
	}

	@media screen and (min-width: 1200px) {
		#testfix  {
			--grid-columns:4;
		}
	}
```

For the more complicated components such as items, this starts to get unfeasible. Ultimately, use of the Clik parser is best, where you can convert short hand like this to CSS:

```
.testitem {
	inherit: item, item-borders
	item {
		htop: 0;
		texttop 0;
		image-align: right;
		imagespace: 1
	}
	@mobile {
		htop: 1
		image-align: center;
	}
}
```

