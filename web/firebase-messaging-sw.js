importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// IMPORTANT: Firebase configuration must be injected at build time or loaded from a secure source
// Do NOT hardcode credentials here. This is a placeholder that should be replaced during build.
//
// For local development, create web/firebase-config.js with your credentials:
// self.firebaseConfig = { apiKey: "...", authDomain: "...", projectId: "...", ... };
//
// For production builds, inject credentials using environment variables or build-time replacement.
importScripts('firebase-config.js');

// Initialize Firebase in the service worker with the loaded config
let messaging = null;
if (typeof self.firebaseConfig === 'undefined') {
  console.error('Firebase configuration not found. Please create web/firebase-config.js or inject config at build time.');
} else {
  firebase.initializeApp(self.firebaseConfig);
  messaging = firebase.messaging();
}

if (!messaging) {
  console.warn('Firebase Messaging is not initialized. Push notifications are disabled.');
}

// Handle background messages
messaging?.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification?.title || 'TeenTalk';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new notification',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification click received.');

  event.notification.close();

  // Navigate to the app or a specific page based on the notification data
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // Check if there's already a window/tab open
      for (const client of clientList) {
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      // If no window/tab is open, open a new one
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
