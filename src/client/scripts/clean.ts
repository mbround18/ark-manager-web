import Path from 'path';
import rimraf from 'rimraf';
const workingDir = Path.join(__dirname, '../../..');
const outDir = Path.join(workingDir, 'dist');

(async function() {
    await rimraf(outDir, {}, ()=> console.log('Cleaned dist folder.'));
})();