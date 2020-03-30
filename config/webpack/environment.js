const { environment } = require("@rails/webpacker");
const directoryAliases = require("./custom/directoryAliases");
const buildOptimizations = require("./custom/buildOptimizations");

const htmlLoader = {
  test: /\.html$/,
  use: "html-loader",
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
  use: "imports-loader?define=>false",
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

// console.log("WEBPACK CONFIG", environment);
module.exports = environment;
