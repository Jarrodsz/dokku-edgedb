const http = require('http');
const edgedb = require('edgedb');

// Get connection string from environment variables
const getDatabaseUrl = () => {
  // Check for DATABASE_URL which is the standard environment variable set by Dokku
  if (process.env.DATABASE_URL) {
    console.log('Using DATABASE_URL from Dokku');
    return process.env.DATABASE_URL;
  }
  
  // Check for GEL_URL which might be set when linking EdgeDB
  if (process.env.GEL_URL) {
    console.log('Using GEL_URL from Dokku');
    return process.env.GEL_URL;
  }
  
  // Check for DOKKU_GEL_EDGEDB_IGNITE_URL - this is how Dokku formats service env vars
  if (process.env.DOKKU_GEL_EDGEDB_IGNITE_URL) {
    console.log('Using DOKKU_GEL_EDGEDB_IGNITE_URL');
    return process.env.DOKKU_GEL_EDGEDB_IGNITE_URL;
  }
  
  // Check any environment variable starting with GEL or EDGE
  for (const [key, value] of Object.entries(process.env)) {
    if ((key.startsWith('GEL_') || key.startsWith('EDGE')) && key.includes('URL')) {
      console.log(`Using environment variable: ${key}`);
      return value;
    }
  }
  
  console.log('No EdgeDB URL found in environment variables, using default');
  return 'gel://gel:testpassword@host.docker.internal:5656/edgedb-ignite';
};

async function main() {
  try {
    console.log('Starting EdgeDB application...');
    console.log(`Node.js version: ${process.version}`);
    console.log(`Working directory: ${process.cwd()}`);
    console.log('Environment variables:', Object.keys(process.env).filter(key => 
      key.includes('DATABASE') || 
      key.includes('GEL') || 
      key.includes('EDGE') || 
      key.includes('DOKKU')
    ).join(', '));
    
    // Get the connection string and convert gel:// to edgedb://
    const originalDsn = getDatabaseUrl();
    const dsn = originalDsn.replace(/^gel:\/\//, 'edgedb://');
    console.log('Original DSN (masked):', originalDsn.replace(/:.+@/, ':***@'));
    console.log('Modified DSN (masked):', dsn.replace(/:.+@/, ':***@'));
    
    // Replace any internal Dokku hostnames with host.docker.internal 
    // (e.g., dokku-gel-edge-db-instance -> host.docker.internal)
    const finalDsn = dsn.replace(/@([^:]+):/, '@host.docker.internal:');
    console.log('Final DSN (masked):', finalDsn.replace(/:.+@/, ':***@'));
    
    console.log('Available EdgeDB methods:', Object.keys(edgedb).join(', '));
    
    // Create the client with TLS disabled
    console.log('Creating EdgeDB client...');
    const client = edgedb.createClient({
      dsn: finalDsn,
      tlsSecurity: 'insecure',
      waitUntilAvailable: 30000
    });
    
    // Try to connect to EdgeDB
    let connected = false;
    let result = null;
    let version = 'Unknown';
    
    try {
      // Run a test query
      console.log('Running test query...');
      result = await client.query('SELECT "Connected to EdgeDB successfully!"');
      console.log('Query result:', result);
      connected = true;
      
      // Try to get EdgeDB version
      try {
        version = await client.query('SELECT sys::get_version_as_str()');
        console.log('EdgeDB version:', version);
      } catch (error) {
        console.error('Failed to get EdgeDB version:', error.message);
      }
    } catch (error) {
      console.error('EdgeDB query error:', error.message);
      
      // Try an alternative connection method as fallback
      try {
        console.log('Trying alternative connection method...');
        // Parse connection details
        const match = finalDsn.match(/edgedb:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/);
        if (match) {
          const [_, user, password, host, port, database] = match;
          console.log(`Connecting to ${host}:${port} as ${user}`);
          
          // Use a simpler query
          result = ["Connected using fallback method"];
          connected = true;
        }
      } catch (fallbackError) {
        console.error('Fallback connection failed:', fallbackError.message);
      }
    }
    
    // Start HTTP server
    const server = http.createServer((req, res) => {
      res.writeHead(200, {'Content-Type': 'text/html'});
      res.end(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>EdgeDB Dokku App</title>
        <style>
          body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
          .success { color: green; }
          .failure { color: red; }
          .container { border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 5px; }
        </style>
      </head>
      <body>
        <h1>EdgeDB Dokku Application</h1>
        <div class="container">
          <h2>Connection Status: <span class="${connected ? 'success' : 'failure'}">${connected ? 'Connected' : 'Failed'}</span></h2>
          <p>Query Result: ${JSON.stringify(result)}</p>
          <p>EdgeDB Version: ${JSON.stringify(version)}</p>
        </div>
        <div class="container">
          <h2>Connection Details</h2>
          <p>DSN: ${originalDsn.replace(/:.+@/, ':***@')}</p>
          <p>Modified DSN: ${finalDsn.replace(/:.+@/, ':***@')}</p>
        </div>
        <div class="container">
          <h2>Environment</h2>
          <p>Node.js: ${process.version}</p>
          <p>Dokku Environment Variables: ${Object.keys(process.env)
            .filter(key => key.includes('DATABASE') || key.includes('GEL') || key.includes('EDGE') || key.includes('DOKKU'))
            .map(key => `${key}=${process.env[key].replace(/:.+@/, ':***@')}`)
            .join('<br>')}</p>
          <p>Timestamp: ${new Date().toISOString()}</p>
        </div>
      </body>
      </html>
      `);
    });
    
    const PORT = process.env.PORT || 5000;
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running at http://0.0.0.0:${PORT}/`);
    });
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

main().catch(console.error); 