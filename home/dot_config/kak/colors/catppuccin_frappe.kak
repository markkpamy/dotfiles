# Catppuccin theme for Kakoune

# Color palette
declare-option str rosewater 'rgb:f2d5cf'
declare-option str flamingo 'rgb:eebebe'
declare-option str pink 'rgb:f4b8e4'
declare-option str mauve 'rgb:ca9ee6'
declare-option str red 'rgb:e78284'
declare-option str maroon 'rgb:ea999c'
declare-option str peach 'rgb:ef9f76'
declare-option str yellow 'rgb:e5c890'
declare-option str green 'rgb:a6d189'
declare-option str teal 'rgb:81c8be'
declare-option str sky 'rgb:99d1db'
declare-option str sapphire 'rgb:85c1dc'
declare-option str blue 'rgb:8caaee'
declare-option str lavender 'rgb:babbf1'
declare-option str text 'rgb:c6d0f5'
declare-option str subtext1 'rgb:b5bfe2'
declare-option str subtext0 'rgb:a5adce'
declare-option str overlay2 'rgb:949cbb'
declare-option str overlay1 'rgb:838ba7'
declare-option str overlay0 'rgb:737994'
declare-option str surface2 'rgb:626880'
declare-option str surface1 'rgb:51576d'
declare-option str surface0 'rgb:414559'
declare-option str base 'rgb:303446'
declare-option str mantle 'rgb:292c3c'
declare-option str crust 'rgb:232634'

# UI
evaluate-commands %sh{
  rosewater="rgb:f2d5cf"
  flamingo="rgb:eebebe"
  pink="rgb:f4b8e4"
  mauve="rgb:ca9ee6"
  red="rgb:e78284"
  maroon="rgb:ea999c"
  peach="rgb:ef9f76"
  yellow="rgb:e5c890"
  green="rgb:a6d189"
  teal="rgb:81c8be"
  sky="rgb:99d1db"
  sapphire="rgb:85c1dc"
  blue="rgb:8caaee"
  lavender="rgb:babbf1"
  text="rgb:c6d0f5"
  subtext1="rgb:b5bfe2"
  subtext0="rgb:a5adce"
  overlay2="rgb:949cbb"
  overlay1="rgb:838ba7"
  overlay0="rgb:737994"
  surface2="rgb:626880"
  surface1="rgb:51576d"
  surface0="rgb:414559"
  base="rgb:303446"
  mantle="rgb:292c3c"
  crust="rgb:232634"

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
