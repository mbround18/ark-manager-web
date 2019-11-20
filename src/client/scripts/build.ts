import Path from 'path';
import rimraf from 'rimraf';
import Bundler from 'parcel-bundler';
import { exec } from "child_process";
const entryFiles = Path.join(__dirname, '..', 'index.html');
const workingDir = Path.join(__dirname, '../../..');
const outDir = Path.join(workingDir, 'dist');
const options = {
    outDir: Path.join(workingDir, 'dist'), // The out directory to put the build files in, defaults to dist
    outFile: 'index.html', // The name of the outputFile
    publicUrl: './asset/',
    cacheDir: Path.join(workingDir, '.cache'),
    watch: false,
    autoInstall: true, // Enable or disable auto install of missing dependencies found during bundling
};


exec(`git rev-parse --short HEAD`, (err: any, stdout: any) => {
    process.env.GIT_VERSION = stdout.replace('\n', '');
});

(async function() {
    await rimraf(outDir, {}, ()=> console.log('Cleaned dist folder.'));

    // Initializes a bundler using the entrypoint location and options provided
    const bundler = new Bundler(entryFiles, options);
    // Run the bundler, this returns the main bundle
    // Use the events if you're using watch mode as this promise will only trigger once and not for every rebuild
    const bundle = await bundler.bundle();
})();