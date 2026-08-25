# alphaca-java

A [wormhole](https://github.com/naborka/wormhole) role: the chief-staff-engineer
persona in a box carrying a JVM toolchain — JDK 21 and 17, Gradle, Maven and
Eclipse JDT.LS.

It is the same persona as wormhole's own `alphaca` role, with a different
toolchain. The persona text is repeated here rather than shared, because a
manifest names one instructions file and wormhole cannot compose two.

## Install

```sh
wormhole role add \
  git@github.com:naborka/wormhole-alphaca-java@<commit sha> \
  --as alphaca-java
```

wormhole fetches that exact commit, shows you everything the role asks for —
grants, environment, and every line of shell its image is built by — and asks
before anything runs. `--as` is what gives it the short name; without it the
role is called after the repository. Then, in any workspace:

```sh
wormhole box --role alphaca-java
```

A role is pinned to a commit and never to a branch. To move to a newer one,
run `role add` again with the new sha: wormhole shows what changed and asks
again.

## What is in it

| | |
|---|---|
| `wormhole.toml` | the recipe: image, agent, access, environment |
| `ROLE.md` | the persona, named by `[agent] instructions` |
| `hooks/preflight.sh` | run inside the box before the agent starts |

Read `wormhole.toml` before installing. Every grant in it is a path on *your*
machine that this box will be able to read.
