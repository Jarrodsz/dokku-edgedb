# dokku edgedb

Official edgedb plugin for dokku. Currently defaults to installing [edgedb/edgedb 2.11](https://hub.docker.com/r/edgedb/edgedb/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## How it works

Since edgedb can be connected only by an authenticated client (TLS certificates MUST be
present), this plugin will create an edgedb credentials file and add the
`EDGEDB_CREDENTIALS_FILE` configuration to the app. All edgedb clients can automatically
use this to connect to the edgedb server.

## Important notes

- The edgedb server usually requires more than 2GB of RAM to _**start**_ (not run). If you do not have
  enough RAM, you will have to create a swap file. Please refer to tutorials online on how to
  do this.

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/ignisda/dokku-edgedb.git edgedb
```

## Commands

```
edgedb:app-links <app>                             # list all edgedb service links for a given app
edgedb:backup <service> <bucket-name> [--use-iam]  # create a backup of the edgedb service to an existing s3 bucket
edgedb:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # set up authentication for backups on the edgedb service
edgedb:backup-deauth <service>                     # remove backup authentication for the edgedb service
edgedb:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedule a backup of the edgedb service
edgedb:backup-schedule-cat <service>               # cat the contents of the configured backup cronfile for the service
edgedb:backup-set-encryption <service> <passphrase> # set encryption for all future backups of edgedb service
edgedb:backup-unschedule <service>                 # unschedule the backup of the edgedb service
edgedb:backup-unset-encryption <service>           # unset encryption for future backups of the edgedb service
edgedb:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
edgedb:connect <service>                           # connect to the service via the edgedb connection tool
edgedb:create <service> [--create-flags...]        # create a edgedb service
edgedb:destroy <service> [-f|--force]              # delete the edgedb service/data/container if there are no links left
edgedb:enter <service>                             # enter or run a command in a running edgedb service container
edgedb:exists <service>                            # check if the edgedb service exists
edgedb:export <service>                            # export a dump of the edgedb service database
edgedb:expose <service> <ports...>                 # expose a edgedb service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
edgedb:import <service>                            # import a dump into the edgedb service database
edgedb:info <service> [--single-info-flag]         # print the service information
edgedb:link <service> <app> [--link-flags...]      # link the edgedb service to the app
edgedb:linked <service> <app>                      # check if the edgedb service is linked to an app
edgedb:links <service>                             # list all apps linked to the edgedb service
edgedb:list                                        # list all edgedb services
edgedb:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
edgedb:pause <service>                             # pause a running edgedb service
edgedb:promote <service> <app>                     # promote service <service> as EDGEDB_URL in <app>
edgedb:restart <service>                           # graceful shutdown and restart of the edgedb service container
edgedb:start <service>                             # start a previously stopped edgedb service
edgedb:stop <service>                              # stop a running edgedb service
edgedb:unexpose <service>                          # unexpose a previously exposed edgedb service
edgedb:unlink <service> <app>                      # unlink the edgedb service from the app
edgedb:upgrade <service> [--upgrade-flags...]      # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to edgedb:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `edgedb:help` command for any undocumented commands.

### Basic Usage

### create a edgedb service

```shell
# usage
dokku edgedb:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password
- `-s|--shm-size SHM_SIZE`: override shared memory size for edgedb docker container

Create a edgedb service named lollipop:

```shell
dokku edgedb:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the edgedb/edgedb image.

```shell
export EDGEDB_IMAGE="edgedb/edgedb"
export EDGEDB_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku edgedb:create lollipop
```

You can also specify custom environment variables to start the edgedb service in semi-colon separated form.

```shell
export EDGEDB_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku edgedb:create lollipop
```

### print the service information

```shell
# usage
dokku edgedb:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku edgedb:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku edgedb:info lollipop --config-dir
dokku edgedb:info lollipop --data-dir
dokku edgedb:info lollipop --dsn
dokku edgedb:info lollipop --exposed-ports
dokku edgedb:info lollipop --id
dokku edgedb:info lollipop --internal-ip
dokku edgedb:info lollipop --links
dokku edgedb:info lollipop --service-root
dokku edgedb:info lollipop --status
dokku edgedb:info lollipop --version
```

### list all edgedb services

```shell
# usage
dokku edgedb:list 
```

List all services:

```shell
dokku edgedb:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku edgedb:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku edgedb:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku edgedb:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku edgedb:logs lollipop --tail 5
```

### link the edgedb service to the app

```shell
# usage
dokku edgedb:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A edgedb service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku edgedb:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_EDGEDB_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_EDGEDB_LOLLIPOP_PORT=tcp://172.17.0.1:5656
DOKKU_EDGEDB_LOLLIPOP_PORT_5656_TCP=tcp://172.17.0.1:5656
DOKKU_EDGEDB_LOLLIPOP_PORT_5656_TCP_PROTO=tcp
DOKKU_EDGEDB_LOLLIPOP_PORT_5656_TCP_PORT=5656
DOKKU_EDGEDB_LOLLIPOP_PORT_5656_TCP_ADDR=172.17.0.1
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku edgedb:link other_service playground
```

It is possible to change the protocol for `EDGEDB_URL` by setting the environment variable `EDGEDB_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground EDGEDB_DATABASE_SCHEME=edgedb2
dokku edgedb:link lollipop playground
```

### unlink the edgedb service from the app

```shell
# usage
dokku edgedb:unlink <service> <app>
```

You can unlink a edgedb service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku edgedb:unlink lollipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the edgedb connection tool

```shell
# usage
dokku edgedb:connect <service>
```

Connect to the service via the edgedb connection tool:

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku edgedb:connect lollipop
```

### enter or run a command in a running edgedb service container

```shell
# usage
dokku edgedb:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku edgedb:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku edgedb:enter lollipop touch /tmp/test
```

### expose a edgedb service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku edgedb:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku edgedb:expose lollipop 5656
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku edgedb:expose lollipop 127.0.0.1:5656
```

### unexpose a previously exposed edgedb service

```shell
# usage
dokku edgedb:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku edgedb:unexpose lollipop
```

### promote service <service> as EDGEDB_URL in <app>

```shell
# usage
dokku edgedb:promote <service> <app>
```

If you have a edgedb service linked to an app and try to link another edgedb service another link environment variable will be generated automatically:

```
DOKKU_EDGEDB_BLUE_URL=edgedb://other_service:ANOTHER_PASSWORD@dokku-edgedb-other-service:5656/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku edgedb:promote other_service playground
```

This will replace `EDGEDB_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
EDGEDB_URL=edgedb://other_service:ANOTHER_PASSWORD@dokku-edgedb-other-service:5656/other_service
DOKKU_EDGEDB_BLUE_URL=edgedb://other_service:ANOTHER_PASSWORD@dokku-edgedb-other-service:5656/other_service
DOKKU_EDGEDB_SILVER_URL=edgedb://lollipop:SOME_PASSWORD@dokku-edgedb-lollipop:5656/lollipop
```

### start a previously stopped edgedb service

```shell
# usage
dokku edgedb:start <service>
```

Start the service:

```shell
dokku edgedb:start lollipop
```

### stop a running edgedb service

```shell
# usage
dokku edgedb:stop <service>
```

Stop the service and removes the running container:

```shell
dokku edgedb:stop lollipop
```

### pause a running edgedb service

```shell
# usage
dokku edgedb:pause <service>
```

Pause the running container for the service:

```shell
dokku edgedb:pause lollipop
```

### graceful shutdown and restart of the edgedb service container

```shell
# usage
dokku edgedb:restart <service>
```

Restart the service:

```shell
dokku edgedb:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku edgedb:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart
- `-s|--shm-size SHM_SIZE`: override shared memory size for edgedb docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku edgedb:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all edgedb service links for a given app

```shell
# usage
dokku edgedb:app-links <app>
```

List all edgedb services that are linked to the `playground` app.

```shell
dokku edgedb:app-links playground
```

### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku edgedb:clone <service> <new-service> [--clone-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password
- `-s|--shm-size SHM_SIZE`: override shared memory size for edgedb docker container

You can clone an existing service to a new one:

```shell
dokku edgedb:clone lollipop lollipop-2
```

### check if the edgedb service exists

```shell
# usage
dokku edgedb:exists <service>
```

Here we check if the lollipop edgedb service exists.

```shell
dokku edgedb:exists lollipop
```

### check if the edgedb service is linked to an app

```shell
# usage
dokku edgedb:linked <service> <app>
```

Here we check if the lollipop edgedb service is linked to the `playground` app.

```shell
dokku edgedb:linked lollipop playground
```

### list all apps linked to the edgedb service

```shell
# usage
dokku edgedb:links <service>
```

List all apps linked to the `lollipop` edgedb service.

```shell
dokku edgedb:links lollipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the edgedb service database

```shell
# usage
dokku edgedb:import <service>
```

Import a datastore dump:

```shell
dokku edgedb:import lollipop < data.dump
```

### export a dump of the edgedb service database

```shell
# usage
dokku edgedb:export <service>
```

By default, datastore output is exported to stdout:

```shell
dokku edgedb:export lollipop
```

You can redirect this output to a file:

```shell
dokku edgedb:export lollipop > data.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### set up authentication for backups on the edgedb service

```shell
# usage
dokku edgedb:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

```shell
dokku edgedb:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku edgedb:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku edgedb:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku edgedb:backup-auth lollipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

### remove backup authentication for the edgedb service

```shell
# usage
dokku edgedb:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku edgedb:backup-deauth lollipop
```

### create a backup of the edgedb service to an existing s3 bucket

```shell
# usage
dokku edgedb:backup <service> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Backup the `lollipop` service to the `my-s3-bucket` bucket on `AWS`:`

```shell
dokku edgedb:backup lollipop my-s3-bucket --use-iam
```

Restore a backup file (assuming it was extracted via `tar -xf backup.tgz`):

```shell
dokku edgedb:import lollipop < backup-folder/export
```

### set encryption for all future backups of edgedb service

```shell
# usage
dokku edgedb:backup-set-encryption <service> <passphrase>
```

Set the GPG-compatible passphrase for encrypting backups for backups:

```shell
dokku edgedb:backup-set-encryption lollipop
```

### unset encryption for future backups of the edgedb service

```shell
# usage
dokku edgedb:backup-unset-encryption <service>
```

Unset the `GPG` encryption passphrase for backups:

```shell
dokku edgedb:backup-unset-encryption lollipop
```

### schedule a backup of the edgedb service

```shell
# usage
dokku edgedb:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku edgedb:backup-schedule lollipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku edgedb:backup-schedule lollipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku edgedb:backup-schedule-cat <service>
```

Cat the contents of the configured backup cronfile for the service:

```shell
dokku edgedb:backup-schedule-cat lollipop
```

### unschedule the backup of the edgedb service

```shell
# usage
dokku edgedb:backup-unschedule <service>
```

Remove the scheduled backup from cron:

```shell
dokku edgedb:backup-unschedule lollipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `EDGEDB_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
