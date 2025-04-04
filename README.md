# dokku gel

Unofficial gel plugin for dokku. Currently defaults to installing [gel/gel:6.2](https://hub.docker.com/r/gel/gel/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## How it works

Since gel can be connected only by an authenticated client (TLS certificates MUST be
present), this plugin will create a gel credentials file and add the
`GEL_CREDENTIALS_FILE` configuration to the app. All gel clients can automatically
use this to connect to the gel server.

## Important notes

- The gel server usually requires more than 2GB of RAM to _**start**_ (not run). If you do not have
  enough RAM, you will have to create a swap file. Please refer to tutorials online on how to
  do this.

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/ignisda/dokku-gel.git gel
```

## Commands

```
gel:app-links <app>                             # list all Gel service links for a given app
gel:backup <service> <bucket-name> [--use-iam]  # create a backup of the Gel service to an existing s3 bucket
gel:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # set up authentication for backups on the Gel service
gel:backup-deauth <service>                     # remove backup authentication for the Gel service
gel:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedule a backup of the Gel service
gel:backup-schedule-cat <service>               # cat the contents of the configured backup cronfile for the service
gel:backup-set-encryption <service> <passphrase> # set encryption for all future backups of Gel service
gel:backup-unschedule <service>                 # unschedule the backup of the Gel service
gel:backup-unset-encryption <service>           # unset encryption for future backups of the Gel service
gel:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
gel:connect <service>                           # connect to the service via the gel connection tool
gel:create <service> [--create-flags...]        # create a Gel service
gel:destroy <service> [-f|--force]              # delete the Gel service/data/container if there are no links left
gel:enter <service>                             # enter or run a command in a running Gel service container
gel:exists <service>                            # check if the Gel service exists
gel:export <service>                            # export a dump of the Gel service database
gel:expose <service> <ports...>                 # expose a Gel service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
gel:import <service>                            # import a dump into the Gel service database
gel:info <service> [--single-info-flag]         # print the service information
gel:link <service> <app> [--link-flags...]      # link the Gel service to the app
gel:linked <service> <app>                      # check if the Gel service is linked to an app
gel:links <service>                             # list all apps linked to the Gel service
gel:list                                        # list all Gel services
gel:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
gel:pause <service>                             # pause a running Gel service
gel:promote <service> <app>                     # promote service <service> as GEL_URL in <app>
gel:restart <service>                           # graceful shutdown and restart of the Gel service container
gel:start <service>                             # start a previously stopped Gel service
gel:stop <service>                              # stop a running Gel service
gel:unexpose <service>                          # unexpose a previously exposed Gel service
gel:unlink <service> <app>                      # unlink the Gel service from the app
gel:upgrade <service> [--upgrade-flags...]      # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to gel:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `gel:help` command for any undocumented commands.

### Basic Usage

### create a Gel service

```shell
# usage
dokku gel:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password
- `-s|--shm-size SHM_SIZE`: override shared memory size for gel docker container

Create a Gel service named lollipop:

```shell
dokku gel:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the gel/gel image.

```shell
export GEL_IMAGE="gel/gel"
export GEL_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku gel:create lollipop
```

You can also specify custom environment variables to start the Gel service in semi-colon separated form.

```shell
export GEL_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku gel:create lollipop
```

### print the service information

```shell
# usage
dokku gel:info <service> [--single-info-flag]
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
- `--ui-url`: show the service UI URL
Get connection information as follows:

```shell
dokku gel:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku gel:info lollipop --config-dir
dokku gel:info lollipop --data-dir
dokku gel:info lollipop --dsn
dokku gel:info lollipop --exposed-ports
dokku gel:info lollipop --id
dokku gel:info lollipop --internal-ip
dokku gel:info lollipop --links
dokku gel:info lollipop --service-root
dokku gel:info lollipop --status
dokku gel:info lollipop --version
```

### list all Gel services

```shell
# usage
dokku gel:list 
```

List all services:

```shell
dokku gel:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku gel:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku gel:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku gel:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku gel:logs lollipop --tail 5
```

### access the GEL UI

The GEL UI is automatically enabled and available on port 10700. You can access it via the `--ui-url` info flag:

```shell
dokku gel:info lollipop --ui-url
```

By exposing this port, you can access the GEL UI in your browser:

```shell
dokku gel:expose lollipop 5656 10700
```

The UI provides a visual interface for managing your GEL database, running queries, and exploring your schema.

### link the Gel service to the app

```shell
# usage
dokku gel:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A Gel service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku gel:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won't be listed when calling dokku config):

```
DOKKU_GEL_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_GEL_LOLLIPOP_PORT=tcp://172.17.0.1:5656
DOKKU_GEL_LOLLIPOP_PORT_5656_TCP=tcp://172.17.0.1:5656
DOKKU_GEL_LOLLIPOP_PORT_5656_TCP_PROTO=tcp
DOKKU_GEL_LOLLIPOP_PORT_5656_TCP_PORT=5656
DOKKU_GEL_LOLLIPOP_PORT_5656_TCP_ADDR=172.17.0.1
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku gel:link other_service playground
```

It is possible to change the protocol for `GEL_URL` by setting the environment variable `GEL_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground GEL_DATABASE_SCHEME=gel2
dokku gel:link lollipop playground
```

### unlink the Gel service from the app

```shell
# usage
dokku gel:unlink <service> <app>
```

You can unlink a Gel service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku gel:unlink lollipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the gel connection tool

```shell
# usage
dokku gel:connect <service>
```

Connect to the service via the gel connection tool:

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku gel:connect lollipop
```

### enter or run a command in a running Gel service container

```shell
# usage
dokku gel:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku gel:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku gel:enter lollipop touch /tmp/test
```

### expose a Gel service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku gel:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku gel:expose lollipop 5656
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku gel:expose lollipop 127.0.0.1:5656
```

### unexpose a previously exposed Gel service

```shell
# usage
dokku gel:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku gel:unexpose lollipop
```

### promote service <service> as GEL_URL in <app>

```shell
# usage
dokku gel:promote <service> <app>
```

If you have a Gel service linked to an app and try to link another Gel service another link environment variable will be generated automatically:

```
DOKKU_GEL_BLUE_URL=gel://other_service:ANOTHER_PASSWORD@dokku-gel-other-service:5656/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku gel:promote other_service playground
```

This will replace `GEL_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
GEL_URL=gel://other_service:ANOTHER_PASSWORD@dokku-gel-other-service:5656/other_service
DOKKU_GEL_BLUE_URL=gel://other_service:ANOTHER_PASSWORD@dokku-gel-other-service:5656/other_service
DOKKU_GEL_SILVER_URL=gel://lollipop:SOME_PASSWORD@dokku-gel-lollipop:5656/lollipop
```

### start a previously stopped Gel service

```shell
# usage
dokku gel:start <service>
```

Start the service:

```shell
dokku gel:start lollipop
```

### stop a running Gel service

```shell
# usage
dokku gel:stop <service>
```

Stop the service and removes the running container:

```shell
dokku gel:stop lollipop
```

### pause a running Gel service

```shell
# usage
dokku gel:pause <service>
```

Pause the running container for the service:

```shell
dokku gel:pause lollipop
```

### graceful shutdown and restart of the Gel service container

```shell
# usage
dokku gel:restart <service>
```

Restart the service:

```shell
dokku gel:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku gel:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart
- `-s|--shm-size SHM_SIZE`: override shared memory size for gel docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku gel:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all Gel service links for a given app

```shell
# usage
dokku gel:app-links <app>
```

List all Gel services that are linked to the `playground` app.

```shell
dokku gel:app-links playground
```

### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku gel:clone <service> <new-service> [--clone-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password
- `-s|--shm-size SHM_SIZE`: override shared memory size for gel docker container

You can clone an existing service to a new one:

```shell
dokku gel:clone lollipop lollipop-2
```

### check if the Gel service exists

```shell
# usage
dokku gel:exists <service>
```

Here we check if the lollipop Gel service exists.

```shell
dokku gel:exists lollipop
```

### check if the Gel service is linked to an app

```shell
# usage
dokku gel:linked <service> <app>
```

Here we check if the lollipop Gel service is linked to the `playground` app.

```shell
dokku gel:linked lollipop playground
```

### list all apps linked to the Gel service

```shell
# usage
dokku gel:links <service>
```

List all apps linked to the `lollipop` Gel service.

```shell
dokku gel:links lollipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the Gel service database

```shell
# usage
dokku gel:import <service>
```

Import a datastore dump:

```shell
dokku gel:import lollipop /tmp/data.dump
```

### export a dump of the Gel service database

```shell
# usage
dokku gel:export <service>
```

By default, datastore output is exported to stdout:

```shell
dokku gel:export lollipop
```

You can redirect this output to a file:

```shell
dokku gel:export lollipop > data.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### set up authentication for backups on the Gel service

```shell
# usage
dokku gel:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

```shell
dokku gel:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku gel:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku gel:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku gel:backup-auth lollipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

### remove backup authentication for the Gel service

```shell
# usage
dokku gel:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku gel:backup-deauth lollipop
```

### create a backup of the Gel service to an existing s3 bucket

```shell
# usage
dokku gel:backup <service> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Backup the `lollipop` service to the `my-s3-bucket` bucket on `AWS`:`

```shell
dokku gel:backup lollipop my-s3-bucket --use-iam
```

Restore a backup file (assuming it was extracted via `tar -xf backup.tgz`):

```shell
dokku gel:import lollipop < backup-folder/export
```

### set encryption for all future backups of Gel service

```shell
# usage
dokku gel:backup-set-encryption <service> <passphrase>
```

Set the GPG-compatible passphrase for encrypting backups for backups:

```shell
dokku gel:backup-set-encryption lollipop
```

### unset encryption for future backups of the Gel service

```shell
# usage
dokku gel:backup-unset-encryption <service>
```

Unset the `GPG` encryption passphrase for backups:

```shell
dokku gel:backup-unset-encryption lollipop
```

### schedule a backup of the Gel service

```shell
# usage
dokku gel:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku gel:backup-schedule lollipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku gel:backup-schedule lollipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku gel:backup-schedule-cat <service>
```

Cat the contents of the configured backup cronfile for the service:

```shell
dokku gel:backup-schedule-cat lollipop
```

### unschedule the backup of the Gel service

```shell
# usage
dokku gel:backup-unschedule <service>
```

Remove the scheduled backup from cron:

```shell
dokku gel:backup-unschedule lollipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `GEL_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.