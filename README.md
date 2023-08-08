HyperText
=========

HyperText is a CLI tool for building simple, static sites.

Requirements
------------

macOS 13 (Ventura) or newer.

Installation
------------

Download the latest executable from the [releases page](https://github.com/jarrodtaylor/hypertext/releases)
and add it to your path.

Getting Started
---------------

After adding the executable to your path, you should be able to run the HyperText command:

```bash
~ $ hypertext
```

HyperText will give you a hint at what do next:

```bash
~ $ 🧑‍🏫 hypertext source/ target/ --stream
```

It expects parameters for a source folder and a target folder. Pass in those parameters and HyperText will
build the site from the source folder into the target folder.

Add the `--stream` flag and HyperText will watch the source folder, automatically rebuilding after each
change.

Rendered Files
--------------

CSS, HTML, JavaScript, Markdown, RSS, and SVG files all get processed during the HyperText build process.

> All other file types are simply copied from source to target.

Files with a `!` at the beginning of their filenames will not be copied to the target folder. 

HyperText uses a few special keywords inside comments of rendered files to help manage your static site.

We'll use HTML as an example. Most of this, where relevant, also applies to the other rendered file types.

### Includes

HyperText can include the contents of one file in another:

```html
<!-- :include path/to/another/file.html
```

### Context Variables

Context variables can be passed to an included file:

```html
<!-- :include path/to/another/file.html ++ message: Hello, World! ++ foo: bar
```

And rendered inside the included file:

```html
<p><!-- @message --></p>
<p><!-- @foo --></p>
```

...becomes...

```html
<p>Hello, World!</p>
<p>bar</p>
```

Missing context variables can be null coalesced:

```html
<p><!-- @baz ?? Something is missing here --></p>
```

...becomes...

```html
<p>Something is missing here</p>
```

Context variables can also be added as YAML at the top of files:

```html
---
message: Hello, World!
foo: bar
---
<p>The rest of the file starts here</p>
```

### Layouts

A file can be be wrapped by the contents of another file using a layout. Add the layout file path as a
context variable at the top of the content file:

```html
---
:layout: path/to/my/!layout.html
title: foobar
---
<p>This is some content</p>
```

> It's good to start layout filenames with a `!` so they aren't copied to the target folder.

And add a content placeholder in the layout file:

```html
<html>
  <head>
    <title><!-- @title --></title>
  </head>
  <body>
    <!-- :content -->
  </body>
</html
```

The context variables from the content file are passed to the layout:

```html
<html>
  <head>
    <title>foobar</title>
  </head>
  <body>
    <p>This is some content</p>
  </body>
</html
```

#### Forced Layouts

When including a file, it's layout will be ignored. To force the layout as part of the render, set the
context variable `:forceLayout` to `true`. This can be done as part of the YAML at the top of the included
file or as a parameter of the include statement:

```html
<!-- :include /my/file.html ++ forceLayout: true -->
```

Markdown
--------

Markdown file are converted to HTML and show up in the target folder with `.html` extensions.

All the usual Markdown syntax is supported along with a few extensions.

### Attributes

HTML attributes can be added to block elements:

```md
This is a paragraph
<!-- :attributes class="foo" id="bar" -->
```

...becomes...

```html
<p class="foo" id="bar">This is a paragraph</p>
```

Attributes can be added to images and links with a similar syntax:

```md
[click me](https://example.com/ class="foo", id="bar")
```

...becomes...

```html
<a href="https://example.com/" class="foo" id="bar">click me</a>
```