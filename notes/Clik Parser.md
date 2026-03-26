# Clik Parser

Container styling does everything we need it to do and the days of pre-processors are numbered. However at this time (2026-03) it's not working in Safari (even on the latest version).

To keep consistency with our container based system we use the Clik parser to emulate the same functionality with explicit CSS statements. The logical pattern of the CSS generation should be exactly the same as the container based solution, using if clauses to replace the container queries, e.g.

```css
@container item ( style(--image-align:left ) ) {
	.itemInner {
		grid-template-columns:  var(--image-width) auto;
	}

	@container item ( style(--texttop:0 ) ) {
```

becomes

```js
if (style["image-align"] eq "left") {
	css.append("grid-template-columns:  var(--image-width) auto;");
	if ( ! style["texttop"] ) {

	}
}
```

Note we don't use the `.itemInner` when doing the styling manually.

The primary problem we have in doing this is inheritance of styles across media. For any given item, we have to construct the complete set of settings values according to the media.

Some settings like `--grid-columns` we can still rely on the CSS applying, and we don't need to do anything other than write it out.

Our styling becomes more problematic.Something like this needs care:

```
@container grid ( not style(--grid-mode:named) ) {
	.gridInner > * {
		grid-area: unset !important;
	}
}
```

Other styling gets particularly complicated. For example, our borders style in menus (normal, boxes, dividers)

If we change the border width in e.g. mobile, we have to know what the borders style is. We probably want to inherit from the main option. In this case, a property is defined with "inherit=1". This is entirely unrelated to the namesake value of CSS variable properties, which we usually don't want to inherit. In the Clik parser, this means that the property will be applied to all media as if it were a CSS property.

E.g. if it is defined in the main scope, it will apply to all scopes unless redefined. If it is redefined in mid, that will also apply to mobile.

## Style Inherits

The inheritance mentioned above is an internal thing that nobody needs to know about. Style inheritance on the other hand is a user exposed mechanism.

Any given content item in the clik system can only have one style. To make maintenance easy, you can set a class to inherit from other styles. The inheritance is in order:

```
.mystyle {
	inherit: text-standard, item-standard;
}
```


