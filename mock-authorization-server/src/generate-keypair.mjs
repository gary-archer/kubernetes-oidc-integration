import {randomBytes} from 'crypto';
import fs from 'fs';
import {generateKeyPair, exportJWK} from 'jose';

if (fs.existsSync('token-signing-keys/private.jwk')) {
    console.log('Token signing keys have already been generated')
    process.exit(0);
}

console.log('Generating the token signing keypair ...');
const algorithm = 'ES256';
const kid = randomBytes(16).toString('hex');
var keypair = await generateKeyPair(algorithm);

const publicKey = await exportJWK(keypair.publicKey);
const privateKey = await exportJWK(keypair.privateKey);

publicKey.kid = kid;
publicKey.alg = algorithm;

fs.writeFileSync('token-signing-keys/public.jwk', JSON.stringify(publicKey, null, 2));
fs.writeFileSync('token-signing-keys/private.jwk', JSON.stringify(privateKey, null ,2));
console.log('Token signing keypair generated successfully');
