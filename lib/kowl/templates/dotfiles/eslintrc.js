// https://eslint.org/docs/rules/
// https://github.com/airbnb/javascript
{
  "env": {
    "browser": true,
    "node": true,
    "es6": true
  },

  extends: ['eslint:recommended'],
  "parserOptions": {
    "ecmaVersion": 6,
    "sourceType": "module",
  },

  // https://eslint.org/docs/user-guide/configuring#configuring-rules
  rules: {
    'arrow-parens':  ["error", "always"],
    'arrow-spacing': ["error", { "before": true, "after": true }],
    'block-spacing': [2, "always"],
    'comma-dangle':  ["error", "never"],
    'keyword-spacing': 2,
    'max-len': ["error", { "ignoreComments": true,
                           "ignoreTrailingComments": true}],
    'no-unused-vars': 0, // allow functions to have unused variables
    'object-curly-spacing': [2, "always"],
    'semi': [2, 'always'],
    'space-before-blocks': 2,
    'space-before-function-paren': [2,'never']
  }
}
