import type { Theme } from 'vitepress';
import DefaultTheme from 'vitepress/theme';

import Landing from './components/Landing.vue';
import './kanagawa.css';

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('Landing', Landing);
  },
} satisfies Theme;
