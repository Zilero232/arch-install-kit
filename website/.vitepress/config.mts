import { fileURLToPath } from 'node:url';

import { ViteImageOptimizer } from 'vite-plugin-image-optimizer';
import { defineConfig } from 'vitepress';

const REPO = 'https://github.com/Zilero232/arch-install-kit';
const SITE = 'https://zilero232.github.io/arch-install-kit/';
const BASE = '/arch-install-kit/';
const DESCRIPTION =
  'From a blank Arch install to a finished Hyprland desktop: one script, curated packages, Kanagawa-themed dotfiles.';
const FONTS =
  'https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&family=Onest:wght@400;500;600&display=swap';

export default defineConfig({
  title: 'Arch Install Kit',
  description: DESCRIPTION,
  base: BASE,
  cleanUrls: true,
  lastUpdated: true,
  appearance: 'dark',

  // Content comes from the repo: docs/** for pages, website/index.md for the landing.
  // docs/ stays plain Markdown; everything site-specific lives in website/.
  srcDir: '..',
  srcExclude: ['*.md', 'docs/README.md', '**/node_modules/**', 'dotfiles/**'],
  rewrites: {
    'docs/:page*': ':page*',
    'website/index.md': 'index.md',
  },

  vite: {
    publicDir: fileURLToPath(new URL('../public', import.meta.url)),
    // Screenshots are imported from assets/ and compressed at build time
    plugins: [ViteImageOptimizer({ png: { quality: 80 }, jpg: { quality: 80 } })],
  },

  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: `${BASE}favicon.svg` }],
    ['meta', { name: 'theme-color', content: '#1f1f28' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    ['link', { rel: 'stylesheet', href: FONTS }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:title', content: 'Arch Install Kit' }],
    ['meta', { property: 'og:description', content: DESCRIPTION }],
    ['meta', { property: 'og:url', content: SITE }],
    ['meta', { property: 'og:image', content: `${SITE}og.jpg` }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
  ],

  themeConfig: {
    logo: '/favicon.svg',
    nav: [
      { text: 'Install', link: '/install/01-backup' },
      { text: 'Usage', link: '/usage/keybindings' },
      { text: 'Reference', link: '/reference/packages' },
    ],

    sidebar: [
      {
        text: 'Install',
        items: [
          { text: '1. Backup', link: '/install/01-backup' },
          { text: '2. USB stick and BIOS', link: '/install/02-usb-and-bios' },
          { text: '3. Installing Arch', link: '/install/03-archinstall' },
          { text: '4. Running install.sh', link: '/install/04-run-installer' },
          { text: '5. After installation', link: '/install/05-after-install' },
        ],
      },
      {
        text: 'Usage',
        items: [
          { text: 'Keybindings', link: '/usage/keybindings' },
          { text: 'Theming', link: '/usage/theming' },
          { text: 'Fish shell', link: '/usage/fish' },
          { text: 'Scripts', link: '/usage/scripts' },
          { text: 'Gaming', link: '/usage/gaming' },
          { text: 'Dual boot', link: '/usage/dual-boot' },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'Troubleshooting', link: '/reference/troubleshooting' },
          { text: 'Packages', link: '/reference/packages' },
          { text: 'Manual Arch install', link: '/reference/manual-arch-install' },
        ],
      },
      {
        text: 'Contributing',
        items: [
          { text: 'Repository structure', link: '/reference/structure' },
          { text: 'Style guide', link: '/reference/style-guide' },
          { text: 'Testing', link: '/reference/testing' },
        ],
      },
    ],

    socialLinks: [{ icon: 'github', link: REPO }],
    editLink: { pattern: `${REPO}/edit/master/:path` },
    search: { provider: 'local' },
    outline: [2, 3],
    footer: { message: 'Released under the MIT License', copyright: '© Artemev Alexandr' },
  },
});
