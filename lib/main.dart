
import 'dart:async';

import 'package:flutter/material.dart';

import 'models/completed_session.dart';
import 'models/playstation_model.dart';
import 'models/session_model.dart';
import 'services/session_billing.dart';

void main() {
  runApp(const PlayStationApp());
}

class PlayStationApp extends StatelessWidget {
  const PlayStationApp({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlayStation Hall Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(clock: clock),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<PlayStationModel> playstations = [
    PlayStationModel(
      id: 1,
      name: 'PlayStation 1',
      controllersCount: 4,
      priceForTwo: 10000,
      priceForThree: 15000,
      priceForFour: 20000,
      isAvailable: true,
    ),
    PlayStationModel(
      id: 2,
      name: 'PlayStation 2',
      controllersCount: 4,
      priceForTwo: 12000,
      priceForThree: 16000,
      priceForFour: 22000,
      isAvailable: false,
    ),
    PlayStationModel(
      id: 3,
      name: 'PlayStation 3',
      controllersCount: 2,
      priceForTwo: 10000,
      priceForThree: 14000,
      priceForFour: 18000,
      isAvailable: true,
    ),
    PlayStationModel(
      id: 4,
      name: 'PlayStation 4',
      controllersCount: 3,
      priceForTwo: 10000,
      priceForThree: 14000,
      priceForFour: 18000,
      isAvailable: true,
    ),
  ];

  final Map<int, SessionModel> activeSessions = {};

  final List<CompletedSession> completedSessions = [];

  Timer? _timer;

  DateTime now() => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || activeSessions.isEmpty) {
          return;
        }

        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int getHourlyPrice(
    PlayStationModel playstation,
    int playersCount,
  ) {
    return selectHourlyPrice(playstation, playersCount);
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final hoursText = hours.toString().padLeft(2, '0');
    final minutesText = minutes.toString().padLeft(2, '0');
    final secondsText = seconds.toString().padLeft(2, '0');

    return '$hoursText:$minutesText:$secondsText';
  }

  Duration getElapsedTime(SessionModel session) {
    return calculateElapsedDuration(
      startTime: session.startTime,
      endTime: now(),
    );
  }

  void startSession(
    int index,
    int playersCount,
    SessionType type,
    Duration? duration,
  ) {
    final playstation = playstations[index];

    if (!playstation.isAvailable ||
        activeSessions.containsKey(playstation.id)) {
      return;
    }

    final hourlyPrice = getHourlyPrice(
      playstation,
      playersCount,
    );

    setState(() {
      activeSessions[playstation.id] = SessionModel(
        playstationId: playstation.id,
        playersCount: playersCount,
        hourlyPrice: hourlyPrice,
        startTime: now(),
        type: type,
        duration: duration,
      );

      playstations[index] = PlayStationModel(
        id: playstation.id,
        name: playstation.name,
        controllersCount: playstation.controllersCount,
        priceForTwo: playstation.priceForTwo,
        priceForThree: playstation.priceForThree,
        priceForFour: playstation.priceForFour,
        isAvailable: false,
      );
    });

    debugPrint(
      'Session started: '
      'PlayStation ${playstation.id}, '
      'Players: $playersCount, '
      'Type: $type, '
      'Duration: ${duration?.inMinutes ?? "Open"} minutes',
    );
  }

  void showStartSessionDialog(
    BuildContext context,
    int index,
    PlayStationModel playstation,
  ) {
    if (!playstation.isAvailable) {
      return;
    }

    int selectedPlayers = 2;
    SessionType selectedType = SessionType.timed;

    int selectedHours = 1;
    int selectedMinutes = 0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final hourlyPrice = getHourlyPrice(
              playstation,
              selectedPlayers,
            );

            return AlertDialog(
              title: Text('فتح جلسة - ${playstation.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('اختار عدد اللاعبين:'),

                    RadioGroup<int>(
                      groupValue: selectedPlayers,
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedPlayers = value;
                        });
                      },
                      child: const Column(
                        children: [
                          RadioListTile<int>(
                            title: Text('شخصين'),
                            value: 2,
                          ),
                          RadioListTile<int>(
                            title: Text('3 لاعبين'),
                            value: 3,
                          ),
                          RadioListTile<int>(
                            title: Text('4 لاعبين'),
                            value: 4,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('نوع الجلسة:'),

                    RadioGroup<SessionType>(
                      groupValue: selectedType,
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                      child: const Column(
                        children: [
                          RadioListTile<SessionType>(
                            title: Text('وقت محدد'),
                            value: SessionType.timed,
                          ),
                          RadioListTile<SessionType>(
                            title: Text('وقت مفتوح'),
                            value: SessionType.open,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (selectedType == SessionType.timed)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: '1',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'الساعات',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                selectedHours =
                                    int.tryParse(value) ?? 0;
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: TextFormField(
                              initialValue: '0',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'الدقائق',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                selectedMinutes =
                                    int.tryParse(value) ?? 0;
                              },
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    Text(
                      'سعر الساعة: $hourlyPrice ل.س',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('إلغاء'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Duration? sessionDuration;

                    if (selectedType == SessionType.timed) {
                      final totalMinutes =
                          (selectedHours * 60) + selectedMinutes;

                      if (selectedHours < 0 ||
                          selectedMinutes < 0 ||
                          selectedMinutes > 59 ||
                          totalMinutes <= 0) {
                        ScaffoldMessenger.of(
                          dialogContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'أدخل مدة صحيحة أكبر من صفر، '
                              'والدقائق بين 0 و59',
                            ),
                          ),
                        );

                        return;
                      }

                      sessionDuration = Duration(
                        minutes: totalMinutes,
                      );
                    }

                    startSession(
                      index,
                      selectedPlayers,
                      selectedType,
                      sessionDuration,
                    );

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('فتح جلسة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // إنهاء الجلسة مع حفظ المبلغ المحسوب والمبلغ المقبوض فعلياً.
  void endSession(
    int index,
    SessionModel session,
    DateTime endTime,
    int calculatedAmount,
    int collectedAmount,
    String? adjustmentReason,
  ) {
    final playstation = playstations[index];

    if (!identical(activeSessions[playstation.id], session)) {
      return;
    }

    final completedSession = createCompletedSession(
      session: session,
      endTime: endTime,
      calculatedAmount: calculatedAmount,
      collectedAmount: collectedAmount,
      adjustmentReason: adjustmentReason,
    );

    final actualDuration = completedSession.actualDuration;

    setState(() {
      completedSessions.add(completedSession);

      activeSessions.remove(playstation.id);

      playstations[index] = PlayStationModel(
        id: playstation.id,
        name: playstation.name,
        controllersCount: playstation.controllersCount,
        priceForTwo: playstation.priceForTwo,
        priceForThree: playstation.priceForThree,
        priceForFour: playstation.priceForFour,
        isAvailable: true,
      );
    });

    debugPrint(
      'Session ended: '
      'PlayStation ${playstation.id}, '
      'Actual duration: ${formatDuration(actualDuration)}, '
      'Calculated amount: $calculatedAmount SYP, '
      'Collected amount: $collectedAmount SYP, '
      'Reason: ${adjustmentReason ?? "None"}',
    );
  }

  void showEndSessionDialog(
    BuildContext context,
    int index,
    SessionModel session,
  ) {
    final playstation = playstations[index];

    // تثبيت وقت النهاية عند الضغط على "إنهاء الجلسة".
    final endTime = now();

    final actualDuration = calculateElapsedDuration(
      startTime: session.startTime,
      endTime: endTime,
    );

    final calculatedAmount = calculateSessionCharge(
      session,
      actualDuration,
    );

    // يبدأ المبلغ المقبوض فعلياً مساوياً للمبلغ المحسوب.
    // الموظف يستطيع تغييره عند الحاجة.
    int? enteredCollectedAmount = calculatedAmount;

    String adjustmentReason = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final amountIsValid =
                enteredCollectedAmount != null &&
                enteredCollectedAmount! >= 0;

            final amountWasChanged =
                enteredCollectedAmount != calculatedAmount;

            return AlertDialog(
              title: Text(
                'إنهاء جلسة - ${playstation.name}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نوع الجلسة: '
                      '${session.type == SessionType.timed ? "محددة" : "مفتوحة"}',
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'عدد اللاعبين: ${session.playersCount}',
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'المدة الفعلية: ${formatDuration(actualDuration)}',
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'سعر الساعة: ${session.hourlyPrice} ل.س',
                    ),

                    const Divider(height: 32),

                    const Text(
                      'المبلغ المحسوب تلقائياً',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '$calculatedAmount ل.س',
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      initialValue: calculatedAmount.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'المبلغ المقبوض فعلياً',
                        suffixText: 'ل.س',
                        border: const OutlineInputBorder(),
                        errorText: amountIsValid
                            ? null
                            : 'أدخل مبلغاً صحيحاً لا يقل عن صفر',
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          enteredCollectedAmount = int.tryParse(value);
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'سبب التعديل (اختياري)',
                        hintText: 'يمكنك تركه فارغاً',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        adjustmentReason = value;
                      },
                    ),

                    const SizedBox(height: 12),

                    if (amountWasChanged && amountIsValid)
                      const Text(
                        'تم تعديل المبلغ عن الحساب التلقائي.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    if (!amountWasChanged)
                      const Text(
                        'المبلغ المعتمد مطابق للحساب التلقائي.',
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('رجوع'),
                ),

                ElevatedButton(
                  onPressed: amountIsValid
                      ? () {
                          final collectedAmount = enteredCollectedAmount!;

                          final trimmedReason =
                              adjustmentReason.trim();

                          endSession(
                            index,
                            session,
                            endTime,
                            calculatedAmount,
                            collectedAmount,
                            trimmedReason.isEmpty
                                ? null
                                : trimmedReason,
                          );

                          Navigator.pop(dialogContext);
                        }
                      : null,
                  child: const Text('تأكيد الإنهاء'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildSessionTimer(SessionModel session) {
    final elapsed = getElapsedTime(session);

    if (session.type == SessionType.open) {
      return Text(
        'الوقت المنقضي: ${formatDuration(elapsed)}',
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final sessionDuration = session.duration;

    if (sessionDuration == null) {
      return const Text('مدة الجلسة غير محددة');
    }

    final remaining = sessionDuration - elapsed;

    if (remaining <= Duration.zero) {
      return const Text(
        'انتهى الوقت — بانتظار الإنهاء أو التمديد',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Text(
      'الوقت المتبقي: ${formatDuration(remaining)}',
      style: const TextStyle(
        color: Colors.deepPurple,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة صالة البلايستيشن'),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: playstations.length,
        itemBuilder: (context, index) {
          final playstation = playstations[index];

          final session = activeSessions[playstation.id];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              leading: const Icon(
                Icons.sports_esports,
                size: 32,
              ),

              title: Text(
                playstation.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Text(
                    playstation.isAvailable
                        ? 'متاح للعب'
                        : 'مشغول',
                    style: TextStyle(
                      color: playstation.isAvailable
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'شخصين: ${playstation.priceForTwo} ل.س',
                  ),

                  Text(
                    '3 لاعبين: ${playstation.priceForThree} ل.س',
                  ),

                  Text(
                    '4 لاعبين: ${playstation.priceForFour} ل.س',
                  ),

                  if (session != null) ...[
                    const SizedBox(height: 12),

                    Text(
                      'عدد اللاعبين: ${session.playersCount}',
                    ),

                    Text(
                      'سعر ساعة الجلسة: ${session.hourlyPrice} ل.س',
                    ),

                    const SizedBox(height: 8),

                    buildSessionTimer(session),

                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () {
                        showEndSessionDialog(
                          context,
                          index,
                          session,
                        );
                      },
                      icon: const Icon(
                        Icons.stop_circle_outlined,
                      ),
                      label: const Text('إنهاء الجلسة'),
                    ),
                  ],
                ],
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {
                showStartSessionDialog(
                  context,
                  index,
                  playstation,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
