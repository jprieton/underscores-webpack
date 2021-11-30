# First, install all dependencies
npm install

# Then, update the @wordpress/scripts package to the latest version
npm install @wordpress/scripts@latest

# Move the sass folder to the src folder
mkdir -p ./src/
mv ./sass/ ./src/scss/

# Update the watch script in package.json file
sed -i "s/node-sass sass\/ -o .\/ --source-map true --output-style expanded --indent-type tab --indent-width 1 -w/webpack --watch --mode=development/g" ./package.json

# Update the compile:css script in package.json file
sed -i "s/node-sass sass\/ -o .\//webpack --mode=production/g" ./package.json

# Update extends in the .stylelintrc.json file
sed -i "s/stylelint-config-wordpress\/scss/@wordpress\/stylelint-config\/scss/g" ./.stylelintrc.json

# Update path of linters
sed -i "s/wp-scripts lint-style 'sass\/\*\*\/\*.scss'/wp-scripts lint-style 'src\/scss\/\*\*\/\*.scss'/g" ./package.json
sed -i "s/wp-scripts lint-js 'js\/\*\*\/\*.scss'/wp-scripts lint-js 'src\/js\/\*\*\/\*.scss'/g" ./package.json

# Add src folder to exclude list
sed -i "s/--exclude .DS_Store/--exclude src webpack.config.js enable-webpack.sh .DS_Store/g" ./package.json

# Download a bare minimum webpack config file
curl -o webpack.config.js https://raw.githubusercontent.com/jprieton/underscore-webpack/main/webpack.config.js

# Create the required directories
mkdir -p ./src/js/

# Generate the entry point script to manage the styles
echo "import '../scss/style.scss';" > ./src/js/style.js

# Done! It's all ready to go!
echo "Done!"
