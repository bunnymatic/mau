const { environment } = require("@rails/webpacker");
const directoryAliases = require("./custom/directoryAliases");
const buildOptimizations = require("./custom/buildOptimizations");

const htmlLoader = {
  test: /\.html$/,
  use: [
    {
      loader: "html-loader",
      options: {
        minimize: {
          caseSensitive: true,
          collapseWhitespace: true,
          conservativeCollapse: true,
          keepClosingSlash: true,
          minifyCSS: false,
          minifyJS: true,
          removeComments: true,
          removeRedundantAttributes: true,
          removeScriptTypeAttributes: true,
          removeStyleLinkTypeAttributes: true,
          removeAttributeQuotes: true,
        },
      },
    },
  ],
};

// Insert json loader at the end of list
environment.loaders.append("html", htmlLoader);

// resolve-url-loader must be used before sass-loader
// handles relative paths for things like fonts in other scss files
environment.loaders.get("sass").use.splice(-1, 0, {
  loader: "resolve-url-loader",
});

const importsLoader = {
  test: /datatables.*/,
  use: "imports-loader?additionalCode=var%20define%20=%20false;",
};

environment.loaders.append("imports-loader", importsLoader);

// Add an additional plugin of your choosing : ProvidePlugin
//
// const webpack = require("webpack");
// const path = require("path");
//
// environment.plugins.prepend(
//   "Provide",
//   new webpack.ProvidePlugin({
//     ngInject: path.resolve(
//       path.join(__dirname, "../../app/webpack/js/ng-inject.js")
//     )
//   })
// );
[directoryAliases, buildOptimizations].forEach((cfg) =>
  environment.config.merge(cfg)
);

environment.splitChunks();

// dart-sass
const sassLoader = environment.loaders.get("sass");
const sassLoaderConfig = sassLoader.use.find(function (element) {
  return element.loader == "sass-loader";
});

// Use Dart-implementation of Sass (default is node-sass)
const options = sassLoaderConfig.options;
options.implementation = require("sass");
// console.log("WEBPACK CONFIG", environment);

module.exports = environment;
