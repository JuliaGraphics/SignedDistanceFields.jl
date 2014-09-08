# SignedDistanceFields

This package implements an algorithm for quickly computing signed distance fields in 2D.

`result = sdf(img)`, where `img` is a 2-dimensional boolean array where `true` indicates the foreground and `false` indicates the background.

There is also an `edf` function with identical usage that calculates the Euclidean distance transform -- the distance from every background pixel to the closest pixel in the foreground.

Signed distance fields are a useful representation for rendering glyphs and other shapes with crisp edges using OpenGL. By allowing the graphics hardware to interpolate between distance samples and testing for the shape boundary in the vertex shader, you can get surprisingly high-resolution output from smaller SDFs, provided that they were downsampled from high-resolution bitmaps.

Here's a [paper from Valve](http://www.valvesoftware.com/publications/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf) introducing the idea and here's a [good blog post](https://www.mapbox.com/blog/text-signed-distance-fields/) about using signed distance fields to render text from [Mapbox](http://mapbox.com).

[![Build Status](https://travis-ci.org/yurivish/SignedDistanceFields.jl.svg?branch=master)](https://travis-ci.org/yurivish/SignedDistanceFields.jl)
