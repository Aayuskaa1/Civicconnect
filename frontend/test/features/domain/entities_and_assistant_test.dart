import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/chat/domain/local_chat_assistant.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthEntity', () {
    test('supports value equality with equatable', () {
      const a = AuthEntity(
        authId: '1',
        email: 'a@test.com',
        fullName: 'A',
        role: 'user',
      );
      const b = AuthEntity(
        authId: '1',
        email: 'a@test.com',
        fullName: 'A',
        role: 'user',
      );
      const c = AuthEntity(
        authId: '2',
        email: 'b@test.com',
        fullName: 'B',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ReportEntity', () {
    test('supports value equality with equatable', () {
      final created = DateTime(2026, 1, 1);
      final a = ReportEntity(
        reportId: 'r1',
        title: 'T',
        description: 'D',
        category: 'Water',
        status: 'pending',
        location: 'L',
        submittedBy: 'u@test.com',
        createdAt: created,
      );
      final b = ReportEntity(
        reportId: 'r1',
        title: 'T',
        description: 'D',
        category: 'Water',
        status: 'pending',
        location: 'L',
        submittedBy: 'u@test.com',
        createdAt: created,
      );

      expect(a, equals(b));
    });
  });

  group('LocalChatAssistant', () {
    test('replies to greeting', () {
      final reply = LocalChatAssistant.reply('hello');
      expect(reply.toLowerCase(), contains('civicconnect'));
    });

    test('replies to thanks', () {
      final reply = LocalChatAssistant.reply('thanks');
      expect(reply.toLowerCase(), contains('welcome'));
    });

    test('explains statuses when asked', () {
      final reply = LocalChatAssistant.reply('what do statuses mean?');
      expect(reply.toLowerCase(), contains('pending'));
      expect(reply.toLowerCase(), contains('resolved'));
    });

    test('describes CivicConnect overview', () {
      final reply = LocalChatAssistant.reply('what is civicconnect');
      expect(reply.toLowerCase(), contains('apartment'));
      expect(reply.toLowerCase(), contains('report'));
    });

    test('explains tabs navigation', () {
      final reply = LocalChatAssistant.reply('what do the tabs do');
      expect(reply.toLowerCase(), contains('home'));
      expect(reply.toLowerCase(), contains('submit'));
    });

    test('explains how to report an issue', () {
      final reply = LocalChatAssistant.reply('how do i report an issue');
      expect(reply.toLowerCase(), contains('submit'));
      expect(reply.toLowerCase(), contains('category'));
    });

    test('lists complaint categories', () {
      final reply = LocalChatAssistant.reply('what categories are available');
      expect(reply.toLowerCase(), contains('maintenance'));
      expect(reply.toLowerCase(), contains('water'));
    });

    test('explains profile tab', () {
      final reply = LocalChatAssistant.reply('tell me about profile');
      expect(reply.toLowerCase(), contains('profile'));
      expect(reply.toLowerCase(), contains('reports'));
    });

    test('explains login and signup', () {
      final reply = LocalChatAssistant.reply('how do i sign up');
      expect(reply.toLowerCase(), contains('sign up'));
      expect(reply.toLowerCase(), contains('password'));
    });

    test('explains photo upload', () {
      final reply = LocalChatAssistant.reply('how do i upload a photo');
      expect(reply.toLowerCase(), contains('camera'));
      expect(reply.toLowerCase(), contains('gallery'));
    });

    test('explains sensor features', () {
      final reply = LocalChatAssistant.reply('how do sensors work');
      expect(reply.toLowerCase(), contains('light sensor'));
      expect(reply.toLowerCase(), contains('accelerometer'));
    });

    test('explains admin role', () {
      final reply = LocalChatAssistant.reply('what can admin do');
      expect(reply.toLowerCase(), contains('admin'));
      expect(reply.toLowerCase(), contains('status'));
    });

    test('handles emergency guidance', () {
      final reply = LocalChatAssistant.reply('this is an emergency');
      expect(reply.toLowerCase(), contains('emergency'));
    });

    test('describes home screen', () {
      final reply = LocalChatAssistant.reply('what is on home');
      expect(reply.toLowerCase(), contains('home'));
    });

    test('describes reports tab', () {
      final reply = LocalChatAssistant.reply('how does reports tab work');
      expect(reply.toLowerCase(), contains('filter'));
    });

    test('returns fallback overview for unknown questions', () {
      final reply = LocalChatAssistant.reply('xyz random question');
      expect(reply.toLowerCase(), contains('civicconnect'));
    });
  });
}
