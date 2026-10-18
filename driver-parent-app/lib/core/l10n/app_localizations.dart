import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  String _t(Map<String, String> t) => t[locale.languageCode] ?? t['en']!;

  // ── Common ────────────────────────────────────────────────────────────────

  String get cancel => _t({'en': 'Cancel', 'fr': 'Annuler', 'rw': 'Hagarika'});
  String get save => _t({'en': 'Save', 'fr': 'Enregistrer', 'rw': 'Bika'});
  String get confirm => _t({'en': 'Confirm', 'fr': 'Confirmer', 'rw': 'Emeza'});
  String get retry => _t({'en': 'Retry', 'fr': 'Réessayer', 'rw': 'Gerageza nanone'});
  String get gotIt => _t({'en': 'Got it', 'fr': 'Compris', 'rw': 'Narabyumvise'});
  String get required => _t({'en': 'Required', 'fr': 'Requis', 'rw': 'Birasabwa'});
  String get remove => _t({'en': 'Remove', 'fr': 'Supprimer', 'rw': 'Kuraho'});
  String get searchNotifications => _t({'en': 'Search notifications', 'fr': 'Rechercher des notifications', 'rw': 'Shakisha menyesha'});
  String get noNotifications => _t({'en': 'You have no notifications', 'fr': 'Vous n\'avez aucune notification', 'rw': 'Nta menyesha ufite'});
  String get sectionNew => _t({'en': 'NEW', 'fr': 'NOUVEAU', 'rw': 'BISHYA'});
  String get sectionEarlier => _t({'en': 'EARLIER', 'fr': 'PRÉCÉDEMMENT', 'rw': 'MBERE'});
  String get online => _t({'en': 'online', 'fr': 'en ligne', 'rw': 'ku murongo'});
  String get offline => _t({'en': 'offline', 'fr': 'hors ligne', 'rw': 'nta murongo'});

  // ── Authentication ────────────────────────────────────────────────────────

  String get welcomeBack => _t({'en': 'Welcome back!', 'fr': 'Bon retour !', 'rw': 'Murakaza neza!'});
  String get loginSubtitle => _t({'en': 'Please provide your login information to sign in to your account.', 'fr': 'Veuillez fournir vos informations de connexion.', 'rw': 'Nyamuneka tanga amakuru yo kwinjira mu konti yawe.'});
  String get emailOrPhone => _t({'en': 'Email or phone number', 'fr': 'Email ou numéro de téléphone', 'rw': 'Imeyili cyangwa nimero ya telefoni'});
  String get password => _t({'en': 'Password', 'fr': 'Mot de passe', 'rw': 'Ijambo banga'});
  String get fieldRequired => _t({'en': 'This field is required', 'fr': 'Ce champ est requis', 'rw': 'Iki gice gisabwa'});
  String get passwordRequired => _t({'en': 'Password is required', 'fr': 'Le mot de passe est requis', 'rw': 'Ijambo banga rirasabwa'});
  String get forgotPassword => _t({'en': 'Forgot password?', 'fr': 'Mot de passe oublié ?', 'rw': 'Wibagiwe ijambo banga?'});
  String get signIn => _t({'en': 'Sign in', 'fr': 'Se connecter', 'rw': 'Injira'});
  String get signingIn => _t({'en': 'Signing in…', 'fr': 'Connexion en cours…', 'rw': 'Ntegereza...'});
  String get newHereCreateAccount => _t({'en': 'New here? Create account', 'fr': 'Nouveau ici ? Créer un compte', 'rw': 'Nshya hano? Fungura konti'});
  String get invalidCredentials => _t({'en': 'Invalid credentials', 'fr': 'Identifiants invalides', 'rw': 'Amakuru yo kwinjira ntabwo ari yo'});
  String get unexpectedServerResponse => _t({'en': 'Unexpected server response', 'fr': 'Réponse inattendue du serveur', 'rw': 'Igisubizo kitazwi cyaturutse kuri seriveri'});
  String get userDataMissing => _t({'en': 'User data missing from response', 'fr': 'Données utilisateur manquantes', 'rw': 'Amakuru y\'umukoresha yangirika'});
  String get couldNotReachServer => _t({'en': 'Could not reach server', 'fr': 'Impossible d\'atteindre le serveur', 'rw': 'Ntishoboye kugera kuri seriveri'});
  String get couldNotReachServerCheck => _t({'en': 'Could not reach server. Check your connection.', 'fr': 'Impossible de joindre le serveur. Vérifiez votre connexion.', 'rw': 'Ntishoboye kugera kuri seriveri. Reba umuyoboro wawe.'});

  String get createYourAccount => _t({'en': 'Create your account', 'fr': 'Créez votre compte', 'rw': 'Fungura konti yawe'});
  String get registerSubtitle => _t({'en': 'We are happy to have you! Please fill in the details below to create your account.', 'fr': 'Nous sommes heureux de vous accueillir ! Veuillez remplir les détails ci-dessous.', 'rw': 'Turishimye kugira unawe! Nyamuneka uzuze amakuru hepfo.'});
  String get firstName => _t({'en': 'First name', 'fr': 'Prénom', 'rw': 'Izina rya mbere'});
  String get lastName => _t({'en': 'Last name', 'fr': 'Nom de famille', 'rw': 'Izina ry\'umuryango'});
  String get phoneNumber => _t({'en': 'Phone number', 'fr': 'Numéro de téléphone', 'rw': 'Nimero ya telefoni'});
  String get emailAddress => _t({'en': 'Email address', 'fr': 'Adresse e-mail', 'rw': 'Aderesi y\'imeyili'});
  String get confirmPassword => _t({'en': 'Confirm password', 'fr': 'Confirmer le mot de passe', 'rw': 'Emeza ijambo banga'});
  String get moreFieldsBelow => _t({'en': 'More fields below ↓', 'fr': 'Plus de champs ci-dessous ↓', 'rw': 'Ibindi gice hepfo ↓'});
  String get firstNameRequired => _t({'en': 'First name is required', 'fr': 'Le prénom est requis', 'rw': 'Izina rya mbere rirasabwa'});
  String get lastNameRequired => _t({'en': 'Last name is required', 'fr': 'Le nom est requis', 'rw': 'Izina ry\'umuryango rirasabwa'});
  String get phoneRequired => _t({'en': 'Phone number is required', 'fr': 'Le numéro de téléphone est requis', 'rw': 'Nimero ya telefoni irasabwa'});
  String get emailRequired => _t({'en': 'Email is required', 'fr': 'L\'e-mail est requis', 'rw': 'Imeyili irasabwa'});
  String get enterValidEmail => _t({'en': 'Please enter a valid email', 'fr': 'Veuillez entrer un e-mail valide', 'rw': 'Injiza imeyili nyayo'});
  String get passwordMin8 => _t({'en': 'Password must be at least 8 characters', 'fr': 'Le mot de passe doit contenir au moins 8 caractères', 'rw': 'Ijambo banga rigomba kuba rifite inyuguti 8 nibura'});
  String get passwordNeedsSymbol => _t({'en': 'Password must contain at least one symbol', 'fr': 'Le mot de passe doit contenir au moins un symbole', 'rw': 'Ijambo banga rigomba kuba rifite ikimenyetso kimwe nibura'});
  String get pleaseConfirmPassword => _t({'en': 'Please confirm your password', 'fr': 'Veuillez confirmer votre mot de passe', 'rw': 'Nyamuneka emeza ijambo banga ryawe'});
  String get passwordsDoNotMatch => _t({'en': 'Passwords do not match', 'fr': 'Les mots de passe ne correspondent pas', 'rw': 'Amagambo banga ntabwo ahura'});
  String get createAccount => _t({'en': 'Create account', 'fr': 'Créer un compte', 'rw': 'Fungura konti'});
  String get alreadyHaveAccount => _t({'en': 'Already have an account? Sign in', 'fr': 'Vous avez déjà un compte ? Se connecter', 'rw': 'Usanzwe ufite konti? Injira'});
  String get registrationFailed => _t({'en': 'Registration failed', 'fr': 'L\'inscription a échoué', 'rw': 'Kwiyandikisha byanze'});

  // ── Driver Home ───────────────────────────────────────────────────────────

  String get busRoute => _t({'en': 'Bus route', 'fr': 'Itinéraire', 'rw': 'Inzira ya bisi'});
  String totalChildren(int n) => _t({'en': '$n Total children', 'fr': '$n enfants au total', 'rw': 'Abana $n bose'});
  String get startNewJourney => _t({'en': 'Start a new journey', 'fr': 'Démarrer un nouveau trajet', 'rw': 'Tangira urugendo rushya'});
  String get endJourney => _t({'en': 'End Journey', 'fr': 'Terminer le trajet', 'rw': 'Rangiza urugendo'});
  String get currentTargetStop => _t({'en': 'Current target stop', 'fr': 'Arrêt cible actuel', 'rw': 'Aho ugomba guhagarara ubu'});

  String get morningPickupActive => _t({'en': 'Morning Pickup — GPS Sharing Active', 'fr': 'Ramassage du matin — GPS actif', 'rw': 'Kwakira abana mu gitondo — GPS irakora'});
  String get afternoonDropoffActive => _t({'en': 'Afternoon Drop-off — GPS Sharing Active', 'fr': 'Dépose de l\'après-midi — GPS actif', 'rw': 'Gusubira inzu nimugoroba — GPS irakora'});
  String get journeyActive => _t({'en': 'Journey Active — GPS Sharing', 'fr': 'Trajet actif — GPS partagé', 'rw': 'Urugendo rugenda — GPS ishyirwaho'});

  String get startJourneySheetTitle => _t({'en': 'Start a new journey', 'fr': 'Démarrer un nouveau trajet', 'rw': 'Tangira urugendo rushya'});
  String get startJourneySheetSubtitle => _t({'en': 'Your GPS location will be shared with parents in real time. Select the trip type to begin.', 'fr': 'Votre position GPS sera partagée avec les parents en temps réel. Sélectionnez le type de trajet.', 'rw': 'Aho uri ku GPS birasangirwa n\'ababyeyi mu gihe nyacyo. Hitamo ubwoko bw\'urugendo.'});
  String get morningPickup => _t({'en': 'Morning Pickup', 'fr': 'Ramassage du matin', 'rw': 'Kwakira abana mu gitondo'});
  String get morningPickupDesc => _t({'en': 'Pick up children and take them to school', 'fr': 'Prendre les enfants et les conduire à l\'école', 'rw': 'Kwakira abana ubajyanye ku ishuri'});
  String get afternoonDropoff => _t({'en': 'Afternoon Drop-off', 'fr': 'Dépose de l\'après-midi', 'rw': 'Gusubira inzu nimugoroba'});
  String get afternoonDropoffDesc => _t({'en': 'Drop children off at their bus stops after school', 'fr': 'Déposer les enfants à leurs arrêts après l\'école', 'rw': 'Kohereza abana mu mazimwe yabo nyuma y\'ishuri'});
  String get suggested => _t({'en': 'Suggested', 'fr': 'Suggéré', 'rw': 'Birasabwa'});

  String get endJourneyConfirmTitle => _t({'en': 'End Journey', 'fr': 'Terminer le trajet', 'rw': 'Rangiza urugendo'});
  String get endJourneyConfirmBody => _t({'en': 'Are you sure you want to end the current journey? GPS sharing will stop immediately.', 'fr': 'Êtes-vous sûr de vouloir terminer le trajet ? Le partage GPS s\'arrêtera immédiatement.', 'rw': 'Uzi neza ko ushaka kurangiza urugendo? GPS izahagarara vuba.'});

  String get noChildrenOnBus => _t({'en': 'No children are assigned to this bus yet.', 'fr': 'Aucun enfant n\'est encore assigné à ce bus.', 'rw': 'Nta bana bashyizweho bisi iyi.'});
  String get waitingForGps => _t({'en': 'Waiting for GPS fix — try again in a moment.', 'fr': 'En attente du signal GPS — réessayez dans un instant.', 'rw': 'Tegereza GPS — gerageza nanone vuba.'});
  String get busDataNotLoaded => _t({'en': 'Bus data not loaded. Tap refresh and try again.', 'fr': 'Données du bus non chargées. Appuyez sur actualiser.', 'rw': 'Amakuru ya bisi ntiyashyizweho. Kanda ugarure nanone.'});
  String couldNotStartJourney(String e) => _t({'en': 'Could not start journey: $e', 'fr': 'Impossible de démarrer le trajet : $e', 'rw': 'Byanze gutangira urugendo: $e'});
  String couldNotEndJourney(String e) => _t({'en': 'Could not end journey: $e', 'fr': 'Impossible de terminer le trajet : $e', 'rw': 'Byanze kurangiza urugendo: $e'});
  String get noChildrenOnBusYet => _t({'en': 'No children assigned to this bus yet.', 'fr': 'Aucun enfant assigné à ce bus.', 'rw': 'Nta bana bashyizweho bisi iyi.'});

  // ── Attendance Sheet ──────────────────────────────────────────────────────

  String get whoIsOnBus => _t({'en': 'Who\'s on the bus?', 'fr': 'Qui est dans le bus ?', 'rw': 'Ni nde uri mu bisi?'});
  String get busStop => _t({'en': 'Bus Stop', 'fr': 'Arrêt de bus', 'rw': 'Aho bisi ihagarara'});
  String get searchName => _t({'en': 'Search a name', 'fr': 'Rechercher un nom', 'rw': 'Shakisha izina'});
  String get allStops => _t({'en': 'All', 'fr': 'Tous', 'rw': 'Bose'});
  String get noChildrenAtStop => _t({'en': 'No children at this stop', 'fr': 'Aucun enfant à cet arrêt', 'rw': 'Nta bana bari aho bisi ihagarara'});
  String get confirmAndStartJourney => _t({'en': 'Confirm & Start Journey', 'fr': 'Confirmer et démarrer le trajet', 'rw': 'Emeza no gutangira urugendo'});
  String get markAsOnboarded => _t({'en': 'Mark as Onboarded', 'fr': 'Marquer comme embarqué', 'rw': 'Shyira nk\'uwinjiye mu bisi'});
  String get absent => _t({'en': 'Absent', 'fr': 'Absent', 'rw': 'Adahari'});
  String get boarded => _t({'en': 'Boarded', 'fr': 'Embarqué', 'rw': 'Yinjiye mu bisi'});
  String get droppedOff => _t({'en': 'Dropped off', 'fr': 'Déposé', 'rw': 'Yasubijwe inzu'});
  String get attendanceSaved => _t({'en': 'Attendance Saved', 'fr': 'Présence enregistrée', 'rw': 'Ubwitabire bwashyizwe'});
  String get attendanceSavedBody => _t({'en': 'The attendance has been successfully recorded for the selected children.', 'fr': 'La présence a été enregistrée avec succès pour les enfants sélectionnés.', 'rw': 'Ubwitabire bwashyizwe neza ku bana bashyizweho.'});
  String get oneMarkCouldNotBeSaved => _t({'en': 'One mark could not be saved. Please try again.', 'fr': 'Une marque n\'a pas pu être enregistrée. Veuillez réessayer.', 'rw': 'Ikimenyetso kimwe ntikishyizwe. Gerageza nanone.'});
  String nMarksCouldNotBeSaved(int n) => _t({'en': '$n marks could not be saved. Please try again.', 'fr': '$n marques n\'ont pas pu être enregistrées. Veuillez réessayer.', 'rw': 'Ibimenyetso $n ntibashyizwe. Gerageza nanone.'});

  // Session picker (all children sheet)
  String get markAttendanceFor => _t({'en': 'Mark attendance for', 'fr': 'Marquer la présence pour', 'rw': 'Shyira ubwitabire bwa'});
  String get whichSession => _t({'en': 'Which session are these children boarding for?', 'fr': 'Pour quelle session ces enfants montent-ils ?', 'rw': 'Ni ikihe gihe abana baza kwinjira mu bisi?'});
  String get morning => _t({'en': 'Morning', 'fr': 'Matin', 'rw': 'Mu gitondo'});
  String get morningSessionDesc => _t({'en': 'Mark children as onboarded for the morning session', 'fr': 'Marquer les enfants embarqués pour la session du matin', 'rw': 'Shyira abana nk\'abinjiye mu bisi bw\'igitondo'});
  String get afternoon => _t({'en': 'Afternoon', 'fr': 'Après-midi', 'rw': 'Nimugoroba'});
  String get afternoonSessionDesc => _t({'en': 'Mark children as onboarded for the afternoon session', 'fr': 'Marquer les enfants embarqués pour la session de l\'après-midi', 'rw': 'Shyira abana nk\'abinjiye mu bisi bw\'umugoroba'});

  // ── Driver Profile ────────────────────────────────────────────────────────

  String get conductorProfile => _t({'en': 'Conductor profile', 'fr': 'Profil du conducteur', 'rw': 'Umwirondoro w\'umushoferi'});
  String get busRouteSettings => _t({'en': 'Bus & route settings', 'fr': 'Paramètres bus et itinéraire', 'rw': 'Igenamiterere ya bisi n\'inzira'});
  String get theme => _t({'en': 'Theme', 'fr': 'Thème', 'rw': 'Igishushanyo'});
  String get themeDark => _t({'en': 'Dark', 'fr': 'Sombre', 'rw': 'Umwizerwe'});
  String get themeLight => _t({'en': 'Light', 'fr': 'Clair', 'rw': 'Mwishyura'});
  String get language => _t({'en': 'Language', 'fr': 'Langue', 'rw': 'Ururimi'});
  String get signOut => _t({'en': 'Sign out', 'fr': 'Se déconnecter', 'rw': 'Sohoka'});
  String get changePhoto => _t({'en': 'Change photo', 'fr': 'Changer la photo', 'rw': 'Hindura ifoto'});
  String get couldNotPickImage => _t({'en': 'Could not pick image', 'fr': 'Impossible de sélectionner l\'image', 'rw': 'Byanze guhitamo ifoto'});
  String get pleaseChooseImage => _t({'en': 'Please choose an image first', 'fr': 'Veuillez d\'abord choisir une image', 'rw': 'Nyamuneka hitamo ifoto mbere'});

  // ── Parent Home ───────────────────────────────────────────────────────────

  String get busHasArrived => _t({'en': 'Bus has arrived', 'fr': 'Le bus est arrivé', 'rw': 'Bisi yagarutse'});
  String get busOnItsWay => _t({'en': 'Bus is on its way', 'fr': 'Le bus est en route', 'rw': 'Bisi iri mu nzira'});
  String minToReachHome(int n) => _t({'en': '$n min to reach home', 'fr': '$n min pour arriver', 'rw': 'Iminota $n kugera'});
  String get yourConductor => _t({'en': 'Your conductor', 'fr': 'Votre conducteur', 'rw': 'Umushoferi wawe'});
  String get noConductorAssigned => _t({'en': 'No conductor assigned', 'fr': 'Aucun conducteur assigné', 'rw': 'Nta mushoferi wishyiriweho'});
  String get busReachedStop => _t({'en': 'Bus has reached the bus stop', 'fr': 'Le bus a atteint l\'arrêt', 'rw': 'Bisi yageze aho ihagarara'});
  String get busReachedStopBody => _t({'en': 'The bus has arrived at the bus stop, pick up your kids from the bus stop as soon as possible.', 'fr': 'Le bus est arrivé à l\'arrêt, venez chercher vos enfants dès que possible.', 'rw': 'Bisi yageze aho ihagarara, nzanye abana bawe vuba bishoboka.'});

  // ── Parent Settings ───────────────────────────────────────────────────────

  String get emergencyContacts => _t({'en': 'Emergency Contacts', 'fr': 'Contacts d\'urgence', 'rw': 'Namba z\'acuri'});
  String get myRouteDetails => _t({'en': 'My route details', 'fr': 'Détails de mon itinéraire', 'rw': 'Amakuru y\'inzira yange'});
  String get journeyLogs => _t({'en': 'Journey logs', 'fr': 'Journaux de trajet', 'rw': 'Imigereka y\'urugendo'});
  String get languageAndSupport => _t({'en': 'Language & support', 'fr': 'Langue et assistance', 'rw': 'Ururimi n\'ubufasha'});
  String get noEmergencyContact => _t({'en': 'No emergency contact yet', 'fr': 'Aucun contact d\'urgence', 'rw': 'Nta namba z\'acuri ziriho'});
  String get noRoutesStops => _t({'en': 'No routes/stops', 'fr': 'Aucune route/arrêt', 'rw': 'Nta nzira cyangwa aho bisi ihagarara'});
  String get newContact => _t({'en': 'New contact', 'fr': 'Nouveau contact', 'rw': 'Konti nshya'});
  String get requestCustomStop => _t({'en': 'Request a custom bus stop', 'fr': 'Demander un arrêt personnalisé', 'rw': 'Saba ahagarara ha bisi hateganijwe'});
  String get viewAllJourneys => _t({'en': 'View all your kids\' journeys', 'fr': 'Voir tous les trajets de vos enfants', 'rw': 'Reba ingendo zose z\'abana bawe'});
  String get contactSupport => _t({'en': 'Contact support', 'fr': 'Contacter le support', 'rw': 'Vugana n\'ubufasha'});
  String get sendClaim => _t({'en': 'Send a claim', 'fr': 'Envoyer une réclamation', 'rw': 'Ohereza ikibazo'});
  String get newEmergencyContact => _t({'en': 'New Emergency Contact', 'fr': 'Nouveau contact d\'urgence', 'rw': 'Konti nshya y\'acuri'});
  String get phoneNumberField => _t({'en': 'Phone number *', 'fr': 'Numéro de téléphone *', 'rw': 'Nimero ya telefoni *'});
  String get labelField => _t({'en': 'Label *', 'fr': 'Étiquette *', 'rw': 'Izina ry\'icyicaro *'});
  String get labelHint => _t({'en': 'e.g. Aunt, Uncle', 'fr': 'ex. Tante, Oncle', 'rw': 'urugero: Nyirarume, Musaza'});
  String get removeContactTitle => _t({'en': 'Remove contact?', 'fr': 'Supprimer le contact ?', 'rw': 'Gukuraho konti?'});
  String removeContactBody(String label, String phone) => _t({'en': '$label ($phone) will be removed.', 'fr': '$label ($phone) sera supprimé.', 'rw': '$label ($phone) izakurwaho.'});

  // ── Language picker ───────────────────────────────────────────────────────

  String get selectLanguage => _t({'en': 'Select language', 'fr': 'Choisir la langue', 'rw': 'Hitamo ururimi'});

  // ── Notifications ─────────────────────────────────────────────────────────

  String get notifications => _t({'en': 'Notifications', 'fr': 'Notifications', 'rw': 'Menyesha'});
  String get allNotifications => _t({'en': 'All notifications', 'fr': 'Toutes les notifications', 'rw': 'Menyesha yose'});
  String get emergencies => _t({'en': 'Emergencies', 'fr': 'Urgences', 'rw': 'Acuri'});

  // ── ETA ───────────────────────────────────────────────────────────────────

  String etaToReachHome(String eta) => _t({'en': '$eta to reach home', 'fr': '$eta pour arriver', 'rw': '$eta kugera inzu'});

  // ── Page headings ──────────────────────────────────────────────────────────

  String get moreSettings => _t({'en': 'More settings', 'fr': 'Plus de paramètres', 'rw': 'Igenamiterere ryinshi'});
  String get myChildren => _t({'en': 'My Children', 'fr': 'Mes enfants', 'rw': 'Abana bange'});
  String get scrollDown => _t({'en': 'Scroll down ↓', 'fr': 'Faites défiler ↓', 'rw': 'Manuka hepfo ↓'});

  // ── Add child form ─────────────────────────────────────────────────────────

  String get addAChild => _t({'en': 'Add a child', 'fr': 'Ajouter un enfant', 'rw': 'Ongeraho umwana'});
  String get fillInChildDetails => _t({'en': 'Fill in the details below to register your child.', 'fr': 'Remplissez les détails ci-dessous pour enregistrer votre enfant.', 'rw': 'Uzuza amakuru hepfo kugirango wandikishe umwana wawe.'});
  String get addPhotoOptional => _t({'en': 'Add photo (optional)', 'fr': 'Ajouter une photo (facultatif)', 'rw': 'Ongeraho ifoto (bidasabwa)'});
  String get fullNameField => _t({'en': 'Full name *', 'fr': 'Nom complet *', 'rw': 'Amazina yose *'});
  String get dateOfBirthField => _t({'en': 'Date of birth *', 'fr': 'Date de naissance *', 'rw': 'Itariki y\'amavuko *'});
  String get dateOfBirthRequired => _t({'en': 'Date of birth is required', 'fr': 'La date de naissance est requise', 'rw': 'Itariki y\'amavuko irasabwa'});
  String get male => _t({'en': 'Male', 'fr': 'Masculin', 'rw': 'Gabo'});
  String get female => _t({'en': 'Female', 'fr': 'Féminin', 'rw': 'Gore'});
  String get gradeField => _t({'en': 'Grade *', 'fr': 'Classe *', 'rw': 'Icyiciro *'});
  String get gradeHint => _t({'en': 'e.g. Grade 3', 'fr': 'ex. Grade 3', 'rw': 'urugero: Icyiciro 3'});
  String get gradeFormat => _t({'en': 'Use format: Grade 3', 'fr': 'Utilisez le format : Grade 3', 'rw': 'Koresha uburyo: Icyiciro 3'});
  String get gradeRange => _t({'en': 'Grade must be between 1 and 13', 'fr': 'La classe doit être entre 1 et 13', 'rw': 'Icyiciro kigomba kuba hagati ya 1 na 13'});
  String get addChild => _t({'en': 'Add child', 'fr': 'Ajouter l\'enfant', 'rw': 'Ongeraho umwana'});

  // ── Parent profile form ────────────────────────────────────────────────────

  String get parentProfile => _t({'en': 'Parent profile', 'fr': 'Profil parent', 'rw': 'Umwirondoro w\'umubyeyi'});

  // ── My children form ───────────────────────────────────────────────────────

  String get didYouKnow => _t({'en': 'Did you know?', 'fr': 'Le saviez-vous ?', 'rw': 'Ese wari uzi?'});
  String get didYouKnowBody => _t({'en': 'You can mark your students as absent easily by tapping them and selecting the absent action.', 'fr': 'Vous pouvez facilement marquer vos élèves absents en appuyant dessus et en sélectionnant l\'action absent.', 'rw': 'Ushobora kugaragaza abana bawe nk\'ababuze vuba ugabasumba hanyuma uchague igikorwa cy\'ubuze.'});
  String get noChildrenYet => _t({'en': 'No children added yet', 'fr': 'Aucun enfant ajouté', 'rw': 'Nta bana bongerwaho kuri ubu'});
  String get tapToAddFirstChild => _t({'en': 'Tap + to add your first child', 'fr': 'Appuyez sur + pour ajouter votre premier enfant', 'rw': 'Kanda + kongeraho umwana wawe wa mbere'});
  String get genderLabel => _t({'en': 'Gender', 'fr': 'Genre', 'rw': 'Igitsina'});
  String get evening => _t({'en': 'Evening', 'fr': 'Soir', 'rw': 'Nimugoroba'});
  String get selectDate => _t({'en': 'Select date', 'fr': 'Sélectionner une date', 'rw': 'Hitamo itariki'});
  String get editDetails => _t({'en': 'Edit details', 'fr': 'Modifier les détails', 'rw': 'Hindura amakuru'});
  String get changesSavedImmediately => _t({'en': 'Changes will be saved immediately.', 'fr': 'Les modifications seront enregistrées immédiatement.', 'rw': 'Impinduka zizabikwa vuba.'});
  String get saveChanges => _t({'en': 'Save changes', 'fr': 'Enregistrer les modifications', 'rw': 'Bika impinduka'});
  String get dateOfBirthLabel => _t({'en': 'Date of birth', 'fr': 'Date de naissance', 'rw': 'Itariki y\'amavuko'});
  String get gradeLabel => _t({'en': 'Grade', 'fr': 'Classe', 'rw': 'Icyiciro'});
  String get choosePhotoFromGallery => _t({'en': 'Tap the box below to choose a photo from your gallery.', 'fr': 'Appuyez sur la zone ci-dessous pour choisir une photo de votre galerie.', 'rw': 'Kanda akazu hepfo guhitamo ifoto uvuye mu bubiko bwawe.'});
  String get tapToSelectPhoto => _t({'en': 'Tap to select photo', 'fr': 'Appuyer pour choisir une photo', 'rw': 'Kanda guhitamo ifoto'});
  String get uploadPhoto => _t({'en': 'Upload photo', 'fr': 'Télécharger la photo', 'rw': 'Ohereza ifoto'});
  String markAbsentTitle(String name) => _t({'en': 'Mark $name absent', 'fr': 'Marquer $name absent', 'rw': 'Shyira $name nk\'ubuze'});
  String get driverNotifiedAbsent => _t({'en': 'The driver will be notified and the child will be marked as absent.', 'fr': 'Le conducteur sera informé et l\'enfant sera marqué absent.', 'rw': 'Umushoferi azamenyeshwa kandi umwana azashyirwa nk\'ubuze.'});
  String get journeyLabel => _t({'en': 'Journey', 'fr': 'Trajet', 'rw': 'Urugendo'});
  String get multipleDays => _t({'en': 'Multiple days', 'fr': 'Plusieurs jours', 'rw': 'Iminsi myinshi'});
  String get startDate => _t({'en': 'Start date', 'fr': 'Date de début', 'rw': 'Itariki yo gutangira'});
  String get dateLabel => _t({'en': 'Date', 'fr': 'Date', 'rw': 'Itariki'});
  String get endDate => _t({'en': 'End date', 'fr': 'Date de fin', 'rw': 'Itariki yo kurangira'});
  String get markAbsentBtn => _t({'en': 'Mark absent', 'fr': 'Marquer absent', 'rw': 'Shyira nk\'ubuze'});
  String markedAbsentSnack(String name) => _t({'en': '$name marked absent', 'fr': '$name marqué absent', 'rw': '$name ashyizwe nk\'ubuze'});
  String removeChildTitle(String name) => _t({'en': 'Remove "$name"?', 'fr': 'Supprimer "$name" ?', 'rw': 'Kuraho "$name"?'});
  String get removeChildBody => _t({'en': 'This will permanently delete this child record and all related data. This cannot be undone.', 'fr': 'Cela supprimera définitivement cet enregistrement et toutes les données liées. Cette action est irréversible.', 'rw': 'Ibi bizasiba burundu amakuru y\'uyu mwana hamwe n\'amakuru ashamikiyeho. Ntibinashobora guhindurwa.'});
  String get keep => _t({'en': 'Keep', 'fr': 'Garder', 'rw': 'Shyira hirya'});
  String get yesRemove => _t({'en': 'Yes, remove', 'fr': 'Oui, supprimer', 'rw': 'Yego, kuraho'});
  String editAbsenceTitle(String name) => _t({'en': 'Edit $name\'s absence', 'fr': 'Modifier l\'absence de $name', 'rw': 'Hindura ubuze bwa $name'});
  String get updateDatesOrJourney => _t({'en': 'Update the dates or journey type.', 'fr': 'Mettez à jour les dates ou le type de trajet.', 'rw': 'Vugurura amatariki cyangwa ubwoko bw\'urugendo.'});
  String nameIsAvailable(String name) => _t({'en': '$name is available?', 'fr': '$name est disponible ?', 'rw': '$name arahari?'});
  String cancelAbsenceSingle(String name, String date) => _t({'en': 'This will cancel the absence marked on $date. The driver will be notified that $name is back.', 'fr': 'Cela annulera l\'absence du $date. Le conducteur sera informé que $name est de retour.', 'rw': 'Ibi bizakuraho ubuze bwashyizwe ku $date. Umushoferi azamenyeshwa ko $name aragarutse.'});
  String cancelAbsenceRange(String name, String start, String end) => _t({'en': 'This will cancel the absence from $start to $end. The driver will be notified that $name is back.', 'fr': 'Cela annulera l\'absence du $start au $end. Le conducteur sera informé que $name est de retour.', 'rw': 'Ibi bizakuraho ubuze kuva $start kugeza $end. Umushoferi azamenyeshwa ko $name aragarutse.'});
  String get keepAbsence => _t({'en': 'Keep absence', 'fr': 'Garder l\'absence', 'rw': 'Shyira hirya ubuze'});
  String get yesCancelIt => _t({'en': 'Yes, cancel it', 'fr': 'Oui, l\'annuler', 'rw': 'Yego, kuraho'});
  String get editDetailsSubtitle => _t({'en': 'Update name, grade or birth date', 'fr': 'Modifier le nom, la classe ou la date de naissance', 'rw': 'Vugurura izina, icyiciro cyangwa itariki y\'amavuko'});
  String get changePhotoSubtitle => _t({'en': 'Upload a profile picture', 'fr': 'Télécharger une photo de profil', 'rw': 'Ohereza ifoto y\'umwirondoro'});
  String get editAbsenceAction => _t({'en': 'Edit absence', 'fr': 'Modifier l\'absence', 'rw': 'Hindura ubuze'});
  String get editAbsenceSubtitle => _t({'en': 'Change the dates or journey type', 'fr': 'Modifier les dates ou le type de trajet', 'rw': 'Hindura amatariki cyangwa ubwoko bw\'urugendo'});
  String get cancelAbsenceAction => _t({'en': 'Cancel absence', 'fr': 'Annuler l\'absence', 'rw': 'Kuraho ubuze'});
  String cancelAbsenceSubtitle(String name) => _t({'en': '$name is available, remove the absence', 'fr': '$name est disponible, supprimez l\'absence', 'rw': '$name arahari, kuraho ubuze'});
  String get markAsAbsentAction => _t({'en': 'Mark as absent', 'fr': 'Marquer comme absent', 'rw': 'Shyira nk\'ubuze'});
  String get markAsAbsentSubtitle => _t({'en': 'Notify driver for one or more days', 'fr': 'Notifier le conducteur pour un ou plusieurs jours', 'rw': 'Menyesha umushoferi ku munsi umwe cyangwa myinshi'});
  String get removeChildAction => _t({'en': 'Remove child', 'fr': 'Supprimer l\'enfant', 'rw': 'Kuraho umwana'});
  String get removeChildSubtitle => _t({'en': 'Permanently delete this record', 'fr': 'Supprimer définitivement cet enregistrement', 'rw': 'Siba burundu iki gice'});
}

// ── Delegate ──────────────────────────────────────────────────────────────────

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'rw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
