import express from 'express';
import fs from 'fs';

if (!fs.existsSync('token-signing-keys/public.jwk')) {
    console.log('Generate token signing keys before running the authorization server');
    process.exit(1);
}

const externalBaseUrl = `https://login.test.example`;
const app = express();

const publicKey = JSON.parse(fs.readFileSync('token-signing-keys/public.jwk', 'ascii'));
const jwksData = {
    keys: [
        publicKey,
    ],
};

const discoveryData = {
    issuer: `${externalBaseUrl}`,
    jwks_uri: `${externalBaseUrl}/jwks`,
};

/*
 * Provide the discovery endpoint that the Kubernetes API server calls
 */
app.get('/.well-known/openid-configuration', (request, response) => {
    response.setHeader('content-type', 'application/json');
    response.status(200).send(JSON.stringify(discoveryData, null, 2));
});

/*
 * Provide a JWKS URI so that the Kubernetes API server can get token signing public keys to verify JWTs
 */
app.get('/jwks', (request, response) => {
    response.setHeader('content-type', 'application/json');
    response.status(200).send(JSON.stringify(jwksData, null, 2));
});

const port = 8443;
app.listen(port, () => {
    console.log(`The mock authorization server is running at HTTP port ${port}`);
});
