// Config checks: Waybar, SwayNC, Hyprland, TOML files, dotfiles hygiene and the package lists.
// Run with `bun test tests/` (part of `bun run test`).

import { describe, expect, test } from 'bun:test';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative, resolve } from 'node:path';

import Ajv2020 from 'ajv/dist/2020';
import { parse as parseJsonc, printParseErrorCode, type ParseError } from 'jsonc-parser';

const REPO = resolve(import.meta.dir, '..');
const DOTFILES = join(REPO, 'dotfiles');
const PACKAGES = join(REPO, 'installer/packages');
const SWAYNC_SCHEMA = '/etc/xdg/swaync/configSchema.json';

// Commands the configs may start, and the package in packages/*.txt that provides each.
// null: part of the base system or the shell (coreutils, systemd, procps, yay from the installer).
const COMMAND_PACKAGES: Record<string, string | null> = {
  alacritty: 'alacritty',
  'blueman-manager': 'blueman',
  brightnessctl: 'brightnessctl',
  command: null,
  hyprctl: 'hyprland',
  hyprpicker: 'hyprpicker',
  hyprshot: 'hyprshot',
  loginctl: null,
  NeoHtop: 'neohtop-bin',
  'nm-connection-editor': 'nm-connection-editor',
  pavucontrol: 'pavucontrol',
  pkill: null,
  playerctl: 'playerctl',
  rofi: 'rofi',
  satty: 'satty',
  sh: null,
  sleep: null,
  'swaync-client': 'swaync',
  'swayosd-client': 'swayosd',
  systemctl: null,
  'waybar-module-pacman-updates': 'waybar-module-pacman-updates-git',
  'waybar-weather': 'waybar-weather',
  wpctl: 'wireplumber',
  yay: null,
};

// Waybar's own click actions (hyprland/workspaces, clock), not shell commands
const WAYBAR_ACTIONS = new Set(['mode', 'shift_up', 'shift_down', 'shift_reset']);

// --- Helpers ---

function readText(path: string): string {
  return readFileSync(path, 'utf8');
}

function readJsonc(path: string): Record<string, any> {
  const errors: ParseError[] = [];
  const value = parseJsonc(readText(path), errors, { allowTrailingComma: false });
  const messages = errors.map((e) => `${printParseErrorCode(e.error)} at offset ${e.offset}`);

  expect(messages, `${relative(REPO, path)} parse errors`).toEqual([]);
  return value;
}

// Every file under dir, recursively
function walk(dir: string): string[] {
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) return walk(path);
    return entry.isFile() ? [path] : [];
  });
}

function isBinary(path: string): boolean {
  return readFileSync(path).subarray(0, 8000).includes(0);
}

// One package name per word, comments and blank lines dropped (same rules as read_pkgs)
function readPkgs(path: string): string[] {
  return readText(path)
    .split('\n')
    .flatMap((line) => line.replace(/#.*/, '').trim().split(/\s+/))
    .filter(Boolean);
}

const listFiles = readdirSync(PACKAGES)
  .filter((name) => name.endsWith('.txt'))
  .sort();
const allListedPackages = new Set(listFiles.flatMap((name) => readPkgs(join(PACKAGES, name))));

// ~/.config/x and ~/bin/x point into dotfiles/, which mirrors $HOME
function repoPathFor(homePath: string): string {
  return join(DOTFILES, homePath.replace(/^~\//, ''));
}

// Problems with one command line: unknown first word, missing ~/ script, unlisted package
function commandProblems(command: string): string[] {
  const first = command.trim().split(/\s+/)[0];

  if (first.startsWith('~/')) {
    const path = repoPathFor(first);
    return existsSync(path) && statSync(path).mode & 0o111
      ? []
      : [`${first}: no executable in dotfiles/`];
  }
  if (first.endsWith('.sh')) {
    // A bare script name runs from ~/bin, which is on PATH
    return existsSync(join(DOTFILES, 'bin', first)) ? [] : [`${first}: not in dotfiles/bin`];
  }
  if (!(first in COMMAND_PACKAGES)) {
    return [`${first}: unknown command (add it to COMMAND_PACKAGES with its package)`];
  }

  const pkg = COMMAND_PACKAGES[first];
  return pkg === null || allListedPackages.has(pkg)
    ? []
    : [`${first}: package ${pkg} is in no list`];
}

// --- Waybar ---

describe('waybar', () => {
  const dir = join(DOTFILES, '.config/waybar');
  const config = readJsonc(join(dir, 'config.jsonc'));
  const modules = readJsonc(join(dir, 'modules.jsonc'));
  const settings: Record<string, any> = { ...modules, ...config };

  test('every module on the bar (and in groups) has settings', () => {
    const listed = ['modules-left', 'modules-center', 'modules-right'].flatMap(
      (key) => config[key] ?? [],
    );
    const grouped = Object.entries(settings)
      .filter(([name]) => name.startsWith('group/'))
      .flatMap(([, group]) => group.modules ?? []);
    const missing = [...listed, ...grouped].filter((name: string) => !(name in settings));

    expect(missing).toEqual([]);
  });

  test('the include points at modules.jsonc', () => {
    expect(config.include).toBe('~/.config/waybar/modules.jsonc');
  });

  test('no format mixes {icon} with a bare {} (waybar 0.15 rejects it)', () => {
    const bad: string[] = [];

    for (const [name, module] of Object.entries(modules)) {
      for (const [key, value] of Object.entries(module as Record<string, unknown>)) {
        if (key.startsWith('format') && typeof value === 'string') {
          if (value.includes('{icon}') && value.includes('{}')) bad.push(`${name}.${key}`);
        }
      }
    }

    expect(bad).toEqual([]);
  });

  test('exec and on-* commands exist (known tool from a package list, or a repo script)', () => {
    const problems: string[] = [];

    for (const [name, module] of Object.entries(modules)) {
      for (const [key, value] of Object.entries(module as Record<string, unknown>)) {
        const isCommand = key === 'exec' || key === 'exec-if' || key.startsWith('on-');
        if (!isCommand || typeof value !== 'string' || WAYBAR_ACTIONS.has(value)) continue;
        problems.push(...commandProblems(value).map((p) => `${name}.${key}: ${p}`));
      }
    }

    expect(problems).toEqual([]);
  });
});

// --- SwayNC ---

describe('swaync', () => {
  const config = JSON.parse(readText(join(DOTFILES, '.config/swaync/config.json')));

  test.skipIf(!existsSync(SWAYNC_SCHEMA))('config.json validates against the schema', () => {
    const schema = JSON.parse(readText(SWAYNC_SCHEMA));
    const ajv = new Ajv2020({ strict: false, allErrors: true });
    const validate = ajv.compile(schema);

    validate(config);
    expect(validate.errors ?? []).toEqual([]);
  });

  if (!existsSync(SWAYNC_SCHEMA)) {
    console.warn(`skip: ${SWAYNC_SCHEMA} not found (install swaync to validate the config)`);
  }

  test('script exec lines have no quotes (swaync splits them on spaces)', () => {
    const scripts = Object.entries(config.scripts ?? {}) as [string, { exec: string }][];
    const quoted = scripts.filter(([, script]) => /['"]/.test(script.exec)).map(([name]) => name);

    expect(scripts.length).toBeGreaterThan(0);
    expect(quoted).toEqual([]);
  });

  test('script and button commands exist', () => {
    const buttons = config['widget-config']['buttons-grid'].actions as Record<string, string>[];
    const commands = [
      ...Object.values(config.scripts ?? {}).map((s: any) => s.exec as string),
      ...buttons.flatMap((b) => [b.command, b['update-command']].filter(Boolean)),
    ];
    const problems = commands.flatMap((command) => commandProblems(command));

    expect(problems).toEqual([]);
  });

  // swaync is a systemd user service: ~/bin is not on its PATH, so a bare name is "not found"
  test('kit scripts are called by their ~/bin path, not a bare name', () => {
    const text = readText(join(DOTFILES, '.config/swaync/config.json'));
    const bare = [...text.matchAll(/(?<![\w~/.-])([\w-]+\.sh)\b/g)].map((m) => m[1]);

    expect(bare).toEqual([]);
  });

  test('~/bin scripts referenced inside sh -c buttons exist in dotfiles/bin', () => {
    const text = readText(join(DOTFILES, '.config/swaync/config.json'));
    const missing = [...text.matchAll(/~\/bin\/([\w.-]+)/g)]
      .map((m) => m[1])
      .filter((name) => !existsSync(join(DOTFILES, 'bin', name)));

    expect(missing).toEqual([]);
  });
});

// --- Hyprland ---

describe('hyprland', () => {
  const hyprland = Bun.which('Hyprland');

  test.skipIf(!hyprland)('hyprland.lua passes Hyprland --verify-config', () => {
    const config = join(DOTFILES, '.config/hypr/hyprland.lua');
    const result = Bun.spawnSync([hyprland!, '--verify-config', '-c', config]);
    const output = result.stdout.toString() + result.stderr.toString();

    // Hyprland that cannot start at all (e.g. a headless container) never reaches the parser;
    // tolerate that only in CI, so a local run always really checks the config
    if (!output.includes('Config parsing result') && process.env.CI) {
      console.warn(`skip: Hyprland --verify-config could not run here:\n${output}`);
      return;
    }

    expect(output).toContain('config ok');
    expect(result.exitCode).toBe(0);
  });

  if (!hyprland) console.warn('skip: Hyprland is not installed, config not verified');

  test('every hyprctl dispatch in dotfiles uses the Lua hl.dsp. syntax', () => {
    const bad: string[] = [];

    for (const file of walk(DOTFILES).filter((f) => !isBinary(f))) {
      readText(file)
        .split('\n')
        .forEach((line, i) => {
          if (/hyprctl dispatch\s+(?!['"\\]*hl\.dsp\.)/.test(line)) {
            bad.push(`${relative(REPO, file)}:${i + 1}: ${line.trim()}`);
          }
        });
    }

    expect(bad).toEqual([]);
  });
});

// --- TOML ---

describe('toml', () => {
  const files = walk(DOTFILES).filter((f) => f.endsWith('.toml'));

  test('there are TOML files to check', () => {
    expect(files.length).toBeGreaterThan(0);
  });

  for (const file of files) {
    test(`${relative(DOTFILES, file)} parses`, () => {
      expect(() => Bun.TOML.parse(readText(file))).not.toThrow();
    });
  }
});

// --- Dotfiles ---

describe('dotfiles', () => {
  // A browser tab that opens the microphone must not flip Bluetooth headphones to the call profile
  test('wireplumber keeps Bluetooth headphones in A2DP', () => {
    const text = readText(
      join(DOTFILES, '.config/wireplumber/wireplumber.conf.d/51-bluetooth.conf'),
    );

    expect(text).toMatch(/^\s*bluetooth\.autoswitch-to-headset-profile = false$/m);
  });

  const files = walk(DOTFILES);

  test('no absolute /home/<user> paths (use ~ or $HOME)', () => {
    const bad = files
      .filter((f) => !isBinary(f))
      .filter((f) => /\/home\/[a-z_][a-z0-9_-]*/.test(readText(f)))
      .map((f) => relative(REPO, f));

    expect(bad).toEqual([]);
  });

  test('every script in ~/bin and waybar/scripts is executable', () => {
    const scripts = files.filter(
      (f) => f.startsWith(join(DOTFILES, 'bin/')) || f.includes('/.config/waybar/scripts/'),
    );
    const notExecutable = scripts
      .filter((f) => !(statSync(f).mode & 0o111))
      .map((f) => relative(REPO, f));

    expect(scripts.length).toBeGreaterThan(0);
    expect(notExecutable).toEqual([]);
  });

  test('only scripts (files with a #! line) are executable', () => {
    const bad = files
      .filter((f) => statSync(f).mode & 0o111)
      .filter((f) => !readText(f).startsWith('#!'))
      .map((f) => relative(REPO, f));

    expect(bad).toEqual([]);
  });

  test('hyprlock runs top under LC_ALL=C (a comma-decimal locale breaks the awk math)', () => {
    const bad = readText(join(DOTFILES, '.config/hypr/hyprlock.conf'))
      .split('\n')
      .filter((line) => /\btop -b/.test(line) && !/LC_ALL=C top -b/.test(line));

    expect(bad).toEqual([]);
  });

  test('launchers that are shown (no NoDisplay/Hidden) have a TryExec', () => {
    const dir = join(DOTFILES, '.local/share/applications');
    const bad = readdirSync(dir)
      .filter((name) => name.endsWith('.desktop'))
      .filter((name) => {
        const text = readText(join(dir, name));
        return !/^(NoDisplay|Hidden)=true$/m.test(text) && !/^TryExec=/m.test(text);
      });

    expect(bad).toEqual([]);
  });

  test('every rofi -theme X has dotfiles/.config/rofi/X.rasi', () => {
    const missing: string[] = [];
    const used: string[] = [];

    for (const file of files.filter((f) => !isBinary(f))) {
      for (const line of readText(file).split('\n')) {
        for (const match of line.matchAll(/\brofi\b[^|;&]*?\s-theme\s+["']?([\w.-]+)/g)) {
          const theme = match[1].replace(/\.rasi$/, '');
          used.push(theme);
          if (!existsSync(join(DOTFILES, '.config/rofi', `${theme}.rasi`))) {
            missing.push(`${relative(REPO, file)}: ${theme}`);
          }
        }
      }
    }

    expect(used.length).toBeGreaterThan(0);
    expect(missing).toEqual([]);
  });
});

// --- Packages ---

// Files that can't @import kanagawa.css carry copies of its values (AGENTS.md, Theming)
const PALETTE_COPIES = [
  'rofi/colors.rasi',
  'alacritty/themes/kanagawa_wave.toml',
  'hypr/theme.lua',
  'hypr/hyprlock.conf',
  'fish/conf.d/fzf.fish',
  'waybar/modules.jsonc',
  'MangoHud/MangoHud.conf',
  'gowall/config.yml',
];
// Upstream terminal black (alacritty) and the hyprlock shadow are not palette colors
const PALETTE_EXTRAS = new Set(['090618', '000000']);

describe('theme', () => {
  const css = readText(join(DOTFILES, '.config/theme/kanagawa.css'));
  const palette = new Set([...css.matchAll(/#([0-9a-f]{6})\b/gi)].map((m) => m[1].toLowerCase()));

  test('every color in the palette copies is a kanagawa.css value', () => {
    const drifted = PALETTE_COPIES.flatMap((file) => {
      const text = readText(join(DOTFILES, '.config', file));
      // #rrggbb, rgb(a)(rrggbb[aa]) and MangoHud's key=RRGGBB
      const hexes = [
        ...text.matchAll(/(?:#|rgba?\(|=\s*)([0-9a-f]{6})(?:[0-9a-f]{2})?(?![0-9a-z])/gi),
      ];
      return hexes
        .map((m) => m[1].toLowerCase())
        .filter((hex) => !palette.has(hex) && !PALETTE_EXTRAS.has(hex))
        .map((hex) => `${file}: ${hex}`);
    });

    expect(drifted).toEqual([]);
  });
});

describe('packages', () => {
  test('every list starts with a "# what this group is for" line', () => {
    const bad = listFiles.filter((name) => !/^# \S/.test(readText(join(PACKAGES, name))));

    expect(bad).toEqual([]);
  });

  test('no package is in two group lists, or in a group and conflicts.txt', () => {
    // bootstrap.txt repeats base tools on purpose: install.sh needs them before any module
    const seen = new Map<string, string>();
    const duplicates: string[] = [];

    for (const name of listFiles.filter((n) => n !== 'bootstrap.txt')) {
      for (const pkg of readPkgs(join(PACKAGES, name))) {
        const other = seen.get(pkg);
        if (other) duplicates.push(`${pkg}: ${other} and ${name}`);
        seen.set(pkg, name);
      }
    }

    expect(duplicates).toEqual([]);
  });

  describe('services.txt', () => {
    const lines = readText(join(REPO, 'installer/services.txt')).split('\n');
    const rows = lines.filter((line) => line.trim() && !line.startsWith('#'));

    test('each row is "unit scope package" with scope system or user', () => {
      const bad = rows.filter((row) => {
        const fields = row.trim().split(/\s+/);
        return (
          fields.length !== 3 ||
          !/\.(service|socket|timer|path)$/.test(fields[0]) ||
          !['system', 'user'].includes(fields[1])
        );
      });

      expect(rows.length).toBeGreaterThan(0);
      expect(bad).toEqual([]);
    });

    test('each package is in a list (or part of the base system)', () => {
      const baseSystem = new Set(['util-linux', 'systemd']);
      const unknown = rows
        .map((row) => row.trim().split(/\s+/)[2])
        .filter((pkg) => !allListedPackages.has(pkg) && !baseSystem.has(pkg));

      expect(unknown).toEqual([]);
    });

    test('columns stay aligned with the header', () => {
      // Where the scope and package columns start
      const columnStarts = (line: string) =>
        [...line.matchAll(/\S+/g)]
          .map((m) => m.index!)
          .slice(-2)
          .join();
      const header = lines.find((line) => line.startsWith('# unit'))!;
      const misaligned = rows.filter((row) => columnStarts(row) !== columnStarts(header));

      expect(misaligned).toEqual([]);
    });
  });
});
