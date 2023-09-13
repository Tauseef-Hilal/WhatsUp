# WhatsUp: The Ultimate WhatsApp Clone

This project brings you the **closest** experience to WhatsApp, crafted with the power of Flutter and Firebase. With features like real-time conversations, efficient media transmission, voice messaging, and robust security, we've recreated the essence of WhatsApp while adding our unique touch. Discover the familiarity you love, paired with exciting enhancements, all in one package.

## Screenshots

Take a closer look to get to know about some of the app features

<section style='display: grid; gap:10px; justify-content: center; grid-template-columns: repeat(auto-fit, 250px);'>
    <img src='screenshots/emoji.png?raw=true' alt='Emoji Picker' />
    <img src='screenshots/home.png?raw=true' alt='Home Page' />
    <img src='screenshots/chat.png?raw=true' alt='Chat Page' />
    <img src='screenshots/document.png?raw=true' alt='Document Upload' />
    <img src='screenshots/voice.png?raw=true' alt='Voice Chat' />
    <img src='screenshots/gallery.png?raw=true' alt='Gallery' />
</section>
<br>

> **Note**: If screenshots are not visible, you might need a VPN or a different WIFI

## Features That Shine 

- **Real-time Conversations:** Experience real-time messaging, just like you would on your favorite chat apps like WhatsApp.
- **Message Attachments:** Share and receive images, music, videos, and documents with ease. Our **compression** technology optimizes storage and bandwidth consumption.
- **Voice Chat:** Capture the essence of your thoughts with voice messages, adding a personal and dynamic touch to your conversations.
- **Slick Interface:** Navigate smoothly through our beautifully designed interface,  crafted with Flutter to ensure a delightful user experience.
- **Stay Updated:** Never miss a beat with push notifications that keep you informed even when the app is in the background. Notification work only on Android because APNs requires a paid subscription.
- **Offline Access:** Access your chats seamlessly, whether you're online or offline.
- [There's more to come! Stay tuned] (#the-future-is-exciting)

## Fortified by Firebase Firestore 🌐

At the heart of WhatsUp is the mighty Firebase Firestore. We rely on Firestore to securely save user data and facilitate seamless message transmission. Each message sent by a user is immediately whisked away to Firestore, ensuring efficient and reliable delivery. Notably, messages sent are promptly removed from Firestore as soon as they are received by the recipient's device, enhancing privacy and security.

## Your Privacy, Our Priority 🛡️

In WhatsUp, messages within a chat are stored exclusively on the phones of the communicating individuals. This design ensures that your conversations remain private and inaccessible to unauthorized parties. Your messages are your own, and we're committed to keeping it that way.

## Known Issues

- Sometimes attachments that were received while in the chat page are not playable
- Code needs to be improved in some places, especially in the chat page.

## Contribute and Elevate 🤝

We heartily welcome contributions from the community to elevate the project. Share your insights, submit those bug reports, request features, and send those pull requests to make WhatsUp shine even brighter.

## The Future is Exciting
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
