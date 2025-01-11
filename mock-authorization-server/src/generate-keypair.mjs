import {randomBytes} from 'crypto';
import fs from 'fs';
import {generateKeyPair, exportJWK, exportPKCS8} from 'jose';

if (fs.existsSync('private.key')) {
    console.log('Keys have already been generated')
    process.exit(1);
}

console.log('Generating the mock authorization server keypair ...');
const algorithm = 'ES256';
const kid = randomBytes(16).toString('hex');
var keypair = await generateKeyPair(algorithm);

const publicKey = await exportJWK(keypair.publicKey);
const privateKey = await exportJWK(keypair.privateKey);

publicKey.kid = kid;
publicKey.alg = algorithm;
privateKey.kid = kid;
privateKey.alg = algorithm;

/*
 * This example exports the private key in an unprotected format to simplify code
 */
fs.writeFileSync('./public.key', JSON.stringify(publicKey, null, 2));
fs.writeFileSync('./private.key', JSON.stringify(privateKey, null ,2));
