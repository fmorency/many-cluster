# MANY Cluster

Simple way of spawning a MANY cluster.

Based on [a-vs-b](https://github.com/liftedinit/a-vs-b)

## Requirements

- docker
- docker-compose
- jq
- bash
- GNU make
- coreutils

## Quick start

Place the binaries the `a-bins` folder. E.g.

```bash
a-bins
├── (optional) abci_migrations.json
├── (optional) ledger_migrations.json
├── many-abci
└── many-ledger
```

Run

```bash
# Use `make start-nodes-background` instead to start cluster detached from the terminal
$ make start-nodes
```

to run a 4 nodes cluster, where the default is to run 4 nodes on TM 0.34

### Custom number of nodes

The number of nodes running can be modified by setting the `NB_NODES_A` variable.

E.g.
```bash
# Start a cluster with 8 nodes
$ make NB_NODES_A=8 start-nodes
```

## Clean

Run the following to remove all generated files and docker containers

```bash
$ make clean
```

NOTE: This command will NOT remove the generated `hybrid/*` Docker images
