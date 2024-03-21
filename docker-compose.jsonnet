local load_ledger_migrations(enable_migrations) =
    if enable_migrations then
        ["--migrations-config=/genfiles/ledger_migrations.json"]
    else
        [];

local generate_allow_addrs_flag(allow_addrs) =
    if allow_addrs then
        ["--allow-addrs=/genfiles/allow_addrs.json5"]
    else
        [];

local abci_command(i) = [
        "-v", "-v",
        "--many", "0.0.0.0:8000",
        "--many-app", "http://ledger-" + i + ":8000",
        "--many-pem", "/genfiles/abci.pem",
        "--abci", "0.0.0.0:26658",
        "--cache-db", "/persistent/abci_request_cache.db",
        "--tendermint", "http://tendermint-" + i + ":26657/"
    ];

local ledger_command(i) = [
        "-v", "-v",
        "--abci",
        "--state=/genfiles/ledger_state.json5",
        "--pem=/genfiles/ledger.pem",
        "--persistent=/persistent/ledger.db",
        "--addr=0.0.0.0:8000",
    ];

local abci_A(i, user, abci_img, allow_addrs) = {
    image: "hybrid/" + abci_img,
    ports: [ (8000 + i) + ":8000" ],
    volumes: [
        // TODO: have a volume specifically created for the cache db.
        // Right now we reuse the same volume as the ledger db.
        "./nodeA_" + i + "/persistent-ledger:/persistent",
        "./nodeA_" + i + ":/genfiles:ro"
    ],
    platform: "linux/x86_64",
    user: "" + user,
    command: abci_command(i) + generate_allow_addrs_flag(allow_addrs),
    depends_on: [ "ledger-" + i ],
    cap_add: ["NET_ADMIN"],
};

local ledger_A(i, user, ledger_img, enable_migrations) = {
    image: "hybrid/" + ledger_img,
    user: "" + user,
    volumes: [
        "./nodeA_" + i + "/persistent-ledger:/persistent",
        "./nodeA_" + i + ":/genfiles:ro",
    ],
    platform: "linux/x86_64",
    command: ledger_command(i) + load_ledger_migrations(enable_migrations),
    cap_add: ["NET_ADMIN"],
};

local generate_tm_command(i, tendermint_tag) =
	if std.length(std.findSubstr("0.35", tendermint_tag)) > 0 then
		[
        "--log-level", "info",
        "start",
        "--rpc.laddr", "tcp://0.0.0.0:26657",
        "--proxy-app", "tcp://abci-" + i + ":26658",
        ]
    else if std.length(std.findSubstr("0.34", tendermint_tag)) > 0 then
       [
        "start",
        "--rpc.laddr", "tcp://0.0.0.0:26657",
        "--proxy_app", "tcp://abci-" + i + ":26658",
        ]
    else
        std.assertEqual(true, false);

local tendermint(i, type="", user, tendermint_tag) = {
    image: tendermint_tag,
    command: generate_tm_command(i, tendermint_tag),
    user: "" + user,
    volumes: [
        "./node" + type + "_" + i + "/tendermint/:/tendermint"
    ],
    ports: [ "" + (26600 + i) + ":26657" ],
    cap_add: ["NET_ADMIN"],
};

function(NB_NODES_A=4,
		 user=1000,
		 tendermint_A_tag="",
		 allow_addrs=false,
		 enable_migrations_A=false) {
    version: '3',
    services: {
        ["abci-" + i]: abci_A(i, user, "many-abci-a", allow_addrs) for i in std.range(1, NB_NODES_A )
    } + {
        ["ledger-" + i]: ledger_A(i, user, "many-ledger-a", enable_migrations_A) for i in std.range(1, NB_NODES_A)
    } + {
        ["tendermint-" + i]: tendermint(i, "A", user, tendermint_A_tag) for i in std.range(1, NB_NODES_A)
    },
}
