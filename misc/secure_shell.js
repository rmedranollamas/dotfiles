/**
 *  STEP 1:  Setup
 *  -  Open Chrome Secure Shell settings
 *  -  Open JS Console (CTRL+SHIFT+J)
 *  -  Copy and paste the following:
 */
var s7d_colours = {
  'base03': '#002b36',
  'base02': '#073642',
  'base01': '#586e75',
  'base00': '#657b83',
  'base0': '#839496',
  'base1': '#93a1a1',
  'base2': '#eee8d5',
  'base3': '#fdf6e3',
  'yellow': '#b58900',
  'orange': '#cb4b16',
  'red': '#dc322f',
  'magenta': '#d33682',
  'violet': '#6c71c4',
  'blue': '#268bd2',
  'cyan': '#2aa198',
  'green': '#859900'
};

// Disable bold
term_.prefs_.set('enable-bold', true);
term_.prefs_.set('enable-bold-as-bright', false);

// Use ANSI 16 colour terminal
term_.prefs_.set('environment', {
  "TERM": "xterm-color"
});

// Get some cool monospaced fonts
term_.prefs_.set('user-css', 'http://fonts.googleapis.com/css?family=Ubuntu+Mono|Droid+Sans+Mono|Source+Code+Pro|Anonymous+Pro');




/**
 * STEP 2:
 * -  Copy / paste ONE of the blocks below to setup Light or Dark
 */

// Solarized Dark
term_.prefs_.set('background-color', s7d_colours.base03);
term_.prefs_.set('foreground-color', s7d_colours.base0);
term_.prefs_.set('cursor-color', s7d_colours.base03);
term_.prefs_.set('color-palette-overrides', [s7d_colours.base02, s7d_colours.red, s7d_colours.green, s7d_colours.yellow, s7d_colours.blue, s7d_colours.magneta, s7d_colours.cyan, s7d_colours.base2, s7d_colours.base3, s7d_colours.orange, s7d_colours.base01, s7d_colours.base00, s7d_colours.base0, s7d_colours.violet, s7d_colours.base1, s7d_colours.base3]);

// Solarized Light
term_.prefs_.set('background-color', s7d_colours.base3);
term_.prefs_.set('foreground-color', s7d_colours.base00);
term_.prefs_.set('cursor-color', s7d_colours.base03);
term_.prefs_.set('color-palette-overrides', [s7d_colours.base2, s7d_colours.red, s7d_colours.green, s7d_colours.yellow, s7d_colours.blue, s7d_colours.magneta, s7d_colours.cyan, s7d_colours.base02, s7d_colours.base03, s7d_colours.orange, s7d_colours.base1, s7d_colours.base0, s7d_colours.base00, s7d_colours.violet, s7d_colours.base01, s7d_colours.base03]);


/**
 * STEP 3:
 * -  Copy / paste ONE of the blocks below to choose a font
 */

// Automagically loaded from Google Fonts
term_.prefs_.set('font-family', '"Ubuntu Mono", monospace');
term_.prefs_.set('font-family', '"Droid Sans Mono", monospace');
term_.prefs_.set('font-family', '"Source Code Pro", monospace');
term_.prefs_.set('font-family', '"Anonymous Pro", monospace');

// Alternatively, if you have a font installed locally just enter it here:
term_.prefs_.set('font-family', '"NAME OF FONT", monospace');