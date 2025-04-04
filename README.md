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

### Ignite Example Application

This repository includes a complete example application called "Ignite" that demonstrates how to connect to EdgeDB/Gel from a Node.js application. The example showcases:

- Connecting to EdgeDB/Gel using environment variables
- Handling connection fallbacks and error cases
- Implementing TLS security options
- Using host.docker.internal to connect from containers
- Building a simple status dashboard

To run the example application:

```shell
# Clone the repository
git clone https://github.com/yourusername/dokku-gel.git
cd dokku-gel

# Deploy the Ignite app
./deploy-ignite.sh

# Access the application
open http://localhost:5001/
```

The application will show connection status, query results, and environment details, making it easy to verify that your EdgeDB/Gel setup is working correctly.

## Troubleshooting

- **Service won't start**: Ensure you have enough memory (2GB+) available
- **Connection issues**: Check that the service is running with `gel:info`
- **Client connection errors**: Verify that the app is properly linked with `gel:link`

## License

This plugin is released under the same license as Dokku.

## Development

### Testing Approaches

We use two methods to test this plugin:

1. **Mock Testing**: Quick testing without a full Dokku setup
2. **Integration Testing**: Complete testing with an actual Dokku installation

#### Supported Commands in Mock Testing

- ✅ `gel:create` - Create a new service
- ✅ `gel:destroy` - Delete a service
- ✅ `gel:info` - Show service details
- ✅ `gel:restart` - Restart a service
- ✅ `gel:start` - Start a service
- ✅ `gel:stop` - Stop a service
- ✅ `gel:link` - Connect service to app
- ✅ `gel:unlink` - Disconnect service from app

#### Quick Test with Mock Dokku

1. Create a simple Dokku mock:

```bash
cat > /usr/local/bin/dokku << 'EOF'
#!/bin/bash
echo "Dokku command executed: $@"
exit 0
EOF
chmod +x /usr/local/bin/dokku
```

2. Run tests:

```bash
DOKKU_BIN=/usr/local/bin/dokku PLUGIN_DATA_ROOT=/var/lib/dokku/services/gel bats tests/*.bats
```

#### Complete Test with Dokku

1. Install Dokku:

```bash
wget -NP . https://dokku.com/install/v0.35.16/bootstrap.sh
sudo DOKKU_TAG=v0.35.16 bash bootstrap.sh
```

2. Install plugin:

```bash
dokku plugin:install https://github.com/your-username/dokku-gel.git
```

3. Run tests:

```bash
cd /var/lib/dokku/plugins/gel
bats tests/*.bats
```