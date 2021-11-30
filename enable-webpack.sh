# First, install all dependencies
npm install

# Then, update the @wordpress/scripts package to the latest version
npm install @wordpress/scripts@latest

# Move the sass folder to the src folder
mv ./sass ./src/scss

# Update the watch script in package.json file
sed -i "s/node-sass sass\/ -o .\/ --source-map true --output-style expanded --indent-type tab --indent-width 1 -w/webpack --watch --mode=development/g" ./package.json

# Update the compile:css script in package.json file
sed -i "s/node-sass sass\/ -o .\//webpack --mode=production/g" ./package.json

# Update extends in the .stylelintrc.json file
sed -i "s/stylelint-config-wordpress\/scss/@wordpress\/stylelint-config\/scss/g" ./.stylelintrc.json

# Download a bare minimum webpack config file
curl -o webpack.config.js https://raw.githubusercontent.com/jprieton/underscore-webpack/main/webpack.config.js

# Generate the entry point script to manage the styles
mkdir -p ./src/js/
echo "import '../scss/style.scss';" > ./src/js/style.js

# Done! It's all ready to go!
echo "Done!"