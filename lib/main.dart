import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const bool _hasSupabaseConfig =
    _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;

/// Supabase data model (tables) for pareja:
/// - couples
///   - id uuid primary key default gen_random_uuid()
///   - user_a uuid references auth.users(id) not null
///   - user_b uuid references auth.users(id) not null
///   - created_at timestamp with time zone default now()
///   - unique index on user_a
///   - unique index on user_b
/// - pairing_codes
///   - code text primary key
///   - owner_id uuid references auth.users(id) not null
///   - used_by uuid references auth.users(id)
///   - used boolean default false
///   - expires_at timestamp with time zone not null
///   - created_at timestamp with time zone default now()

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_hasSupabaseConfig) {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parejas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E63)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _authSubscription;
  Session? _session;

  @override
  void initState() {
    super.initState();
    if (_hasSupabaseConfig) {
      final supabase = Supabase.instance.client;
      _session = supabase.auth.currentSession;
      _authSubscription =
          supabase.auth.onAuthStateChange.listen((AuthState state) {
        setState(() {
          _session = state.session;
        });
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSupabaseConfig) {
      return const SupabaseConfigScreen();
    }

    if (_session == null) {
      return const WelcomeScreen();
    }

    return const HomeScreen();
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF1F5),
              Color(0xFFFFE4E6),
              Color(0xFFFCE7F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: const [
                    SizedBox(height: 16),
                    Text(
                      'Momentos en Pareja',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9F1239),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Guarda fechas especiales, recuerdos y crea contenido para compartir juntos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.45,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final float = 10 * _controller.value;
                      final sway = 6 * (0.5 - (_controller.value - 0.5).abs());
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 20 + float,
                            left: 30,
                            child: _FloatingHeart(
                              size: 36,
                              opacity: 0.4,
                              offset: Offset(0, sway),
                            ),
                          ),
                          Positioned(
                            top: 80,
                            right: 40,
                            child: _FloatingHeart(
                              size: 24,
                              opacity: 0.6,
                              offset: Offset(0, -sway),
                            ),
                          ),
                          Positioned(
                            bottom: 40 + float,
                            left: 40,
                            child: _FloatingHeart(
                              size: 28,
                              opacity: 0.35,
                              offset: Offset(0, -sway),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 30,
                            child: _FloatingHeart(
                              size: 32,
                              opacity: 0.45,
                              offset: Offset(0, sway),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, -8 + float / 2),
                            child: _CoupleIllustration(scale: 1 + float / 120),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE11D48),
                          side: const BorderSide(color: Color(0xFFE11D48)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Registrarse'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Conecta tus recuerdos con amor',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingHeart extends StatelessWidget {
  const _FloatingHeart({
    required this.size,
    required this.opacity,
    required this.offset,
  });

  final double size;
  final double opacity;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Icon(
        Icons.favorite,
        size: size,
        color: const Color(0xFFF43F5E).withOpacity(opacity),
      ),
    );
  }
}

class _CoupleIllustration extends StatelessWidget {
  const _CoupleIllustration({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 6),
              ),
            ),
            Positioned(
              left: 24,
              child: _PersonAvatar(
                color: const Color(0xFFF97316),
                icon: Icons.face,
              ),
            ),
            Positioned(
              right: 24,
              child: _PersonAvatar(
                color: const Color(0xFF38BDF8),
                icon: Icons.face_2,
              ),
            ),
            const Positioned(
              bottom: 34,
              child: Icon(
                Icons.favorite,
                size: 34,
                color: Color(0xFFE11D48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Icon(
        icon,
        size: 38,
        color: color,
      ),
    );
  }
}

class SupabaseConfigScreen extends StatelessWidget {
  const SupabaseConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RomanticScaffold(
      title: 'Configura Supabase',
      subtitle:
          'Agrega SUPABASE_URL y SUPABASE_ANON_KEY para habilitar el acceso.',
      child: SizedBox.shrink(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos iniciar sesión.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RomanticScaffold(
      title: 'Bienvenido de vuelta',
      subtitle: 'Retoma la historia que están escribiendo juntos.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _AuthTextField(
              controller: _emailController,
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Ingresa tu correo.' : null,
            ),
            const SizedBox(height: 16),
            _AuthTextField(
              controller: _passwordController,
              label: 'Contraseña',
              obscureText: true,
              validator: (value) => value == null || value.length < 6
                  ? 'Mínimo 6 caracteres.'
                  : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Entrar', key: ValueKey('text')),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                '¿No tienes cuenta? Regístrate',
                style: TextStyle(color: Color(0xFF9F1239)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'display_name': _nameController.text.trim(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa tu correo para confirmar la cuenta.'),
        ),
      );
      Navigator.of(context).pop();
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos crear la cuenta.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RomanticScaffold(
      title: 'Crea tu cuenta',
      subtitle: 'Empieza a celebrar cada momento especial.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _AuthTextField(
              controller: _nameController,
              label: 'Nombre',
              validator: (value) => value == null || value.isEmpty
                  ? 'Dinos cómo te llamas.'
                  : null,
            ),
            const SizedBox(height: 16),
            _AuthTextField(
              controller: _emailController,
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Ingresa tu correo.' : null,
            ),
            const SizedBox(height: 16),
            _AuthTextField(
              controller: _passwordController,
              label: 'Contraseña',
              obscureText: true,
              validator: (value) => value == null || value.length < 6
                  ? 'Mínimo 6 caracteres.'
                  : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crear cuenta', key: ValueKey('text')),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                '¿Ya tienes cuenta? Inicia sesión',
                style: TextStyle(color: Color(0xFF9F1239)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pairingController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _pairingCode;
  DateTime? _pairingExpiresAt;
  bool _isLinked = false;
  String? _partnerId;

  @override
  void initState() {
    super.initState();
    _loadPairingStatus();
  }

  @override
  void dispose() {
    _pairingController.dispose();
    super.dispose();
  }

  Future<void> _loadPairingStatus() async {
    if (!_hasSupabaseConfig) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final couple = await client
          .from('couples')
          .select('id, user_a, user_b')
          .or('user_a.eq.${user.id},user_b.eq.${user.id}')
          .maybeSingle();

      if (couple != null) {
        final userA = couple['user_a'] as String;
        final userB = couple['user_b'] as String;
        setState(() {
          _isLinked = true;
          _partnerId = userA == user.id ? userB : userA;
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _isLinked = false;
        _partnerId = null;
      });

      final nowIso = DateTime.now().toIso8601String();
      final activeCode = await client
          .from('pairing_codes')
          .select('code, expires_at')
          .eq('owner_id', user.id)
          .eq('used', false)
          .gt('expires_at', nowIso)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (activeCode != null) {
        setState(() {
          _pairingCode = activeCode['code'] as String;
          _pairingExpiresAt =
              DateTime.tryParse(activeCode['expires_at'] as String);
        });
      } else {
        setState(() {
          _pairingCode = null;
          _pairingExpiresAt = null;
        });
      }
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos cargar tu estado.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _createCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _generatePairingCode() async {
    if (_isLinked) return;
    final now = DateTime.now();
    if (_pairingExpiresAt != null && _pairingExpiresAt!.isAfter(now)) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      final expiresAt = now.add(const Duration(minutes: 15));
      String? code;
      for (var i = 0; i < 3; i++) {
        final candidate = _createCode();
        try {
          await client.from('pairing_codes').insert({
            'code': candidate,
            'owner_id': user.id,
            'expires_at': expiresAt.toIso8601String(),
            'used': false,
          });
          code = candidate;
          break;
        } on PostgrestException catch (_) {
          continue;
        }
      }
      if (code == null) {
        throw Exception('No se pudo generar un código único.');
      }
      setState(() {
        _pairingCode = code;
        _pairingExpiresAt = expiresAt;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos generar el código.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _hasExistingCouple(String userId) async {
    final client = Supabase.instance.client;
    final existing = await client
        .from('couples')
        .select('id')
        .or('user_a.eq.$userId,user_b.eq.$userId')
        .maybeSingle();
    return existing != null;
  }

  Future<void> _linkWithCode() async {
    final input = _pairingController.text.trim().toUpperCase();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de tu pareja.')),
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      if (await _hasExistingCouple(user.id)) {
        throw Exception('Ya tienes una pareja vinculada.');
      }

      final codeRow = await client
          .from('pairing_codes')
          .select('code, owner_id, expires_at')
          .eq('code', input)
          .eq('used', false)
          .gt('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      if (codeRow == null) {
        throw Exception('El código no es válido o ya expiró.');
      }

      final ownerId = codeRow['owner_id'] as String;
      if (ownerId == user.id) {
        throw Exception('Ese código es tuyo. Comparte tu código con tu pareja.');
      }

      if (await _hasExistingCouple(ownerId)) {
        throw Exception('Tu pareja ya está vinculada con alguien más.');
      }

      await client.from('couples').insert({
        'user_a': ownerId,
        'user_b': user.id,
      });

      await client.from('pairing_codes').update({
        'used': true,
        'used_by': user.id,
      }).eq('code', input);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Pareja vinculada con éxito!')),
      );
      _pairingController.clear();
      await _loadPairingStatus();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RomanticScaffold(
      title: 'Hola, amor',
      subtitle: 'Tu espacio para recordar momentos inolvidables.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: const [
                Text(
                  'Tu aventura está lista para comenzar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9F1239),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Guarda recuerdos, celebra fechas y comparte sorpresas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                : _isLinked
                    ? _LinkedPartnerCard(partnerId: _partnerId)
                    : _PairingCard(
                        pairingCode: _pairingCode,
                        expiresAt: _pairingExpiresAt,
                        isSubmitting: _isSubmitting,
                        controller: _pairingController,
                        onGenerate: _generatePairingCode,
                        onLink: _linkWithCode,
                      ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE11D48),
                side: const BorderSide(color: Color(0xFFE11D48)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedPartnerCard extends StatelessWidget {
  const _LinkedPartnerCard({this.partnerId});

  final String? partnerId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Ya están conectados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9F1239),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            partnerId == null
                ? 'Tu pareja está sincronizada con tu espacio.'
                : 'Tu pareja está sincronizada.\nCódigo interno: $partnerId',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _PairingCard extends StatelessWidget {
  const _PairingCard({
    required this.pairingCode,
    required this.expiresAt,
    required this.isSubmitting,
    required this.controller,
    required this.onGenerate,
    required this.onLink,
  });

  final String? pairingCode;
  final DateTime? expiresAt;
  final bool isSubmitting;
  final TextEditingController controller;
  final VoidCallback onGenerate;
  final VoidCallback onLink;

  String _formatExpiry(DateTime? time) {
    if (time == null) return '';
    final minutes = time.difference(DateTime.now()).inMinutes;
    if (minutes <= 0) return 'expirado';
    return 'expira en ${minutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Vincula a tu pareja',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9F1239),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Comparte un código temporal o ingresa el de tu pareja.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          if (pairingCode != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFBCFE8)),
              ),
              child: Column(
                children: [
                  Text(
                    pairingCode!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Color(0xFF9F1239),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatExpiry(expiresAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isSubmitting ? null : onGenerate,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE11D48),
                side: const BorderSide(color: Color(0xFFE11D48)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Generar código'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Código de pareja',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isSubmitting
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Vincular', key: ValueKey('text')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RomanticScaffold extends StatefulWidget {
  const RomanticScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  State<RomanticScaffold> createState() => _RomanticScaffoldState();
}

class _RomanticScaffoldState extends State<RomanticScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF1F5),
              Color(0xFFFFE4E6),
              Color(0xFFFCE7F3),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final float = 6 * _controller.value;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: 20,
                                child: _FloatingHeart(
                                  size: 28,
                                  opacity: 0.35,
                                  offset: Offset(0, -float),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: _FloatingHeart(
                                  size: 20,
                                  opacity: 0.5,
                                  offset: Offset(0, float),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: _FloatingHeart(
                                  size: 32,
                                  opacity: 0.4,
                                  offset: Offset(0, -float),
                                ),
                              ),
                              child!,
                            ],
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 22,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 42,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9F1239),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 28),
                      widget.child,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFBCFE8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFBCFE8)),
        ),
      ),
    );
  }
}
