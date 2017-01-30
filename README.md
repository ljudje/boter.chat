# Metalsmith startr

A boilerplate / template based around the Metalsmith static page genrator.

Powered by: Metalsmith, Grunt, Haml, Sass, CoffeeScript, Browserify, Foundation & some glue code.

## Requirements for OS X

You need [Node.js](https://nodejs.org/en), [NPM](https://www.npmjs.com/
) & *XCode Command Line Tools* installed.

Download Node.js & NPM from the Node homepage: https://nodejs.org/en/

If the `make build` command fails, you might need to install XCode Command Line Developer Tools first:

    $ xcode-select --install

## Development

To work on the website:

    $ make dev-server

Visit [localhost:9080](http://localhost:9080/)

## Deployment

Deployment-ready files are contained in the `build` directory.
