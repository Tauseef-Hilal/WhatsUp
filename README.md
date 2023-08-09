# 🚀 WhatsUp: The Ultimate WhatsApp Clone

Welcome to the WhatsUp repository! 🎉 This project brings you the closest experience to WhatsApp, crafted with the power of Flutter and Firebase. With features like real-time conversations, efficient media transmission, voice messaging, and robust security, we've recreated the essence of WhatsApp while adding our unique touch. Discover the familiarity you love, paired with exciting enhancements, all in one package.

## Features That Shine ✨

- **Real-time Conversations:** Experience the thrill of real-time messaging, just like you would on your favorite chat apps like WhatsApp.
- **Message Attachments:** Share and receive images, music, videos, and documents with ease. Our compression technology optimizes storage and bandwidth consumption.
- **Firebase Magic:** Safeguard your conversations with Firebase, ensuring rock-solid security for your login and messaging experience.
- **Express Yourself:** Capture the essence of your thoughts with voice messages, adding a personal and dynamic touch to your conversations.
- **Slick Interface:** Navigate smoothly through our beautifully designed interface, crafted with Flutter to ensure a delightful user journey.
- **Stay Updated:** Never miss a beat with push notifications that keep you informed even when the app is in the background. Notification work only on Android because APNs requires a paid subscription.
- **Offline Access:** Enjoy your chats and conversations seamlessly, whether you're online or offline.

## Let's Get Started 🚀

Follow these simple steps to get WhatsUp up and running:

1. **Clone Me:** Start by cloning this repository to your local machine.
2. **Firebase Setup:** Fire up a Firebase project and activate Firebase Authentication, Firestore and Storage.
3. **Dependencies Power-Up:** Run `flutter pub get` to install the magic ingredients your project needs.
4. **Launch Mode:** Ignite the app with `flutter run` and watch it come to life on your chosen device or emulator.

## How the Magic Happens 🪄

1. **Join the Circle:** Sign up or log in using your phone number, and let Firebase Authentication do its thing.
2. **Chat All You Want:** Engage in real-time conversations that feel just like magic.
3. **Attachments Unleashed:** Tap the attachment button, choose your media, and follow the breadcrumbs to send. Our image compression optimizes the sharing experience.
4. **Voice Your Thoughts:** Record and send voice messages by holding down the microphone button while speaking. Release to send your audio gem.

## Fortified by Firebase Firestore 🌐

At the heart of WhatsUp is the mighty Firebase Firestore. We rely on Firestore to securely save user data and facilitate seamless message transmission. Each message sent by a user is immediately whisked away to Firestore, ensuring efficient and reliable delivery. Notably, messages sent are promptly removed from Firestore as soon as they are received by the recipient's device, enhancing privacy and security.

## Your Privacy, Our Priority 🛡️

In WhatsUp, messages within a chat are stored exclusively on the phones of the communicating individuals. This design ensures that your conversations remain private and inaccessible to unauthorized parties. Your messages are your own, and we're committed to keeping it that way.

## Known Issues

- Voice not playing after download
- Voice/Music not seeking properly
- Android recorded files not working on iOS (issue with the package [audio_waveforms](https://github.com/SimformSolutionsPvtLtd/audio_waveforms/issues/237))
- Unread banner not rendering properly when unread message count is high
- Keyboard height issues on some devices (specifically Android devices)

## Contribute and Elevate 🤝

We heartily welcome contributions from the community to elevate the project. Share your insights, submit those bug reports, request features, and send those pull requests to make WhatsUp shine even brighter.

## The Future is Exciting 🌟

Exciting enhancements await us on the horizon, including:

- **Voice & Video Calling** Connect face-to-face or chat with your voice using our intuitive video and voice calling features.
- **Group Chats:** Coming soon, group chat functionality to engage with multiple contacts at once.
- **Status Updates** Share your current mood or updates with your friends using status messages.
- **Backups** Safeguard your chats and memories with easy-to-use backup and restore functionality.
- **Enhanced Notifications** Stay in the loop with detailed notifications, even when the app is in the background.
- **Message Management** Forward, delete, or reply to messages effortlessly to keep conversations organized.
- **Encrypted Secrets:** Adding end-to-end encryption for messages, attachments, and voice messages to keep your conversations yours.
- **Your Way, Your Look:** Customization options to make your WhatsUp experience uniquely yours.

Stay tuned for these fantastic updates!

## Help Us Soar 🦅

Join us in making WhatsUp a sensation. Star the repository, fork it, and spread the word on social media.

Thank you for reading. Let the conversations begin! 🗣️📞
