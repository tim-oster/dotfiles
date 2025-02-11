#!/bin/sh

PAD="Wacom Intuos PT S 2 Pad pad"
STYLUS="Wacom Intuos PT S 2 Pen stylus"

# relative mode
xsetwacom set "$STYLUS" mode relative

# pen height
#xsetwacom set "$STYLUS" cursorproximity 20
