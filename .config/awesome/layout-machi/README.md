# ![](icon.png) layout-machi

A manual layout for Awesome with a rapid interactive editor.

Demos: https://imgur.com/a/OlM60iw

Draft mode: https://imgur.com/a/BOvMeQL

## Why?

TL;DR --- I want the control of my layout.

1. Dynamic tiling is an overkill, since tiling is only useful for persistent windows, and people extensively use hibernate/sleep these days.
2. I don't want to have all windows moving around whenever a new window shows up.
3. I want to have a flexible layout such that I can quickly adjust to whatever I need.

## Compatibilities

I developed it with Awesome 4.3.
Please let me know if it does not work in other versions.

## Really quick usage

See `rc.patch` for adding layout-machi to the default 4.3 config.

## Quick usage

Suppose this git is checked out at `~/.config/awesome/layout-machi`

Use `local machi = require("layout-machi")` to load the module.

The package provide a default layout `machi.default_layout` and editor `machi.default_editor`, which can be added into the layout list.

The package comes with the icon for `layoutbox`, which can be set with the following statement (after a theme has been loaded):

`require("beautiful").layout_machi = machi.get_icon()`

By default, any machi layout will use the layout command from `machi.layout.default_cmd`, which is initialized as `dw66.` (see interpretation below).
You can change it after loading the module.

## Use the layout

Use `local layout = machi.layout.create(args)` to instantiate the layout with an editor object. `args` is a table of arguments, where the followings can be used:

  - `name`: the constant name of the layout.
  - `name_func`: a `function(t)` closure that returns a string for tag `t`. `name_func` overrides `name`.
  - `persistent`: whether to keep a history of the command for the layout. The default is `true`.
  - `default_cmd`: the command to use if there is no persistent history for this layout.
  - `editor`: the editor used for the layout. The default is `machi.default_editor` (or `machi.editor.default_editor`).

Either `name` or `name_func` must be set - others are optional.

The function is compatible with the previous `machi.layout.create(name, editor, default_cmd)` calls.

## The layout editor and commands

### Starting editor in lua

Call `local editor = machi.editor.create()` to create an editor.
To edit the layout `l` on screen `s`, call `editor.start_interactive(s = awful.screen.focused(), l = awful.layout.get(s))`.

### Basic usage

The editing command starts with the open region of the entire workarea, perform "operations" to split the current region into multiple sub-regions, then recursively edits each of them (by default, the maximum split depth is 2).
The layout is defined by a sequence of operations as a layout command.
The layout editor allows users to interactively input their commands and shows the resulting layouts on screen, with the following auxiliary functions:

1. `Up`/`Down`: restore to the history command
2. `Backspace`: undo the last command.
3. `Escape`: exit the editor without saving the layout.
4. `Enter`: when all regions are defined, hit enter will save the layout.

### Layout command

As aforementioned, command a sequence of operations.
There are three kinds of operations:

1. Operations taking argument string and parsed as multiple numbers.

   `h` horizontally split, `v` vertically split, `w` grid split, `d` draft split

2. Operations taking argument string as a single number.

   `s` shift active region, `t` set the maximum split depth

3. Operation not taking argument.

   `.` finish all regions, `-` finish the current region, `/` remove the current region, `;` no-op

Argument strings are composed of numbers and `,`. If the string contains `,`, it will be used to split argument into multiple numbers.
Otherwise, each digit in the string will be treated as a separated number in type 1 ops.

Each operation may take argument string either from before (such as `22w`) or after (such as `w22`).
When any ambiguity arises, operation before always take the argument after. So `h11v` is interpreted as `h11` and `v`.

For examples:

`h-v`

```
11 22
11 22
11
11 33
11 33
```


`hvv` (or `22w`)

```
11 33
11 33

22 44
22 44
```


`131h2v-12v`

Details:

 - `131h`: horizontally split the initial region (entire desktop) to the ratio of 1:3:1
 - For the first `1` part:
   - `2v`: vertically split the region to the ratio of 2:1
 - `-`: skip the editing of the middle `3` part
 - For the right `1` part:
   - `12v`: split the right part vertically to the ratio of 1:2

Tada!

```
11 3333 44
11 3333 44
11 3333
11 3333 55
   3333 55
22 3333 55
22 3333 55
```


`12210121d`

```
11 2222 3333 44
11 2222 3333 44

55 6666 7777 88
55 6666 7777 88
55 6666 7777 88
55 6666 7777 88

99 AAAA BBBB CC
99 AAAA BBBB CC
```

### Advanced grid layout

__More document coming soon. For now there is only a running example.__

Simple grid, `w44`:
```
0 1 2 3

4 5 6 7

8 9 A B

C D E F
```

Merge grid from the top-left corner, size 3x1, `w4431`:
```
0-0-0 1

2 3 4 5

6 7 8 9

A B C D
```

Another merge, size 1x3, `w443113`:
```
0-0-0 1
      |
2 3 4 1
      |
5 6 7 1

8 9 A B
```

Another merge, size 1x3, `w44311313`:
```
0-0-0 1
      |
2 3 4 1
|     |
2 5 6 1
|
2 7 8 9
```

Another merge, size 2x2, `w4431131322`:
```
0-0-0 1
      |
2 3-3 1
| | | |
2 3-3 1
|
2 4 5 6
```

Final merge, size 3x1, `w443113132231`:
```
0-0-0 1
      |
2 3-3 1
| | | |
2 3-3 1
|
2 4-4-4
```

### Draft mode

__This mode is experimental. Its usage may change fast.__

Unlike the original machi layout, where a window fits in a single region, draft mode allows window to span across multiple regions.
Each tiled window is associated with a upper-left region (ULR) and a bottom-right region (BRR).
The geometry of the window is from the upper-left corner of the ULR to the bottom-right corner of the BRR.

This is suppose to work with regions produced with `d` or `w` operation.
To enable draft mode in a layout, configure the layout with a command with a leading `d`, for example, `d12210121`, or `dw66`.

### Persistent history

By default, the last 100 command sequences are stored in `.cache/awesome/history_machi`.
To change that, please refer to `editor.lua`. (XXX more documents)

## Switcher

Calling `machi.switcher.start()` will create a switcher supporting the following keys:

 - Arrow keys: move focus into other regions by the direction.
 - `Shift` + arrow keys: move the focused window to other regions by the direction. In draft mode, move the window while preserving its size.
 - `Control`[ + `Shift`] + arrow keys: move the bottom-right (or top-left window if `Shift` is pressed) region of the focused window by direction. Only works in draft mode.
 - `Tab`: switch beteen windows covering the current regions.

So far, the key binding is not configurable. One has to modify the source code to change it.

## Caveats

1. layout-machi handles `beautiful.useless_gap` slightly differently.

2. True transparency is required. Otherwise switcher and editor will block the clients.

## License

Apache 2.0 --- See LICENSE
