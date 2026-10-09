{{flutter_js}}
{{flutter_build_config}}

// Runs the app in the frame from index.html rather than on the whole page.
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.querySelector('#app'),
    });
    await appRunner.runApp();
  },
});
