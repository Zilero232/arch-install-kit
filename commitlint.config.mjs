// Gitmoji conventional commits: `✨ feat(hypr): add clipboard history`
export default {
  extends: ['gitmoji'],
  rules: {
    'header-max-length': [2, 'always', 100],
    'scope-enum': [
      2,
      'always',
      [
        'installer',
        'packages',
        'hypr',
        'waybar',
        'rofi',
        'shell',
        'dotfiles',
        'scripts',
        'login',
        'docs',
        'tooling',
        'deps',
        'tests',
        'theme',
        'system',
        'ci',
      ],
    ],
  },
  // Interactive prompt for `bun run commit` (czg)
  prompt: {
    useEmoji: true,
    emojiAlign: 'left',
    allowCustomScopes: false,
    allowEmptyScopes: true,
  },
};
