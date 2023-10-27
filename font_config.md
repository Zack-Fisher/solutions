# fc-cache, font config system on linux

font config provides a bunch of XML rules to find proper fonts.
there's C libraries that do all of this in the background.

/etc/fonts/conf.d/ is the rulesdir

they're all executed in order, and they all try to match.
it's the same deal as usb driver matching.

just match against a rule, it even has the ordered numbering
to show the importance of a rule.

-fc-cache -f -v, reloads the font cache

## examples

### usage in suckless term

this bit from the st config.h file
in the source, we pass this static string into the fontconfig server.
we'll get back a proper font that (hopefully) matches the string
based on the props that we asked for.

```c
static char *font = "mono:pixelsize=22:antialias=true:autohint=true";
static char *font2[] = { "NotoColorEmoji:pixelsize=20:antialias=true:autohint=true" };
static int borderpx = 2;
```

so functionally, font-config allows an application to ask nicely for what 
it WANTS out of a font, rather than trying to bundle the perfect one into
the application itself.

### raw usage in C

```c
#include <stdio.h>
#include <fontconfig/fontconfig.h>

int main() {
    FcPattern* pattern;
    FcResult result;
    FcChar8* fontFile;

    // Initialize Fontconfig
    FcConfig* config = FcInitLoadConfigAndFonts();

    // Create a pattern to match serif fonts
    pattern = FcPatternCreate();
    FcPatternAddString(pattern, FC_FAMILY, (FcChar8*) "serif");

    // Set the pixel size of the font
    FcPatternAddDouble(pattern, FC_PIXEL_SIZE, 12.0);

    // Configure the font matching options
    FcConfigSubstitute(config, pattern, FcMatchPattern);
    FcDefaultSubstitute(pattern);

    // Match the font pattern to find a font
    FcPattern* match = FcFontMatch(config, pattern, &result);

    // Get the font file name
    FcPatternGetString(match, FC_FILE, 0, &fontFile);

    // Print the font file name
    printf("Serif Font File: %s\n", fontFile);

    // Cleanup
    FcPatternDestroy(pattern);
    FcPatternDestroy(match);
    FcConfigDestroy(config);

    return 0;
}
```

## testing font matching

sometimes, you just want to see what font config is going to do with a specific string.
this is how you do that, just use fc-match <pattern> and it'll return what it thinks you want, what the C program would use.

### gpt

To test a font match against Fontconfig on your system, you can use the
fc-match command-line tool. Fontconfig is a library designed to provide a
unified interface for configuring and customizing font settings on Linux and
Unix-based systems.

Here's how you can use fc-match to test a font match:

Open a terminal on your system.

Type the following command:

bash

fc-match <font-pattern>

Replace <font-pattern> with the font pattern you want to test. For example, if
you want to test the font match for the pattern "Arial", you would enter:

bash

fc-match Arial

### notes about fallbacks

it'll just fallback to the default font on the system if it doesn't find a match.
the fonts need to match exactly, it works really weird.

TT stands for truetype, include that.

zack@zackarchmain ~ $ fc-match ProggyCleanTT
ProggyClean.ttf: "ProggyCleanTT" "Regular"
zack@zackarchmain ~ $ fc-match ProggyClean
FreeSans.otf: "FreeSans" "Regular"
zack@zackarchmain ~ $


### actually writing the rules

the query "ProggyCleanTT" will map to a member of this font family, with this font.

gpt insists that the size param is valid, but it's not.
i think that it needs to be specified in the query itself, or somewhere else in the XML doc
<size>28</size>

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd"> <!-- haha actually using the doctype of an XML doc. 
    fonts.dtd is apparently an XML thing for specifying the layout of the document? not sure, xml sux
-->
<fontconfig>
    <alias>
        <family>DEFAULT</family>
        <prefer>
            <family>ProggyCleanSZ</family>
        </prefer>
    </alias>
</fontconfig>
```

the size and other props of the font can be inline-overridden in the request with the string and the : syntax
for parameters in fontconfig, eg

```c
static char *font = "mono:pixelsize=22:antialias=true:autohint=true";
```

### changing the proper system default

an example /etc/fonts/local.conf file.

this local.conf is the default rule that determines the proper fallback behavior.
eg, with this local.conf on my system, the following happens:

```bash
zack@zackarchmain ~ $ fc-match alskdflkj
FreeSans.otf: "FreeSans" "Regular"
zack@zackarchmain ~ $
```

we can get around this jank by just making a last-effort rule that matches with everything.

"
Create a new file with the .conf extension in your ~/.config/fontconfig/conf.d/
directory. You can name it something like 99-custom.conf. The 99- prefix is
used to ensure it's loaded last, and thus can override previous settings.
"

for example, this is how you would set the system default font to roboto, using this:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
 <alias>
  <family>sans-serif</family>
  <prefer>
   <family>Roboto</family>
  </prefer>
 </alias>
 <alias>
  <family>serif</family>
  <prefer>
   <family>Roboto</family>
  </prefer>
 </alias>
 <alias>
  <family>monospace</family>
  <prefer>
   <family>Roboto</family>
  </prefer>
 </alias>
</fontconfig>
```

make it a rule, and call it /etc/fonts/conf.d/99-roboto-default.conf or something.

i'm honestly not sure what the purpose of /etc/fonts/local.conf is.
i thought it was the default rule, but that's clearly not true.
