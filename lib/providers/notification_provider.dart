import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/notification_service.dart';
import '../data/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final notificationsForUserProvider = StreamProvider<List<AppNotification>>((
  ref,
) {
  final svc = ref.watch(notificationServiceProvider);
  return svc.notificationsForCurrentUser();
});

final unreadCountForVehicleProvider = StreamProvider.family<int, String>((
  ref,
  vehicleId,
) {
  final svc = ref.watch(notificationServiceProvider);
  return svc.unreadCountForVehicle(vehicleId);
});

final markReadForVehicleProvider = FutureProvider.family<void, String>((
  ref,
  vehicleId,
) async {
  final svc = ref.read(notificationServiceProvider);
  await svc.markReadForVehicle(vehicleId);
});
