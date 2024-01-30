HyperText
=========
HyperText is a CLI for building simple, static sites. It sits in the web publishing sweet spot
between hand coding and frameworks. You can use layouts, include files in other files,
and expand dynamic content with variables, all while ending up with a static site that doesn't need
a server app to run or a frontend library to render.

Using an up-to-date version of macOS, [download the latest executable][executable]
(v0.0.0) and add it to your path.

> You might be able to build and run HyperText on Linux. I haven't tried it yet.

Full documentation is at [hypertext.sh][hypertext.sh].

Quick Start
-----------
After install in the executable, you'll be able to run the `hypertext` command in your CLI.

```bash
$ hypertext --help
USAGE: hypertext <source> <target> [--stream]

ARGUMENTS:
  <source>                Relative path to source directory.
  <target>                Relative path to target directory.

OPTIONS:
  --stream                Stream changes from source to target.
  --version               Show the version.
  -h, --help              Show help information.
```

HyperText reads files from a `source` directory, renders them, and copies the output to a `target`
directory. The `source` and `target` directories can be any directories you want -- HyperText
doesn't care about project structure and doesn't come with any code generators.

### Building a Site

Building a site is as simple as pointing the `hypertext` command to your `source` and `target`
directories.

> If your `target` directory doesn't exit, HyperText will create it.

For this readme, we'll use `src` as the source directory and `public` as the target directory.

```bash
$ hypertext src public
```

> HyperText will only build files that have been modified since the last time the command was run.
> A file is considered modified if it, or any of its dependencies (includes or layouts), has been
> saved *after* the creation date of its associated file in the `target` directory.

#### Ignored Files

Files starting with a `!` are not rendered or copied to the `target` directory. This is useful for
includes and layouts that won't be read on their own from `target`.

For example, `src/!layout.html` can be used to layout other files without being copied to
`public/!layout.html`.

### Streaming

Adding the `--stream` option to the `hypertext` command tells HyperText to watch the `source`
directory and automatically build the site on each saved change.

```bash
$ hypertext src public --stream
Streaming src -> public (^c to stop)
```

`^c` will stop the stream.

### Static Files

Static files are any files that HyperText doesn't know how to render, such as images and PDFs. These
files are copied directly from `source` to `target`.

### Rendered Files

Rendered files are any files that HyperText knows how to render. These include CSS, HTML,
JavaScript, Markdown, RSS, and SVG files.

These files are rendered before being saved to the `target` directory. Rendering a file will expand
its includes, replace its variables with their values, and wrap its content in a layout.

> Markdown (`.md`) files are converted to HTML and saved to the `target` directory with a `.html`
> file extension.

#### Metadata

Metadata is defined at the top of a rendered file as key/value pairs surrounded by `---`'s.

```html
---
foo: bar
abc: 123
---
```

#### Variables

Variables are prefixed with `@` symbols and written into the comments of a rendered file.

```html
---
@title: Hello, world!
---
<html>
  <head>
    <title><!-- @title --></title>
  </head>
</html>
```

While rendering, their values are read from metadata and expanded to replace the comment.

```html
<html>
  <head>
    <title>Hello, world!</title>
  </head>
</html>
```

Each type of rendered file uses its own comment syntax.

| File Type                     | Comment Format            |
| ----------------------------- | ------------------------- |
| .css                          | `/* @foo */`              |
| .htm, .html, .md, .rss, .svg  | `<!-- @foo -->`           |
| .js                           | `/* @foo */` or `// @foo` |

Variables can define fallback values using `??` for when no value is defined.

```html
---
@title: Hello, world!
---
<html>
  <head>
    <title><!-- @title ?? My Webpage --></title>
  </head>
  <body>
    <!-- @foo ?? bar -->
  </body>
</html>
```

In this example, `@title` is defined while `@foo` is not.

```html
<html>
  <head>
    <title>Hello, world!</title>
  </head>
  <body>
    bar
  </body>
</html>
```

#### Includes

Files can be included in other files with the `#include` macro.

> The remaining examples are in html but apply to all rendered files.

Using the following as `src/blog.html`:

```html
<html>
  <body>
    <!-- #include posts/!one.md -->
    <!-- #include posts/!two.md -->
  </body>
</html>
```

And `src/posts/!one.md` and `src/posts/!two.md`:

```md
## Post One

This is the first post.
```

```md
## Post Two

This is the second post.
```

Will render `target/blog.html` as:

```html
<html>
  <body>
    <h2>Post One</h2>
    <p>This is the first post.</p>
    <h2>Post Two</h2>
    <p>This is the second post.</p>
  </body>
</html>
```

Variables used in included files can be overridden by passing in values from the including file
using the `++` syntax.

For example, a generic blog post file `src/posts/!generic.md` that looks like this:

```md
## <!-- @name -->

<!-- @content ?? This is some generic content. -->
```

Can be included in `src/blog.html` like this:

```html
<html>
  <body>
    <!-- #include posts/!generic.md ++ @name: My Blog Post -->
    <!-- #include posts/!generic.md ++ @name: My Other Post ++ @content: Some new content. -->
  </body>
</html>
```

To create a `target/blog.html` that looks like this:

```html
<html>
  <body>
    <h2>My Blog Post</h2>
    <p>This is some generic content.</p>
    <h2>My Other Post</h2>
    <p>Some new content.</p>
  </body>
</html>
```

Values passed in from an including file take precedence over values defined in the metadata of the
included file.

> Variables can be passed as values of include params.

#### Layouts

Layouts are the opposite of includes. A file can the `#layout` macro in its metadata to define
the layout file it will be included in. A layout file uses the `#content` macro do define where
its included files are rendered.

> Variable values defined in included files take precedence over those defined in layouts.

For example, an about page `src/about.html`:

```html
---
#layout: !design.html
@pageTitle: About Me
---
<p>This is an about page.</p>
```

Will be rendered inside `src/!design.html`:

```html
<html>
  <head>
    <title><!-- @pageTitle ?? My Website --></title>
  </head>
  <body>
    <!-- #content -->
  </body>
</html>
```

To create `target/about.html`:

```html
<html>
  <head>
    <title>About Me</title>
  </head>
  <body>
    <p>This is an about page.</p>
  </body>
</html>
```

By default, a file being included with the `#include` macro will not use a layout even if one is
defined in its metadata. To force a nested layout, add `#forceLayout: true` to the included file's
metadata or pass it in as part of the `#include` syntax.

[hypertext.sh]: https://hypertext.sh
[releases]: https://github.com/jarrodtaylor/hypertext/releases
[executable]: https://github.com/jarrodtaylor/hypertext/releases/download/v0.0.0/hypertext