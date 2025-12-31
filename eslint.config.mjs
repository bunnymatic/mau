import js from "@eslint/js";
import globals from "globals";

import typescriptParser from "@typescript-eslint/parser";
import ts from 'typescript-eslint';
import unusedImports from "eslint-plugin-unused-imports";
import simpleImportSort from "eslint-plugin-simple-import-sort";


export default [
  // files and ignores can *not* be in the same block https://github.com/eslint/eslint/issues/17400
  js.configs.recommended,
  ...ts.configs.recommended,
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.jquery,
        ...globals.node
      },
      ecmaVersion: 12,
      sourceType: "module",
      parser: typescriptParser,
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      }
    },
  }, {
    files: [
      "app/webpack/**/*.js",
      "app/webpack/**/*.jsx",
      "app/webpack/**/*.ts",
      "app/webpack/**/*.tsx"
    ],
  },
  {
    ignores: [
      "app/webpack/custom.d.ts",
      "app/webpack/js/vendor/**/*",
      "vendor/bundle/**",
      "eslint.config.js",
      "postcss.config.js",
      "coverage/**",
      "public/vite*/**",
      "babel.config.js",
      "app/webpack/javascripts/ujs-shims/**",
      "app/webpack/javascripts/vendored/**"]
    },
    {plugins: {
      "unused-imports": unusedImports,
      "simple-import-sort": simpleImportSort,
  },},
    {
      rules: {
        "@typescript-eslint/no-this-alias": 'off',
        "no-unused-vars": 'off',
        "import/no-unresolved": 0,
        "no-duplicate-imports": ["error", { includeExports: true }],
        "unused-imports/no-unused-imports": "error",
        "simple-import-sort/imports": "error",
        "simple-import-sort/exports": "error",
        "unused-imports/no-unused-imports": "error",
        "unused-imports/no-unused-vars": [
            "warn",
            {
                "vars": "all",
                "varsIgnorePattern": "^_",
                "args": "after-used",
                "argsIgnorePattern": "^_",
            },
        ],
        "@typescript-eslint/no-unused-vars": [
          "error",
          {
            argsIgnorePattern: "^_",
            varsIgnorePattern: "^_",
          },
        ]
        //     "no-var": "error",
        // "comma-dangle": ["error", "only-multiline"],
        // "space-before-function-paren": ["error", "never"],
        // indent: ["error", 2],
        // quotes: ["error", "double", { avoidEscape: true }],
        // semi: ["error", "always"],
        // "no-unused-vars": [
        //   "error",
        //   {
        //     argsIgnorePattern: "^_",
        //     varsIgnorePattern: "^_",
        //   },
        // ]
      },
    }
  ];
