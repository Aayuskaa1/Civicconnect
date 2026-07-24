import { Request, Response, NextFunction } from 'express';
import { ChatMessageSchema } from '../dtos/chat.dto';
import { sendResponse } from '../utils/apihelper.util';

const APP_OVERVIEW = `CivicConnect is a mobile app for apartment residents to report and track building issues with management.

Main tabs:
• Home — greeting, quick actions (Report an issue / Ask AI), open/resolved/total counts, category filters, and a recent reports feed. Pull down to refresh.
• Reports — browse all apartment reports. Filter by category and status, then tap a card for full details.
• Submit — create a new issue with title, category, description, location (e.g. Block B, 3rd floor), and an optional photo.
• Ask AI — this chat. Ask anything about how CivicConnect works.
• Profile — your name/username/role, stats (submitted / pending / resolved), edit profile (name + photo), and a list of your own reports.

Categories: Maintenance, Water, Electricity, Safety, Parking, Noise, Other.

Statuses:
• Pending — submitted and waiting
• In Progress — building management is working on it
• Resolved — fixed/closed

Typical flow: Sign Up or Login → Submit an issue → track it in Profile → browse others in Reports → Ask AI anytime for guidance.`;

const SYSTEM_CONTEXT = `You are CivicConnect Assistant. Always answer thoroughly and completely.
Cover every part of the user's question. Include related app details (tabs, steps, categories, statuses, profile, photos) when useful.
Use clear bullet points. Never give a tiny one-line answer if more detail helps.
Stay on CivicConnect and apartment building topics only.`;

type Topic = {
  id: string;
  patterns: RegExp[];
  answer: string;
};

const TOPICS: Topic[] = [
  {
    id: 'overview',
    patterns: [
      /what (is|does) (this )?app/,
      /what is civicconnect/,
      /about (the )?app/,
      /app (info|information|overview)/,
      /tell me about/,
      /features/,
      /what can (i|this app)/,
      /how does (this|the) app/,
      /explain (the )?app/,
      /everything/,
      /full (guide|overview)/,
      /overview/,
    ],
    answer: APP_OVERVIEW,
  },
  {
    id: 'tabs',
    patterns: [
      /tab/,
      /navigate/,
      /navigation/,
      /menu/,
      /where (do i|is)/,
      /bottom (bar|nav)/,
      /screens?/,
      /sections?/,
    ],
    answer:
      'CivicConnect has 5 bottom tabs:\n\n' +
      '1. Home\n' +
      '• Greets you by name\n' +
      '• Shortcuts: Report an issue, Ask AI for help\n' +
      '• Shows Open / Resolved / Total counts\n' +
      '• Category chips to filter recent reports\n' +
      '• Recent reports feed (tap a card for details)\n' +
      '• Logout icon in the top-right\n\n' +
      '2. Reports\n' +
      '• Full list of building reports\n' +
      '• Filter by category and status\n' +
      '• Tap any report for description, photo, location, and status\n\n' +
      '3. Submit\n' +
      '• File a new apartment issue\n' +
      '• Fill title, category, description, location\n' +
      '• Optional photo from camera or gallery\n\n' +
      '4. Ask AI\n' +
      '• Chat with me for complete app guidance\n\n' +
      '5. Profile\n' +
      '• Your details and report stats\n' +
      '• Edit name/photo\n' +
      '• See only your submitted reports\n\n' +
      'Tap any tab anytime to switch.',
  },
  {
    id: 'howto',
    patterns: [
      /how (do i |to )?use/,
      /getting started/,
      /\bstart\b/,
      /guide/,
      /tutorial/,
      /walkthrough/,
      /steps/,
    ],
    answer:
      'Complete guide to using CivicConnect:\n\n' +
      '1. Create an account\n' +
      '• Sign Up with full name, email, password (min 6 characters)\n' +
      '• Then Sign In with the same email/password\n\n' +
      '2. Explore Home\n' +
      '• See greeting, counts, categories, recent reports\n' +
      '• Use Report an issue or Ask AI shortcuts\n\n' +
      '3. Submit an issue\n' +
      '• Open Submit\n' +
      '• Add title, category, description, location, optional photo\n' +
      '• Tap submit\n\n' +
      '4. Track progress\n' +
      '• Profile shows your reports and stats\n' +
      '• Reports shows all building issues with filters\n' +
      '• Status moves: Pending → In Progress → Resolved\n\n' +
      '5. Get help anytime in Ask AI',
  },
  {
    id: 'submit',
    patterns: [
      /how (do i |to )?report/,
      /submit/,
      /create (a )?report/,
      /new issue/,
      /file (an )?issue/,
      /leak/,
      /broken/,
      /problem/,
      /complaint/,
    ],
    answer:
      'How to report an issue in CivicConnect (full steps):\n\n' +
      '1. Open the Submit tab\n' +
      '2. Enter a clear title (example: “Water leaking near Block A stairs”)\n' +
      '3. Choose a category (Maintenance, Water, Electricity, Safety, Parking, Noise, or Other)\n' +
      '4. Write a detailed description\n' +
      '5. Add location (example: “Block B, 3rd floor near lift”)\n' +
      '6. Optional: attach a photo from Camera or Gallery\n' +
      '7. Tap submit\n\n' +
      'After submitting:\n' +
      '• Status starts as Pending\n' +
      '• Find it under Profile → your reports\n' +
      '• It can also appear in Home and Reports\n' +
      '• Tap the report anytime for full details\n\n' +
      'Tips: be specific about location, add a photo when possible, pick the closest category.',
  },
  {
    id: 'home',
    patterns: [/home( screen| tab)?/, /dashboard/],
    answer:
      'Home is your CivicConnect overview. It includes:\n\n' +
      '• Header with your name and logout\n' +
      '• Building intro card\n' +
      '• Buttons: Report an issue (opens Submit) and Ask AI for help\n' +
      '• Stats: Open, Resolved, Total\n' +
      '• Category chips to filter the feed\n' +
      '• Recent reports list — tap for details, or View all for Reports\n' +
      '• Pull down to refresh\n\n' +
      'Use Home to quickly see building activity and jump into action.',
  },
  {
    id: 'reports',
    patterns: [/reports?( screen| tab| list)?/, /browse/, /filter/],
    answer:
      'The Reports tab shows apartment issues in detail:\n\n' +
      '• Full list of building reports\n' +
      '• Filter by category chips\n' +
      '• Filter by status: All, Pending, In Progress, Resolved\n' +
      '• Tap a card for title, description, location, photo, status, and who submitted it\n' +
      '• Pull to refresh for updates\n\n' +
      'Use Reports for the complete feed, not just recent items on Home.',
  },
  {
    id: 'status',
    patterns: [/status/, /pending/, /in.?progress/, /resolved/, /track/],
    answer:
      'CivicConnect report statuses:\n\n' +
      '• Pending — submitted and waiting\n' +
      '• In Progress — building management is handling it\n' +
      '• Resolved — fixed/closed\n\n' +
      'Where to track:\n' +
      '• Profile — your reports + submitted/pending/resolved counts\n' +
      '• Reports — filter the building list by status\n' +
      '• Home — open/resolved/total counts and recent feed\n' +
      '• Report detail — current status badge\n\n' +
      'Admin accounts can update status on the report detail screen.',
  },
  {
    id: 'category',
    patterns: [
      /categor/,
      /which type/,
      /what type/,
      /maintenance/,
      /water/,
      /electric/,
      /safety/,
      /parking/,
      /noise/,
    ],
    answer:
      'CivicConnect categories (choose one when submitting):\n\n' +
      '• Maintenance — lifts, doors, common-area repairs\n' +
      '• Water — leaks, supply, drainage\n' +
      '• Electricity — lights, outages, wiring\n' +
      '• Safety — hazards, rails, security concerns\n' +
      '• Parking — blocked spots, visitor parking\n' +
      '• Noise — loud disturbances\n' +
      '• Other — anything else\n\n' +
      'Home and Reports can filter by these same categories. Pick the closest match.',
  },
  {
    id: 'photo',
    patterns: [/photo/, /image/, /camera/, /picture/, /upload/, /gallery/],
    answer:
      'Photos in CivicConnect:\n\n' +
      '1. Issue photos (Submit tab)\n' +
      '• Tap the image area\n' +
      '• Choose Camera or Gallery\n' +
      '• Attach a clear photo of the problem\n' +
      '• Optional, but recommended\n\n' +
      '2. Profile photo (Profile → Edit)\n' +
      '• Update your account picture\n' +
      '• Email stays the same for login\n\n' +
      'Clear photos help management understand and fix issues faster.',
  },
  {
    id: 'profile',
    patterns: [/profile/, /edit (my )?name/, /my reports/, /account/, /stats/],
    answer:
      'Profile is your personal CivicConnect area:\n\n' +
      '• Display name, username, and role\n' +
      '• Stats: submitted, pending, resolved\n' +
      '• Edit — change name and/or profile photo\n' +
      '• Your reports list (only issues you submitted)\n' +
      '• Tap any report for full details\n' +
      '• Pull down to refresh\n\n' +
      'Email is used for login and is not changed in Edit Profile.',
  },
  {
    id: 'auth',
    patterns: [
      /login/,
      /sign ?in/,
      /password/,
      /register/,
      /sign ?up/,
      /account create/,
      /logout/,
      /log out/,
      /sign out/,
    ],
    answer:
      'Accounts in CivicConnect:\n\n' +
      'Sign Up:\n' +
      '• Full name, email, password (min 6 characters), confirm password\n\n' +
      'Sign In:\n' +
      '• Same email + password\n' +
      '• Opens the dashboard tabs after success\n\n' +
      'Session:\n' +
      '• Stay signed in until logout\n' +
      '• Logout icon is top-right on Home\n\n' +
      'If login fails, check credentials and that the backend server is running.',
  },
  {
    id: 'askai',
    patterns: [/ask ai/, /chat/, /assistant/, /this (chat|tab)/],
    answer:
      'Ask AI is CivicConnect’s in-app guide. I explain:\n\n' +
      '• What the app is and what each tab does\n' +
      '• How to submit reports step by step\n' +
      '• Categories and statuses\n' +
      '• Photos, profile, login/signup\n' +
      '• Where to find your own reports\n\n' +
      'Use suggestion chips or type any question. I answer with full details.',
  },
  {
    id: 'admin',
    patterns: [/admin/, /role/, /management update/, /change status/],
    answer:
      'Roles in CivicConnect:\n\n' +
      '• Residents (user)\n' +
      '  – sign up/login\n' +
      '  – submit reports\n' +
      '  – use Home / Reports / Profile / Ask AI\n\n' +
      '• Admins\n' +
      '  – everything residents can do\n' +
      '  – update report status on detail screen: Pending → In Progress → Resolved\n\n' +
      'Residents track progress; admins update status.',
  },
  {
    id: 'emergency',
    patterns: [/emergency/, /fire/, /ambulance/, /police/, /urgent/, /danger/],
    answer:
      'Safety first:\n' +
      '• For life-threatening emergencies, contact local emergency services immediately.\n' +
      '• For non-emergency building hazards, submit a Safety report in CivicConnect (Submit tab) with clear details and a photo if possible.\n' +
      '• Also notify your building security/management directly.\n\n' +
      'CivicConnect documents and tracks building issues — emergency response comes first.',
  },
];

function isMostlyGreeting(text: string): boolean {
  return /^(hello|hi|hey|good (morning|afternoon|evening))[\s!,.]*$/i.test(text);
}

function buildReply(message: string): string {
  const text = message.toLowerCase().trim();

  if (isMostlyGreeting(text)) {
    return (
      'Hello! I\'m your CivicConnect guide. I give complete answers about the app.\n\n' +
      'Ask me anything, for example:\n' +
      '• What is CivicConnect?\n' +
      '• How do I use this app?\n' +
      '• What do the tabs do?\n' +
      '• How do I report an issue?\n' +
      '• What do statuses mean?\n' +
      '• How do I edit my profile?\n\n' +
      'I will cover every relevant detail in my reply.'
    );
  }

  if (/^(thank|thanks|thx)[\s!,.]*$/i.test(text)) {
    return (
      'You’re welcome! Ask anytime — for the full app overview say “What is CivicConnect?” ' +
      'or ask about any tab/feature and I’ll explain everything related to it.'
    );
  }

  if (/who (are|r) you|what (can|do) you (do|help)|help me\b/.test(text)) {
    return (
      'I’m the CivicConnect assistant. I answer completely about how this app works.\n\n' +
      APP_OVERVIEW +
      '\n\nAsk any follow-up and I’ll include all related steps and details.'
    );
  }

  const matched = TOPICS.filter((topic) =>
    topic.patterns.some((pattern) => pattern.test(text))
  );

  if (matched.length === 0) {
    return (
      'Here is the complete CivicConnect overview for your question:\n\n' +
      APP_OVERVIEW +
      '\n\nYou can also ask specifically about:\n' +
      '• Tabs / navigation\n' +
      '• How to report an issue\n' +
      '• Categories\n' +
      '• Statuses\n' +
      '• Photos\n' +
      '• Profile\n' +
      '• Login / signup / logout'
    );
  }

  // Combine every matched topic so multi-part questions get full answers.
  const uniqueAnswers: string[] = [];
  const seen = new Set<string>();
  for (const topic of matched) {
    if (seen.has(topic.id)) continue;
    seen.add(topic.id);
    uniqueAnswers.push(topic.answer);
  }

  // If the user asked something broad, also include overview once.
  if (
    matched.length >= 2 &&
    !seen.has('overview') &&
    /and|also|everything|all|explain|detail/.test(text)
  ) {
    uniqueAnswers.unshift(APP_OVERVIEW);
  }

  return uniqueAnswers.join('\n\n————\n\n');
}

async function openAiReply(
  message: string,
  history: Array<{ role: 'user' | 'assistant'; content: string }>
): Promise<string | null> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) return null;

  const model = process.env.OPENAI_MODEL || 'gpt-4o-mini';
  const messages = [
    {
      role: 'system',
      content:
        `${SYSTEM_CONTEXT}\n\nAlways answer fully. If the user asks multiple things, answer each one completely.\n\nApp facts:\n${APP_OVERVIEW}`,
    },
    ...history.slice(-8).map((item) => ({
      role: item.role,
      content: item.content,
    })),
    { role: 'user', content: message },
  ];

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.2,
      max_tokens: 1200,
    }),
  });

  if (!response.ok) return null;

  const data = (await response.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  return data.choices?.[0]?.message?.content?.trim() || null;
}

export class ChatController {
  public chat = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { message, history } = ChatMessageSchema.parse(req.body);

      let reply: string | null = null;
      try {
        reply = await openAiReply(message, history || []);
      } catch {
        reply = null;
      }

      if (!reply) {
        reply = buildReply(message);
      }

      sendResponse(res, 200, true, 'Assistant reply generated', {
        reply,
        source: process.env.OPENAI_API_KEY ? 'ai' : 'assistant',
      });
    } catch (error) {
      next(error);
    }
  };
}
