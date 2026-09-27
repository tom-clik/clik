# Clik

Component-based web styling driven by CSS custom properties.

Clik's variable-selected component modes require container style queries.
Current browser requirements, Safari troubleshooting, and fallback guidance are
documented in [Browser compatibility](notes/Browser%20compatibility.md).

Class-driven equivalents of every container-query component stylesheet use the
`{type}_classes.css` naming convention. `assets/js/clik.classStyles.js` reflects
the component custom properties into the classes consumed by those files.
