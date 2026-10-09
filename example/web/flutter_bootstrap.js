{{flutter_js}}
{{flutter_build_config}}

// Runs the app in the frame from index.html rather than on the whole page.
_flutter.loader.load({
  config: {
    wasmAllowList: { webkit: true },
  },
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.querySelector('#app'),
    });
    await appRunner.runApp();
    hideSplash();
  },
});

// The splash stays at least this long since the page opened, so it is seen
// even when the app loads at once.
const splashMinimum = 2000;

// How long the splash fades out, as in index.html.
const splashFade = 600;

// Fades out the splash from index.html once the app draws its first frame.
function hideSplash() {
  const splash = document.querySelector('#splash');
  if (!splash) return;
  const wait = Math.max(0, splashMinimum - performance.now());
  setTimeout(() => requestAnimationFrame(() => {
    splash.classList.add('is-hidden');
    // Removed by time rather than on transitionend, which may not come:
    // a hidden splash left above the app would slow down every frame.
    setTimeout(() => splash.remove(), splashFade);
  }), wait);
}
