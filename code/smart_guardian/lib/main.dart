import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SmartGuardianApp());
}

class SmartGuardianApp extends StatelessWidget {
  const SmartGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Guardian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

// ============================================
// Navigation principale avec BottomNavigationBar
// ============================================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const HomePage(), const RobotControlPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.videocam_outlined),
            selectedIcon: Icon(Icons.videocam),
            label: 'Surveillance',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Robot',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isStreamOpen = false;
  final String _streamUrl = 'http://192.168.137.61:5000/video_feed';

  void _toggleStream() {
    setState(() {
      _isStreamOpen = !_isStreamOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 28),
            SizedBox(width: 10),
            Text(
              'Smart Guardian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou icône
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.videocam,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),

              // Titre
              Text(
                'Surveillance Vidéo',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cliquez pour ouvrir le flux vidéo',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 40),

              // Bouton principal
              ElevatedButton.icon(
                onPressed: _toggleStream,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  backgroundColor: _isStreamOpen
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                icon: Icon(
                  _isStreamOpen ? Icons.stop : Icons.play_arrow,
                  size: 28,
                ),
                label: Text(
                  _isStreamOpen ? 'Fermer le Stream' : 'Ouvrir le Stream',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Zone de visualisation du stream
              if (_isStreamOpen)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Mjpeg(
                        stream: _streamUrl,
                        isLive: true,
                        fit: BoxFit.cover,
                        loading: (context) => Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        error: (context, error, stack) => Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 50,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Erreur: $error',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (!_isStreamOpen)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      const Flexible(
                        child: Text(
                          'Le flux vidéo sera affiché ici',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// Page de contrôle du Robot
// ============================================
class RobotControlPage extends StatefulWidget {
  const RobotControlPage({super.key});

  @override
  State<RobotControlPage> createState() => _RobotControlPageState();
}

class _RobotControlPageState extends State<RobotControlPage> {
  final String _baseUrl = 'http://192.168.137.61:5000';
  final String _streamUrl = 'http://192.168.137.61:5000/video_feed';
  String _status = 'Prêt';
  bool _isConnected = false;
  bool _isLoading = false;
  String _drivingMode = 'manual'; // Mode de conduite: "auto" ou "manual"

  @override
  void initState() {
    super.initState();
    // Test de connexion au démarrage
    _checkConnection();
    _getDrivingMode();
  }

  Future<void> _checkConnection() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true;
          _status = 'Connecté au serveur';
        });
        // Récupérer le mode de conduite
        _getDrivingMode();
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _status =
            'Erreur: ${e.toString().length > 40 ? e.toString().substring(0, 40) : e.toString()}';
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _getDrivingMode() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/robot/mode'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = response.body;
        // Parse la réponse JSON
        if (data.contains('"driving_mode"')) {
          if (data.contains('"auto"')) {
            setState(() => _drivingMode = 'auto');
          } else {
            setState(() => _drivingMode = 'manual');
          }
        }
      }
    } catch (e) {
      // Erreur silencieuse, on garde le mode par défaut
    }
  }

  Future<void> _setAutoMode() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/robot/auto'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          _drivingMode = 'auto';
          _status = 'Mode automatique activé';
        });
      }
    } catch (e) {
      setState(() => _status = 'Erreur activation mode auto');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _setManualMode() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/robot/manual'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          _drivingMode = 'manual';
          _status = 'Mode manuel activé';
        });
      }
    } catch (e) {
      setState(() => _status = 'Erreur activation mode manuel');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _sendCommand(String command) async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/robot/$command'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Commande $command envoyée';
          _isConnected = true;
        });
      } else {
        setState(() => _status = 'Erreur: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _status = 'Erreur: ${e.toString()}';
        _isConnected = false;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _connectBluetooth() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/robot/connect'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Bluetooth connecté';
          _isConnected = true;
        });
      } else {
        setState(() => _status = 'Échec connexion: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _status = 'Erreur: ${e.toString()}';
        _isConnected = false;
      });
    }
    setState(() => _isLoading = false);
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required String command,
    Color? color,
  }) {
    return GestureDetector(
      onTapDown: (_) => _sendCommand(command),
      onTapUp: (_) => _sendCommand('S'),
      onTapCancel: () => _sendCommand('S'),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (color ?? Theme.of(context).colorScheme.primary)
                  .withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, size: 28),
            SizedBox(width: 10),
            Text(
              'Contrôle Robot',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Zone de visualisation de la caméra avec MJPEG
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Mjpeg(
                    stream: _streamUrl,
                    isLive: true,
                    fit: BoxFit.cover,
                    timeout: const Duration(seconds: 10),
                    loading: (context) => Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Connexion à $_streamUrl',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (context, error, stack) => Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.videocam_off,
                              color: Colors.red,
                              size: 50,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Erreur: $error',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status et connexion Bluetooth
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _status,
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Afficher l'URL du serveur
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Serveur: $_baseUrl',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),

              const SizedBox(height: 10),

              // Boutons de connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouton test connexion
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkConnection,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.green,
                    ),
                    icon: const Icon(Icons.wifi, color: Colors.white),
                    label: const Text(
                      'Tester',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Bouton connexion Bluetooth
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _connectBluetooth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    icon: const Icon(
                      Icons.bluetooth_searching,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Bluetooth',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Section Mode de conduite
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _drivingMode == 'auto'
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _drivingMode == 'auto' ? Colors.orange : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _drivingMode == 'auto'
                              ? Icons.smart_toy
                              : Icons.gamepad,
                          color: _drivingMode == 'auto'
                              ? Colors.orange
                              : Colors.blue,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Mode: ${_drivingMode == 'auto' ? 'Automatique' : 'Manuel'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _drivingMode == 'auto'
                                ? Colors.orange
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bouton Mode Manuel
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading || _drivingMode == 'manual'
                                ? null
                                : _setManualMode,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: _drivingMode == 'manual'
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            icon: const Icon(Icons.gamepad, color: Colors.white),
                            label: const Text(
                              'Manuel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Bouton Mode Auto
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading || _drivingMode == 'auto'
                                ? null
                                : _setAutoMode,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: _drivingMode == 'auto'
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            icon: const Icon(Icons.smart_toy, color: Colors.white),
                            label: const Text(
                              'Auto',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Bouton pour rafraîchir le statut
                    TextButton.icon(
                      onPressed: _isLoading ? null : _getDrivingMode,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Actualiser le statut'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Contrôles directionnels
              const Text(
                '🎮 Contrôles',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Bouton Avancer
              _buildControlButton(
                icon: Icons.arrow_upward,
                label: 'Avancer',
                command: 'F',
              ),

              const SizedBox(height: 10),

              // Ligne avec Gauche, Stop, Droite
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: Icons.arrow_back,
                    label: 'Gauche',
                    command: 'L',
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendCommand('S'),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop, size: 32, color: Colors.white),
                          SizedBox(height: 4),
                          Text(
                            'STOP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildControlButton(
                    icon: Icons.arrow_forward,
                    label: 'Droite',
                    command: 'R',
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Bouton Reculer
              _buildControlButton(
                icon: Icons.arrow_downward,
                label: 'Reculer',
                command: 'B',
              ),

              const SizedBox(height: 30),

              // Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Maintenez les boutons pour déplacer le robot. Relâchez pour arrêter.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
