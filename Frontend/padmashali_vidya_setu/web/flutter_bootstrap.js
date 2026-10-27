{{flutter_js}}
{{flutter_build_config}}

// The loading splash in index.html stays until Flutter draws its first frame (the app's own splash screen).
window.addEventListener('flutter-first-frame', () => {
  const splash = document.getElementById('splash');
  if (!splash) return;
  splash.classList.add('done');
  setTimeout(() => splash.remove(), 400);
}, { once: true });

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
});
