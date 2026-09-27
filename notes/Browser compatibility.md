# Browser compatibility

## Support target

Clik's variable-driven component modes depend on **container style queries of
custom properties** (`@container ... style(--setting: value)`). This is a newer
feature than size container queries. The practical minimum browser versions for
the current stylesheets are:

| Browser | Minimum version | Limiting feature |
| --- | ---: | --- |
| Chrome | 111 | Container style queries |
| Edge | 111 | Container style queries |
| Firefox | 128 | Container style queries |
| Safari (macOS and iOS) | 18 | Container style queries |

Safari 17 and earlier can parse custom properties, `@property`, and size
container queries, but do not evaluate Clik's `style()` queries. In those
versions the base declarations still apply, but rules that select a component
mode do not. This explains the broad “unstyled/default mode” failure rather
than a problem with the extra inner element.

The `gridInner`-style wrapper is still required: a container query cannot style
the query container itself, only its descendants. `container-name` without a
`container-type` is intentional for style-only queries; adding
`container-type: inline-size` is not a Safari fix and can introduce unwanted
layout containment.

## Other required features

The non-legacy styles also use registered custom properties (`@property`) and
`:has()`. The style-query minimums above are already new enough to include the
uses in Clik. JavaScript assumes ES2017-era features and a global jQuery.

## Safari checklist

1. Check the Safari version on both macOS and iOS. All iOS browsers use the
   system WebKit engine, so installing Chrome on an older iOS release does not
   add style-query support.
2. Inspect the computed custom property on the **named outer container**, not
   on its inner child. For example, `--grid-mode` must compute on `.grid` and
   `.gridInner` must be its descendant.
3. Do not put component content in a shadow tree or move it outside the named
   container; container lookup follows the containing tree.
4. Validate setting values against any `@property` declaration. An invalid
   registered value computes to its initial value, which can look as if the
   style query was ignored.
5. If Safari 17 or older must be supported, serve the legacy class-based
   stylesheets and corresponding classes, or add a JavaScript reflection
   fallback. There is no CSS-only equivalent that preserves arbitrary
   variable-driven mode selection in browsers without style queries.

## Bugs found during the audit

The image component had several browser-independent errors that can present
differently between parsers:

- the registered property was `--height-fix`, while CSS and JavaScript read
  `--heightfix`;
- `middle` is not a valid `object-position` keyword (`center` is);
- `.cs-imagegrid:.flickity-enabled` was an invalid selector; and
- popup arrow offsets used the invalid unit `60x` instead of `60px`.

These have been corrected. JavaScript still accepts `--heightfix` as a
transitional alias, but new styles should use `--height-fix`.
