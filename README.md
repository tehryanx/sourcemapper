# Sourcemapper
Reconstruct javascript from a sourcemap in bash

Sourcemaps are used to help developers debug minified javascript. If a sourcemap is provided, the minified js will be served to visitors, but the browsers debugger will be able to access the original unminified code. Sourcemapper enables you to download the original, unminified javascript source tree from the commandline so that you don't have to analyze it with the in-browser debugger. 

## Finding sourcemap files
To find a sourcemap, look at the very end of a minified javascript file. If a sourcemap exists it should be linked there. 

Occasionally the .map file will exist even though the reference isn't in the minified source. You might be able to find it by adding .map to the end of the javascripts filename as in: script.js.map

Finally, if there are no sourcemaps available on production servers, check development and staging servers.

### Note:
*If you find that files contain just the phrase: "Not Found" or other errors that means that the files were listed in the sourcemap, but not actually accessible. I decided to have the empty files created anyway in case the directory structure itself is valuable information.*

```
$ ./sourcemaps.sh https://github.githubassets.com/assets/github-bootstrap-ce762218.js.map
https://github.githubassets.com/assets
Map loaded: read 539892 bytes from github-bootstrap-ce762218.js.map.
337 files to be written.
Writing: ./sourcemaps/node_modules/request-idle-polyfill/dist/index.js
Writing: ./sourcemaps/node_modules/smoothscroll-polyfill/dist/smoothscroll.js
Writing: ./sourcemaps/node_modules/user-select-contain-polyfill/user-select-contain.mjs
Writing: ./sourcemaps/node_modules/mdn-polyfills/Element.prototype.toggleAttribute.js
Writing: ./sourcemaps/app/assets/modules/environment-bootstrap.js
Writing: ./sourcemaps/app/assets/modules/github/failbot.js
Writing: ./sourcemaps/node_modules/@github/auto-check-element/dist/index.esm.js
Writing: ./sourcemaps/app/assets/modules/github/failbot-error.js
Writing: ./sourcemaps/node_modules/@github/clipboard-copy-element/dist/index.esm.js
Writing: ./sourcemaps/node_modules/@github/details-menu-element/dist/index.esm.js
Writing: ./sourcemaps/node_modules/@github/file-attachment-element/dist/index.js
Writing: ./sourcemaps/node_modules/@github/g-emoji-element/dist/index.esm.js
Writing: ./sourcemaps/node_modules/@github/image-crop-element/dist/index.esm.js
Writing: ./sourcemaps/node_modules/@github/markdown-toolbar-element/dist/index.esm.js
Writing: ./sourcemaps/node_modules/@github/tab-container-element/dist/index.esm.js
Writing: ./sourcemaps/node_modules/@github/text-expander-element/dist/index.esm.js
Writing: ./sourcemaps/node_modules/@github/time-elements/dist/time-elements.js
Writing: ./sourcemaps/app/assets/modules/github/confirm.js
Writing: ./sourcemaps/app/assets/modules/github/hotkey-map.js
Writing: ./sourcemaps/app/assets/modules/github/include-fragment-element-hacks.js
Writing: ./sourcemaps/app/assets/modules/github/poll-include-fragment-element.js
```
