### Why?
Layout-machi is great, however it requires you to use its built-in switcher to manage your open windows. If you are shuffling, swapping, and moving things around often, this could become counter productive.

`Machina` is built on top of layout-machi, and allows you to bind frequently used actions to your keys and gives you additional user friendly features.

A combination of `layout-machi` and `awesomewm-machina` will give you a similar experience to fancy zones on windows.


### What?
These are the features I added:

- Quick Expand:
Expand focused window to left, right, or vertically. This will make the window snap to the next available region.

- Directional Swapping:
Swap windows between regions.

- Directional Shifting:
Relocate windows like Elv13's collision module.

- Rotational Shifting:
Relocate windows clockwise or counter clockwise. This uses a different algorithm compared to directional shifting and should be more accurate in merging your floating clients to the tiling layout.

- Shuffling:
Go backward or forward in a region, and it will cycle the clients inside that area.

- Auto-Hide Floating Windows:
Often times, the floating windows pollutes your background if you are using `useless-gaps`. Machina will hide those for you, but they can still be accessed through your window-switcher such as Rofi.

- Floating and Tiled:
All keybindings, including swapping work seamlessy on both the tiled and the floating windows. So, if you need to push that terminal to a corner, you can easily do so without changing it to tiling mode.

- Experimental Tabs:
We now have tabs for tiled clients :)

### Next?

- [ ] keybindings could also be called by numbers for a given region. (win+1, win+2 etc).
- [ ] Better keybindings could be done vimium style, by drawing wiboxes over the tabs.
- [ ] Better keybindings (possibly emacs style, or vim style): an xcape key can be used to to initiate awm layer and enter can exit from it.
- [X] Tags must always have a focused window. Added tag.selected signal.
- [X] Clickable tabs
- [X] Close tabs. (right click)
- [X] Allow detaching from floating tabs. (double click)
- [X] Move focus by index: focus_by_index()
- [X] On focus of tiled clients, allow realigning visible floating windows to sides via shortcuts.
- [X] Add align to left or right for floating windows: align_floats()
- [X] Override cyclefocus for tabbed regions or bind alt-tab?
- [ ] Merge Backham and Mouser (focus should stay client under mouse - sometimes?)
- [X] Update tabs on tag change via signal
- [ ] Add binding for relocating the entire region
- [ ] Deck spread (send focused client to a direction without moving focus)
- [ ] Client pull (pull a client from a direction onto the current deck)
- [ ] Visual teleport (overlay with region numbers to choose from, possibly on all monitors, kind of like vimium)
- [ ] Add tabbing for floating clients: drag and drop seems not so easy, using rofi could be fine too but it is another step. Focus and mark could work better. Execute the shourtcut and choose the window to be tabbed with mouse or possibly via keyboard.
- [x] Permanently mark floating windows to remain (rules: always_on, bypass)
- [x] Allow expanding regions horizontally and vertically
- [x] Auto resize all clients in the region when expanded
- [x] Avoid machi's auto expansion on config reload
- [x] Show tabs everywhere
- [x] Dual monitor support
- [x] Allow zooming to center
- [x] Fixed geometries for zooming in
- [x] Auto hide floating layer
- [x] Auto hide floating layer exclusions
- [x] Simple move to designated coordinates (move_to)
- [x] Focus/Unfocus to tabbed regions should have visual indicator
- [x] Teleport client to other monitor
- [x] Directional swapping toggle
- [x] Rotational swapping toggle
- [x] Refresh layout on tag switching
- [x] Infinite directions left-to-right
- [ ] Better support for infinite directions on dual monitors
- [x] Floating clients should respond to swapping
- [x] Floating clients should respond to shifting

### Layout-Machi compatibility

Machina should work just fine with both versions of layout-machi. 

### Problems?

If you have any issues or recommendations, please feel free to open a request. PRs are most welcome.


### Install
switch to your awesome config folder, typically at:

```
cd ~/.config/awesome
```

clone this repository:

```
git clone https://github.com/basaran/awesomewm-machina machina
```

and call it from your `rc.lua`

```lua
local machina = require('machina')()
```

### Keybindings

This module directly injects into rc.lua and ideally, all keybindings should work unless you override them in your rc.lua.

If you have any issues, you can change in your `rc.lua`:

```lua
root.keys(globalkeys)
```

to:

```lua
root.keys(gears.table.join(root.keys(),globalkeys))
```
or, you can just copy / paste what you like from `init.lua` onto your rc.lua globalkeys table.

Some of the default shortcuts are:

```lua

-- Please see init.lua for keybindings and their descriptions.

```


### Preview
https://user-images.githubusercontent.com/30809170/123538385-ab5f7b80-d702-11eb-9a14-e8b9045d9d27.mp4

### Tabs
https://user-images.githubusercontent.com/30809170/125209584-c6d09780-e267-11eb-8b6a-adc14126d8f9.mp4

### Expansions
https://user-images.githubusercontent.com/30809170/125209587-d059ff80-e267-11eb-9a03-5b02cae63ccb.mp4




