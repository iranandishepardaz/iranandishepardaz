import 'ShortMessages.dart';
import 'package:telephony/telephony.dart';

class ShortMessageLister {
  static Future<List<ShortMessage>> getInboxShortMessages(int count) async {
    List<ShortMessage> allMessages = [];
    final Telephony telephony = Telephony.instance;
    List<SmsMessage> messages = await telephony.getInboxSms(columns: [
      SmsColumn.ADDRESS,
      SmsColumn.BODY,
      SmsColumn.DATE,
      SmsColumn.TYPE,
      SmsColumn.THREAD_ID
    ],
        //filter: SmsFilter.where(SmsColumn.THREAD_ID).lessThan("20"),
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC)
        ]);
    for (int i = 0; i < messages.length; i++) {
      try {
        ShortMessage tmpMessage = ShortMessage(
            address: messages[i].address!,
            sentAt: messages[i].date!,
            messageBody: messages[i].body!,
            kind: messages[i].type! == SmsType.MESSAGE_TYPE_OUTBOX
                ? 0
                : messages[i].type! == SmsType.MESSAGE_TYPE_INBOX
                    ? 1
                    : messages[i].type! == SmsType.MESSAGE_TYPE_DRAFT
                        ? 2
                        : 9,
            uploaded: 0);
        allMessages.add(tmpMessage);
        await tmpMessage.insert();
      } catch (Exception) {}
    }
    return allMessages;
  }

  static Future<List<ShortMessage>> getOutboxShortMessages(int count) async {
    List<ShortMessage> allMessages = [];
    final Telephony telephony = Telephony.instance;
    List<SmsMessage> messages = await telephony.getSentSms(columns: [
      SmsColumn.ADDRESS,
      SmsColumn.BODY,
      SmsColumn.DATE,
      SmsColumn.TYPE,
      SmsColumn.THREAD_ID
    ],
        //filter: SmsFilter.where(SmsColumn.THREAD_ID).lessThan("20"),
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC)
        ]);
    for (int i = 0; i < messages.length; i++) {
      try {
        ShortMessage tmpMessage = ShortMessage(
            address: messages[i].address!,
            sentAt: messages[i].date!,
            messageBody: messages[i].body!,
            kind: messages[i].type! == SmsType.MESSAGE_TYPE_OUTBOX
                ? 0
                : messages[i].type! == SmsType.MESSAGE_TYPE_INBOX
                    ? 1
                    : messages[i].type! == SmsType.MESSAGE_TYPE_DRAFT
                        ? 2
                        : 9,
            uploaded: 0);
        allMessages.add(tmpMessage);
        await tmpMessage.insert();
      } catch (Exception) {}
    }
    return allMessages;
  }
}
