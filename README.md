# dokku-gel (EdgeDB)

Unofficial [Gel/EdgeDB](https://www.geldata.com/) plugin for dokku. This plugin provides a simplified way to run EdgeDB (Gel) instances with Dokku.

## Quick Start Guide

```shell
# Install the plugin
sudo dokku plugin:install https://github.com/ignisda/dokku-gel.git gel

# Create a Gel service
dokku gel:create mydb

# Link to your app
dokku gel:link mydb myapp

# Access the admin UI (get the URL)
dokku gel:info mydb --ui-url

# Expose the admin UI (port 10700)
dokku gel:expose mydb 10700
```

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Memory Requirements

EdgeDB/Gel requires more than 2GB of RAM to start (not just to run). If you do not have enough RAM, you'll need to create a swap file. See [How to Add Swap Space](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-20-04) for instructions.

## Installation

```shell
sudo dokku plugin:install https://github.com/ignisda/dokku-gel.git gel
```

## How It Works

Since EdgeDB/Gel can only be connected to by an authenticated client with TLS certificates, this plugin manages the credentials and properly configures your apps to connect to the database. The plugin will create a gel credentials file and add the `GEL_CREDENTIALS_FILE` configuration to your app. All gel clients can automatically use this to connect to the gel server.

## Essential Commands

| Command | Description |
|---------|-------------|
| `gel:create <service>` | Create a Gel service |
| `gel:destroy <service>` | Destroy a Gel service |
| `gel:list` | List all Gel services |
| `gel:info <service>` | Show service info (use `--ui-url` for UI URL) |
| `gel:link <service> <app>` | Link service to app |
| `gel:unlink <service> <app>` | Unlink service from app |
| `gel:expose <service> <port>` | Expose service on specified port |
| `gel:unexpose <service>` | Unexpose service |
| `gel:start <service>` | Start a service |
| `gel:stop <service>` | Stop a service |
| `gel:restart <service>` | Restart a service |
| `gel:connect <service>` | Connect to service via gel CLI |
| `gel:logs <service>` | View service logs |
| `gel:import <service>` | Import data into service |
| `gel:export <service>` | Export data from service |

## Accessing the Admin UI

EdgeDB/Gel comes with a powerful admin UI that's automatically enabled and available on port 10700. You can access it through the following steps:

1. Get the UI URL:
   ```shell
   dokku gel:info mydb --ui-url
   ```

2. Expose the UI port:
   ```shell
   dokku gel:expose mydb 10700
   ```
   
   Optionally, you can map it to a different port:
   ```shell
   dokku gel:expose mydb 8080:10700
   ```

3. Navigate to the URL in your browser

The UI provides tools for managing your database, running queries, and exploring your schema.

## Data Management

### Importing Data

```shell
dokku gel:import mydb < dump_file
```

### Exporting Data

```shell
dokku gel:export mydb > backup.dump
```

## For Developers

If you're working with EdgeDB/Gel in your application, here are the key environment variables set by this plugin:

- `GEL_CREDENTIALS_FILE`: Path to the gel credentials file
- `GEL_URL`: Connection URL for the database

In your application code, you can connect to the database using any EdgeDB client library. The client will automatically use the credentials file.

### Example Connection (JavaScript)

```javascript
import { createClient } from "edgedb";

// The client will automatically use GEL_CREDENTIALS_FILE
const client = createClient();

async function run() {
  const result = await client.query(`SELECT "Hello, EdgeDB!";`);
  console.log(result);
}

run();
```

## Development

This section covers how to set up a development environment to work on the dokku-gel plugin.

### Setting Up the Development Environment

The plugin includes a Docker-based development environment that simulates a Dokku installation:

1. **Prerequisites**:
   - Docker Desktop (for macOS/Windows) or Docker Engine (for Linux)
   - Git

2. **Clone the repository**:
   ```shell
   git clone https://github.com/yourusername/dokku-gel.git
   cd dokku-gel
   ```

3. **Set up the development container**:
   ```shell
   ./development/setup.sh
   ```
   
   This script:
   - Builds a container with Dokku dependencies
   - Mounts the plugin code to `/var/lib/dokku/plugins/dokku-gel`
   - Sets up SSH access on port 2222
   - Exposes Gel ports (5656 for the database, 10700 for the UI)

4. **Connect to the development container**:
   ```shell
   ssh -p 2222 root@localhost  # Password: dokku
   ```

### Running Tests

The plugin uses the [Bats](https://github.com/bats-core/bats-core) testing framework for unit and integration tests:

1. **Inside the development container**:
   ```shell
   cd /var/lib/dokku/plugins/dokku-gel
   
   # Run a specific test
   bats tests/service_create.bats
   
   # Run all tests
   bats tests/*.bats
   ```

2. **From your host machine**:
   ```shell
   # Run a specific test
   docker exec -it dokku-gel-dev bash -c "cd /var/lib/dokku/plugins/dokku-gel && bats tests/service_create.bats"
   
   # Run all tests
   docker exec -it dokku-gel-dev bash -c "cd /var/lib/dokku/plugins/dokku-gel && bats tests/*.bats"
   ```

### Development Workflow

1. **Make code changes** in the plugin
2. **Test your changes** using the Bats test framework
3. **Restart the plugin** if needed:
   ```shell
   docker exec -it dokku-gel-dev bash -c "cd /var/lib/dokku/plugins/dokku-gel && dokku plugin:install"
   ```
4. **Try the plugin commands** manually:
   ```shell
   docker exec -it dokku-gel-dev bash -c "dokku gel:help"
   ```

### Debugging

If you encounter issues:

1. **Check container logs**:
   ```shell
   docker logs dokku-gel-dev
   ```

2. **Inspect the plugin installation**:
   ```shell
   docker exec -it dokku-gel-dev bash -c "ls -la /var/lib/dokku/plugins/enabled"
   ```

3. **Enable debug output** by setting `DOKKU_TRACE=1`:
   ```shell
   docker exec -it dokku-gel-dev bash -c "DOKKU_TRACE=1 dokku gel:command"
   ```

### Common Issues

- **Dokku command not found**: The development container might not have Dokku properly installed or initialized
- **Plugin not found**: Check that symbolic links are correctly set up in `/var/lib/dokku/plugins/enabled`
- **Test failures**: Ensure environment variables are correctly set and that the development container has proper permissions

## Troubleshooting

- **Service won't start**: Ensure you have enough memory (2GB+) available
- **Connection issues**: Check that the service is running with `gel:info`
- **Client connection errors**: Verify that the app is properly linked with `gel:link`

## License

This plugin is released under the same license as Dokku.