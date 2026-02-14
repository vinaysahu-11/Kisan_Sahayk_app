import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'dart:io';
import '../theme/app_colors.dart';
import '../services/ai_service.dart';
import '../models/ai_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();
  final ImagePicker _imagePicker = ImagePicker();

  List<ChatMessage> _messages = [];
  String? _currentConversationId;
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String _selectedLanguage = 'en';
  String _selectedModel = 'advanced'; // advanced or fast
  
  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _loadConversationHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<void> _loadConversationHistory() async {
    try {
      final result = await _aiService.getHistory(type: 'chat', limit: 50);
      if (result['history'] != null) {
        setState(() {
          _conversations = (result['history'] as List)
              .map((c) => Conversation.fromJson(c))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    try {
      setState(() => _isLoading = true);
      final result = await _aiService.getConversation(conversationId);
      final conversation = Conversation.fromJson(result);
      
      setState(() {
        _currentConversationId = conversationId;
        _messages = conversation.messages;
        _isLoading = false;
      });
      
      Navigator.pop(context); // Close drawer
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load conversation');
    }
  }

  void _newChat() {
    setState(() {
      _messages = [];
      _currentConversationId = null;
    });
    Navigator.pop(context); // Close drawer
  }

  Future<void> _deleteConversation(String conversationId) async {
    try {
      await _aiService.deleteConversation(conversationId);
      await _loadConversationHistory();
      
      if (_currentConversationId == conversationId) {
        _newChat();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation deleted')),
      );
    } catch (e) {
      _showError('Failed to delete conversation');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    _textController.clear();
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _aiService.sendChatMessage(
        message: text,
        conversationId: _currentConversationId,
        language: _selectedLanguage,
      );

      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: response['message'] ?? 'No response',
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(assistantMessage);
        _currentConversationId = response['conversationId'];
        _isLoading = false;
        _isTyping = false;
      });

      _scrollToBottom();
      await _loadConversationHistory();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isTyping = false;
      });
      _showError('Failed to get AI response: $e');
    }
  }

  Future<void> _handleImagePick(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      // Convert to base64
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Show disease scan dialog
      _showDiseaseScanDialog(base64Image);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to process image: $e');
    }
  }

  void _showDiseaseScanDialog(String base64Image) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Scanning Plant...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Analyzing disease with AI Vision...'),
          ],
        ),
      ),
    );

    try {
      final result = await _aiService.scanDisease(
        imageBase64: base64Image,
        language: _selectedLanguage,
      );

      Navigator.pop(context); // Close loading dialog
      setState(() => _isLoading = false);

      final detection = DiseaseDetectionResult.fromJson(result);
      _showDiseaseResultDialog(detection);
    } catch (e) {
      Navigator.pop(context);
      setState(() => _isLoading = false);
      _showError('Failed to scan disease: $e');
    }
  }

  void _showDiseaseResultDialog(DiseaseDetectionResult detection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${detection.plantType} - ${detection.disease}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Confidence', '${(detection.confidence * 100).toStringAsFixed(1)}%'),
              if (detection.severity != null) 
                _buildInfoRow('Severity', detection.severity!.toUpperCase()),
              if (detection.symptoms != null)
                _buildSection('Symptoms', detection.symptoms!),
              if (detection.medicines.isNotEmpty)
                _buildListSection('Medicines', detection.medicines),
              if (detection.organicAlternatives.isNotEmpty)
                _buildListSection('Organic Alternatives', detection.organicAlternatives),
              if (detection.preventiveSteps.isNotEmpty)
                _buildListSection('Prevention', detection.preventiveSteps),
              if (detection.shops.isNotEmpty)
                _buildShopsSection(detection.shops),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSoilAnalysisDialog() {
    final phController = TextEditingController();
    final nController = TextEditingController();
    final pController = TextEditingController();
    final kController = TextEditingController();
    String selectedSeason = 'Kharif';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soil Analysis'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phController,
                decoration: const InputDecoration(labelText: 'pH Level'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nController,
                decoration: const InputDecoration(labelText: 'Nitrogen (kg/ha)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: pController,
                decoration: const InputDecoration(labelText: 'Phosphorus (kg/ha)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: kController,
                decoration: const InputDecoration(labelText: 'Potassium (kg/ha)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSeason,
                decoration: const InputDecoration(labelText: 'Season'),
                items: ['Kharif', 'Rabi', 'Zaid'].map((season) {
                  return DropdownMenuItem(value: season, child: Text(season));
                }).toList(),
                onChanged: (value) => selectedSeason = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phController.text.isEmpty ||
                  nController.text.isEmpty ||
                  pController.text.isEmpty ||
                  kController.text.isEmpty) {
                _showError('Please fill all fields');
                return;
              }

              Navigator.pop(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyzing soil data...'),
                    ],
                  ),
                ),
              );

              try {
                final result = await _aiService.analyzeSoil(
                  ph: double.parse(phController.text),
                  nitrogen: double.parse(nController.text),
                  phosphorus: double.parse(pController.text),
                  potassium: double.parse(kController.text),
                  season: selectedSeason,
                  language: _selectedLanguage,
                );

                Navigator.pop(context); // Close loading
                final analysis = SoilAnalysisResult.fromJson(result);
                _showSoilResultDialog(analysis);
              } catch (e) {
                Navigator.pop(context);
                _showError('Failed to analyze soil: $e');
              }
            },
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }

  void _showSoilResultDialog(SoilAnalysisResult analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soil Analysis Results'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(analysis.message, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              if (analysis.crops.isNotEmpty)
                _buildListSection('Recommended Crops', analysis.crops),
              if (analysis.fertilizers.isNotEmpty)
                _buildListSection('Fertilizers', analysis.fertilizers),
              if (analysis.organicSolutions.isNotEmpty)
                _buildListSection('Organic Solutions', analysis.organicSolutions),
              if (analysis.irrigation.isNotEmpty)
                _buildSection('Irrigation', analysis.irrigation),
              if (analysis.warnings.isNotEmpty)
                _buildListSection('Warnings', analysis.warnings),
              if (analysis.shops.isNotEmpty)
                _buildShopsSection(analysis.shops),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildShopsSection(List<AgriShop> shops) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏪 Nearby Shops',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...shops.map((shop) => Card(
                child: ListTile(
                  title: Text(shop.name),
                  subtitle: Text('${shop.distance} km • ${shop.address}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      // Launch phone dialer
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient(context),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
            _buildQuickActions(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('AI Krishi Mitra'),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient(context),
        ),
      ),
      actions: [
        // Model Selector
        PopupMenuButton<String>(
          icon: const Icon(Icons.psychology),
          tooltip: 'AI Model',
          onSelected: (value) {
            setState(() => _selectedModel = value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'advanced',
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: _selectedModel == 'advanced'
                          ? Theme.of(context).primaryColor
                          : null),
                  const SizedBox(width: 8),
                  const Text('Advanced (GPT-4o)'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'fast',
              child: Row(
                children: [
                  Icon(Icons.flash_on,
                      color: _selectedModel == 'fast'
                          ? Theme.of(context).primaryColor
                          : null),
                  const SizedBox(width: 8),
                  const Text('Fast Mode'),
                ],
              ),
            ),
          ],
        ),
        // Language Selector
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          tooltip: 'Language',
          onSelected: (value) {
            setState(() => _selectedLanguage = value);
            _saveLanguagePreference(value);
          },
          itemBuilder: (context) => [
            _buildLanguageMenuItem('en', 'English'),
            _buildLanguageMenuItem('hi', 'हिंदी'),
            _buildLanguageMenuItem('cg', 'छत्तीसगढ़ी'),
            _buildLanguageMenuItem('hinglish', 'Hinglish'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildLanguageMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(Icons.check,
              color: _selectedLanguage == value
                  ? Theme.of(context).primaryColor
                  : Colors.transparent),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
            ),
            child: const SafeArea(
              child: Center(
                child: Text(
                  'AI Conversations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('New Chat'),
            onTap: _newChat,
          ),
          const Divider(),
          Expanded(
            child: _conversations.isEmpty
                ? const Center(child: Text('No conversation history'))
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(
                          conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          conv.lastMessage ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteConversation(conv.id),
                        ),
                        selected: _currentConversationId == conv.id,
                        onTap: () => _loadConversation(conv.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to AI Krishi Mitra',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your intelligent farming assistant\nAsk me anything about agriculture!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('Best crops for this season?'),
                _buildSuggestionChip('How to improve soil health?'),
                _buildSuggestionChip('Organic pest control methods'),
                _buildSuggestionChip('Fertilizer recommendations'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => _handleSubmitted(text),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Text(
                message.content,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Thinking...'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.science,
              label: 'Soil Test',
              onPressed: _showSoilAnalysisDialog,
            ),
            _buildQuickActionButton(
              icon: Icons.camera_alt,
              label: 'Scan Disease',
              onPressed: () => _handleImagePick(ImageSource.camera),
            ),
            _buildQuickActionButton(
              icon: Icons.photo_library,
              label: 'From Gallery',
              onPressed: () => _handleImagePick(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: _isLoading
                  ? null
                  : () {
                      // TODO: Implement voice recording
                      _showError('Voice feature coming soon!');
                    },
              tooltip: 'Voice',
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: _selectedLanguage == 'hi'
                      ? 'कुछ भी पूछें...'
                      : _selectedLanguage == 'cg'
                          ? 'कुछु भी पूछव...'
                          : 'Ask me anything...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _handleSubmitted,
                enabled: !_isLoading,
              ),
            ),
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _isLoading
                  ? null
                  : () => _handleSubmitted(_textController.text),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}
