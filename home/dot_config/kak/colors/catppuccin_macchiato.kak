# Catppuccin theme for Kakoune

# Color palette
declare-option str rosewater 'rgb:f4dbd6'
declare-option str flamingo 'rgb:f0c6c6'
declare-option str pink 'rgb:f5bde6'
declare-option str mauve 'rgb:c6a0f6'
declare-option str red 'rgb:ed8796'
declare-option str maroon 'rgb:ee99a0'
declare-option str peach 'rgb:f5a97f'
declare-option str yellow 'rgb:eed49f'
declare-option str green 'rgb:a6da95'
declare-option str teal 'rgb:8bd5ca'
declare-option str sky 'rgb:91d7e3'
declare-option str sapphire 'rgb:7dc4e4'
declare-option str blue 'rgb:8aadf4'
declare-option str lavender 'rgb:b7bdf8'
declare-option str text 'rgb:cad3f5'
declare-option str subtext1 'rgb:b8c0e0'
declare-option str subtext0 'rgb:a5adcb'
declare-option str overlay2 'rgb:939ab7'
declare-option str overlay1 'rgb:8087a2'
declare-option str overlay0 'rgb:6e738d'
declare-option str surface2 'rgb:5b6078'
declare-option str surface1 'rgb:494d64'
declare-option str surface0 'rgb:363a4f'
declare-option str base 'rgb:24273a'
declare-option str mantle 'rgb:1e2030'
declare-option str crust 'rgb:181926'

# UI
evaluate-commands %sh{
  rosewater="rgb:f4dbd6"
  flamingo="rgb:f0c6c6"
  pink="rgb:f5bde6"
  mauve="rgb:c6a0f6"
  red="rgb:ed8796"
  maroon="rgb:ee99a0"
  peach="rgb:f5a97f"
  yellow="rgb:eed49f"
  green="rgb:a6da95"
  teal="rgb:8bd5ca"
  sky="rgb:91d7e3"
  sapphire="rgb:7dc4e4"
  blue="rgb:8aadf4"
  lavender="rgb:b7bdf8"
  text="rgb:cad3f5"
  subtext1="rgb:b8c0e0"
  subtext0="rgb:a5adcb"
  overlay2="rgb:939ab7"
  overlay1="rgb:8087a2"
  overlay0="rgb:6e738d"
  surface2="rgb:5b6078"
  surface1="rgb:494d64"
  surface0="rgb:363a4f"
  base="rgb:24273a"
  mantle="rgb:1e2030"
  crust="rgb:181926"

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
