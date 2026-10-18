export default {
  '*.{sh,bash,bats}': 'shellcheck -x',
  '*.{md,json,jsonc,yml,yaml,mjs,ts,mts,vue,css}': 'prettier --write',
};
