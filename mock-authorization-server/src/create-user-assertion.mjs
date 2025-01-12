import fs from 'fs';
import {decodeJwt, importJWK, SignJWT} from 'jose';

if (!fs.existsSync('crypto/token-signing-public.jwk')) {
    console.log('Generate keys before issuing a user assertion');
    process.exit(1);
}

const group = process.argv.length > 2 && process.argv[2] === 'devops' ? 'devops' : 'developers';

/*
 * Load crypto keys
 */
const publicJwk = JSON.parse(fs.readFileSync('./crypto/token-signing-public.jwk', 'ascii'));
const privateJwk = JSON.parse(fs.readFileSync('./crypto/token-signing-private.jwk', 'ascii'));
const privateKey = await importJWK(privateJwk, publicJwk.alg);

/*
 * Set properties that the API server trusts
 */
const issuerID = 'https://login.test.example';
const audience = 'my-client';
const expiryTime = Date.now() / 1000 + (15 * 60 * 1000);

/*
 * Set values based on 
 */
const userID = group === 'developers' ? 'john.doe' : 'jane.doe';
const employeeGroups = [group];

/*
 * Create a user JWT assertion for authentication with the Kubernetes API server
 */
const userAssertion = await new SignJWT({
    sub: userID,  
    iss: issuerID,
    aud: audience,
    employee_groups: employeeGroups,
})
    .setProtectedHeader( {kid: publicJwk.kid, alg: publicJwk.alg} )
    .setIssuedAt(Date.now() - 30000)
    .setExpirationTime(expiryTime)
    .sign(privateKey);

console.log(decodeJwt(userAssertion));
console.log(userAssertion);
