#!/bin/sh
# Alphaca Java preflight. Runs in the box before the agent starts; wormhole
# has already written ROLE.md into ~/.claude/CLAUDE.md, so everything here is
# best-effort extras — a failure warns and moves on, it never blocks launch.
set -eu

# Java does not read /etc/ssl/certs/ca-certificates.crt, the file
# `[access] host_ca` mounts from the host; it reads a keystore that was built
# from the box's own CA set when the image was. On a network that intercepts
# TLS that means git and wget work while Gradle and Maven cannot reach a
# repository. Alpine's p11-kit has the mounted bundle compiled in as its
# trust path, so rebuilding the keystore now picks up the host's CAs.
if [ -x /etc/ca-certificates/update.d/java-cacerts ]; then
    if /etc/ca-certificates/update.d/java-cacerts; then
        echo "[preflight] java keystore rebuilt from the host CA bundle"
    else
        echo "[preflight] WARN: java keystore rebuild failed" >&2
    fi
else
    echo "[preflight] WARN: no java-cacerts hook; java trusts the image's CAs" >&2
fi

# RTK PreToolUse hook. Telemetry disable first records consent so init skips
# that prompt; --auto-patch skips the settings prompt; </dev/null forces
# non-TTY stdin so nothing can block even if the consent record is missing.
if command -v rtk >/dev/null 2>&1; then
    rtk telemetry disable >/dev/null 2>&1 </dev/null || true
    if rtk init -g --auto-patch </dev/null; then
        echo "[preflight] rtk init done"
    else
        echo "[preflight] WARN: rtk init failed" >&2
    fi
else
    echo "[preflight] WARN: rtk binary not on PATH" >&2
fi

# Plugins. Marketplaces first, then installs; each on its own so one bad
# source does not take the rest down.
for marketplace in JuliusBrussee/caveman mattpocock/skills; do
    claude plugin marketplace add "$marketplace" </dev/null \
        || echo "[preflight] WARN: marketplace $marketplace failed" >&2
done
for plugin in \
    caveman@caveman \
    mattpocock-skills@mattpocock \
    context7@claude-plugins-official \
    jdtls-lsp@claude-plugins-official
do
    claude plugin install "$plugin" </dev/null \
        || echo "[preflight] WARN: plugin $plugin failed" >&2
done
