# Enable webpack 5.x in underscore based theme 

This guide allows to you use webpack 5.x with `_s`, we need do some adjusts. 

Please read the entire guide carefully to understand the steps involved in this change, you can find a link to a bash script for the automation of these tasks at the end of this document, additionally you can see the source code of this script [here](https://github.com/jprieton/underscore-webpack/blob/main/enable-webpack.sh).

<br>

> **Note**
>  
> For this guide I will use a clean installation of [_s](https://underscores.me/) starter theme.
>
> This guide only cover the SASS watcher, other topics, as bundle scripts, are treated superficially.
>
> Maybe is required to update the bundled version of [@wordpress/scripts](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-scripts/) if your theme uses a version prior to 18.0.0, before following the steps in this guide, please check if your project requires that version. 
>
> Isn't recommended for ongoing projects, please go to caution if you want apply to an ongoing project, if you use [CleanWebpackPlugin](https://github.com/johnagan/clean-webpack-plugin) you will lose your files without a minimum configuration, further in this guide I will explain to avoid this in detail.

<br>

## Installation of _s theme

There are several ways to create your underscore based theme

- Generate a  from the [underscore](https://underscores.me/) site, remember check the *sassify* option (recommended),

- Using the command line interface WP-CLI, read more [here](https://developer.wordpress.org/cli/commands/scaffold/_s/) how to use the `scaffold` command, remember use the `-sassify` option, you can execute a command similar to this on the root of your WordPress installation,

  ```shell-script
  # Example
  wp scaffold _s sample-theme --theme_name="Sample Theme" --author="John Doe" --sassify
  ```
  
- Or download from GitHub [repository](https://github.com/automattic/_s).

To start using all the tools that come with `_s` you need to install the necessary Node.js and Composer dependencies, go to your theme root directory and execute in terminal the following command:

```bash
composer install
npm install
```

<br>


## Update @wordpress/scripts (optional)

> **Note**
>
> Latest version of underscores uses the 19.2.2 version of @wordpress/scripts
> 
> This step is not included in the bash file

This step is required only if you have an installation of `_s` that uses [@wordpress/scripts](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-scripts/) prior to 18.0.0, in a clean install this step is not required

If you have as dependency the [@wordpress/scripts](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-scripts/) prior to version 18.0.0, this version uses webpack 4.x, we need update to more recent version to use webpack 5.x in our project, (recommended 19.2.2, already tested in this guide) to do this and avoid the *Fix the upstream dependency conflict* we need uninstall and reinstall the @wordpress/scripts package, then execute in terminal the following command:

```bash
npm remove @wordpress/scripts && npm install @wordpress/scripts@19.2.2 --save-dev
```

Yes, in this case, only a package is required to be updated.

<br>

## Move the `sass` folder

It's a personal preference, I'm prefer have all sources in the `src` folder.

To do this run:

```bash
mkdir ./src/
mv ./sass/ ./src/scss/
```

<br>

## Add `webpack.config.js` file

In this repository there are a bare minimum `webpack.config.js` that allows to you start to work in your theme, you can download [here](https://raw.githubusercontent.com/jprieton/underscore-webpack/main/webpack.config.js) and put it on your root theme directory or run the following command:

```bash
curl -o webpack.config.js https://raw.githubusercontent.com/jprieton/underscores-webpack/main/webpack.config.js
```

Please read this about the `CleanWebpackPlugin`.

In this file pay attention on the initialization of `MiniCssExtractPlugin`, this configuration allow creates the `style.css` and `woocommerce.css` files in the root directory of the theme, any other will be created in the `dist` directory (o any other that you configure in the `BUILD_DIR`)

if you check *WooCommerce boilerplate* option when you generate your theme, uncomment the `woocomerce` entry point

<br>

## Add `postcss.config.js` file

In this repository there are a bare minimum `postcss.config.js`, you can download [here](https://raw.githubusercontent.com/jprieton/underscores-webpack/main/postcss.config.js) and put it on your root theme directory or run the following command:

```bash
curl -o postcss.config.js https://raw.githubusercontent.com/jprieton/underscores-webpack/main/postcss.config.js
```

<br>

## Update `package.json` file

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
    "watch": "webpack --watch --mode=development",
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

## Generate entry poitns

In the `webpack.config.js` file there are two entry points, `styles` and `woocommerce`, we need create the files associated to these entry points executing in terminal the following commands:

```bash
# Create the required directories
mkdir -p ./src/js/

# Generate the entry point script to manage the styles
echo "import '../scss/style.scss';" > ./src/js/style.js
echo "import '../scss/woocommerce.scss';" > ./src/js/woocommerce.js
```

<br>

## `CleanWebpackPlugin` workaround :warning:	

> **Note**
> 
> This step it is not required if you starts a clean installation of _s theme and download the `webpack.config.js` from this repository, 


> **Warning**
> 
> If you are working in a preexistent theme, please read carefully this instructions, make a backup and double check the configuration of the *CleanWebpackPlugin* before run webpack, **you can lose your files if you set the incorrect path to clean!**

 Since the build folder in our `webpack.config.js` is same the root of our theme, enable `CleanWebpackPlugin` with default configuration all files and folders in your theme will be deleted! (`.git` folder is erased too!), it's necessary define what folder the plugin can clean, in our `webpack.config.js` are ready 

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

If you have a better configuration or you can improve this document don't hesitate in create a issue ticket.

<br>

## There are an automated way to do this?

Yes, you can download [here](https://raw.githubusercontent.com/jprieton/underscore-webpack/main/enable-webpack.sh) the bash script o run:

```bash
curl https://raw.githubusercontent.com/jprieton/underscore-webpack/main/enable-webpack.sh | bash
```

<br>

## Bug tracker?

Have a bug? Please create an issue on GitHub at https://github.com/jprieton/underscores-webpack/issues
