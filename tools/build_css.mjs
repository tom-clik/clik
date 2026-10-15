import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = fileURLToPath(new URL('../', import.meta.url));
const manifest = JSON.parse(await readFile(path.join(root, 'staticCSS.json'), 'utf8'));
for (const pkg of manifest.packages) {
    const parts = [];
    for (const name of pkg.scripts) {
        const script = manifest.scripts.find(script => script.name === name);
        if (!script?.min?.startsWith('/_assets/')) throw new Error(`Missing local CSS: ${name}`);
        parts.push(await readFile(path.join(root, 'assets', script.min.slice('/_assets/'.length)), 'utf8'));
    }
    const output = path.join(root, 'assets', pkg.min.slice('/_assets/'.length));
    await mkdir(path.dirname(output), { recursive: true });
    await writeFile(output, parts.join('\n'));
    console.log(output);
}
