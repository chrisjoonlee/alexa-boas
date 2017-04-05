#!/bin/bash
# Bash script to set up the work environment for Alexa SDK on Node.js
# Prerequisite: Node.js, npm, Python3 (with pip and virtualenv)
# ============================================================================
# Install Node.js 6.10.1 & npm 4.4.4 (latest versions) with nvm
# 1. Install nvm (https://github.com/creationix/nvm) - local install
# For instructions on global install, see the github repo
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
echo "export NVM_DIR=\"$HOME/.nvm\"
[ -s \"$NVM_DIR/nvm.sh\"  ] && . \"$NVM_DIR/nvm.sh\"" >> ~/.bashrc

echo "Testing nvm..."
command -v nvm
#
# 2. Update node and npm
npm install -g npm
nvm install 6.10.1
node -v   # Should be 6.10.1
npm -v    # Should be 4.4.4
# ============================================================================
# You need to save a few config files in the root directory. Make sure we have
# copies of the following:
# .babelrc
# .createlog.py
# .env
# .eslintrc.json
# .flowconfig
# Gruntfile.js
# package.json
# You can install all node modules with npm as long as you have package.json
npm install
# In order to test everything installed properly, create a placeholder
echo "
// @flow
{
'use strict';
var alexa = require('alexa-sdk');
var winston = require('winston');
function square (x: number): number {
    return x * x;
}
var n = square('2');    // Flow should throw an error here
}
" >> test/index.js
# Grunt CLI tool is necesary to use local grunt
npm install -g grunt-cli
# ... Then run everything
grunt build
npm run build
npm run flow check
npm run bst proxy lambda test/index.js
PID=$!; kill -INT $PID
nano src/index.js
# ============================================================================
# Set up RethinkDB
virtualenv reqlenv -p python3
source reqlenv/bin/activate
pip install rethinkdb
deactivate
# Install JS driver as well just in case
npm install --save-dev rethinkdb
# Test RethinkDB
rethinkdb --bind all
# ============================================================================
README="
This README is intended to explain how to manage the work environment.
There are many modules at play, so let's break them down one by one.

# Static Typing & Linting
## Flow Type Checker
You don't *have to* use it, but it would definitely facilitate your production
process if you do. Even if you choose not to, I will be using it so you might
still want to transpile any JavaScript code you get from me with \`babel\`.

The package.json installs flow locally and creates an alias automatically, so
you can invoke the Flow binary with \`npm run flow\` anywhere in your project
directory.

While you can manually create a \`.flowconfig\` file at the root directory, you
can also use \`flow init\` command to generate it automatically. For any details
on how to configure your Flow with the config file, refer to the [official
documentation](https://flow.org/en/).

In order to type check your code at any time during production, you can simply
run \`flow status\` or \`flow\` in the terminal.

Below is a brief tutorial on how to use Flow.

    \`\`\`javascript
    // @flow
    
    function square (x: string) {
        // Flow knows that the argument has to be a number.
        // Therefore, it will throw an error.
        return x * x;
    }
    \`\`\`

## ESLint
There is no special reason why I chose ESLint over JSHint or JSLint... The
latter was just annoying me while I was setting up the working environment.
Anyways, ESLint has a neat way of supporting custom parsers/compilers, meaning
that we can make it \"compatible\" with Flow-typed JavaScript using babel. To
make things even easier, ESLint already provides babel-eslint, which is
precisely what I'm using if you look at the \`.eslintrc.json\`.

ESLint doesn't do much other than making sure the script follows certain style
guidelines, such as using double-quotes, etc. It also checks for some
syntactic problems (such as unused variables, which I have disabled). You can
modify the \`.eslintrc.json\` file however you want; it's pretty intuitive.

While you can manually lint a file by running \`npm run eslint \$FILE\`, the
functionality has been automated by \`grunt\`.

# Transpiling
Babel compiles JavaScript, and we need this functionality especially because 
of Flow. Node.js doesn't recognize the Flow syntax, and therefore, by trans-
piling with babel, we make sure to strip off all type annotations. All scripts
with annotations should go to the test/ directory, from where babel transpiles
and moves the files to the src/ directory automatically. Any scripts used for
any purposes other than editing/debugging (e.g. for running on \`bst\` server)
should be from the src/ directory. Just think of it as this: if the script
will be interpreted by the node, use the stripped ones (in src/).

In package.json you will find two different kinds of babels: \`babel-cli\` and
\`babel-node\`. They are redundant, and it ended up that way because, the
latter, which is a lighter version of babel that is used only to strip Flow
type annotations, didn't fulfill my needs and later I installed babel-cli. I'm
just too lazy to get rid of \`babel-node\`.

Babel, like ESLint, has been automated by \`grunt\`.

# BST (Bespoken-Tools)
BST is a module that makes local testing of Alexa-SDK possible. Fire up a new
terminal window, and run \`npm run bst proxy lambda /path/to/index.js\`. (bst
can be installed in global scope if you want; run \`npm install -g bst\`).
Then, in another terminal window (keep the proxy server running!), run \`npm
run bst speak hello\`. This obviously won't work with appropriate Lambda
function (Lambda refers to the function that runs Alexa skill we're developing
), but technically it's supposed to return the Response and Return JSON. Once
you start learning Alexa-SDK, you'll know what I mean.

For now, you must remember 2 things: \`npm run bst proxy lambda /path/to/index
.js\` to run the proxy server, then \`npm run best speak something\` to mimic
a test request.

# Automation - Grunt
Grunt automates all tedious stuff. I set it up so that you almost never have
to run Babel and ESLint yourself. (You have to run \`bst\` yourself, but if
you're really *that* lazy you can probably just write up a small shell script
for that).

The following line will transpile all JavaScript in test/ and move them to
src/, then lint everything:

    \`\$ grunt build\`

This is probably all we're going to use for a while. There is an option to
create a distributable version, though (concatenated scripts, uglified, etc.)

    \`\$ grunt produce\`

All configuration details can be found in \`Gruntfile.js\`.

# RethinkDB
We'll go over it later, but it is essentially a real-time database (ReQL) that
we can potentially use to store our data.

" >> README.md
