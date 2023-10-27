# fonts in the tty

in the default console, fonts are special. we need to use bitmap fonts, since there's no real rendering
system we can take advantage of, so we can't rescale fonts effectively because of how we're drawing them.

### changing it

setfont cybercafe

this works, because cybercafe is in the /usr/share/kbd/consolefonts directory.
you can try any of the other fonts there, but it should only work in the tty, not in X (or Wayland?).


making this persist depends on the init system.


### bitmap fonts

we can take any ttf and turn it into a bitmap font by crushing it.
bitmap is worse and simpler than ttf, bitmap is literally just a grid of pixels.
it's basically what you think of when you think "font".

"
    A bitmap font is a font with designs composed of a grid of dots or pixels,
    representing each glyph. Bitmap fonts are designed to be displayed at a
    specific size, which is determined at design time. When bitmap fonts are
    scaled, they can become blurred, hence they are not as flexible as other font
    types such as TrueType or OpenType fonts.

    In contrast, a TrueType font (TTF) is scalable and can maintain high quality at
    any size. TTF uses a series of mathematical curves and lines to create glyphs,
    allowing them to scale up or down smoothly.

    To convert a TTF font to a bitmap font, you could use a tool like FontForge
    which is an open source font editor.
"
