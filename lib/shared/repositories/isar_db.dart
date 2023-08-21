import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_clone/features/chat/models/attachement.dart';
import 'package:whatsapp_clone/features/chat/models/recent_chat.dart';
import 'package:whatsapp_clone/features/home/data/repositories/contact_repository.dart';
import 'package:whatsapp_clone/shared/models/contact.dart';
import 'package:whatsapp_clone/shared/models/messages.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';

import '../../features/chat/models/message.dart';

final isarProvider = Provider((ref) => IsarDb());

class IsarDb {
  static late final Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [StoredMessageSchema, ContactSchema, UserSchema],
      directory: dir.path,
    );
  }

  static Future<void> addMessage(Message message) async {
    final storedMsg = StoredMessage(
      messageId: message.id,
      chatId: getChatId(message.senderId, message.receiverId),
      content: message.content,
      senderId: message.senderId,
      receiverId: message.receiverId,
      status: message.status,
      timestamp: message.timestamp.toDate(),
      attachment: message.attachment != null
          ? EmbeddedAttachment(
              fileName: message.attachment!.fileName,
              fileExtension: message.attachment!.fileExtension,
              fileSize: message.attachment!.fileSize,
              width: message.attachment!.width,
              height: message.attachment!.height,
              autoDownload: message.attachment!.autoDownload,
              uploadStatus: message.attachment!.uploadStatus,
              url: message.attachment!.url,
              type: message.attachment!.type,
              samples: message.attachment!.samples,
            )
          : null,
    );

    await isar.writeTxn(() async {
      await isar.storedMessages.put(storedMsg);
    });
  }

  static Future<void> addMessages(List<Message> messages) async {
    final storedMessages = messages
        .map(
          (message) => StoredMessage(
            messageId: message.id,
            chatId: getChatId(message.senderId, message.receiverId),
            content: message.content,
            senderId: message.senderId,
            receiverId: message.receiverId,
            status: message.status,
            timestamp: message.timestamp.toDate(),
            attachment: message.attachment != null
                ? EmbeddedAttachment(
                    fileName: message.attachment!.fileName,
                    fileExtension: message.attachment!.fileExtension,
                    fileSize: message.attachment!.fileSize,
                    width: message.attachment!.width,
                    height: message.attachment!.height,
                    uploadStatus: message.attachment!.uploadStatus,
                    autoDownload: message.attachment!.autoDownload,
                    url: message.attachment!.url,
                    type: message.attachment!.type,
                    samples: message.attachment!.samples,
                  )
                : null,
          ),
        )
        .toList();

    await isar.writeTxn(() async {
      await isar.storedMessages.putAll(storedMessages);
    });
  }

  static Future<void> updateMessage(
    String messageId, {
    String? content,
    MessageStatus? status,
    Attachment? attachment,
  }) async {
    await isar.writeTxn(() async {
      StoredMessage? msg = await isar.storedMessages
          .filter()
          .messageIdEqualTo(messageId)
          .build()
          .findFirst();

      if (msg == null) return;

      msg.content = content ?? msg.content;
      msg.status = status ?? msg.status;

      if (attachment != null) {
        msg.attachment = EmbeddedAttachment(
          fileName: attachment.fileName,
          fileExtension: attachment.fileExtension,
          fileSize: attachment.fileSize,
          width: attachment.width,
          height: attachment.height,
          uploadStatus: attachment.uploadStatus,
          autoDownload: attachment.autoDownload,
          url: attachment.url,
          type: attachment.type,
          samples: attachment.samples,
        );
      }

      await isar.storedMessages.put(msg);
    });
  }

  static Stream<List<Message>> getChatStream(String chatId) {
    return isar.storedMessages
        .filter()
        .chatIdEqualTo(chatId)
        .sortByTimestampDesc()
        .build()
        .watch(fireImmediately: true)
        .map((event) => event
            .map(
              (msg) => Message(
                id: msg.messageId,
                content: msg.content,
                senderId: msg.senderId,
                receiverId: msg.receiverId,
                timestamp: Timestamp.fromDate(msg.timestamp),
                status: msg.status,
                attachment: msg.attachment != null
                    ? Attachment(
                        fileName: msg.attachment!.fileName!,
                        fileExtension: msg.attachment!.fileExtension!,
                        fileSize: msg.attachment!.fileSize!,
                        width: msg.attachment!.width,
                        height: msg.attachment!.height,
                        uploadStatus: msg.attachment!.uploadStatus!,
                        autoDownload: msg.attachment!.autoDownload ?? false,
                        url: msg.attachment!.url!,
                        type: msg.attachment!.type!,
                        samples: msg.attachment!.samples,
                      )
                    : null,
              ),
            )
            .toList());
  }

  static Stream<List<RecentChat>> getRecentChatStream(WidgetRef ref) {
    final currentUser = User.fromMap(
      jsonDecode(SharedPref.instance.getString('user')!),
    );

    return isar.storedMessages
        .where()
        .sortByTimestampDesc()
        .watch(fireImmediately: true)
        .asyncMap((event) async {
      final Map<String, int> visitedChats = {};
      final recentChats = <RecentChat>[];

      for (final msg in event) {
        final clientIsSender = msg.senderId == currentUser.id;
        if (visitedChats.containsKey(msg.chatId)) {
          if (clientIsSender) continue;
          if (msg.status == MessageStatus.seen) continue;

          visitedChats[msg.chatId] = visitedChats[msg.chatId]! + 1;
          continue;
        }

        var sender = await IsarDb.getUserById(
          clientIsSender ? msg.receiverId : msg.senderId,
        );

        Contact? contact;
        if (sender != null) {
          contact = await ref
              .read(contactsRepositoryProvider)
              .getContactByPhone(sender.phone.number!);
        }

        sender ??= await ref
            .read(firebaseFirestoreRepositoryProvider)
            .getUserById(
              msg.senderId == currentUser.id ? msg.receiverId : msg.senderId,
            );

        final senderName =
            contact?.displayName ?? sender!.phone.formattedNumber;

        recentChats.add(
          RecentChat(
            message: Message(
              id: msg.messageId,
              content: msg.content,
              senderId: msg.senderId,
              receiverId: msg.receiverId,
              timestamp: Timestamp.fromDate(msg.timestamp),
              status: msg.status,
              attachment: msg.attachment != null
                  ? Attachment(
                      fileName: msg.attachment!.fileName!,
                      fileExtension: msg.attachment!.fileExtension!,
                      fileSize: msg.attachment!.fileSize!,
                      width: msg.attachment!.width,
                      height: msg.attachment!.height,
                      uploadStatus: msg.attachment!.uploadStatus!,
                      autoDownload: msg.attachment!.autoDownload ?? false,
                      url: msg.attachment!.url!,
                      type: msg.attachment!.type!,
                    )
                  : null,
            ),
            user: User.fromMap(
              sender!.toMap()..addAll({'name': senderName}),
            ),
          ),
        );

        visitedChats[msg.chatId] =
            clientIsSender || msg.status == MessageStatus.seen ? 0 : 1;
      }

      for (final chat in recentChats) {
        chat.unreadCount = visitedChats[
            getChatId(chat.message.senderId, chat.message.receiverId)]!;
      }

      return recentChats;
    });
  }

  static Future<void> addContacts() async {
    final providerContainer = ProviderContainer();
    final self = getCurrentUser()!;

    var contacts = await providerContainer
        .read(contactsRepositoryProvider)
        .getContacts(self: self);

    final users = await Future.wait(
      contacts.map(
        (e) => providerContainer
            .read(firebaseFirestoreRepositoryProvider)
            .getUserByPhone(e.phoneNumber),
      ),
    );

    for (var i = 0; i < contacts.length; i++) {
      final user = users[i];
      var contact = contacts[i];

      if (user != null && user.id != self.id) {
        contact = Contact(
          userId: user.id,
          avatarUrl: user.avatarUrl,
          contactId: contact.contactId,
          displayName: contact.displayName,
          phoneNumber: contact.phoneNumber,
        );
      } else {
        contact = Contact(
          contactId: contact.contactId,
          displayName: contact.displayName,
          phoneNumber: contact.phoneNumber,
        );
      }

      contacts[i] = contact;
    }

    await isar.writeTxn(() async {
      await isar.contacts.putAll(contacts);
      await isar.users.putAll(users.nonNulls.toList());
    });
  }

  static Future<void> refreshContacts() async {
    await isar.writeTxn(() async {
      await isar.contacts.clear();
      await isar.users.clear();
    });

    await IsarDb.addContacts();
  }

  static Future<List<Contact>> getContacts() async {
    return isar.contacts.where().findAll();
  }

  static Future<User?> getUserById(String id) async {
    return await isar.users.filter().idEqualTo(id).findFirst();
  }

  static Future<List<Contact>> getWhatsAppContacts() async {
    return await isar.contacts.filter().userIdIsNotNull().findAll();
  }
}
