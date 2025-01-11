import express from 'express';
import fs from 'fs';

if (!fs.existsSync('public.key')) {
    console.log('Generate keys before running the authorization server');
    process.exit(1);
}

const port = 3000;
const localUrl = `http://localhost:${port}`;
const baseUrl = process.env.BASE_URL || localUrl;
const app = express();

const publicKey = JSON.parse(fs.readFileSync('./public.key', 'ascii'));
const jwksData = {
    keys: [
        publicKey,
    ],
};

const discoveryData = {
    issuer: baseUrl,
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

app.listen(port, () => {
    console.log(`The mock authorization server is running at ${localUrl}`);
});
