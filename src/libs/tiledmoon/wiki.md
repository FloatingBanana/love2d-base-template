# Tilemoon

Tilemoon helps you to load and manage Tiled maps in your lua projects.

Tiled maps are relatively simple to use by itself, this library just provide some tools to make things easier. It's aimed to be a universal tool that helps you to manage the powerful features that Tiled offers rather than a "ready to use" library.

## Getting started

```lua

local tilemoon = require("libs.tilemoon")

local map = tilemoon("tiledmap")

local layer map:getLayerByName("collidables", true)
```