/// On-device CivicConnect assistant. Used when the backend chat API is unreachable
/// so Ask AI still answers thoroughly.
class LocalChatAssistant {
  LocalChatAssistant._();

  static const overview =
      'CivicConnect is a mobile app for apartment residents to report and track building issues with management.\n\n'
      'Main tabs:\n'
      '• Home — greeting, quick actions (Report an issue / Ask AI), open/resolved/total counts, category filters, and a recent reports feed. Pull down to refresh.\n'
      '• Reports — browse all apartment reports. Filter by category and status, then tap a card for full details.\n'
      '• Submit — create a new issue with title, category, description, location (e.g. Block B, 3rd floor), and an optional photo.\n'
      '• Ask AI — this chat. Ask anything about how CivicConnect works.\n'
      '• Profile — your name/username/role, stats (submitted / pending / resolved), edit profile (name + photo), and a list of your own reports.\n\n'
      'Categories: Maintenance, Water, Electricity, Safety, Parking, Noise, Other.\n\n'
      'Statuses:\n'
      '• Pending — submitted and waiting\n'
      '• In Progress — building management is working on it\n'
      '• Resolved — fixed/closed\n\n'
      'Typical flow: Sign Up or Login → Submit an issue → track it in Profile → browse others in Reports → Ask AI anytime for guidance.';

  static String reply(String message) {
    final text = message.toLowerCase().trim();

    if (RegExp(r'^(hello|hi|hey|good (morning|afternoon|evening))[\s!,.]*$')
        .hasMatch(text)) {
      return 'Hello! I\'m your CivicConnect guide. I give complete answers about the app.\n\n'
          'Ask me anything, for example:\n'
          '• What is CivicConnect?\n'
          '• How do I use this app?\n'
          '• What do the tabs do?\n'
          '• How do I report an issue?\n'
          '• What do statuses mean?\n'
          '• How do I edit my profile?\n\n'
          'I will cover every relevant detail in my reply.';
    }

    if (RegExp(r'^(thank|thanks|thx)[\s!,.]*$').hasMatch(text)) {
      return 'You’re welcome! Ask anytime — for the full app overview say “What is CivicConnect?” '
          'or ask about any tab/feature and I’ll explain everything related to it.';
    }

    final parts = <String>[];

    if (_any(text, [
      'what is this app',
      'what does this app',
      'what is civicconnect',
      'about the app',
      'about app',
      'app overview',
      'tell me about',
      'features',
      'what can i',
      'what can this',
      'how does this app',
      'how does the app',
      'explain the app',
      'explain app',
      'everything',
      'full guide',
      'full overview',
      'overview',
    ])) {
      parts.add(overview);
    }

    if (_any(text, [
      'tab',
      'navigate',
      'navigation',
      'menu',
      'where do i',
      'where is',
      'bottom bar',
      'bottom nav',
      'screen',
      'section',
    ])) {
      parts.add(
        'CivicConnect has 5 bottom tabs:\n\n'
        '1. Home\n'
        '• Greets you by name\n'
        '• Shortcuts: Report an issue, Ask AI for help\n'
        '• Shows Open / Resolved / Total counts\n'
        '• Category chips to filter recent reports\n'
        '• Recent reports feed (tap a card for details)\n'
        '• Logout icon in the top-right\n\n'
        '2. Reports\n'
        '• Full list of building reports\n'
        '• Filter by category and status\n'
        '• Tap any report for description, photo, location, and status\n\n'
        '3. Submit\n'
        '• File a new apartment issue\n'
        '• Fill title, category, description, location\n'
        '• Optional photo from camera or gallery\n\n'
        '4. Ask AI\n'
        '• Chat with me for complete app guidance\n\n'
        '5. Profile\n'
        '• Your details and report stats\n'
        '• Edit name/photo\n'
        '• See only your submitted reports\n\n'
        'Tap any tab anytime to switch.',
      );
    }

    if (_any(text, [
      'how do i use',
      'how to use',
      'getting started',
      'start',
      'guide',
      'tutorial',
      'walkthrough',
      'steps',
    ])) {
      parts.add(
        'Complete guide to using CivicConnect:\n\n'
        '1. Create an account\n'
        '• Sign Up with full name, email, password (min 6 characters)\n'
        '• Then Sign In with the same email/password\n\n'
        '2. Explore Home\n'
        '• See greeting, counts, categories, recent reports\n'
        '• Use Report an issue or Ask AI shortcuts\n\n'
        '3. Submit an issue\n'
        '• Open Submit\n'
        '• Add title, category, description, location, optional photo\n'
        '• Tap submit\n\n'
        '4. Track progress\n'
        '• Profile shows your reports and stats\n'
        '• Reports shows all building issues with filters\n'
        '• Status moves: Pending → In Progress → Resolved\n\n'
        '5. Get help anytime in Ask AI',
      );
    }

    if (_any(text, [
      'how do i report',
      'how to report',
      'submit',
      'create a report',
      'new issue',
      'file an issue',
      'leak',
      'broken',
      'problem',
      'complaint',
      'report an issue',
    ])) {
      parts.add(
        'How to report an issue in CivicConnect (full steps):\n\n'
        '1. Open the Submit tab\n'
        '2. Enter a clear title (example: “Water leaking near Block A stairs”)\n'
        '3. Choose a category (Maintenance, Water, Electricity, Safety, Parking, Noise, or Other)\n'
        '4. Write a detailed description\n'
        '5. Add location (example: “Block B, 3rd floor near lift”)\n'
        '6. Optional: attach a photo from Camera or Gallery\n'
        '7. Tap submit\n\n'
        'After submitting:\n'
        '• Status starts as Pending\n'
        '• Find it under Profile → your reports\n'
        '• It can also appear in Home and Reports\n'
        '• Tap the report anytime for full details\n\n'
        'Tips: be specific about location, add a photo when possible, pick the closest category.',
      );
    }

    if (_any(text, ['home', 'dashboard'])) {
      parts.add(
        'Home is your CivicConnect overview. It includes:\n\n'
        '• Header with your name and logout\n'
        '• Building intro card\n'
        '• Buttons: Report an issue (opens Submit) and Ask AI for help\n'
        '• Stats: Open, Resolved, Total\n'
        '• Category chips to filter the feed\n'
        '• Recent reports list — tap for details, or View all for Reports\n'
        '• Pull down to refresh\n\n'
        'Use Home to quickly see building activity and jump into action.',
      );
    }

    if (_any(text, ['reports', 'browse', 'filter'])) {
      parts.add(
        'The Reports tab shows apartment issues in detail:\n\n'
        '• Full list of building reports\n'
        '• Filter by category chips\n'
        '• Filter by status: All, Pending, In Progress, Resolved\n'
        '• Tap a card for title, description, location, photo, status, and who submitted it\n'
        '• Pull to refresh for updates\n\n'
        'Use Reports for the complete feed, not just recent items on Home.',
      );
    }

    if (_any(text, [
      'status',
      'pending',
      'in progress',
      'in-progress',
      'resolved',
      'track',
    ])) {
      parts.add(
        'CivicConnect report statuses:\n\n'
        '• Pending — submitted and waiting\n'
        '• In Progress — building management is handling it\n'
        '• Resolved — fixed/closed\n\n'
        'Where to track:\n'
        '• Profile — your reports + submitted/pending/resolved counts\n'
        '• Reports — filter the building list by status\n'
        '• Home — open/resolved/total counts and recent feed\n'
        '• Report detail — current status badge\n\n'
        'Admin accounts can update status on the report detail screen.',
      );
    }

    if (_any(text, [
      'categor',
      'which type',
      'what type',
      'maintenance',
      'water',
      'electric',
      'safety',
      'parking',
      'noise',
    ])) {
      parts.add(
        'CivicConnect categories (choose one when submitting):\n\n'
        '• Maintenance — lifts, doors, common-area repairs\n'
        '• Water — leaks, supply, drainage\n'
        '• Electricity — lights, outages, wiring\n'
        '• Safety — hazards, rails, security concerns\n'
        '• Lighting — dark hallways / stairwells (also suggested by the light sensor)\n'
        '• Parking — blocked spots, visitor parking\n'
        '• Noise — loud disturbances\n'
        '• Other — anything else\n\n'
        'Home and Reports can filter by these same categories. Pick the closest match.',
      );
    }

    if (_any(text, [
      'sensor',
      'shake',
      'light sensor',
      'lux',
      'accelerometer',
      'bump',
    ])) {
      parts.add(
        'CivicConnect uses two phone sensors:\n\n'
        '1. Light sensor — if the hallway/stairwell is very dark (low lux), '
        'the app can suggest a Lighting / Safety report and may switch to a darker UI.\n'
        '2. Accelerometer — shake the phone to open Report an issue quickly. '
        'A hard bump can also suggest a Safety report.\n\n'
        'These run while you are on the dashboard.',
      );
    }

    if (_any(text, [
      'photo',
      'image',
      'camera',
      'picture',
      'upload',
      'gallery',
    ])) {
      parts.add(
        'Photos in CivicConnect:\n\n'
        '1. Issue photos (Submit tab)\n'
        '• Tap the image area\n'
        '• Choose Camera or Gallery\n'
        '• Attach a clear photo of the problem\n'
        '• Optional, but recommended\n\n'
        '2. Profile photo (Profile → Edit)\n'
        '• Update your account picture\n'
        '• Email stays the same for login\n\n'
        'Clear photos help management understand and fix issues faster.',
      );
    }

    if (_any(text, [
      'profile',
      'edit my name',
      'edit name',
      'my reports',
      'account',
      'stats',
    ])) {
      parts.add(
        'Profile is your personal CivicConnect area:\n\n'
        '• Display name, username, and role\n'
        '• Stats: submitted, pending, resolved\n'
        '• Edit — change name and/or profile photo\n'
        '• Your reports list (only issues you submitted)\n'
        '• Tap any report for full details\n'
        '• Pull down to refresh\n\n'
        'Email is used for login and is not changed in Edit Profile.',
      );
    }

    if (_any(text, [
      'login',
      'sign in',
      'signin',
      'password',
      'register',
      'sign up',
      'signup',
      'logout',
      'log out',
      'sign out',
    ])) {
      parts.add(
        'Accounts in CivicConnect:\n\n'
        'Sign Up:\n'
        '• Full name, email, password (min 6 characters), confirm password\n\n'
        'Sign In:\n'
        '• Same email + password\n'
        '• Opens the dashboard tabs after success\n\n'
        'Session:\n'
        '• Stay signed in until logout\n'
        '• Logout icon is top-right on Home\n\n'
        'If login fails, check credentials and that the backend server is running.',
      );
    }

    if (_any(text, ['ask ai', 'chat', 'assistant', 'this chat', 'this tab'])) {
      parts.add(
        'Ask AI is CivicConnect’s in-app guide. I explain:\n\n'
        '• What the app is and what each tab does\n'
        '• How to submit reports step by step\n'
        '• Categories and statuses\n'
        '• Photos, profile, login/signup\n'
        '• Where to find your own reports\n\n'
        'Use suggestion chips or type any question. I answer with full details.',
      );
    }

    if (_any(text, [
      'admin',
      'role',
      'management update',
      'change status',
    ])) {
      parts.add(
        'Roles in CivicConnect:\n\n'
        '• Residents (user)\n'
        '  – sign up/login\n'
        '  – submit reports\n'
        '  – use Home / Reports / Profile / Ask AI\n\n'
        '• Admins\n'
        '  – everything residents can do\n'
        '  – update report status on detail screen: Pending → In Progress → Resolved\n\n'
        'Residents track progress; admins update status.',
      );
    }

    if (_any(text, [
      'emergency',
      'fire',
      'ambulance',
      'police',
      'urgent',
      'danger',
    ])) {
      parts.add(
        'Safety first:\n'
        '• For life-threatening emergencies, contact local emergency services immediately.\n'
        '• For non-emergency building hazards, submit a Safety report in CivicConnect (Submit tab) with clear details and a photo if possible.\n'
        '• Also notify your building security/management directly.\n\n'
        'CivicConnect documents and tracks building issues — emergency response comes first.',
      );
    }

    if (parts.isEmpty) {
      return 'Here is the complete CivicConnect overview for your question:\n\n'
          '$overview\n\n'
          'You can also ask specifically about:\n'
          '• Tabs / navigation\n'
          '• How to report an issue\n'
          '• Categories\n'
          '• Statuses\n'
          '• Photos\n'
          '• Profile\n'
          '• Login / signup / logout';
    }

    return parts.join('\n\n————\n\n');
  }

  static bool _any(String text, List<String> keys) {
    for (final key in keys) {
      if (text.contains(key)) return true;
    }
    return false;
  }
}
