# Bundled web libraries

The embedded pages load these local browser bundles without a package manager
or a network connection. Release artifacts come from the corresponding npm
packages; their license files are kept alongside the bundles.

| Package | Version | Files |
| --- | --- | --- |
| jQuery | 4.0.0 | `jquery-4.0.0.min.js` |
| Swiper | 14.2.0 | `swiper/swiper-bundle.min.js`, `swiper/swiper-bundle.min.css` |
| Viewer.js | 1.15.0 | `viewer/viewer.js`, `viewer/viewer*.css` |
| jQuery Viewer | 1.0.1 | `viewer/jquery-viewer.js` |
| @xterm/xterm | 6.0.0 | `xterm/xterm.js`, `xterm/xterm.css` |
| @xterm/addon-fit | 0.11.0 | `xterm/xterm-addon-fit.js` |

Swiper 14 requires Safari 16.4 or newer; OrcaSlicer's macOS minimum is 13.3.
Linux builds require WebKitGTK 2.40 or newer.
Only the browser bundle is packaged. The CSS bundle is generated from the
release's `swiper-bundle.css` with esbuild 0.28.2
(`--minify --target=safari16.4`) to lower CSS nesting for those webviews.

The jQuery Viewer adapter replaces `$.isFunction(fn)` with
`typeof fn === "function"`, since jQuery 4 removed that helper. Load Viewer.js
before the adapter. All pages share the same jQuery copy.
The supported webviews provide native JSON parsing and serialization; no JSON2
polyfill is required.
