import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/library/widgets/achiever_carousel.dart';
import 'package:shreshtlibrary/features/library/widgets/review_form.dart';

final libraryInfoProvider = StreamProvider.autoDispose<LibraryInfo>(
  (ref) => ref.watch(studentApiProvider).libraryInfoStream(),
);
final facilitiesProvider = StreamProvider.autoDispose<List<Facility>>(
  (ref) => ref.watch(studentApiProvider).facilitiesStream(),
);
final achieversProvider = StreamProvider.autoDispose<List<Achiever>>(
  (ref) => ref.watch(studentApiProvider).achieversStream(),
);
final featuredAchieversProvider = StreamProvider.autoDispose<List<Achiever>>(
  (ref) => ref.watch(studentApiProvider).achieversStream(featured: true),
);
final reviewsProvider = StreamProvider.autoDispose<List<ReviewRecord>>(
  (ref) => ref.watch(studentApiProvider).reviewsStream(),
);
final reviewSummaryProvider = StreamProvider.autoDispose<ReviewSummary>(
  (ref) => ref.watch(studentApiProvider).reviewSummaryStream(),
);
final galleryImagesProvider = StreamProvider.autoDispose<List<GalleryImage>>(
  (ref) => ref.watch(studentApiProvider).galleryImagesStream(),
);

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return PageScaffold(
      title: l10n.library_title,
      onRefresh: () async {
        ref.invalidate(libraryInfoProvider);
        ref.invalidate(facilitiesProvider);
        ref.invalidate(achieversProvider);
        ref.invalidate(featuredAchieversProvider);
        ref.invalidate(reviewsProvider);
        ref.invalidate(reviewSummaryProvider);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsyncPane(
            value: ref.watch(libraryInfoProvider),
            builder: (info) => SectionCard(
              title: l10n.library_details,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (info.featureImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: info.featureImage!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (info.logoSquare != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: CachedNetworkImageProvider(
                              info.logoSquare!,
                              errorListener: (err) =>
                                  debugPrint('Image error: $err'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              info.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (info.logoSquare == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        info.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (info.tagline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(info.tagline!),
                    ),
                  if (info.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(info.description!),
                    ),
                  if (info.address != null)
                    InfoTile(
                      label: l10n.library_label_address,
                      value: info.address!,
                      icon: Icons.location_on_outlined,
                    ),
                  if (info.phonePrimary != null)
                    InfoTile(
                      label: l10n.library_label_phone,
                      value: info.phonePrimary!,
                      icon: Icons.phone_outlined,
                    ),
                  if (info.email != null)
                    InfoTile(
                      label: l10n.library_label_email,
                      value: info.email!,
                      icon: Icons.mail_outline,
                    ),
                  if (info.whatsappNumber != null)
                    InfoTile(
                      label: l10n.library_label_whatsapp,
                      value: info.whatsappNumber!,
                      icon: Icons.chat_outlined,
                    ),
                  if (info.emergencyContact != null)
                    InfoTile(
                      label: l10n.library_label_emergency_contact,
                      value: info.emergencyContact!,
                      icon: Icons.warning_amber_outlined,
                    ),
                  if (info.openingTime != null && info.closingTime != null)
                    InfoTile(
                      label: l10n.library_label_working_hours,
                      value:
                          '${info.openingTime} - ${info.closingTime} ${info.weeklyOff != null ? l10n.library_weekly_off(info.weeklyOff!) : ''}',
                      icon: Icons.access_time,
                    ),
                  if (info.website != null)
                    InfoTile(
                      label: l10n.library_label_website,
                      value: info.website!,
                      icon: Icons.language,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AsyncPane(
            value: ref.watch(libraryInfoProvider),
            builder: (info) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (info.totalCapacity != null ||
                    info.statisticsDescription != null)
                  SectionCard(
                    title: l10n.library_capacity_stats,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (info.totalCapacity != null)
                          Text(
                            l10n.library_total_capacity(info.totalCapacity!),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (info.availableSeats != null)
                          Text(
                            l10n.library_currently_available(
                              info.availableSeats!,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        if (info.statisticsDescription != null) ...[
                          const SizedBox(height: 8),
                          Text(info.statisticsDescription!),
                        ],
                      ],
                    ),
                  ),
                if (info.welcomeMessage != null ||
                    info.history != null ||
                    info.mission != null ||
                    info.vision != null)
                  SectionCard(
                    title: l10n.library_about_us,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (info.welcomeMessage != null) ...[
                          Text(
                            info.welcomeMessage!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (info.history != null) ...[
                          Text(
                            l10n.library_history,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.history!),
                          const SizedBox(height: 12),
                        ],
                        if (info.mission != null) ...[
                          Text(
                            l10n.library_mission,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.mission!),
                          const SizedBox(height: 12),
                        ],
                        if (info.vision != null) ...[
                          Text(
                            l10n.library_vision,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.vision!),
                        ],
                      ],
                    ),
                  ),
                if (info.services != null || info.coursesSupported != null) ...[
                  const SizedBox(height: 16),
                  SectionCard(
                    title: l10n.library_services_courses,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (info.services != null) ...[
                          Text(
                            l10n.library_services_offered,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.services!),
                          const SizedBox(height: 12),
                        ],
                        if (info.coursesSupported != null) ...[
                          Text(
                            l10n.library_courses_supported,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.coursesSupported!),
                        ],
                      ],
                    ),
                  ),
                ],
                if (info.membershipDetails != null ||
                    info.membershipBenefits != null) ...[
                  const SizedBox(height: 16),
                  SectionCard(
                    title: l10n.library_membership_info,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (info.membershipDetails != null) ...[
                          Text(
                            l10n.library_details_lbl,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.membershipDetails!),
                          const SizedBox(height: 12),
                        ],
                        if (info.membershipBenefits != null) ...[
                          Text(
                            l10n.library_benefits_lbl,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.membershipBenefits!),
                          const SizedBox(height: 12),
                        ],
                        if (info.registrationProcess != null) ...[
                          Text(
                            l10n.library_registration_process,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.registrationProcess!),
                          const SizedBox(height: 12),
                        ],
                        if (info.requiredDocuments != null) ...[
                          Text(
                            l10n.library_required_documents,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.requiredDocuments!),
                        ],
                      ],
                    ),
                  ),
                ],
                if (info.libraryRules != null || info.faq != null) ...[
                  const SizedBox(height: 16),
                  SectionCard(
                    title: l10n.library_rules_guidelines,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (info.libraryRules != null) ...[
                          Text(
                            l10n.library_rules,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.libraryRules!),
                          const SizedBox(height: 12),
                        ],
                        if (info.faq != null) ...[
                          Text(
                            l10n.library_faq,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(info.faq!),
                        ],
                      ],
                    ),
                  ),
                ],
                if (info.googleMapUrl != null &&
                    info.latitude != null &&
                    info.longitude != null) ...[
                  const SizedBox(height: 16),
                  SectionCard(
                    title: l10n.library_location,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 150,
                          child: Center(
                            child: Icon(
                              Icons.map_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Open google maps URL logic here
                          },
                          icon: const Icon(Icons.directions),
                          label: Text(l10n.library_get_directions),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l10n.library_facilities,
            child: AsyncPane(
              value: ref.watch(facilitiesProvider),
              builder: (rows) => rows.isEmpty
                  ? Text(l10n.library_no_facilities)
                  : Column(
                      children: rows
                          .map(
                            (facility) => InfoTile(
                              label:
                                  facility.description ??
                                  l10n.library_facility_fallback,
                              value: facility.name,
                              icon: Icons.check_circle_outline,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l10n.library_featured_achievers,
            child: AsyncPane(
              value: ref.watch(featuredAchieversProvider),
              builder: (rows) => rows.isEmpty
                  ? Text(l10n.library_no_featured_achievers)
                  : AchieverCarousel(rows),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l10n.library_all_achievers_title,
            child: AsyncPane(
              value: ref.watch(achieversProvider),
              builder: (rows) => rows.isEmpty
                  ? Text(l10n.library_no_achievers)
                  : AchieverCarousel(rows),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l10n.library_gallery,
            child: AsyncPane(
              value: ref.watch(galleryImagesProvider),
              builder: (rows) => rows.isEmpty
                  ? Text(l10n.library_no_gallery_images)
                  : SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: rows.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final image = rows[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: image.imageUrl,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l10n.library_reviews,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AsyncPane(
                  value: ref.watch(reviewSummaryProvider),
                  builder: (summary) => Text(
                    l10n.library_reviews_summary(
                      summary.averageRating.toStringAsFixed(1),
                      summary.count,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const ReviewForm(),
                const SizedBox(height: 12),
                AsyncPane(
                  value: ref.watch(reviewsProvider),
                  builder: (rows) => rows.isEmpty
                      ? Text(l10n.library_no_reviews)
                      : Column(
                          children: rows
                              .map(
                                (review) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    child: Text(review.rating.toString()),
                                  ),
                                  title: Text(review.studentName),
                                  subtitle: Text(review.comment),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AsyncPane(
            value: ref.watch(libraryInfoProvider),
            builder: (info) => Column(
              children: [
                if (info.facebookUrl != null ||
                    info.instagramUrl != null ||
                    info.youtubeUrl != null ||
                    info.telegramUrl != null)
                  SectionCard(
                    title: l10n.library_social_media,
                    child: Wrap(
                      spacing: 16,
                      children: [
                        if (info.facebookUrl != null)
                          const Icon(Icons.facebook, size: 32),
                        if (info.instagramUrl != null)
                          const Icon(Icons.camera_alt_outlined, size: 32),
                        if (info.youtubeUrl != null)
                          const Icon(Icons.video_library_outlined, size: 32),
                        if (info.telegramUrl != null)
                          const Icon(Icons.send_outlined, size: 32),
                      ],
                    ),
                  ),
                if (info.footerText != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      info.footerText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
