#!/usr/bin/env bats
# lib/log.sh: plain output without a terminal, the summary table and the rule width.

load helpers

setup() {
    setup_sandbox
}

@test "no terminal: plain ASCII, no color codes" {
    run kit 'step Packages 3 12; info note; ok done; dry "rm -rf x"; warn careful 2>&1; err broken 2>&1'

    assert_success
    assert_output "$(
        cat <<'EOF'

==> Packages  3/12
  - note
  [ok] done
  [dry] rm -rf x
  [!] careful
  [x] broken
EOF
    )"
    refute_output --partial $'\e['
}

@test "NO_COLOR forces plain output even when styling would be possible" {
    run kit 'can_style'
    assert_failure

    run kit 'banner'
    assert_output "$(printf '\n== Arch Install Kit (Hyprland, Kanagawa) ==')"
}

@test "warn and err write to stderr, info to stdout" {
    run kit 'info out 2>/dev/null; warn hidden 2>/dev/null; err hidden 2>/dev/null'

    assert_success
    assert_output "  - out"
}

@test "die prints the error and exits 1" {
    run kit 'die "no way" 2>&1; echo unreachable'

    assert_failure 1
    assert_output "  [x] no way"
}

@test "rule: the requested width, capped at 60" {
    run kit 'rule 10'
    assert_output "----------"

    run kit 'rule 100'
    assert_equal "${#output}" 60
}

@test "print_summary: one line per module and the total time" {
    run kit 'record_result preflight ok 1; record_result packages failed 42; record_result dotfiles ok 3; print_summary'

    assert_success
    assert_output "$(
        cat <<'EOF'

==> Summary
  [ok] preflight         1s
  [x]  packages         42s
  [ok] dotfiles          3s
  ------------------------
  total              46s
EOF
    )"
}
