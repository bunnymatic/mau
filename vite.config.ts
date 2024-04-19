import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import svg from 'vite-plugin-svgr';
import tsconfigPaths from 'vite-tsconfig-paths'
import path from 'path';

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
    tsconfigPaths(),
  ],
  test: {
    globals: true,
    setupFiles: '../../jstest/setupFiles.js',
    environment: 'jsdom',
    alias: {
      "@js": path.resolve(__dirname, "./app/webpack/js"),
      "@reactjs": path.resolve(__dirname, "./app/webpack/reactjs"),
      "@models": path.resolve(__dirname, "./app/webpack/js/app/models"),
      "@services": path.resolve(__dirname, "./app/webpack/js/services"),
      "@test": path.resolve(__dirname, "./app/webpack/test"),
      "@fixtures": path.resolve(__dirname, "./spec/fixtures"),
      "images": path.resolve(__dirname, "./app/frontend/entrypoints/images"),
    }
  }
});
