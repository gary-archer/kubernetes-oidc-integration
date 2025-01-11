import fs from 'fs';
import {importJWK, SignJWT} from 'jose';

if (!fs.existsSync('./public.jwk')) {
    console.log('Generate keys before issuing an ID token');
    process.exit(1);
}

/*
 * Load crypto keys
 */
const jwk = JSON.parse(fs.readFileSync('./private.key', 'ascii'));
const privateKey = await importJWK(jwk, jwk.alg);

/*
 * Test Kubernetes authentication as various users by editing these values
 */
const userID = 'john.doe';
const issuerID = 'https://login.example.com';
const audience = 'kubernetes-client';
const expiryTime = Date.now() / 1000 + (15 * 60 * 1000);

/*
 * Create a user JWT assertion for authentication with the Kubernetes API server
 */
const userAssertion = await new SignJWT({
    sub: userID,  
    iss: issuerID,
    aud: audience,
})
    .setProtectedHeader( {kid: jwk.kid, alg: jwk.alg} )
    .setIssuedAt(Date.now() - 30000)
    .setExpirationTime(expiryTime)
    .sign(privateKey);

console.log(`Token issued for Kubernetes user ${userID}`);
console.log(userAssertion);
