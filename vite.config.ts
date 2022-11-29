import { defineConfig } from 'vite'
import path from 'path';
import RubyPlugin from 'vite-plugin-ruby'
import svg from 'vite-plugin-svgr';
import inject from "@rollup/plugin-inject";

export default defineConfig({
  build: {
    sourcemap: true,
  },
  plugins: [
    // inject({   // => that should be first under plugins array
    //   $: 'jquery',
    //   jQuery: 'jquery',
    // }),
    RubyPlugin(),
    svg(),
  ],
  resolve: {
    alias: {
      "@js": path.resolve(__dirname, './app/webpack/js'),
      "@reactjs": path.resolve(__dirname, './app/webpack/reactjs'),
      "@models": path.resolve(__dirname, './app/webpack/js/app/models/'),
      "@services": path.resolve(__dirname, './app/webpack/js/services/'),
      "@styles": path.resolve(__dirname, './app/webpack/stylesheets'),
      "images": path.resolve(__dirname, './app/webpack/images/'),
    },
  },
})
