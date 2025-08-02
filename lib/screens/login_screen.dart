import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'home_screen.dart';

/// Screen for managing user profiles and login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  List<UserProfile> _profiles = [];
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  UserProfile? _editingProfile;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final profiles = await ProfileService.getProfiles();
      setState(() => _profiles = profiles);
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Error al cargar perfiles: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = UserProfile(
        id: _editingProfile?.id ?? ProfileService.generateProfileId(),
        name: _nameController.text.trim(),
        host: _hostController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        createdAt: _editingProfile?.createdAt ?? DateTime.now(),
        lastUsed: _editingProfile?.lastUsed,
      );

      await ProfileService.saveProfile(profile);
      await _loadProfiles();
      _clearForm();
      
      if (mounted) {
        AppHelpers.showSuccess(context, 
          _editingProfile != null ? 'Perfil actualizado' : 'Perfil guardado');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Error al guardar perfil: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProfile(UserProfile profile) async {
    final confirmed = await _showDeleteConfirmation(profile.name);
    if (!confirmed) return;

    try {
      await ProfileService.deleteProfile(profile.id);
      await _loadProfiles();
      
      if (mounted) {
        AppHelpers.showSuccess(context, 'Perfil eliminado');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Error al eliminar perfil: $e');
      }
    }
  }

  Future<void> _selectProfile(UserProfile profile) async {
    setState(() => _isLoading = true);

    try {
      await ProfileService.setActiveProfile(profile.id);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Error al seleccionar perfil: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void _editProfile(UserProfile profile) {
    setState(() {
      _editingProfile = profile;
      _nameController.text = profile.name;
      _hostController.text = profile.host;
      _usernameController.text = profile.username;
      _passwordController.text = profile.password;
    });
  }

  void _clearForm() {
    setState(() => _editingProfile = null);
    _nameController.clear();
    _hostController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  Future<bool> _showDeleteConfirmation(String profileName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text('¿Estás seguro de que deseas eliminar el perfil "$profileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Perfiles IPTV'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Profile form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _editingProfile != null ? 'Editar Perfil' : 'Nuevo Perfil',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del perfil',
                                hintText: 'Mi proveedor IPTV',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa un nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            
                            TextFormField(
                              controller: _hostController,
                              decoration: const InputDecoration(
                                labelText: 'Host/Servidor',
                                hintText: 'http://mi-servidor:8080',
                                prefixIcon: Icon(Icons.dns),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa el host';
                                }
                                if (!value.startsWith('http://') && !value.startsWith('https://')) {
                                  return 'El host debe comenzar con http:// o https://';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(Icons.account_circle),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa el usuario';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible 
                                        ? Icons.visibility_off 
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa la contraseña';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.defaultPadding * 1.5),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _saveProfile,
                                    icon: Icon(_editingProfile != null ? Icons.save : Icons.add),
                                    label: Text(_editingProfile != null ? 'Actualizar' : 'Guardar'),
                                  ),
                                ),
                                if (_editingProfile != null) ...[
                                  const SizedBox(width: AppConstants.defaultPadding),
                                  ElevatedButton(
                                    onPressed: _clearForm,
                                    child: const Text('Cancelar'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // Profiles list
                  Expanded(
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            child: Row(
                              children: [
                                Text(
                                  'Perfiles guardados',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Spacer(),
                                if (_profiles.isNotEmpty)
                                  Text(
                                    '${_profiles.length} perfil${_profiles.length == 1 ? '' : 'es'}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          
                          if (_profiles.isEmpty)
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'No hay perfiles guardados.\nCrea uno para comenzar.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: _profiles.length,
                                itemBuilder: (context, index) {
                                  final profile = _profiles[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(profile.name[0].toUpperCase()),
                                    ),
                                    title: Text(profile.name),
                                    subtitle: Text(profile.host),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editProfile(profile),
                                          tooltip: 'Editar',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteProfile(profile),
                                          tooltip: 'Eliminar',
                                        ),
                                      ],
                                    ),
                                    onTap: () => _selectProfile(profile),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}