<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue';

// What ./install.sh prints on a typical laptop, module by module (see modules/)
const LINES = [
  { kind: 'cmd', text: './install.sh --yes' },
  { kind: 'step', name: 'preflight', note: 'Arch, online, 214G free' },
  { kind: 'step', name: 'pacman', note: 'multilib on, system updated' },
  { kind: 'step', name: 'aur-helper', note: 'yay installed' },
  { kind: 'step', name: 'packages', note: '11 groups installed' },
  { kind: 'step', name: 'gpu', note: 'intel-ucode, mesa, vulkan-intel' },
  { kind: 'step', name: 'login', note: 'SDDM Astronaut, Plymouth' },
  { kind: 'step', name: 'boot', note: 'Windows Boot Manager found' },
  { kind: 'step', name: 'dotfiles', note: 'configs in ~/.config' },
  { kind: 'step', name: 'services', note: 'sddm, network, bluetooth' },
  { kind: 'cmd', text: 'reboot' },
] as const;

const STEP_DELAY_MS = 420;

const shown = ref(0);
let timer: ReturnType<typeof setInterval> | undefined;

onMounted(() => {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reduceMotion) {
    shown.value = LINES.length;
    return;
  }
  timer = setInterval(() => {
    shown.value += 1;
    if (shown.value >= LINES.length) clearInterval(timer);
  }, STEP_DELAY_MS);
});

onBeforeUnmount(() => clearInterval(timer));
</script>

<template>
  <figure class="terminal" aria-label="install.sh output">
    <div class="terminal-bar">
      <span class="terminal-title">alacritty ~/arch-install-kit</span>
    </div>
    <pre class="terminal-body"><template v-for="(line, i) in LINES" :key="i"><span
      v-if="i < shown"
      class="line"
    ><template v-if="line.kind === 'cmd'"><span class="prompt">❯</span> {{ line.text }}</template><template v-else><span class="arrow">==&gt;</span> <span class="module">{{ line.name.padEnd(11) }}</span><span class="ok">ok</span>  <span class="note">{{ line.note }}</span></template>
</span></template><span class="cursor" aria-hidden="true">▍</span></pre>
  </figure>
</template>

<style scoped>
.terminal {
  margin: 0;
  border: 1px solid var(--kw-line);
  border-radius: 10px;
  background: var(--kw-ink-0);
  box-shadow: 0 30px 80px -30px rgba(0, 0, 0, 0.7);
  overflow: hidden;
}

.terminal-bar {
  padding: 8px 14px;
  border-bottom: 1px solid var(--kw-line);
  background: var(--kw-ink-2);
}

.terminal-title {
  font: 500 12px/1 var(--kw-mono);
  color: var(--kw-muted);
}

.terminal-body {
  margin: 0;
  padding: 16px 18px 18px;
  min-height: 300px;
  font: 13px/1.75 var(--kw-mono);
  font-variant-ligatures: none;
  color: var(--kw-fg);
  white-space: pre-wrap;
}

.line {
  display: inline;
}

.prompt {
  color: var(--kw-aqua);
}

.arrow {
  color: var(--kw-blue);
}

.module {
  color: var(--kw-fg);
}

.ok {
  color: var(--kw-green);
  font-weight: 700;
}

.note {
  color: var(--kw-muted);
}

.cursor {
  color: var(--kw-yellow);
  animation: blink 1.1s steps(1) infinite;
}

@keyframes blink {
  50% {
    opacity: 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .cursor {
    animation: none;
  }
}
</style>
