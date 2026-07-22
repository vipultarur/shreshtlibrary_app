import 'package:flutter_test/flutter_test.dart';
import 'package:shreshtlibrary/core/models/models.dart';

void main() {
  group('Models Equatable Tests', () {
    test('StudentIdCard supports value comparisons', () {
      final card1 = StudentIdCard(
        studentId: 1,
        fullName: 'Test User',
        mobile: '1234567890',
        email: 'test@example.com',
        goal: 'Study',
        qrData: 'qr123',
        photoUrl: 'http://example.com/photo.jpg',
      );
      final card2 = StudentIdCard(
        studentId: 1,
        fullName: 'Test User',
        mobile: '1234567890',
        email: 'test@example.com',
        goal: 'Study',
        qrData: 'qr123',
        photoUrl: 'http://example.com/photo.jpg',
      );
      final card3 = StudentIdCard(
        studentId: 2,
        fullName: 'Test User 2',
        mobile: '0987654321',
        email: 'test2@example.com',
        goal: 'Work',
        qrData: 'qr456',
        photoUrl: null,
      );

      expect(card1, equals(card2));
      expect(card1, isNot(equals(card3)));
    });

    test('Facility supports value comparisons', () {
      final facility1 = Facility(
        id: 1,
        name: 'Library',
        iconKey: 'library',
        description: 'Quiet place',
      );
      final facility2 = Facility(
        id: 1,
        name: 'Library',
        iconKey: 'library',
        description: 'Quiet place',
      );
      final facility3 = Facility(
        id: 2,
        name: 'Gym',
        iconKey: 'fitness',
        description: 'Workout',
      );

      expect(facility1, equals(facility2));
      expect(facility1, isNot(equals(facility3)));
    });

    test('ReviewRecord supports value comparisons', () {
      final review1 = ReviewRecord(
        id: 1,
        studentName: 'Alice',
        rating: 5,
        comment: 'Great!',
        createdAt: '2023-10-01',
      );
      final review2 = ReviewRecord(
        id: 1,
        studentName: 'Alice',
        rating: 5,
        comment: 'Great!',
        createdAt: '2023-10-01',
      );
      final review3 = ReviewRecord(
        id: 2,
        studentName: 'Bob',
        rating: 4,
        comment: 'Good',
        createdAt: '2023-10-02',
      );

      expect(review1, equals(review2));
      expect(review1, isNot(equals(review3)));
    });

    test('GalleryImage supports value comparisons', () {
      final img1 = GalleryImage(id: 1, imageUrl: 'url1', caption: 'desc1', order: 1);
      final img2 = GalleryImage(id: 1, imageUrl: 'url1', caption: 'desc1', order: 1);
      final img3 = GalleryImage(id: 2, imageUrl: 'url2', caption: 'desc2', order: 2);

      expect(img1, equals(img2));
      expect(img1, isNot(equals(img3)));
    });

    test('HomeSlider supports value comparisons', () {
      final slider1 = HomeSlider(id: 1, image: 'url1', linkUrl: 'action1', title: 'title1', subtitle: 'sub1');
      final slider2 = HomeSlider(id: 1, image: 'url1', linkUrl: 'action1', title: 'title1', subtitle: 'sub1');
      final slider3 = HomeSlider(id: 2, image: 'url2', linkUrl: 'action2', title: 'title2', subtitle: 'sub2');

      expect(slider1, equals(slider2));
      expect(slider1, isNot(equals(slider3)));
    });
  });
}
