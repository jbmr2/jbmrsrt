const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const API_PORT = 9997;
const API_HOST = '127.0.0.1';

const server = http.createServer((req, res) => {
    // Basic CORS for localhost
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    // Serve manager.html
    if (req.url === '/' || req.url === '/manager.html') {
        fs.readFile(path.join(__dirname, 'manager.html'), (err, data) => {
            if (err) {
                res.writeHead(500);
                res.end('Error loading manager.html');
                return;
            }
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(data);
        });
        return;
    }

    // Proxy API requests to MediaMTX
    if (req.url.startsWith('/api/')) {
        const targetPath = req.url.replace('/api/', '/v3/');
        
        const proxyReq = http.request({
            host: API_HOST,
            port: API_PORT,
            path: targetPath,
            method: req.method,
            headers: req.headers
        }, (proxyRes) => {
            res.writeHead(proxyRes.statusCode, proxyRes.headers);
            proxyRes.pipe(res);
        });

        proxyReq.on('error', (err) => {
            res.writeHead(502);
            res.end('MediaMTX API not reachable');
        });

        req.pipe(proxyReq);
        return;
    }

    res.writeHead(404);
    res.end('Not Found');
});

server.on('error', (err) => {
    console.error('Server error:', err.message);
    process.exit(1);
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Web interface running at http://0.0.0.0:${PORT}/`);
    console.log(`API Proxy active: /api/ -> http://${API_HOST}:${API_PORT}/v3/`);
});
