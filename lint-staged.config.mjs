export default {
  '*.sh': 'shellcheck -x',
  '*.{md,json,jsonc,yml,yaml,mjs}': 'prettier --write',
};
