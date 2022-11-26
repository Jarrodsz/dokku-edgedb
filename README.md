# dokku-edgedb

Plugin for [Edgedb][1] on dokku.

## How it works

Since edgedb can be connected only by an authenticated client (TLS certificates MUST be
present), this plugin will create an edgedb credentials file and add the
`EDGEDB_CREDENTIALS_FILE` configuration to the app. All edgedb clients can automatically
use this to connect to the edgedb server.

## Supported commands

Right now, the plugin supports only the `create`, `link`, `unlink` and `destroy` commands.

[1]: https://www.edgedb.com/
