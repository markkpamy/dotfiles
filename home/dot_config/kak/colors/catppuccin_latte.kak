# Catppuccin theme for Kakoune

# Color palette
declare-option str rosewater 'rgb:dc8a78'
declare-option str flamingo 'rgb:dd7878'
declare-option str pink 'rgb:ea76cb'
declare-option str mauve 'rgb:8839ef'
declare-option str red 'rgb:d20f39'
declare-option str maroon 'rgb:e64553'
declare-option str peach 'rgb:fe640b'
declare-option str yellow 'rgb:df8e1d'
declare-option str green 'rgb:40a02b'
declare-option str teal 'rgb:179299'
declare-option str sky 'rgb:04a5e5'
declare-option str sapphire 'rgb:209fb5'
declare-option str blue 'rgb:1e66f5'
declare-option str lavender 'rgb:7287fd'
declare-option str text 'rgb:4c4f69'
declare-option str subtext1 'rgb:5c5f77'
declare-option str subtext0 'rgb:6c6f85'
declare-option str overlay2 'rgb:7c7f93'
declare-option str overlay1 'rgb:8c8fa1'
declare-option str overlay0 'rgb:9ca0b0'
declare-option str surface2 'rgb:acb0be'
declare-option str surface1 'rgb:bcc0cc'
declare-option str surface0 'rgb:ccd0da'
declare-option str base 'rgb:eff1f5'
declare-option str mantle 'rgb:e6e9ef'
declare-option str crust 'rgb:dce0e8'

# UI
evaluate-commands %sh{
  rosewater="rgb:dc8a78"
  flamingo="rgb:dd7878"
  pink="rgb:ea76cb"
  mauve="rgb:8839ef"
  red="rgb:d20f39"
  maroon="rgb:e64553"
  peach="rgb:fe640b"
  yellow="rgb:df8e1d"
  green="rgb:40a02b"
  teal="rgb:179299"
  sky="rgb:04a5e5"
  sapphire="rgb:209fb5"
  blue="rgb:1e66f5"
  lavender="rgb:7287fd"
  text="rgb:4c4f69"
  subtext1="rgb:5c5f77"
  subtext0="rgb:6c6f85"
  overlay2="rgb:7c7f93"
  overlay1="rgb:8c8fa1"
  overlay0="rgb:9ca0b0"
  surface2="rgb:acb0be"
  surface1="rgb:bcc0cc"
  surface0="rgb:ccd0da"
  base="rgb:eff1f5"
  mantle="rgb:e6e9ef"
  crust="rgb:dce0e8"

  echo "
    # Default
    face global value ${peach}
    face global type ${yellow}
    face global variable ${text}
    face global module ${text}
    face global function ${blue}
    face global string ${green}
    face global keyword ${mauve}
    face global operator ${sky}
    face global attribute ${blue}
    face global comment ${surface2}+i
    face global documentation comment
    face global meta ${pink}
    face global builtin ${peach}
    face global title ${lavender}+b
    face global header ${lavender}
    face global mono ${subtext1}
    face global block ${subtext1}
    face global link ${lavender}+u
    face global bullet ${lavender}
    face global list ${mauve}
    face global Default ${text},${base}
    face global PrimarySelection ${text},${mauve}
    face global SecondarySelection ${text},${surface2}
    face global PrimaryCursor ${base},${text}+fg
    face global SecondaryCursor ${base},${text}+fg
    face global PrimaryCursorEol ${base},${mauve}+fg
    face global SecondaryCursorEol ${base},${mauve}+fg
    face global LineNumbers ${surface1}
    face global LineNumberCursor ${text}
    face global LineNumbersWrapped ${surface0}
    face global MenuForeground ${base},${lavender}
    face global MenuBackground ${text},${surface0}
    face global MenuInfo ${surface0}
    face global Information ${base},${lavender}
    face global Error ${base},${red}
    face global DiagnosticError ${red}
    face global DiagnosticWarning ${yellow}
    face global DiagnosticInfo ${blue}
    face global DiagnosticHint ${green}
    face global StatusLine ${text},${mantle}
    face global StatusLineMode ${base},${lavender}
    face global StatusLineInfo ${blue}
    face global StatusLineValue ${peach}
    face global StatusCursor ${text},${overlay1}
    face global Prompt ${base},${lavender}
    face global MatchingChar default,${surface1}
    face global Whitespace ${surface1}+f
    face global WrapMarker ${surface1}
    face global BufferPadding ${surface0}
  "
}
