# Catppuccin theme for Kakoune

# Color palette
declare-option str rosewater 'rgb:f5e0dc'
declare-option str flamingo 'rgb:f2cdcd'
declare-option str pink 'rgb:f5c2e7'
declare-option str mauve 'rgb:cba6f7'
declare-option str red 'rgb:f38ba8'
declare-option str maroon 'rgb:eba0ac'
declare-option str peach 'rgb:fab387'
declare-option str yellow 'rgb:f9e2af'
declare-option str green 'rgb:a6e3a1'
declare-option str teal 'rgb:94e2d5'
declare-option str sky 'rgb:89dceb'
declare-option str sapphire 'rgb:74c7ec'
declare-option str blue 'rgb:89b4fa'
declare-option str lavender 'rgb:b4befe'
declare-option str text 'rgb:cdd6f4'
declare-option str subtext1 'rgb:bac2de'
declare-option str subtext0 'rgb:a6adc8'
declare-option str overlay2 'rgb:9399b2'
declare-option str overlay1 'rgb:7f849c'
declare-option str overlay0 'rgb:6c7086'
declare-option str surface2 'rgb:585b70'
declare-option str surface1 'rgb:45475a'
declare-option str surface0 'rgb:313244'
declare-option str base 'rgb:1e1e2e'
declare-option str mantle 'rgb:181825'
declare-option str crust 'rgb:11111b'

# UI
evaluate-commands %sh{
  rosewater="rgb:f5e0dc"
  flamingo="rgb:f2cdcd"
  pink="rgb:f5c2e7"
  mauve="rgb:cba6f7"
  red="rgb:f38ba8"
  maroon="rgb:eba0ac"
  peach="rgb:fab387"
  yellow="rgb:f9e2af"
  green="rgb:a6e3a1"
  teal="rgb:94e2d5"
  sky="rgb:89dceb"
  sapphire="rgb:74c7ec"
  blue="rgb:89b4fa"
  lavender="rgb:b4befe"
  text="rgb:cdd6f4"
  subtext1="rgb:bac2de"
  subtext0="rgb:a6adc8"
  overlay2="rgb:9399b2"
  overlay1="rgb:7f849c"
  overlay0="rgb:6c7086"
  surface2="rgb:585b70"
  surface1="rgb:45475a"
  surface0="rgb:313244"
  base="rgb:1e1e2e"
  mantle="rgb:181825"
  crust="rgb:11111b"

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
