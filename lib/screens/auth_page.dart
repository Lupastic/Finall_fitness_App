import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/google_sign_in_provider.dart';
import '../providers/settings_provider.dart'; // <--- ДОБАВЬ ЭТОТ ИМПОРТ
import 'navigation_wrapper.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;

  bool _isLoading = false; // Это _isLoading отвечает за кнопки на этой странице

  Future<void> _signInWithGoogle() async {
    final googleProvider = Provider.of<GoogleSignInProvider>(context, listen: false);
    // Получаем SettingsProvider до блока try, чтобы использовать его и в finally если нужно
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });
    try {
      await googleProvider.signInWithGoogle();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        // <--- ЗАГРУЗКА НАСТРОЕК ПОЛЬЗОВАТЕЛЯ --->
        await settingsProvider.loadSettingsFromFirebase();
        // <--- КОНЕЦ ЗАГРУЗКИ НАСТРОЕК --->

        // Теперь можно использовать settingsProvider.name для приветствия, если нужно
        Navigator.pushReplacementNamed(context, '/profile'); // Убедитесь, что роут '/profile' существует
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка входа через Google: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        print("Google sign-in error: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Получаем SettingsProvider до блока try
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (!mounted) return;

      // <--- ЗАГРУЗКА НАСТРОЕК ПОЛЬЗОВАТЕЛЯ --->
      // Загружаем настройки ДО отображения SnackBar и навигации
      await settingsProvider.loadSettingsFromFirebase();
      // <--- КОНЕЦ ЗАГРУЗКИ НАСТРОЕК --->

      // Теперь можно использовать имя из settingsProvider для приветствия
      String displayName = settingsProvider.name.isNotEmpty ? settingsProvider.name : (cred.user?.email ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Добро пожаловать, $displayName!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavigationWrapper()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Произошла ошибка входа.';
      if (e.code == 'user-not-found') {
        message = 'Пользователь с таким email не найден.';
      } else if (e.code == 'wrong-password') {
        message = 'Неверный пароль.';
      } else if (e.code == 'invalid-email') {
        message = 'Некорректный формат email адреса.';
      } else if (e.code == 'user-disabled') {
        message = 'Учетная запись этого пользователя отключена.';
      } else if (e.code == 'too-many-requests') {
        message = 'Слишком много попыток входа. Попробуйте позже.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Произошла неизвестная ошибка. Попробуйте снова.'),
            backgroundColor: Colors.red,
          ),
        );
        print("Sign in error: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // При регистрации мы обычно не загружаем настройки, так как их еще нет.
    // Но SettingsProvider.loadSettingsFromFirebase() должен уметь обрабатывать
    // случай нового пользователя (создавать дефолтные настройки в Firebase).
    // Если ты хочешь, чтобы дефолтные настройки (включая пустое имя)
    // были созданы в Firebase сразу после регистрации, то можно вызвать:
    // final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    // await settingsProvider.loadSettingsFromFirebase(); // Это создаст дефолтные данные для нового user.uid

    setState(() {
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    try {
      final cred = await auth.createUserWithEmailAndPassword( // Получаем cred, чтобы получить uid
        email: email,
        password: pass,
      );

      // <--- ОПЦИОНАЛЬНО: Создание дефолтных настроек для нового пользователя --->
      // Если SettingsProvider.loadSettingsFromFirebase() умеет создавать дефолтный документ
      // для нового пользователя, то это хорошее место для вызова.
      if (cred.user != null && mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        await settingsProvider.loadSettingsFromFirebase(); // Это должно создать дефолтные данные, если их нет
      }
      // <--- КОНЕЦ ОПЦИОНАЛЬНОЙ ЧАСТИ --->


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Аккаунт успешно создан! Пожалуйста, войдите.'),
          backgroundColor: Colors.green,
        ),
      );
      emailController.clear();
      passwordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'Произошла ошибка регистрации.';
      if (e.code == 'weak-password') {
        message = 'Пароль слишком слабый. Используйте не менее 6 символов.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Этот email уже используется другой учетной записью.';
      } else if (e.code == 'invalid-email') {
        message = 'Некорректный формат email адреса.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Произошла неизвестная ошибка при регистрации.'),
            backgroundColor: Colors.red,
          ),
        );
        print("Sign up error: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildLoadingIndicatorForTextButton() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // UI остается без изменений
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите ваш email.';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Пожалуйста, введите корректный email.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите ваш пароль.';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен содержать не менее 6 символов.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : signIn,
                child: _isLoading ? _buildLoadingIndicator() : const Text('Войти'),
              ),
              TextButton(
                onPressed: _isLoading ? null : signUp,
                child: _isLoading ? _buildLoadingIndicatorForTextButton() : const Text('Зарегистрироваться'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: _isLoading ? _buildLoadingIndicator() : const Text('Войти через Google'),
                onPressed: _isLoading ? null : _signInWithGoogle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}