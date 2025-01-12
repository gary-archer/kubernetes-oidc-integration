import express from 'express';
import fs from 'fs';
import https from 'https'

if (!fs.existsSync('crypto/token-signing-public.jwk')) {
    console.log('Generate token signing keys before running the authorization server');
    process.exit(1);
}
if (!fs.existsSync('crypto/internal-ssl.key')) {
    console.log('Generate SSL certificates before running the authorization server');
    process.exit(1);
}

const port = 8443;
const baseUrl = `https://mockauthorizationserver.identity.svc:${port}`;
const app = express();

const publicKey = JSON.parse(fs.readFileSync('./crypto/token-signing-public.jwk', 'ascii'));
const jwksData = {
    keys: [
        publicKey,
    ],
};

const discoveryData = {
    issuer: 'https://login.test.example',
    jwks_uri: `${baseUrl}/jwks`,
};

/*
 * Provide the discovery endpoint that the Kubernetes API server calls
 */
app.get('/.well-known/openid-configuration', (request, response) => {
    response.setHeader('content-type', 'application/json');
    response.status(200).send(JSON.stringify(discoveryData, null, 2));
});

/*
 * Provide a JWKS URI so that the Kubernetes API server can get token signing public keys to verify ID tokens
 */
app.get('/jwks', (request, response) => {
    response.setHeader('content-type', 'application/json');
    response.status(200).send(JSON.stringify(jwksData, null, 2));
});

const sslOptions = {
    key: fs.readFileSync('./crypto/internal-ssl.key'),
    cert: fs.readFileSync('./crypto/internal-ssl.crt'),
};

const httpsServer = https.createServer(sslOptions, app);
httpsServer.listen(port, () => {
    console.log(`The mock authorization server is running at ${baseUrl}`);
});
