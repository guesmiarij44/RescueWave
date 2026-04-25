import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RescueBoatApp());
}

// ─────────────────────────────────────────────
// THEME & CONSTANTS
// ─────────────────────────────────────────────

class AppColors {
  static const Color primary      = Color(0xFF0077B6);   // deep ocean blue
  static const Color accent       = Color(0xFF00B4D8);   // cyan
  static const Color danger       = Color(0xFFEF233C);   // alert red
  static const Color success      = Color(0xFF06D6A0);   // safe green
  static const Color warning      = Color(0xFFFFB703);   // warning amber
  static const Color dark         = Color(0xFF03071E);   // near-black
  static const Color surface      = Color(0xFF0D1B2A);   // card surface
  static const Color surfaceLight = Color(0xFF1B2A3A);   // lighter surface
  static const Color text         = Color(0xFFEAF4FB);
  static const Color textMuted    = Color(0xFF7CA5BF);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum UserRole { adminPrincipal, adminSecondaire, maitreDuNauge }

class AppUser {
  final String cin;
  final String nom;
  final String prenom;
  final UserRole role;
  final String? adminCin;  // CIN de l'admin responsable

  const AppUser({
    required this.cin,
    required this.nom,
    required this.prenom,
    required this.role,
    this.adminCin,
  });
}

class AlerteNoyade {
  final String id;
  final DateTime heure;
  final String lieu;
  final String? photoUrl;
  bool confirmee;
  bool traitee;

  AlerteNoyade({
    required this.id,
    required this.heure,
    required this.lieu,
    this.photoUrl,
    this.confirmee = false,
    this.traitee = false,
  });
}

class HistoriqueVictime {
  final String id;
  final DateTime date;
  final int age;
  final String lieu;
  final String description;
  final String maitreCin;
  final bool survivant;

  const HistoriqueVictime({
    required this.id,
    required this.date,
    required this.age,
    required this.lieu,
    required this.description,
    required this.maitreCin,
    required this.survivant,
  });
}

// ─────────────────────────────────────────────
// FAKE DATA / MOCK STATE
// ─────────────────────────────────────────────

class AppState extends ChangeNotifier {
  AppUser? currentUser;

  // Mock users
  final List<AppUser> users = const [
    AppUser(cin: '14666020', nom: 'Guesmi',  prenom: 'Arij',  role: UserRole.adminPrincipal),
    AppUser(cin: '23456789', nom: 'lakhdher',  prenom: 'Nesrine',   role: UserRole.adminSecondaire, adminCin: '12345678'),
    AppUser(cin: '34567890', nom: 'Jouni',  prenom: 'Houssem', role: UserRole.maitreDuNauge,   adminCin: '23456789'),
    AppUser(cin: '45678901', nom: 'Fasatoui',  prenom: 'Marwen',     role: UserRole.maitreDuNauge,   adminCin: '23456789'),
  ];

  final List<AlerteNoyade> alertes = [
    AlerteNoyade(id: 'A001', heure: DateTime.now().subtract(const Duration(minutes: 3)),  lieu: 'Zone B – Plage Nord',  confirmee: false),
    AlerteNoyade(id: 'A002', heure: DateTime.now().subtract(const Duration(hours: 1)),    lieu: 'Zone C – Piscine Est', confirmee: true, traitee: true),
  ];

  final List<HistoriqueVictime> historique = [
    HistoriqueVictime(id: 'H001', date: DateTime.now().subtract(const Duration(days: 2)),  age: 14, lieu: 'Plage Nord – Zone B',  description: 'Enfant emporté par le courant. Secouru rapidement.',  maitreCin: '34567890', survivant: true),
    HistoriqueVictime(id: 'H002', date: DateTime.now().subtract(const Duration(days: 5)),  age: 32, lieu: 'Piscine Est – Zone C', description: 'Malaise cardiaque en milieu aquatique.',              maitreCin: '45678901', survivant: true),
    HistoriqueVictime(id: 'H003', date: DateTime.now().subtract(const Duration(days: 10)), age: 67, lieu: 'Plage Sud – Zone A',   description: 'Noyade profonde, prise en charge SAMU.',           maitreCin: '34567890', survivant: false),
  ];

  static const String motDePasseGeneral = 'sauvetage2026';

  bool login(String cin, String mdp) {
    if (mdp != motDePasseGeneral) return false;
    final user = users.where((u) => u.cin == cin).firstOrNull;
    if (user == null) return false;
    currentUser = user;
    notifyListeners();
    return true;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void confirmerAlerte(String id) {
    final a = alertes.where((x) => x.id == id).firstOrNull;
    if (a != null) { a.confirmee = true; notifyListeners(); }
  }

  void traiterAlerte(String id) {
    final a = alertes.where((x) => x.id == id).firstOrNull;
    if (a != null) { a.traitee = true; notifyListeners(); }
  }
}

// ─────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────

class RescueBoatApp extends StatefulWidget {
  const RescueBoatApp({super.key});
  @override
  State<RescueBoatApp> createState() => _RescueBoatAppState();
}

class _RescueBoatAppState extends State<RescueBoatApp> {
  final AppState _state = AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (_, __) => MaterialApp(
        title: 'RescueWave',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.dark,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.surface,
          ),
          fontFamily: 'Roboto',
        ),
        home: _state.currentUser == null
            ? LoginScreen(appState: _state)
            : HomeScreen(appState: _state),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WAVE PAINTER (decoration)
// ─────────────────────────────────────────────

class WavePainter extends CustomPainter {
  final double animation;
  WavePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.7 +
          sin((x / size.width * 2 * pi) + animation * 2 * pi) * 18 +
          sin((x / size.width * 3 * pi) + animation * 2 * pi * 1.3) * 10;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = AppColors.accent.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.78);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.78 +
          sin((x / size.width * 2 * pi) + animation * 2 * pi * 0.8 + 1) * 14 +
          sin((x / size.width * 4 * pi) + animation * 2 * pi * 1.1) * 8;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter old) => old.animation != animation;
}

// ─────────────────────────────────────────────
// LOGIN SCREEN
// ─────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  final AppState appState;
  const LoginScreen({super.key, required this.appState});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _cinCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();
  bool _mdpVisible = false;
  bool _loading = false;
  String? _erreur;

  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _cinCtrl.dispose();
    _mdpCtrl.dispose();
    super.dispose();
  }

  Future<void> _connexion() async {
    setState(() { _loading = true; _erreur = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    final ok = widget.appState.login(_cinCtrl.text.trim(), _mdpCtrl.text.trim());
    if (!ok) {
      setState(() { _loading = false; _erreur = 'CIN ou mot de passe incorrect.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF020B18), AppColors.dark, Color(0xFF03184A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Animated wave
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => CustomPaint(
                painter: WavePainter(_waveCtrl.value),
              ),
            ),
          ),
          // Circles deco
          Positioned(top: -60, right: -60,
            child: _Circle(120, AppColors.primary.withOpacity(0.12))),
          Positioned(top: 80, left: -40,
            child: _Circle(80, AppColors.accent.withOpacity(0.08))),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.directions_boat_rounded,
                          size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text('RescueWave',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                          letterSpacing: 2,
                        )),
                    const SizedBox(height: 6),
                    const Text('Système de surveillance aquatique',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 48),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Connexion',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              )),
                          const SizedBox(height: 4),
                          const Text('Entrez votre CIN et mot de passe',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              )),
                          const SizedBox(height: 24),
                          _InputField(
                            controller: _cinCtrl,
                            label: 'Numéro CIN',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _InputField(
                            controller: _mdpCtrl,
                            label: 'Mot de passe',
                            icon: Icons.lock_outline_rounded,
                            obscure: !_mdpVisible,
                            suffix: IconButton(
                              icon: Icon(
                                _mdpVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _mdpVisible = !_mdpVisible),
                            ),
                          ),
                          if (_erreur != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.danger.withOpacity(0.4)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.danger, size: 16),
                                const SizedBox(width: 8),
                                Text(_erreur!,
                                    style: const TextStyle(
                                        color: AppColors.danger, fontSize: 13)),
                              ]),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loading ? null : _connexion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Se connecter',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_rounded,
                            size: 14, color: AppColors.textMuted),
                        SizedBox(width: 6),
                        Text('Accès sécurisé – Personnel autorisé uniquement',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME SCREEN (Bottom Nav Shell)
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser!;
    final isAdmin = user.role != UserRole.maitreDuNauge;

    final pages = [
      DashboardPage(appState: widget.appState),
      AlertesPage(appState: widget.appState),
      HistoriquePage(appState: widget.appState),
      if (isAdmin) AdminPage(appState: widget.appState),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        isAdmin: isAdmin,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAVIGATION
// ─────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;
  final void Function(int) onTap;
  const _BottomNav(
      {required this.currentIndex, required this.isAdmin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(
                color: AppColors.primary.withOpacity(0.2), width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.accent),
            label: 'Tableau de bord',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: true,
              label: const Text('1'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications_rounded,
                color: AppColors.danger),
            label: 'Alertes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon:
                Icon(Icons.history_rounded, color: AppColors.accent),
            label: 'Historique',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings_rounded,
                  color: AppColors.warning),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD PAGE
// ─────────────────────────────────────────────

class DashboardPage extends StatelessWidget {
  final AppState appState;
  const DashboardPage({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser!;
    final alertesActives = appState.alertes.where((a) => !a.traitee).length;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
                onPressed: () => _confirmLogout(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF03184A), AppColors.surface],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.accent]),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenue, ${user.prenom}',
                                  style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _roleLabel(user.role),
                                  style: const TextStyle(
                                      color: AppColors.accent, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status boat card
                _BoatStatusCard(),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      label: 'Alertes actives',
                      value: '$alertesActives',
                      icon: Icons.warning_amber_rounded,
                      color: alertesActives > 0 ? AppColors.danger : AppColors.success,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                      label: 'Interventions',
                      value: '${appState.historique.length}',
                      icon: Icons.handshake_rounded,
                      color: AppColors.accent,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                      label: 'Sauvés',
                      value: '${appState.historique.where((h) => h.survivant).length}',
                      icon: Icons.favorite_rounded,
                      color: AppColors.success,
                    )),
                  ],
                ),
                const SizedBox(height: 20),

                // GPS buoy card
                _GpsCard(),
                const SizedBox(height: 20),

                // Latest alert
                if (alertesActives > 0) ...[
                  const _SectionTitle('🚨  Dernière alerte non traitée'),
                  const SizedBox(height: 10),
                  _AlerteCard(
                    alerte: appState.alertes.firstWhere((a) => !a.traitee),
                    appState: appState,
                    compact: true,
                  ),
                ],
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Déconnexion', style: TextStyle(color: AppColors.text)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?',
            style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              appState.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.adminPrincipal:    return 'Administrateur Principal';
      case UserRole.adminSecondaire:   return 'Administrateur Secondaire';
      case UserRole.maitreDuNauge:     return 'Maître-Nageur';
    }
  }
}

// ─────────────────────────────────────────────
// ALERTES PAGE
// ─────────────────────────────────────────────

class AlertesPage extends StatelessWidget {
  final AppState appState;
  const AlertesPage({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Alertes',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (_, __) {
          final alertes = appState.alertes;
          if (alertes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                  SizedBox(height: 16),
                  Text('Aucune alerte en cours',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: alertes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _AlerteCard(
              alerte: alertes[i],
              appState: appState,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HISTORIQUE PAGE
// ─────────────────────────────────────────────

class HistoriquePage extends StatelessWidget {
  final AppState appState;
  const HistoriquePage({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Historique des victimes',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: appState.historique.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final h = appState.historique[i];
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: h.survivant
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.danger.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      h.survivant
                          ? Icons.favorite_rounded
                          : Icons.heart_broken_rounded,
                      color: h.survivant ? AppColors.success : AppColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      h.survivant ? 'Survie confirmée' : 'Décès',
                      style: TextStyle(
                        color: h.survivant ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(h.date),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(Icons.person_rounded, 'Âge', '${h.age} ans'),
                const SizedBox(height: 6),
                _InfoRow(Icons.location_on_rounded, 'Lieu', h.lieu),
                const SizedBox(height: 6),
                _InfoRow(Icons.notes_rounded, 'Description', h.description),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ─────────────────────────────────────────────
// ADMIN PAGE
// ─────────────────────────────────────────────

class AdminPage extends StatelessWidget {
  final AppState appState;
  const AdminPage({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser!;
    final isPrincipal = user.role == UserRole.adminPrincipal;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Administration',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Role badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPrincipal
                    ? [const Color(0xFF7B2D8B), const Color(0xFFB455C8)]
                    : [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(isPrincipal
                    ? Icons.workspace_premium_rounded
                    : Icons.manage_accounts_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPrincipal
                          ? 'Administrateur Principal'
                          : 'Administrateur Secondaire',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(user.nom + ' ' + user.prenom,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Members section
          const _SectionTitle('👥  Membres gérés'),
          const SizedBox(height: 12),
          ...appState.users
              .where((u) => u.adminCin == user.cin)
              .map((u) => _MemberTile(member: u))
              .toList(),

          if (isPrincipal) ...[
            const SizedBox(height: 24),
            const _SectionTitle('🛡️  Administrateurs secondaires'),
            const SizedBox(height: 12),
            ...appState.users
                .where((u) => u.role == UserRole.adminSecondaire)
                .map((u) => _MemberTile(member: u, isAdmin: true))
                .toList(),
          ],

          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Ajouter un membre'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Ajouter un membre',
            style: TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InputField(
                controller: TextEditingController(),
                label: 'CIN du nouveau membre',
                icon: Icons.badge_outlined),
            const SizedBox(height: 12),
            _InputField(
                controller: TextEditingController(),
                label: 'Nom complet',
                icon: Icons.person_outlined),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _BoatStatusCard extends StatefulWidget {
  @override
  State<_BoatStatusCard> createState() => _BoatStatusCardState();
}

class _BoatStatusCardState extends State<_BoatStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2342), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) => Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success
                    .withOpacity(0.1 + 0.15 * _pulse.value),
                border: Border.all(
                    color: AppColors.success
                        .withOpacity(0.3 + 0.4 * _pulse.value),
                    width: 2),
              ),
              child: child,
            ),
            child: const Icon(Icons.directions_boat_rounded,
                color: AppColors.success, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bateau Sauveteur',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success),
                  ),
                  const SizedBox(width: 6),
                  const Text('En ligne – Mode surveillance',
                      style: TextStyle(
                          color: AppColors.success, fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                const Text('Caméra IA active • GPS actif',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            children: [
              _MiniStat('Batterie', '87%', AppColors.success),
              const SizedBox(height: 8),
              _MiniStat('Signal', '4G', AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style:
                const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

class _GpsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.my_location_rounded,
                color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bouée de Sauvetage GPS',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                SizedBox(height: 4),
                Text('36.8065° N, 10.1815° E',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontFamily: 'monospace')),
                SizedBox(height: 2),
                Text('Dernière mise à jour : il y a 12s',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _AlerteCard extends StatelessWidget {
  final AlerteNoyade alerte;
  final AppState appState;
  final bool compact;
  const _AlerteCard(
      {required this.alerte, required this.appState, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = alerte.traitee
        ? AppColors.success.withOpacity(0.3)
        : alerte.confirmee
            ? AppColors.warning.withOpacity(0.4)
            : AppColors.danger.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: alerte.traitee
            ? []
            : [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                alerte.traitee
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                color: alerte.traitee ? AppColors.success : AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                alerte.traitee
                    ? 'Mission accomplie'
                    : alerte.confirmee
                        ? 'Mission confirmée'
                        : '🚨 Alerte détectée',
                style: TextStyle(
                  color: alerte.traitee
                      ? AppColors.success
                      : alerte.confirmee
                          ? AppColors.warning
                          : AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${alerte.heure.hour}:${alerte.heure.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoRow(Icons.location_on_rounded, 'Lieu', alerte.lieu),
          const SizedBox(height: 6),
          _InfoRow(Icons.tag, 'Référence', alerte.id),
          if (!alerte.traitee) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (!alerte.confirmee)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => appState.confirmerAlerte(alerte.id),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Confirmer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: AppColors.dark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                if (alerte.confirmee) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => appState.traiterAlerte(alerte.id),
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text('Mission terminée'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.dark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final AppUser member;
  final bool isAdmin;
  const _MemberTile({required this.member, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAdmin
                  ? AppColors.warning.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.2),
            ),
            child: Icon(
              isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_rounded,
              color: isAdmin ? AppColors.warning : AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${member.prenom} ${member.nom}',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text('CIN: ${member.cin}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_remove_rounded,
                color: AppColors.danger, size: 20),
            onPressed: () {},
            tooltip: 'Révoquer l\'accès',
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.text, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('$label : ',
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 12)),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: AppColors.text, fontSize: 12)),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}