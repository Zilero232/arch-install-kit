// The INCY polkit rule, run against a stub of polkit's JavaScript API.
import { describe, expect, test } from 'bun:test';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

type Rule = (action: unknown, subject: unknown) => string;

const RULE_FILE = join(import.meta.dir, '..', 'etc/polkit-1/rules.d/50-incy.rules');
const HELPER = '/usr/lib/incy/incy-helper-linux.sh';
const HELPER_REAL = '/opt/incy/lib/app/resources/bin/incy-helper-linux.sh';
const XRAY = '/opt/incy/lib/app/resources/bin/xray';

// Loads the rule file the way polkitd does: polkit.addRule registers the function
function loadRule(): Rule {
  let rule: Rule | undefined;
  const polkit = {
    Result: { YES: 'yes', NOT_HANDLED: 'not_handled' },
    addRule: (fn: Rule) => {
      rule = fn;
    },
    log: () => {},
  };
  new Function('polkit', readFileSync(RULE_FILE, 'utf8'))(polkit);
  if (!rule) throw new Error('the rule file registered no rule');
  return rule;
}

const rule = loadRule();
const user = { local: true, active: true, isInGroup: (group: string) => group === 'wheel' };

function ask(id: string, details: Record<string, string>, subject = user): string {
  return rule({ id, lookup: (key: string) => details[key] }, subject);
}

const start = `start-xray-tun ${XRAY} /var/tmp/incy-xray/config.json /var/tmp/incy-xray/pid /var/tmp/incy-xray/xray.log /var/tmp/incy-xray/geo tun_incy`;

describe('INCY polkit rule', () => {
  test('allows the INCY action for the real helper calls', () => {
    expect(ask('cc.incy.vpn.run-helper', { command_line: `${HELPER} ${start}` })).toBe('yes');
    expect(
      ask('cc.incy.vpn.run-helper', {
        command_line: `${HELPER} setup-routes-dns tun_incy 8888 100 198.18.0.2`,
      }),
    ).toBe('yes');
  });

  test('allows the generic pkexec action when the program is the resolved helper', () => {
    expect(
      ask('org.freedesktop.policykit.exec', {
        program: HELPER_REAL,
        command_line: `${HELPER} ${start}`,
      }),
    ).toBe('yes');
  });

  test('ignores the generic pkexec action for any other program', () => {
    expect(
      ask('org.freedesktop.policykit.exec', {
        program: '/usr/bin/bash',
        command_line: `${HELPER} ${start}`,
      }),
    ).toBe('not_handled');
  });

  test('refuses a different binary, paths outside the state dir and traversal', () => {
    expect(
      ask('cc.incy.vpn.run-helper', {
        command_line: `${HELPER} start-xray-tun /home/me/evil /var/tmp/incy-xray/c`,
      }),
    ).toBe('not_handled');
    expect(
      ask('cc.incy.vpn.run-helper', {
        command_line: `${HELPER} start-xray-tun ${XRAY} /var/tmp/incy-xray/c /etc/shadow`,
      }),
    ).toBe('not_handled');
    expect(
      ask('cc.incy.vpn.run-helper', {
        command_line: `${HELPER} teardown x 1 1 /var/tmp/incy-xray/../../etc/shadow`,
      }),
    ).toBe('not_handled');
  });

  test('asks for the password outside an active local wheel session', () => {
    const inactive = { ...user, active: false };
    expect(ask('cc.incy.vpn.run-helper', { command_line: `${HELPER} ${start}` }, inactive)).toBe(
      'not_handled',
    );
  });

  test('keeps no debug logging', () => {
    expect(readFileSync(RULE_FILE, 'utf8')).not.toContain('polkit.log');
  });
});
