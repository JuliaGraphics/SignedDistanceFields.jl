# SignedDistanceFields

This package implements an algorithm for quickly computing signed distance fields in 2D.

**Usage**: `result = sdf(img)`, where `img` is a 2-dimensional boolean array where `true` indicates the foreground and `false` indicates the background.

This package also exports an `edf` function with identical usage that calculates the closest distance from every background pixel to the foreground.

Signed distance fields are a useful representation for rendering glyphs and other shapes with crisp edges using OpenGL. By allowing the graphics hardware to interpolate between distance samples and testing for the shape boundary in the vertex shader, [Valve paper from 2007](http://www.valvesoftware.com/publications/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf)

Here's a good blog post about signed distance fields from [Mapbox](https://www.mapbox.com/blog/text-signed-distance-fields/).

[![Build Status](https://travis-ci.org/yurivish/SignedDistanceFields.jl.svg?branch=master)](https://travis-ci.org/yurivish/SignedDistanceFields.jl)
