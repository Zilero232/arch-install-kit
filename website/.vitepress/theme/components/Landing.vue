<script setup lang="ts">
import { ref } from 'vue';
import { withBase } from 'vitepress';

import InstallTerminal from './InstallTerminal.vue';

import desktop from '../../../../assets/screenshots/hyrpland_preview.png';
import launcher from '../../../../assets/screenshots/application_manager.png';
import terminals from '../../../../assets/screenshots/several_terminals.png';
import files from '../../../../assets/screenshots/file_explorer.png';
import ranger from '../../../../assets/screenshots/file_manager_cli.png';
import calendar from '../../../../assets/screenshots/calendar_calculator.png';
import power from '../../../../assets/screenshots/wlogout_preview.png';

const REPO = 'https://github.com/Zilero232/arch-install-kit';

const QUICK_START = [
  'sudo pacman -S --needed git',
  `git clone ${REPO}.git ~/arch-install-kit`,
  'cd ~/arch-install-kit && ./install.sh',
].join('\n');

const INSIDE = [
  {
    term: 'Hyprland',
    color: 'blue',
    text: 'Tiling compositor with hyprlock, hypridle, hyprpaper and hyprsunset. Every keybinding has a description.',
  },
  {
    term: 'Waybar',
    color: 'aqua',
    text: 'Workspaces, weather, pending updates, an audio visualizer, network and Bluetooth.',
  },
  {
    term: 'Rofi',
    color: 'violet',
    text: 'Apps, calculator, emoji and clipboard history from one launcher.',
  },
  {
    term: 'Fish + Alacritty',
    color: 'yellow',
    text: 'Abbreviations, small functions, an Oh My Posh prompt and mise for tool versions.',
  },
  {
    term: 'SDDM + Plymouth',
    color: 'pink',
    text: 'Astronaut login screen and a boot splash. Windows shows up in GRUB if you dual-boot.',
  },
  {
    term: 'Safe re-runs',
    color: 'green',
    text: 'System files are backed up before the first edit, replaced configs land in ~/.config-backup.',
  },
];

const STEPS = [
  {
    title: 'Back up',
    text: 'Keys, secrets and package lists from the old system.',
    link: '/install/01-backup',
  },
  {
    title: 'Write the USB',
    text: 'Rufus or dd, Secure Boot off.',
    link: '/install/02-usb-and-bios',
  },
  {
    title: 'Install Arch',
    text: 'archinstall with the Minimal profile.',
    link: '/install/03-archinstall',
  },
  {
    title: 'Run install.sh',
    text: 'Pick groups, confirm, wait.',
    link: '/install/04-run-installer',
  },
  {
    title: 'Make it yours',
    text: 'Monitors, weather key, wallpapers.',
    link: '/install/05-after-install',
  },
];

const GALLERY = [
  { src: launcher, caption: 'Rofi launcher' },
  { src: terminals, caption: 'Tiled terminals' },
  { src: files, caption: 'Thunar' },
  { src: ranger, caption: 'Ranger with image previews' },
  { src: calendar, caption: 'Calendar and calculator' },
  { src: power, caption: 'Power menu' },
];

const copied = ref(false);

async function copyQuickStart() {
  await navigator.clipboard.writeText(QUICK_START);
  copied.value = true;
  setTimeout(() => (copied.value = false), 1600);
}
</script>

<template>
  <div class="landing">
    <section class="hero">
      <div class="hero-text">
        <h1>From a blank Arch install to a finished Hyprland desktop</h1>
        <p class="lead">
          One script installs the packages, drivers and Kanagawa-themed configs, sets up login and
          boot, and can be run again whenever you like.
        </p>
        <div class="actions">
          <a class="button primary" :href="withBase('/install/01-backup')"
            >Read the install guide</a
          >
          <a class="button" :href="withBase('/install/04-run-installer')">I already have Arch</a>
        </div>
      </div>
      <InstallTerminal class="hero-terminal" />
    </section>

    <section class="screen" aria-label="The desktop">
      <img
        class="screen-shot"
        :src="desktop"
        alt="Hyprland desktop with Alacritty and fastfetch"
        width="2546"
        height="1430"
      />
    </section>

    <section class="quick">
      <h2>Already on Arch?</h2>
      <p>Run this as your user on a fresh install with the Minimal profile.</p>
      <div class="quick-code">
        <pre><code>{{ QUICK_START }}</code></pre>
        <button type="button" class="copy" @click="copyQuickStart">
          {{ copied ? 'Copied' : 'Copy' }}
        </button>
      </div>
    </section>

    <section class="inside">
      <h2>What you get</h2>
      <dl>
        <div v-for="item in INSIDE" :key="item.term" class="inside-row">
          <dt :class="`accent-${item.color}`">{{ item.term }}</dt>
          <dd>{{ item.text }}</dd>
        </div>
      </dl>
    </section>

    <section class="steps">
      <h2>The way in</h2>
      <ol>
        <li v-for="step in STEPS" :key="step.title">
          <a :href="withBase(step.link)">
            <strong>{{ step.title }}</strong>
            <span>{{ step.text }}</span>
          </a>
        </li>
      </ol>
    </section>

    <section class="gallery">
      <h2>Around the desktop</h2>
      <div class="gallery-grid">
        <figure v-for="shot in GALLERY" :key="shot.caption">
          <a :href="shot.src" target="_blank" rel="noreferrer">
            <img :src="shot.src" :alt="shot.caption" loading="lazy" width="2559" height="1439" />
          </a>
          <figcaption>{{ shot.caption }}</figcaption>
        </figure>
      </div>
    </section>

    <section class="outro">
      <p>MIT licensed. Fork it, change the packages and colors, make it your own setup.</p>
      <a class="button" :href="REPO">Open on GitHub</a>
    </section>
  </div>
</template>

<style scoped>
.landing {
  max-width: 1180px;
  margin: 0 auto;
  padding: 56px 24px 96px;
}

h1,
h2 {
  font-family: var(--kw-mono);
  color: var(--kw-fg);
  letter-spacing: -0.02em;
}

h2 {
  margin: 0 0 20px;
  font-size: 26px;
  line-height: 1.25;
  font-weight: 700;
  border: 0;
  padding: 0;
}

section + section {
  margin-top: 112px;
}

/* Hero */

.hero {
  display: grid;
  grid-template-columns: minmax(0, 0.9fr) minmax(0, 1.1fr);
  gap: 56px;
  align-items: center;
}

h1 {
  margin: 0;
  font-size: clamp(32px, 4vw, 52px);
  line-height: 1.08;
  font-weight: 700;
  text-wrap: balance;
}

.lead {
  margin: 24px 0 0;
  max-width: 34em;
  font-size: 18px;
  line-height: 1.6;
  color: var(--kw-muted);
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 32px;
}

.button {
  display: inline-block;
  padding: 11px 20px;
  border: 1px solid var(--kw-line);
  border-radius: 8px;
  font: 600 15px/1.2 var(--kw-sans);
  color: var(--kw-fg);
  text-decoration: none;
  transition:
    border-color 0.15s,
    background-color 0.15s;
}

.button:hover {
  border-color: var(--kw-blue);
}

.button.primary {
  border-color: var(--kw-blue);
  background: var(--kw-blue);
  color: var(--kw-ink-0);
}

.button.primary:hover {
  background: var(--kw-blue-bright);
}

.button:focus-visible,
.copy:focus-visible,
.steps a:focus-visible,
.gallery a:focus-visible {
  outline: 2px solid var(--kw-yellow);
  outline-offset: 3px;
}

/* The desktop */

.screen {
  border: 1px solid var(--kw-line);
  border-radius: 12px;
  overflow: hidden;
  background: var(--kw-ink-0);
}

.screen img {
  display: block;
  width: 100%;
  height: auto;
}

/* Quick start */

.quick {
  max-width: 760px;
}

.quick p {
  margin: 0 0 16px;
  color: var(--kw-muted);
}

.quick-code {
  position: relative;
  border: 1px solid var(--kw-line);
  border-radius: 10px;
  background: var(--kw-ink-0);
}

.quick-code pre {
  margin: 0;
  padding: 18px 96px 18px 20px;
  overflow-x: auto;
  font: 14px/1.8 var(--kw-mono);
  color: var(--kw-fg);
}

.copy {
  position: absolute;
  top: 12px;
  right: 12px;
  padding: 6px 12px;
  border: 1px solid var(--kw-line);
  border-radius: 6px;
  font: 600 13px/1 var(--kw-sans);
  color: var(--kw-fg);
  background: var(--kw-ink-2);
  cursor: pointer;
}

.copy:hover {
  border-color: var(--kw-blue);
}

/* What you get: term on the left, explanation on the right */

.inside dl {
  margin: 0;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  column-gap: 56px;
  row-gap: 28px;
}

.inside-row {
  display: grid;
  grid-template-columns: 11em minmax(0, 1fr);
  gap: 16px;
}

.inside dt {
  font: 700 15px/1.6 var(--kw-mono);
}

.inside dd {
  margin: 0;
  line-height: 1.6;
  color: var(--kw-muted);
}

.accent-blue {
  color: var(--kw-blue);
}
.accent-aqua {
  color: var(--kw-aqua);
}
.accent-violet {
  color: var(--kw-violet);
}
.accent-yellow {
  color: var(--kw-yellow);
}
.accent-pink {
  color: var(--kw-pink);
}
.accent-green {
  color: var(--kw-green);
}

/* The way in: a real sequence, so it is numbered */

.steps ol {
  margin: 0;
  padding: 0;
  list-style: none;
  counter-reset: step;
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 16px;
}

.steps li {
  counter-increment: step;
}

.steps a {
  display: block;
  height: 100%;
  padding: 18px 16px 20px;
  border-top: 2px solid var(--kw-line);
  color: inherit;
  text-decoration: none;
  transition: border-color 0.15s;
}

.steps a::before {
  content: counter(step);
  display: block;
  margin-bottom: 10px;
  font: 700 28px/1 var(--kw-mono);
  color: var(--kw-blue);
}

.steps a:hover {
  border-top-color: var(--kw-blue);
}

.steps strong {
  display: block;
  font: 600 16px/1.4 var(--kw-sans);
  color: var(--kw-fg);
}

.steps span {
  display: block;
  margin-top: 6px;
  font-size: 14px;
  line-height: 1.5;
  color: var(--kw-muted);
}

/* Gallery */

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 20px;
}

.gallery figure {
  margin: 0;
}

.gallery img {
  display: block;
  width: 100%;
  height: auto;
  border: 1px solid var(--kw-line);
  border-radius: 8px;
}

.gallery figcaption {
  margin-top: 8px;
  font-size: 14px;
  color: var(--kw-muted);
}

/* Outro */

.outro {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  padding-top: 40px;
  border-top: 1px solid var(--kw-line);
}

.outro p {
  margin: 0;
  max-width: 40em;
  color: var(--kw-muted);
}

/* Smaller screens */

@media (max-width: 1024px) {
  .hero {
    grid-template-columns: 1fr;
    gap: 40px;
  }

  .inside dl {
    grid-template-columns: 1fr;
  }

  .steps ol {
    grid-template-columns: 1fr;
  }

  .gallery-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  section + section {
    margin-top: 80px;
  }
}

@media (max-width: 560px) {
  .landing {
    padding: 32px 16px 72px;
  }

  .inside-row {
    grid-template-columns: 1fr;
    gap: 4px;
  }

  .gallery-grid {
    grid-template-columns: 1fr;
  }
}
</style>
