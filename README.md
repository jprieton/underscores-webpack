# Enable webpack 5.x in underscore based theme 

This guide allows to you use webpack 5.x with `_s`, we need update only the `@wordpress/scripts` package and do some adjusts. 

Please read the entire guide carefully to understand the steps involved in this change, you can find a link to a bash script for the automation of these tasks at the end of this document, additionally you can see the source code of this script [here](https://github.com/jprieton/underscore-webpack/blob/main/enable-webpack.sh).

<br>

> **Important notes:** For this guide I will use a clean installation of [_s](https://underscores.me/) starter theme.
>
> This guide only cover the SASS watcher, other topics, as bundle scripts, are treated superficially.
>
> Is required to update the the bundled version of [@wordpress/scripts](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-scripts/), before following the steps in this guide, please check if your project requires that version. 
>
> Isn't recommended for ongoing projects, please go to caution if you want apply to an ongoing project, if you use [CleanWebpackPlugin](https://github.com/johnagan/clean-webpack-plugin) you will lose your files without a minimum configuration, further in this guide I will explain to avoid this in detail.

<br>

## Installation of _s theme

There are several ways to create your underscore based theme

- Generate a  from the [underscore](https://underscores.me/) site, remember check the *sassify* option,

- Using the command line interface WP-CLI, read more [here](https://developer.wordpress.org/cli/commands/scaffold/_s/) how to use the `scaffold` command, remember use the `-sassify` option, you can execute a command similar to this on the root of your WordPress installation,

  ```bash
  # Example
  $ wp scaffold _s sample-theme --theme_name="Sample Theme" --author="John Doe" --sassify
  ```
  
- Or download from GitHub [repository](https://github.com/automattic/_s).

To start using all the tools that come with `_s` you need to install the necessary Node.js and Composer dependencies, go to your theme root directory and execute in terminal the following command:

```bash
$ composer install
$ npm install
```

<br>


## Update the packages

The current installation of `_s` have as dependency the [@wordpress/scripts](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-scripts/), this version uses webpack 4.x, we need update to latest version to use webpack 5.x in our project, to do this execute in terminal the following command:

```bash
$ npm install @wordpress/scripts@latest --save-dev
```

Yes, only a package require to be updated.

<br>

## Move the `sass` folder

It's a personal preference, I'm like have all sources in the `src` folder.

To do this run:

```bash
$ mkdir ./src/
$ mv ./sass/ ./src/scss/
```

<br>

## Add webpack.config.js file

In this repository there are a bare minimum `webpack.config.js` that allows to you start to work in your theme, you can download [here](https://raw.githubusercontent.com/jprieton/underscore-webpack/main/webpack.config.js) and put it on your root theme directory or run the following command:

```bash
$ curl -o webpack.config.js https://raw.githubusercontent.com/jprieton/underscores-webpack/main/webpack.config.js
```

Please read this about the `CleanWebpackPlugin`.

In this file pay attention on the initialization of `MiniCssExtractPlugin`, this configuration allow creates the `style.css` file in the root directory of the theme, any other will be created in the `dist` directory (o any other that you configure in the `BUILD_DIR`)

<br>

## Update stylelintrc.json file

When the `@wordpress/scripts` package was updated, this broke the linter, this is due a [deprecated](https://www.npmjs.com/package/stylelint-config-wordpress/v/10.0.2) extension removed in the updated version of the `@wordpress/scripts` package, to fix you must edit the `stylelintrc.json` and update the new extension:

```js
// Before
{
  "extends": [
    "stylelint-config-wordpress/scss" // <-- Old extension
  ],
  // Other settings
}

// After
{
  "extends": [
    "@wordpress/stylelint-config/scss" // <-- New extension
  ],
  // Other settings
}
```

<br>

## Update package.json file

Finally it's necessary update the `scripts` property of the `package.json` file

```js
// Before
{
  // Other settings
  "scripts": {
    // Other scripts
    "watch": "node-sass sass/ -o ./ --source-map true --output-style expanded --indent-type tab --indent-width 1 -w",
    "compile:css": "node-sass sass/ -o ./ && stylelint '*.css' --fix || true && stylelint '*.css' --fix",
    // Update this lines only if you moved the sass directory to src folder
 	"lint:scss": "wp-scripts lint-style 'sass/**/*.scss'",
    // Other scripts
  }
  // Other settings
}
    
// After
{
  // Other settings
  "scripts": {
    // Other scripts
    "watch": "webpack  --watch --mode=development",
    "compile:css": "webpack --mode=production && stylelint '*.css' --fix || true && stylelint '*.css' --fix",
    // Update this lines only if you moved the sass directory to src folder
 	"lint:scss": "wp-scripts lint-style 'src/scss/**/*.scss'",
    // Other scripts
  }
  // Other settings
}
```

And that's is all, you must be capable of run any of the scripts without issues. From here you can customize you webpack environment as you like 

<br>

## `CleanWebpackPlugin` workaround

Since the build folder in our webpack.config.js is same the root of our theme, enable `CleanWebpackPlugin` with default configuration all files and folders in your theme will be deleted! (`.git` folder is erased too!), it's necessary define what folder the plugin can clean

```js
	new CleanWebpackPlugin({
		cleanStaleWebpackAssets: true,
		verbose: true, // Optional
		cleanOnceBeforeBuildPatterns: [
			"*.map",      // Allow clean style.map file from root folder
			"dist/**/**", // Allow clean dist folder recursively
		]
	}),
```

You can read in detail how to configure this plugin and other options [here](https://github.com/johnagan/clean-webpack-plugin), please take a look if you are no sure about your configuration is safe or if you need check if all is OK.

If you have a better configuration don't hesitate in create a issue

<br>

## There are an automated way to do this?

Yes, you can download [here](https://raw.githubusercontent.com/jprieton/underscore-webpack/main/enable-webpack.sh) the bash script o run:

```bash
$ curl -o enable-webpack.sh https://raw.githubusercontent.com/jprieton/underscore-webpack/main/enable-webpack.sh | bash
```

<br>

## Bug tracker?

Have a bug? Please create an issue on GitHub at https://github.com/jprieton/underscores-enable-webpack/issues