# Scroll fix

Scroll fix can be applied to a container to ensure it remains visible on the screen as the user scrolls down the page.

The divs need a class (`.scroll-fix`) applying to them to trigger the behaviour. Otherwise we'd have to check every container and every CS.

As all this does is apply a class (scroll by default) you can control all the bevahiours via CSS anyway.

The "threshold" for scroll is set by a css var `--scroll-threshold`


