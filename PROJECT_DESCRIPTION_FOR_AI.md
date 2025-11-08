# TeenTalk - Descrizione Progetto per AI Assistants

Questa è una descrizione completa e strutturata del progetto TeenTalk, ottimizzata per AI coding assistants come Cursor, GitHub Copilot, Claude, etc.

## 🎯 Visione Generale

**TeenTalk** è un'app mobile sviluppata in Flutter per creare una community scolastica sicura e controllata per studenti delle scuole superiori e università di Brescia, Italia.

### Obiettivo Principale
Fornire uno spazio digitale sicuro dove gli studenti possono:
- Condividere contenuti, fare domande e interagire tra loro
- Pubblicare post e commenti in modo pubblico o anonimo
- Interagire solo con studenti della propria scuola (isolamento per scuola)
- Essere protetti da contenuti inappropriati tramite moderazione AI e umana

## 📱 Stack Tecnologico

### Frontend
- **Framework**: Flutter 3.19.6 (Dart SDK >=3.3.4)
- **State Management**: Riverpod 2.4.9
- **Routing**: GoRouter 12.1.3
- **Architettura**: Clean Architecture con feature-first approach
- **UI**: Material Design 3 con tema personalizzato TeenTalk

### Backend
- **Authentication**: Firebase Auth (Email/Password, Google Sign-In, Phone OTP, Anonymous)
- **Database**: Cloud Firestore
- **Storage**: Firebase Cloud Storage (immagini post)
- **Functions**: Firebase Cloud Functions (moderazione, notifiche, audit logs)
- **Analytics**: Firebase Analytics
- **Messaging**: Firebase Cloud Messaging (notifiche push)

### Code Generation
- **Freezed**: Modelli immutabili
- **JSON Serializable**: Serializzazione API
- **Build Runner**: Generazione codice

## 🏫 Scuole Supportate

L'app supporta le seguenti istituzioni scolastiche di Brescia:

1. Liceo Arnaldo
2. Liceo Calini
3. Liceo Gambara
4. Liceo Copernico
5. Liceo Veronica Gambara
6. Istituto Lunardi
7. Istituto Mantegna
8. Istituto Tartaglia
9. Istituto Castelli
10. Istituto Fortuny
11. Istituto Golgi
12. ITIS Benedetti
13. ITIS Beretta
14. ITC Abba
15. ITC Passerini
16. Università degli Studi di Brescia
17. Altro

**Nota**: Ogni utente seleziona la propria scuola durante l'onboarding. I feed dovrebbero essere filtrati per scuola (TODO: implementare filtro scuola nei post).

## 🔐 Autenticazione e Registrazione

### Metodi di Autenticazione
1. **Email/Password**: Registrazione e login con email verificata
2. **Google Sign-In**: Autenticazione social con Google
3. **Phone OTP**: Autenticazione tramite SMS con codice OTP
4. **Anonymous**: Accesso temporaneo senza account (limitato)

### Processo di Onboarding
1. **Selezione Metodo Auth**: Utente sceglie come autenticarsi
2. **Creazione Account**: Validazione email/telefono, creazione profilo Firebase
3. **Consenso GDPR**: Obbligatorio per tutti gli utenti
4. **Termini di Servizio**: Accettazione obbligatoria
5. **Informazioni Personali**:
   - Nome completo
   - Data di nascita (calcolo età automatico)
   - Scuola di appartenenza
   - Nickname (verificato, unico, minimo 3 caratteri, massimo 20)
6. **Consenso Genitoriale**: 
   - Obbligatorio per utenti sotto i 18 anni (GDPR Italia)
   - Richiede contatto genitore/tutore
   - Verifica separata
7. **Preferenze Privacy**:
   - Visibilità profilo
   - Consenso post anonimi
8. **Completamento**: Accesso all'app principale

### Gestione Nickname
- Nickname unico e verificato
- Può essere modificato massimo una volta ogni 30 giorni
- Formato: solo lettere, numeri e underscore (a-zA-Z0-9_)
- Lunghezza: 3-20 caratteri
- Case-insensitive (lowercase per ricerca)

## 📝 Sistema di Post e Commenti

### Struttura Post
```dart
{
  id: string,
  authorId: string,              // Sempre salvato (anche per post anonimi)
  authorNickname: string,        // Visibile solo se !isAnonymous
  isAnonymous: boolean,          // Toggle per ogni post
  content: string,               // Testo del post (max 2000 caratteri)
  section: 'spotted' | 'general', // Sezione feed
  school: string?,               // TODO: Aggiungere filtro scuola
  imageUrl: string?,             // URL immagine (opzionale)
  createdAt: timestamp,
  updatedAt: timestamp,
  likeCount: number,
  likedBy: string[],             // Array di user IDs
  commentCount: number,
  mentionedUserIds: string[],    // @mentions nel contenuto
  isModerated: boolean,          // Flag per contenuti segnalati
}
```

### Sezioni Feed
- **Spotted**: Post anonimi/non anonimi di tipo "spotted" (default)
- **General**: Post generali di discussione

### Sistema di Commenti
```dart
{
  id: string,
  postId: string,
  authorId: string,              // Sempre salvato
  authorNickname: string,
  isAnonymous: boolean,          // Toggle per ogni commento
  content: string,
  createdAt: timestamp,
  likeCount: number,
  likedBy: string[],
  replyToCommentId: string?,     // Per risposte annidate
  replyCount: number,
  mentionedUserIds: string[],
  isModerated: boolean,
}
```

### Caratteristiche
- **Toggle Anonimo**: Ogni post/commento può essere pubblicato anonimamente
- **Privacy Autore**: Anche se anonimo, `authorId` è sempre salvato per moderazione
- **Threading**: Supporto risposte annidate ai commenti
- **Mentions**: Estrazione automatica di @username nel contenuto
- **Likes**: Sistema like/unlike con conteggio in tempo reale
- **Paginazione**: 20 post/commenti per pagina con infinite scroll
- **Real-time**: Aggiornamenti in tempo reale tramite Firestore snapshots

### Limitazioni Contenuto
- Lunghezza post: 1-2000 caratteri
- Lunghezza commento: 1-2000 caratteri
- Dimensione immagine: massimo 5MB
- Formati immagine supportati: JPEG, PNG, WebP

## 🔒 Privacy e Anonimato

### Post Anonimi
- **Identità Preservata**: L'`authorId` è sempre salvato nel database per moderazione
- **Display Pubblico**: Post anonimi mostrano "Anonymous" invece del nickname
- **Audit Logs**: Tutti i post anonimi hanno log immutabili per tracciabilità
- **Conteggio**: Contatore `anonymousPostsCount` nel profilo utente
- **Moderazione**: Gli admin possono vedere l'autore reale nei report

### Protezione Dati
- **GDPR Compliance**: Consenso esplicito per trattamento dati
- **Consenso Genitoriale**: Obbligatorio per minori (<18 anni)
- **Profilo Visibile**: Utente può nascondere il proprio profilo
- **Blocking**: Utenti possono bloccare altri utenti
- **Report**: Sistema di segnalazione per contenuti inappropriati

## 🛡️ Sistema di Moderazione

### Livelli di Moderazione
1. **AI Automatica**: Analisi automatica di testo e immagini (Cloud Functions)
2. **Segnalazioni Utenti**: Sistema di report per contenuti inappropriati
3. **Review Admin**: Panel admin per revisione manuale
4. **Audit Logs**: Log immutabili di tutte le azioni di moderazione

### Tipi di Report
- **Spam**: Contenuti spam o pubblicitari
- **Inappropriate**: Contenuti inappropriati
- **Harassment**: Bullismo o molestie
- **Hate Speech**: Discorsi d'odio
- **Violence**: Minacce o violenza
- **Sexual Content**: Contenuti sessuali
- **Misinformation**: Informazioni false
- **Self Harm**: Contenuti di autolesionismo
- **Other**: Altro

### Workflow Moderazione
1. **Report Utente**: Utente segnala contenuto → crea record in `reports` collection
2. **Auto-Hide**: Contenuto marcato come `isModerated: true` → nascosto dal feed
3. **Review Admin**: Admin vede report nel panel admin
4. **Decisione Admin**:
   - **Resolve (Delete)**: Elimina contenuto permanentemente
   - **Restore**: Ripristina contenuto (rimuove flag `isModerated`)
   - **Dismiss**: Chiude report senza modifiche
5. **Audit Log**: Decisione registrata in `moderationDecisions` collection

### Collections Firestore Moderazione
- **reports**: Segnalazioni utenti (admin-only read)
- **moderationDecisions**: Decisioni admin (audit trail)
- **moderationQueue**: Coda contenuti da moderare
- **auditLogs**: Log immutabili (subcollection di moderationQueue)

## 👥 Sistema di Messaggistica Diretta

### Conversazioni
- **1-to-1**: Solo messaggi privati tra due utenti
- **Conversation ID**: Generato deterministicamente da user IDs ordinati
- **Real-time**: Aggiornamenti in tempo reale tramite Firestore snapshots
- **Read Receipts**: Indicatori di lettura (isRead, readAt)

### Struttura Dati
```dart
// Conversation
{
  userId1: string,
  userId2: string,
  lastMessageId: string?,
  lastMessage: string?,
  lastSenderId: string?,
  lastMessageTime: timestamp?,
  unreadCount: number,
  createdAt: timestamp,
}

// Message (subcollection)
{
  conversationId: string,
  senderId: string,
  receiverId: string,
  text: string,
  imageUrl: string?,
  isRead: boolean,
  createdAt: timestamp,
  readAt: timestamp?,
}
```

### Privacy e Blocco
- **Blocking**: Utenti possono bloccare altri utenti
- **Restrizioni**: Messaggi da utenti bloccati vengono rifiutati
- **Block List**: Gestione lista utenti bloccati in `blocks/{userId}/blockedUsers/`

### Notifiche Push
- **FCM Integration**: Firebase Cloud Messaging per notifiche
- **Topic Subscription**: Sottoscrizione a topic per messaggi
- **Background Handler**: Gestione notifiche quando app è in background

## 👤 Profilo Utente

### Dati Profilo
```dart
{
  uid: string,
  nickname: string,
  nicknameVerified: boolean,
  nicknameLowercase: string,      // Per ricerche case-insensitive
  lastNicknameChangeAt: timestamp?, // Per limite 30 giorni
  gender: string?,
  school: string,                  // Scuola selezionata
  anonymousPostsCount: number,     // Contatore post anonimi
  createdAt: timestamp,
  privacyConsentGiven: boolean,
  privacyConsentTimestamp: timestamp,
  isMinor: boolean?,
  guardianContact: string?,
  parentalConsentGiven: boolean?,
  parentalConsentTimestamp: timestamp?,
  allowAnonymousPosts: boolean,
  profileVisible: boolean,
  isAdmin: boolean,                // Admin privileges
  isModerator: boolean,            // Moderator privileges
  updatedAt: timestamp?,
}
```

### Ruoli Utente
- **User**: Utente standard (default)
- **Moderator**: Può moderare contenuti (flag `isModerator`)
- **Admin**: Accesso completo al panel admin (flag `isAdmin`)

## 🎛️ Admin Panel

### Funzionalità Admin
1. **Reports Management**: Visualizza e gestisce segnalazioni utenti
2. **Content Moderation**: Revisiona e decide su contenuti segnalati
3. **Analytics Dashboard**: Metriche in tempo reale
4. **Decision Logging**: Audit trail completo delle decisioni

### Analytics Dashboard
- **Active Reports**: Segnalazioni pending
- **Resolved Reports**: Segnalazioni risolte
- **Dismissed Reports**: Segnalazioni chiuse
- **Flagged Posts**: Post segnalati
- **Flagged Comments**: Commenti segnalati
- **Resolution Rate**: Percentuale di risoluzione
- **Total Flagged Content**: Totale contenuti segnalati

### Filtri Reports
- **Status**: pending, resolved, dismissed, restored
- **Date Range**: Filtro per periodo temporale
- **Real-time Updates**: Aggiornamenti in tempo reale

## 🗄️ Struttura Database Firestore

### Collections Principali
```
users/{userId}
  - Dati profilo utente
  - Privacy settings
  - Admin/Moderator flags

posts/{postId}
  - Contenuti post
  - Metadata (likes, comments, mentions)
  - Moderation flags

comments/{commentId}
  - Contenuti commenti
  - Threading (replyToCommentId)
  - Moderation flags

conversations/{conversationId}
  - Metadata conversazione
  - messages/{messageId} (subcollection)
    - Messaggi privati

reports/{reportId}
  - Segnalazioni utenti
  - Status e metadata

moderationDecisions/{decisionId}
  - Decisioni admin
  - Audit trail

blocks/{userId}
  - blockedUsers/{blockedUserId} (subcollection)
    - Lista utenti bloccati

moderationQueue/{contentId}
  - Coda moderazione
  - auditLogs/{logId} (subcollection)
    - Log immutabili
```

### Security Rules
- **Authentication Required**: Tutte le operazioni richiedono autenticazione
- **Owner Validation**: Utenti possono modificare solo i propri contenuti
- **Admin Override**: Admin possono modificare/eliminare qualsiasi contenuto
- **School Isolation**: TODO - Implementare filtro scuola nei post
- **Privacy Rules**: Utenti possono leggere solo profili visibili o propri
- **Report Protection**: Reports accessibili solo ad admin

## 🔔 Sistema di Notifiche

### Tipi di Notifiche
1. **Mentions**: Notifica quando @username menzionato
2. **Replies**: Notifica quando qualcuno risponde a commento
3. **Messages**: Notifica nuovi messaggi privati
4. **Reports**: Notifica admin per nuove segnalazioni (TODO)
5. **Moderation**: Notifica autori quando contenuto moderato (TODO)

### Implementazione
- **FCM**: Firebase Cloud Messaging per push notifications
- **Firestore Triggers**: Cloud Functions triggerate da eventi Firestore
- **Notification Service**: Servizio centralizzato per gestione notifiche

## 🧪 Testing

### Test Coverage
- **Unit Tests**: Test per repository, services, providers
- **Widget Tests**: Test per componenti UI
- **Integration Tests**: Test end-to-end per feature complete
- **Golden Tests**: Test per UI consistency (stub)

### Test Files
- `test/features/auth/` - Test autenticazione
- `test/features/comments/` - Test commenti
- `test/features/messages/` - Test messaggistica
- `test/features/feed/` - Test feed

## 🚀 Deployment

### Firebase Setup
1. **Firebase Project**: Creare progetto Firebase
2. **Enable Services**: Auth, Firestore, Storage, Functions, Analytics, FCM
3. **Security Rules**: Deploy Firestore security rules
4. **Indexes**: Deploy Firestore indexes
5. **Cloud Functions**: Deploy Cloud Functions per moderazione

### Build & Release
- **Android**: Build APK/AAB per Google Play
- **iOS**: Build IPA per App Store
- **Web**: Build web per Firebase Hosting (opzionale)

## 📋 TODO / Future Enhancements

### Funzionalità Mancanti
1. **School Filtering**: Implementare filtro scuola nei post (query Firestore)
2. **Post Search**: Ricerca post per keywords
3. **User Search**: Ricerca utenti per nickname
4. **Post Editing**: Modifica post dopo pubblicazione
5. **Comment Editing**: Modifica commenti dopo pubblicazione
6. **Post Deletion**: Eliminazione post con conferma
7. **Image Moderation**: Analisi AI immagini (Cloud Functions)
8. **Notification Settings**: Preferenze notifiche utente
9. **Push Notifications**: Implementazione completa FCM
10. **Analytics Events**: Tracking eventi utente
11. **Localization**: Supporto italiano (attualmente EN/ES)

### Miglioramenti
1. **Performance**: Ottimizzazione query Firestore
2. **Caching**: Cache locale per contenuti frequenti
3. **Offline Support**: Supporto modalità offline
4. **Image Compression**: Compressione immagini prima upload
5. **Video Support**: Supporto video nei post
6. **Group Chats**: Messaggistica di gruppo
7. **Post Scheduling**: Programmazione post
8. **Hashtags**: Sistema hashtags per categorizzazione
9. **Trending**: Algoritmo trending posts
10. **User Verification**: Verifica utenti verificati

## 🔧 Convenzioni di Codice

### Architettura
- **Clean Architecture**: Separazione concerns (data, domain, presentation)
- **Feature-First**: Organizzazione per feature, non per tipo
- **Repository Pattern**: Astrazione accesso dati
- **Provider Pattern**: State management con Riverpod

### Naming Conventions
- **Files**: snake_case (es. `auth_provider.dart`)
- **Classes**: PascalCase (es. `AuthProvider`)
- **Variables**: camelCase (es. `currentUser`)
- **Constants**: lowerCamelCase o UPPER_SNAKE_CASE

### File Structure
```
lib/src/features/{feature}/
  ├── data/
  │   ├── models/
  │   ├── repositories/
  │   └── services/
  ├── domain/
  │   └── models/
  └── presentation/
      ├── pages/
      ├── widgets/
      └── providers/
```

## 🐛 Known Issues

1. **School Filtering**: Non implementato nei post (solo nel profilo utente)
2. **Localization**: Mancante italiano (solo EN/ES)
3. **Image Moderation**: Stub implementation (non funzionante)
4. **Push Notifications**: Stub implementation (non funzionante)
5. **Admin Role**: Non completamente integrato in tutti i feature

## 📚 Documentazione Aggiuntiva

- `ADMIN_PANEL_MVP.md` - Documentazione admin panel
- `AUTH_IMPLEMENTATION.md` - Documentazione autenticazione
- `COMMENTS_FEATURE.md` - Documentazione commenti
- `DIRECT_MESSAGES_IMPLEMENTATION.md` - Documentazione messaggistica
- `FEED_SECTIONS_IMPLEMENTATION.md` - Documentazione feed sections
- `MODERATION_WORKFLOW.md` - Documentazione moderazione
- `ONBOARDING_FLOW.md` - Documentazione onboarding
- `POST_COMPOSER_IMPLEMENTATION.md` - Documentazione composer
- `FIREBASE_SETUP.md` - Setup Firebase
- `SECURITY_RULES_SUMMARY.md` - Security rules

## 🎨 Design System

### Colori TeenTalk
- **Primary**: Purple (colore principale)
- **Secondary**: Pink (colore secondario)
- **Accent**: Emerald (accento)
- **Theme**: Material Design 3 con supporto light/dark mode

### Componenti UI
- **Buttons**: Material 3 styled buttons
- **Cards**: Post cards con Material 3 elevation
- **Input Fields**: Text fields con validazione
- **Navigation**: Bottom navigation bar con 4 tab (Feed, Messages, Profile, Admin)

## 🔐 Sicurezza

### Best Practices
1. **Input Validation**: Validazione lato client e server
2. **Rate Limiting**: Limitazione richieste (TODO: implementare)
3. **Content Filtering**: Filtro contenuti inappropriati
4. **Audit Logging**: Log completo di azioni sensibili
5. **Encryption**: Dati sensibili crittografati (TODO: end-to-end encryption per DM)
6. **Secure Storage**: Credenziali in secure storage
7. **HTTPS Only**: Tutte le comunicazioni via HTTPS

### Compliance
- **GDPR**: Conformità GDPR per utenti UE
- **COPPA**: Considerazioni per utenti minori
- **Privacy Policy**: Policy privacy obbligatoria
- **Terms of Service**: Termini di servizio obbligatori

---

**Ultimo Aggiornamento**: Gennaio 2025
**Versione**: 1.0.0
**Stato**: MVP in sviluppo

