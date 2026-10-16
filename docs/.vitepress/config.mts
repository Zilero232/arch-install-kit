import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitepress';

const REPO = 'https://github.com/Zilero232/arch-install-kit';

export default defineConfig({
  title: 'Arch Install Kit',
  description: 'Arch Linux + Hyprland setup installed with one command',
  base: '/arch-install-kit/',
  cleanUrls: true,
  lastUpdated: true,

  // docs/README.md is the index for GitHub browsing; the site uses index.md
  srcExclude: ['README.md'],
  // Screenshots and wallpapers stay in assets/ and are served from the site root
  vite: { publicDir: fileURLToPath(new URL('../../assets/screenshots', import.meta.url)) },

  head: [['meta', { name: 'theme-color', content: '#1f1f28' }]],

  themeConfig: {
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
          { text: '2. USB and BIOS', link: '/install/02-usb-and-bios' },
          { text: '3. Install Arch', link: '/install/03-archinstall' },
          { text: '4. Run install.sh', link: '/install/04-run-installer' },
          { text: '5. After install', link: '/install/05-after-install' },
        ],
      },
      {
        text: 'Usage',
        items: [
          { text: 'Keybindings', link: '/usage/keybindings' },
          { text: 'Fish shell', link: '/usage/fish' },
          { text: 'Scripts', link: '/usage/scripts' },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'Packages', link: '/reference/packages' },
          { text: 'Repository structure', link: '/reference/structure' },
          { text: 'Troubleshooting', link: '/reference/troubleshooting' },
          { text: 'Manual Arch install', link: '/reference/manual-arch-install' },
        ],
      },
    ],

    socialLinks: [{ icon: 'github', link: REPO }],
    editLink: { pattern: `${REPO}/edit/master/docs/:path` },
    search: { provider: 'local' },
    outline: [2, 3],
    footer: { message: 'Released under the MIT License', copyright: '© Artemev Alexandr' },
  },
});
