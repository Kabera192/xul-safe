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

  // ── Auth / nav / shared widgets (app-wide localization pass) ────────────────

  String get appReturnToLogin => _t({'en': 'Return to Login', 'fr': 'Retour à la connexion', 'rw': 'Subira ku kwinjira'});
  String get appTitle => _t({'en': 'Bus App', 'fr': 'Application Bus', 'rw': 'Porogaramu ya Bisi'});

  // ── Parent pages / forms (app-wide localization pass) ───────────────────────

  String get parTripIncidentsTitle => _t({'en': 'Trip incidents', 'fr': 'Incidents de trajet', 'rw': 'Ibibazo by\'urugendo'});
  String get parAddChildFirstRequestStop => _t({'en': 'Add a child first to request a bus stop for them.', 'fr': 'Ajoutez d\'abord un enfant pour demander un arrêt de bus pour lui.', 'rw': 'Banza wongere umwana kugira ngo usabe ahagarara ha bisi kuri we.'});
  String get parRequestStopTitle => _t({'en': 'Request a bus stop', 'fr': 'Demander un arrêt de bus', 'rw': 'Saba ahagarara ha bisi'});
  String get parChangeProfilePicture => _t({'en': 'Change profile picture', 'fr': 'Changer la photo de profil', 'rw': 'Hindura ifoto y\'umwirondoro'});
  String get parSaving => _t({'en': 'Saving…', 'fr': 'Enregistrement…', 'rw': 'Kubika...'});
  String get parProfilePicture => _t({'en': 'Profile picture', 'fr': 'Photo de profil', 'rw': 'Ifoto y\'umwirondoro'});
  String get parEditFullName => _t({'en': 'Edit Full Name', 'fr': 'Modifier le nom complet', 'rw': 'Hindura amazina yose'});
  String get parEditEmail => _t({'en': 'Edit Email', 'fr': 'Modifier l\'e-mail', 'rw': 'Hindura imeyili'});
  String get parEditPhoneNumber => _t({'en': 'Edit Phone Number', 'fr': 'Modifier le numéro de téléphone', 'rw': 'Hindura nimero ya telefoni'});
  String get parEditProfilePicture => _t({'en': 'Edit Profile Picture', 'fr': 'Modifier la photo de profil', 'rw': 'Hindura ifoto y\'umwirondoro'});
  String get parChangePassword => _t({'en': 'Change Password', 'fr': 'Changer le mot de passe', 'rw': 'Hindura ijambo banga'});
  String get parPhotoUpdateLater => _t({'en': 'Photo update will be connected later.', 'fr': 'La mise à jour de la photo sera disponible plus tard.', 'rw': 'Guhindura ifoto bizashyirwaho nyuma.'});
  String get parEmailLabel => _t({'en': 'Email', 'fr': 'E-mail', 'rw': 'Imeyili'});
  String get parCurrentPassword => _t({'en': 'Current password', 'fr': 'Mot de passe actuel', 'rw': 'Ijambo banga rya ubu'});
  String get parNewPassword => _t({'en': 'New password', 'fr': 'Nouveau mot de passe', 'rw': 'Ijambo banga rishya'});
  String get parAtLeast6Chars => _t({'en': 'At least 6 characters', 'fr': 'Au moins 6 caractères', 'rw': 'Nibura inyuguti 6'});
  String get parConfirmNewPassword => _t({'en': 'Confirm new password', 'fr': 'Confirmer le nouveau mot de passe', 'rw': 'Emeza ijambo banga rishya'});
  String get parIncidentsTitle => _t({'en': 'Incidents', 'fr': 'Incidents', 'rw': 'Ibibazo'});
  String get parSearchIncidents => _t({'en': 'Search incidents', 'fr': 'Rechercher des incidents', 'rw': 'Shakisha ibibazo'});
  String get parNoIncidentsFound => _t({'en': 'No incidents found', 'fr': 'Aucun incident trouvé', 'rw': 'Nta kibazo kiboneka'});
  String get parOngoing => _t({'en': 'ONGOING', 'fr': 'EN COURS', 'rw': 'BIRAKOMEZA'});
  String get parResolved => _t({'en': 'RESOLVED', 'fr': 'RÉSOLU', 'rw': 'BYAKEMUTSE'});
  String get parActive => _t({'en': 'ACTIVE', 'fr': 'ACTIF', 'rw': 'BIRAKOMEJE'});
  String parJourneyColon(String impact) => _t({'en': 'Journey: $impact', 'fr': 'Trajet : $impact', 'rw': 'Urugendo: $impact'});
  String get parIncidentTypeAccident => _t({'en': 'Bus accident or collision', 'fr': 'Accident ou collision de bus', 'rw': 'Impanuka cyangwa kugongana kwa bisi'});
  String get parIncidentTypeMedical => _t({'en': 'Sick / injured student', 'fr': 'Élève malade / blessé', 'rw': 'Umwana murwayi/wakomeretse'});
  String get parIncidentTypeBreakdown => _t({'en': 'Bus mechanical issue', 'fr': 'Problème mécanique du bus', 'rw': 'Ikibazo cya mashini ya bisi'});
  String get parIncidentTypeDelay => _t({'en': 'Journey delay', 'fr': 'Retard du trajet', 'rw': 'Gutinda kw\'urugendo'});
  String get parIncidentTypeRoadObstruction => _t({'en': 'Road obstruction', 'fr': 'Obstruction sur la route', 'rw': 'Umuhanda wabujijwe'});
  String get parIncidentTypeChildBehavior => _t({'en': 'Student behavior issue', 'fr': 'Problème de comportement de l\'élève', 'rw': 'Ikibazo cy\'imyitwarire y\'umwana'});
  String get parIncidentTypeOther => _t({'en': 'Other incident', 'fr': 'Autre incident', 'rw': 'Ikindi kibazo'});
  String get parImpactNone => _t({'en': 'No impact', 'fr': 'Aucun impact', 'rw': 'Nta ngaruka'});
  String get parImpactDelayed => _t({'en': 'Delayed', 'fr': 'Retardé', 'rw': 'Byatinze'});
  String get parImpactStopped => _t({'en': 'Stopped', 'fr': 'Arrêté', 'rw': 'Byahagaze'});
  String parTodayAt(String time) => _t({'en': 'Today, $time', 'fr': 'Aujourd\'hui, $time', 'rw': 'Uyu munsi, $time'});
  String parYesterdayAt(String time) => _t({'en': 'Yesterday, $time', 'fr': 'Hier, $time', 'rw': 'Ejo hashize, $time'});
  String get parPhotoUnavailable => _t({'en': 'Photo unavailable', 'fr': 'Photo indisponible', 'rw': 'Ifoto ntiboneka'});
  String get parAffectedStudentSingular => _t({'en': 'Affected student', 'fr': 'Élève concerné', 'rw': 'Umwana wagizweho ingaruka'});
  String get parAffectedStudentsPlural => _t({'en': 'Affected students', 'fr': 'Élèves concernés', 'rw': 'Abana bagizweho ingaruka'});
  String get parJourneyImpact => _t({'en': 'Journey impact', 'fr': 'Impact sur le trajet', 'rw': 'Ingaruka ku rugendo'});
  String get parWhatHappened => _t({'en': 'What happened?', 'fr': 'Que s\'est-il passé ?', 'rw': 'Ni iki cyabaye?'});
  String get parReported => _t({'en': 'Reported', 'fr': 'Signalé', 'rw': 'Byatangajwe'});
  String get parResolvedLabel => _t({'en': 'Resolved', 'fr': 'Résolu', 'rw': 'Byakemutse'});
  String get parVoiceNoteUnavailable => _t({'en': 'Voice note unavailable', 'fr': 'Note vocale indisponible', 'rw': 'Ijwi ntiriboneka'});
  String get parStudentFallback => _t({'en': 'Student', 'fr': 'Élève', 'rw': 'Umwana'});
  String get parCouldNotSearchLocation => _t({'en': 'Could not search location', 'fr': 'Impossible de rechercher le lieu', 'rw': 'Byanze gushakisha ahantu'});
  String get parCouldNotCaptureLocation => _t({'en': 'Could not capture current location', 'fr': 'Impossible de capturer la position actuelle', 'rw': 'Byanze gufata aho uri ubu'});
  String get parSelectChildForStop => _t({'en': 'Please select which child this stop is for', 'fr': 'Veuillez sélectionner l\'enfant concerné par cet arrêt', 'rw': 'Nyamuneka hitamo umwana uyu muhagarara ari uwe'});
  String get parAddressRequired => _t({'en': 'Address is required', 'fr': 'L\'adresse est requise', 'rw': 'Aderesi irasabwa'});
  String get parCaptureOrSelectLocation => _t({'en': 'Please capture or select a location first', 'fr': 'Veuillez d\'abord capturer ou sélectionner un lieu', 'rw': 'Nyamuneka banza ufate cyangwa uhitemo ahantu'});
  String get parAddressLabel => _t({'en': 'Address', 'fr': 'Adresse', 'rw': 'Aderesi'});
  String get parNoteOptionalHint => _t({'en': 'Note (optional), e.g. near the blue gate', 'fr': 'Note (facultatif), ex. près de la porte bleue', 'rw': 'Inyandiko (bidasabwa), urugero: hafi y\'irembo ry\'ubururu'});
  String get parSearchPlaceName => _t({'en': 'Search a place name', 'fr': 'Rechercher un nom de lieu', 'rw': 'Shakisha izina ry\'ahantu'});
  String get parSearchingLocation => _t({'en': 'Searching location…', 'fr': 'Recherche du lieu…', 'rw': 'Dushakisha ahantu...'});
  String get parCapturing => _t({'en': 'Capturing…', 'fr': 'Capture en cours…', 'rw': 'Kwifata...'});
  String get parCaptureCurrentLocation => _t({'en': 'Capture my current location', 'fr': 'Capturer ma position actuelle', 'rw': 'Fata aho ndi ubu'});
  String get parSubmitting => _t({'en': 'Submitting…', 'fr': 'Envoi en cours…', 'rw': 'Kohereza...'});
  String get parSubmitRequest => _t({'en': 'Submit request', 'fr': 'Envoyer la demande', 'rw': 'Ohereza icyifuzo'});
  String get parWhichChildForStop => _t({'en': 'Which child is this stop for?', 'fr': 'Pour quel enfant est cet arrêt ?', 'rw': 'Uyu muhagarara ni uwuhe mwana?'});
  String get parRequestSubmitted => _t({'en': 'Request submitted', 'fr': 'Demande envoyée', 'rw': 'Icyifuzo cyoherejwe'});
  String get parRequestSubmittedBody => _t({'en': 'Your custom bus stop request has been sent to the school admin for approval. You\'ll be notified once it\'s reviewed.', 'fr': 'Votre demande d\'arrêt personnalisé a été envoyée à l\'administration de l\'école pour approbation. Vous serez informé une fois examinée.', 'rw': 'Icyifuzo cyawe cy\'ahagarara hateganijwe cyoherejwe ku buyobozi bw\'ishuri kugira ngo byemezwe. Uzamenyeshwa igihe bizasuzumwa.'});

  // ── Driver pages / forms (app-wide localization pass) ───────────────────────

  String get drvAttendanceTitle => _t({'en': 'Attendance', 'fr': 'Présence', 'rw': 'Ubwitabire'});
  String get drvWeekdayMonday => _t({'en': 'Monday', 'fr': 'Lundi', 'rw': 'Kuwa mbere'});
  String get drvWeekdayTuesday => _t({'en': 'Tuesday', 'fr': 'Mardi', 'rw': 'Kuwa kabiri'});
  String get drvWeekdayWednesday => _t({'en': 'Wednesday', 'fr': 'Mercredi', 'rw': 'Kuwa gatatu'});
  String get drvWeekdayThursday => _t({'en': 'Thursday', 'fr': 'Jeudi', 'rw': 'Kuwa kane'});
  String get drvWeekdayFriday => _t({'en': 'Friday', 'fr': 'Vendredi', 'rw': 'Kuwa gatanu'});
  String get drvWeekdaySaturday => _t({'en': 'Saturday', 'fr': 'Samedi', 'rw': 'Kuwa gatandatu'});
  String get drvWeekdaySunday => _t({'en': 'Sunday', 'fr': 'Dimanche', 'rw': 'Ku cyumweru'});
  String get drvMonthJan => _t({'en': 'Jan', 'fr': 'Janv.', 'rw': 'Mutarama'});
  String get drvMonthFeb => _t({'en': 'Feb', 'fr': 'Févr.', 'rw': 'Gashyantare'});
  String get drvMonthMar => _t({'en': 'Mar', 'fr': 'Mars', 'rw': 'Werurwe'});
  String get drvMonthApr => _t({'en': 'Apr', 'fr': 'Avr.', 'rw': 'Mata'});
  String get drvMonthMay => _t({'en': 'May', 'fr': 'Mai', 'rw': 'Gicurasi'});
  String get drvMonthJun => _t({'en': 'Jun', 'fr': 'Juin', 'rw': 'Kamena'});
  String get drvMonthJul => _t({'en': 'Jul', 'fr': 'Juil.', 'rw': 'Nyakanga'});
  String get drvMonthAug => _t({'en': 'Aug', 'fr': 'Août', 'rw': 'Kanama'});
  String get drvMonthSep => _t({'en': 'Sep', 'fr': 'Sept.', 'rw': 'Nzeli'});
  String get drvMonthOct => _t({'en': 'Oct', 'fr': 'Oct.', 'rw': 'Ukwakira'});
  String get drvMonthNov => _t({'en': 'Nov', 'fr': 'Nov.', 'rw': 'Ugushyingo'});
  String get drvMonthDec => _t({'en': 'Dec', 'fr': 'Déc.', 'rw': 'Ukuboza'});
  String drvChildAvailableForPickup(String name) => _t({'en': '$name is now available for pickup', 'fr': '$name est maintenant disponible pour le ramassage', 'rw': '$name araboneka ubu kugira ngo afatwe'});
  String drvChildrenCountTitle(int n) => _t({'en': 'Children($n)', 'fr': 'Enfants($n)', 'rw': 'Abana($n)'});
  String get drvChildrenTitleNoCount => _t({'en': 'Children', 'fr': 'Enfants', 'rw': 'Abana'});
  String get drvCreateBusStopTitle => _t({'en': 'Create bus stop', 'fr': 'Créer un arrêt de bus', 'rw': 'Kurema aho bisi ihagarara'});
  String get drvModifyBusStopTitle => _t({'en': 'Modify bus stop', 'fr': 'Modifier l\'arrêt de bus', 'rw': 'Hindura aho bisi ihagarara'});
  String get drvCouldNotDetermineBus => _t({'en': 'Could not determine the bus assigned to this driver', 'fr': 'Impossible de déterminer le bus assigné à ce conducteur', 'rw': 'Ntibyashoboye kumenya bisi yahawe uyu mushoferi'});
  String get drvAttachmentFailedPhoto => _t({'en': 'photo', 'fr': 'photo', 'rw': 'ifoto'});
  String get drvAttachmentFailedVoiceNote => _t({'en': 'voice note', 'fr': 'note vocale', 'rw': 'ijwi ryanditswe'});
  String get drvAttachmentAnd => _t({'en': 'and', 'fr': 'et', 'rw': 'na'});
  String drvAttachmentWarningBody(String items, String pronoun) => _t({'en': 'The incident was reported, but the $items could not be attached. Please try adding $pronoun again later.', 'fr': 'L\'incident a été signalé, mais $items n\'a pas pu être joint. Veuillez réessayer d\'ajouter $pronoun plus tard.', 'rw': 'Ikibazo cyamenyekanishijwe, ariko $items ntibyashoboye kwoherezwa. Ongera ugerageze kongeramo $pronoun nyuma.'});
  String get drvThemPronoun => _t({'en': 'them', 'fr': 'les', 'rw': 'byo'});
  String get drvItPronoun => _t({'en': 'it', 'fr': 'le', 'rw': 'cyo'});
  String get drvTripIncidentsTitle => _t({'en': 'Trip incidents', 'fr': 'Incidents de trajet', 'rw': 'Ibibazo by\'urugendo'});
  String get drvCantStartJourneyTitle => _t({'en': 'Can\'t Start Journey', 'fr': 'Impossible de démarrer le trajet', 'rw': 'Ntushobora gutangira urugendo'});
  String drvStopNumberFallback(Object n) => _t({'en': 'Stop $n', 'fr': 'Arrêt $n', 'rw': 'Igihagararo $n'});
  String get drvManageIncidents => _t({'en': 'Manage incidents', 'fr': 'Gérer les incidents', 'rw': 'Gucunga ibibazo'});
  String get drvReportIncidentAction => _t({'en': 'Report incident', 'fr': 'Signaler un incident', 'rw': 'Tanga ikibazo'});
  String drvBusRouteWithId(Object id) => _t({'en': 'Bus route $id', 'fr': 'Itinéraire de bus $id', 'rw': 'Inzira ya bisi $id'});
  String get drvStudentProfileTitle => _t({'en': 'Student profile', 'fr': 'Profil de l\'élève', 'rw': 'Umwirondoro w\'umwana w\'ishuri'});
  String get drvNotAvailable => _t({'en': 'Not available', 'fr': 'Non disponible', 'rw': 'Ntibiraboneka'});
  String get drvNotAssigned => _t({'en': 'Not assigned', 'fr': 'Non assigné', 'rw': 'Ntibyagenewe'});
  String get drvNoCoordinatesAvailable => _t({'en': 'No coordinates available', 'fr': 'Aucune coordonnée disponible', 'rw': 'Nta koridone iraboneka'});
  String get drvCoordinatesNotAvailableYet => _t({'en': 'Coordinates not available yet', 'fr': 'Coordonnées pas encore disponibles', 'rw': 'Koridone ntiraboneka'});
  String get drvFullNamesLabel => _t({'en': 'Full names', 'fr': 'Noms complets', 'rw': 'Amazina yose'});
  String get drvParentGuardianContactsTitle => _t({'en': 'Parent/ Guardian contacts', 'fr': 'Contacts du parent/tuteur', 'rw': 'Namba z\'ababyeyi/abarezi'});
  String get drvGuardiansNumberLabel => _t({'en': 'Guardian\'s number', 'fr': 'Numéro du tuteur', 'rw': 'Nimero y\'umurezi'});
  String get drvCouldNotSearchLocation => _t({'en': 'Could not search location', 'fr': 'Impossible de rechercher l\'emplacement', 'rw': 'Ntibyashoboye gushakisha aho biherereye'});
  String get drvUnexpectedSearchResponse => _t({'en': 'Unexpected search response', 'fr': 'Réponse de recherche inattendue', 'rw': 'Igisubizo cy\'ishakiro kitari ngombwa'});
  String get drvCouldNotCaptureLocation => _t({'en': 'Could not capture current location', 'fr': 'Impossible de capturer la position actuelle', 'rw': 'Ntibyashoboye gufata aho uri ubu'});
  String get drvStopDetailRequired => _t({'en': 'Stop detail is required', 'fr': 'Le détail de l\'arrêt est requis', 'rw': 'Ibisobanuro by\'aho bisi ihagarara birasabwa'});
  String get drvPleaseCaptureOrSelectLocation => _t({'en': 'Please capture or select a location first', 'fr': 'Veuillez d\'abord capturer ou sélectionner un emplacement', 'rw': 'Banza ufate cyangwa uhitemo aho biherereye'});
  String get drvEnterSmallDetailHint => _t({'en': 'Enter a small detail', 'fr': 'Entrez un petit détail', 'rw': 'Andika agasobanuro gake'});
  String get drvSearchPlaceNameHint => _t({'en': 'Search a place name', 'fr': 'Rechercher un nom de lieu', 'rw': 'Shakisha izina ry\'ahantu'});
  String get drvSearchingLocation => _t({'en': 'Searching location…', 'fr': 'Recherche de l\'emplacement…', 'rw': 'Gushaka aho biherereye…'});
  String get drvCapturingEllipsis => _t({'en': 'Capturing…', 'fr': 'Capture en cours…', 'rw': 'Kwifata…'});
  String get drvCaptureCurrentLocationBtn => _t({'en': 'Capture my current location', 'fr': 'Capturer ma position actuelle', 'rw': 'Fata aho ndi ubu'});
  String get drvSavingEllipsis => _t({'en': 'Saving…', 'fr': 'Enregistrement…', 'rw': 'Kubika…'});
  String get drvSaveBusStopBtn => _t({'en': 'Save bus stop', 'fr': 'Enregistrer l\'arrêt de bus', 'rw': 'Bika aho bisi ihagarara'});
  String get drvEditFullNameTitle => _t({'en': 'Edit Full Name', 'fr': 'Modifier le nom complet', 'rw': 'Hindura amazina yose'});
  String get drvEditEmailTitle => _t({'en': 'Edit Email', 'fr': 'Modifier l\'email', 'rw': 'Hindura imeyili'});
  String get drvEditPhoneNumberTitle => _t({'en': 'Edit Phone Number', 'fr': 'Modifier le numéro de téléphone', 'rw': 'Hindura nimero ya telefoni'});
  String get drvEditProfilePictureTitle => _t({'en': 'Edit Profile Picture', 'fr': 'Modifier la photo de profil', 'rw': 'Hindura ifoto y\'umwirondoro'});
  String drvCompletedCount(int confirmed, int total) => _t({'en': '$confirmed / $total completed', 'fr': '$confirmed / $total terminés', 'rw': '$confirmed / $total byarangiye'});
  String get drvNoStudentsOnBus => _t({'en': 'No students on this bus', 'fr': 'Aucun élève dans ce bus', 'rw': 'Nta mwana uri muri bisi'});
  String get drvAbsentToday => _t({'en': 'Absent today', 'fr': 'Absent aujourd\'hui', 'rw': 'Ntahari uyu munsi'});
  String get drvCompletedStatus => _t({'en': 'Completed', 'fr': 'Terminé', 'rw': 'Byarangiye'});
  String get drvOnBusStatus => _t({'en': 'On bus', 'fr': 'Dans le bus', 'rw': 'Ari mu bisi'});
  String get drvHeadingHomeStatus => _t({'en': 'Heading home', 'fr': 'En route vers la maison', 'rw': 'Ajya mu rugo'});
  String get drvNotYetBoarded => _t({'en': 'Not yet boarded', 'fr': 'Pas encore monté', 'rw': 'Ntarinjira mu bisi'});
  String get drvNotYetPickedUp => _t({'en': 'Not yet picked up', 'fr': 'Pas encore récupéré', 'rw': 'Ntaraza gufatwa'});
  String get drvUnnamedStudent => _t({'en': 'Unnamed student', 'fr': 'Élève sans nom', 'rw': 'Umwana w\'ishuri utazwi izina'});
  String get drvMorningJourneyLabel => _t({'en': 'Morning Journey', 'fr': 'Trajet du matin', 'rw': 'Urugendo rw\'igitondo'});
  String get drvBoardedBusLabel => _t({'en': 'Boarded bus', 'fr': 'Monté dans le bus', 'rw': 'Yinjiye mu bisi'});
  String get drvArrivedAtSchoolLabel => _t({'en': 'Arrived at school', 'fr': 'Arrivé à l\'école', 'rw': 'Yageze ku ishuri'});
  String get drvAfternoonJourneyLabel => _t({'en': 'Afternoon Journey', 'fr': 'Trajet de l\'après-midi', 'rw': 'Urugendo rw\'nimugoroba'});
  String get drvDroppedAtStopLabel => _t({'en': 'Dropped at stop', 'fr': 'Déposé à l\'arrêt', 'rw': 'Yamanuwe ku gihagararo'});
  String get drvAbsentForJourney => _t({'en': 'Absent for this journey', 'fr': 'Absent pour ce trajet', 'rw': 'Ntahari kuri uru rugendo'});
  String get drvStudentsAssignedTitle => _t({'en': 'Students assigned', 'fr': 'Élèves assignés', 'rw': 'Abana boherejwe'});
  String get drvStudentsAssignedBody => _t({'en': 'You have successfully assigned the selected students to this bus stop.', 'fr': 'Vous avez assigné avec succès les élèves sélectionnés à cet arrêt de bus.', 'rw': 'Washyize neza abana bahiswemo kuri aka gahagararo ka bisi.'});
  String get drvBusStopSavedTitle => _t({'en': 'Bus stop Saved', 'fr': 'Arrêt de bus enregistré', 'rw': 'Aho bisi ihagarara byabitswe'});
  String get drvBusStopSavedBody => _t({'en': 'You have successfully added a new bus stop to the route you can see it among other bus stops and assign students to it.', 'fr': 'Vous avez ajouté avec succès un nouvel arrêt de bus à l\'itinéraire, vous pouvez le voir parmi les autres arrêts et lui assigner des élèves.', 'rw': 'Washyizeho neza ahagarara ha bisi hashya ku nzira, urashobora kuhabona hamwe n\'ahandi hagarara maze ushyireho abana.'});
  String get drvOtherReason => _t({'en': 'Other reason', 'fr': 'Autre raison', 'rw': 'Impamvu indi'});
  String get drvReasonMovedAway => _t({'en': 'Students have moved to another place', 'fr': 'Les élèves ont déménagé ailleurs', 'rw': 'Abana bimukiye ahandi'});
  String get drvReasonNoLongerInSchool => _t({'en': 'Students are no longer in this school', 'fr': 'Les élèves ne sont plus dans cette école', 'rw': 'Abana batakiri muri iri shuri'});
  String get drvPleaseSelectReason => _t({'en': 'Please select a reason', 'fr': 'Veuillez sélectionner une raison', 'rw': 'Nyamuneka hitamo impamvu'});
  String get drvPleaseEnterReason => _t({'en': 'Please enter the reason', 'fr': 'Veuillez saisir la raison', 'rw': 'Nyamuneka andika impamvu'});
  String get drvAreYouSureTitle => _t({'en': 'Are you sure?', 'fr': 'Êtes-vous sûr ?', 'rw': 'Uzi neza?'});
  String get drvDeleteStopConfirmBody => _t({'en': 'Are you sure you want to delete this bus stop? If so, can you clarify why below.', 'fr': 'Êtes-vous sûr de vouloir supprimer cet arrêt de bus ? Si oui, précisez pourquoi ci-dessous.', 'rw': 'Uzi neza ko ushaka gusiba aka gahagararo ka bisi? Niba ari byo, sobanura impamvu hepfo.'});
  String get drvDeletingEllipsis => _t({'en': 'Deleting…', 'fr': 'Suppression…', 'rw': 'Gusiba…'});
  String get drvBusStopDeletedTitle => _t({'en': 'Bus stop Deleted', 'fr': 'Arrêt de bus supprimé', 'rw': 'Aho bisi ihagarara byasibwe'});
  String get drvBusStopDeletedBody => _t({'en': 'You have successfully deleted this bus stop. It will no longer appear in the route stops list.', 'fr': 'Vous avez supprimé avec succès cet arrêt de bus. Il n\'apparaîtra plus dans la liste des arrêts.', 'rw': 'Wasibye neza aka gahagararo ka bisi. Ntikazongera kugaragara ku rutonde rw\'ahagarara.'});
  String get drvStopNameRequired => _t({'en': 'Stop name is required', 'fr': 'Le nom de l\'arrêt est requis', 'rw': 'Izina ry\'ahagarara birasabwa'});
  String get drvTabDetails => _t({'en': 'Details', 'fr': 'Détails', 'rw': 'Ibisobanuro'});
  String get drvTabEditName => _t({'en': 'Edit name', 'fr': 'Modifier le nom', 'rw': 'Hindura izina'});
  String get drvTabLocation => _t({'en': 'Location', 'fr': 'Emplacement', 'rw': 'Aho biherereye'});
  String get drvStopNameLabel => _t({'en': 'Stop name', 'fr': 'Nom de l\'arrêt', 'rw': 'Izina ry\'ahagarara'});
  String get drvNoNameSet => _t({'en': 'No name set', 'fr': 'Aucun nom défini', 'rw': 'Nta izina rishyizweho'});
  String get drvCoordinatesLabel => _t({'en': 'Coordinates', 'fr': 'Coordonnées', 'rw': 'Koridone'});
  String get drvAssignStudents => _t({'en': 'Assign students', 'fr': 'Assigner des élèves', 'rw': 'Shyira abana'});
  String get drvEnterStopNameHint => _t({'en': 'Enter stop name or detail', 'fr': 'Entrez le nom ou le détail de l\'arrêt', 'rw': 'Andika izina cyangwa ibisobanuro by\'ahagarara'});
  String get drvSaveNameBtn => _t({'en': 'Save name', 'fr': 'Enregistrer le nom', 'rw': 'Bika izina'});
  String get drvSaveLocationBtn => _t({'en': 'Save location', 'fr': 'Enregistrer l\'emplacement', 'rw': 'Bika aho biherereye'});
  String get drvBusStopUpdatedTitle => _t({'en': 'Bus stop Updated', 'fr': 'Arrêt de bus mis à jour', 'rw': 'Aho bisi ihagarara byavuguruwe'});
  String get drvBusStopUpdatedBody => _t({'en': 'You have successfully updated this bus stop. The changes will now appear in the route stops list.', 'fr': 'Vous avez mis à jour avec succès cet arrêt de bus. Les modifications apparaîtront désormais dans la liste des arrêts.', 'rw': 'Wavuguruye neza aka gahagararo ka bisi. Impinduka zizagaragara ku rutonde rw\'ahagarara.'});
  String get drvChangeProfilePictureTitle => _t({'en': 'Change profile picture', 'fr': 'Changer la photo de profil', 'rw': 'Hindura ifoto y\'umwirondoro'});
  String get drvProfilePicturePlaceholder => _t({'en': 'Profile picture', 'fr': 'Photo de profil', 'rw': 'Ifoto y\'umwirondoro'});
  String get drvPleaseSelectOneStudent => _t({'en': 'Please select at least one student', 'fr': 'Veuillez sélectionner au moins un élève', 'rw': 'Nyamuneka hitamo nibura umwana umwe'});
  String get drvCompleteChangesBtn => _t({'en': 'Complete changes', 'fr': 'Terminer les modifications', 'rw': 'Rangiza impinduka'});
  String get drvAssigningStatus => _t({'en': 'Assigning', 'fr': 'Attribution en cours', 'rw': 'Birimo gushyirwa'});
  String get drvReassignStatus => _t({'en': 'Re-assign', 'fr': 'Réassigner', 'rw': 'Ongera ushyire'});
  String get drvAssignStatus => _t({'en': 'Assign', 'fr': 'Assigner', 'rw': 'Shyira'});
  String get drvNoStudentsAvailable => _t({'en': 'No students available to assign', 'fr': 'Aucun élève disponible à assigner', 'rw': 'Nta mwana uhari wo gushyirwa'});
  String get drvBusDetailsTitle => _t({'en': 'Bus details', 'fr': 'Détails du bus', 'rw': 'Amakuru ya bisi'});
  String get drvNoBusAssignedYet => _t({'en': 'No bus assigned yet', 'fr': 'Aucun bus assigné encore', 'rw': 'Nta bisi yahawe kugeza ubu'});
  String get drvNoRouteAssignedYet => _t({'en': 'No route assigned yet', 'fr': 'Aucun itinéraire assigné encore', 'rw': 'Nta nzira yahawe kugeza ubu'});
  String get drvBusStopsTitle => _t({'en': 'Bus stops', 'fr': 'Arrêts de bus', 'rw': 'Ahagarara ha bisi'});
  String get drvCreateNewBusStopBtn => _t({'en': 'Create new bus stop', 'fr': 'Créer un nouvel arrêt de bus', 'rw': 'Kurema ahagarara hashya ha bisi'});
  String drvBusStopNumbered(Object n) => _t({'en': 'Bus stop $n', 'fr': 'Arrêt de bus $n', 'rw': 'Igihagararo cya bisi $n'});
  String get drvUnnamedBusStop => _t({'en': 'Unnamed bus stop', 'fr': 'Arrêt de bus sans nom', 'rw': 'Ahagarara ha bisi hatazwi izina'});
  String drvStudentCountLabel(int n) => _t({'en': '$n student(s)', 'fr': '$n élève(s)', 'rw': 'Abana $n'});
  String get drvNoBusStopsYet => _t({'en': 'No bus stops created yet', 'fr': 'Aucun arrêt de bus créé encore', 'rw': 'Nta hagarara ha bisi harashyizweho'});
  String get drvUnknownStop => _t({'en': 'Unknown stop', 'fr': 'Arrêt inconnu', 'rw': 'Ahagarara hatazwi'});
  String get drvNoChildrenFound => _t({'en': 'No children found', 'fr': 'Aucun enfant trouvé', 'rw': 'Nta mwana wabonetse'});
  String get drvUnnamedChild => _t({'en': 'Unnamed child', 'fr': 'Enfant sans nom', 'rw': 'Umwana utazwi izina'});
  String get drvTakePhoto => _t({'en': 'Take photo', 'fr': 'Prendre une photo', 'rw': 'Fata ifoto'});
  String get drvChooseFromGallery => _t({'en': 'Choose from gallery', 'fr': 'Choisir depuis la galerie', 'rw': 'Hitamo mu bubiko'});
  String get drvMicPermissionRequired => _t({'en': 'Microphone permission is required to record a voice note.', 'fr': 'L\'autorisation du microphone est requise pour enregistrer une note vocale.', 'rw': 'Uburenganzira bwo gukoresha mikoro burakenewe kugira ngo wandike ijwi.'});
  String get drvAddPhotoBtn => _t({'en': 'Add photo', 'fr': 'Ajouter une photo', 'rw': 'Ongeraho ifoto'});
  String get drvJourneyImpactLabel => _t({'en': 'Journey impact', 'fr': 'Impact sur le trajet', 'rw': 'Ingaruka ku rugendo'});
  String get drvRecordingTapToStop => _t({'en': 'Recording... Tap to stop', 'fr': 'Enregistrement... Appuyez pour arrêter', 'rw': 'Kwandika... Kanda kugira uhagarike'});
  String get drvVoiceNoteRecorded => _t({'en': 'Voice note recorded', 'fr': 'Note vocale enregistrée', 'rw': 'Ijwi ryanditswe'});
  String get drvRecordAudioLabel => _t({'en': 'Record audio', 'fr': 'Enregistrer l\'audio', 'rw': 'Andika ijwi'});
  String get drvSendReportBtn => _t({'en': 'Send report', 'fr': 'Envoyer le rapport', 'rw': 'Ohereza raporo'});
  String get drvImpactNone => _t({'en': 'No impact', 'fr': 'Aucun impact', 'rw': 'Nta ngaruka'});
  String get drvImpactDelayed => _t({'en': 'Delayed', 'fr': 'Retardé', 'rw': 'Byatinze'});
  String get drvImpactStopped => _t({'en': 'Stopped', 'fr': 'Arrêté', 'rw': 'Byahagaze'});
  String get drvEditAccidentTitle => _t({'en': 'Edit accident', 'fr': 'Modifier l\'accident', 'rw': 'Hindura impanuka'});
  String get drvEditBreakdownTitle => _t({'en': 'Edit mechanical issue', 'fr': 'Modifier le problème mécanique', 'rw': 'Hindura ikibazo cya moteri'});
  String get drvEditDelayTitle => _t({'en': 'Edit delay', 'fr': 'Modifier le retard', 'rw': 'Hindura ubutinzi'});
  String get drvEditRoadObstructionTitle => _t({'en': 'Edit road obstruction', 'fr': 'Modifier l\'obstruction de la route', 'rw': 'Hindura ikibuza inzira'});
  String get drvEditMedicalTitle => _t({'en': 'Edit medical incident', 'fr': 'Modifier l\'incident médical', 'rw': 'Hindura ikibazo cy\'ubuzima'});
  String get drvEditBehaviorTitle => _t({'en': 'Edit behavior incident', 'fr': 'Modifier l\'incident de comportement', 'rw': 'Hindura ikibazo cy\'imyitwarire'});
  String get drvEditOtherIncidentTitle => _t({'en': 'Edit other incident', 'fr': 'Modifier un autre incident', 'rw': 'Hindura ikindi kibazo'});
  String get drvEditIncidentTitle => _t({'en': 'Edit incident', 'fr': 'Modifier l\'incident', 'rw': 'Hindura ikibazo'});
  String get drvReportAccidentTitle => _t({'en': 'Report accident', 'fr': 'Signaler un accident', 'rw': 'Tanga impanuka'});
  String get drvReportBreakdownTitle => _t({'en': 'Report mechanical issue', 'fr': 'Signaler un problème mécanique', 'rw': 'Tanga ikibazo cya moteri'});
  String get drvReportDelayTitle => _t({'en': 'Report delay', 'fr': 'Signaler un retard', 'rw': 'Tanga ubutinzi'});
  String get drvReportRoadObstructionTitle => _t({'en': 'Report road obstruction', 'fr': 'Signaler une obstruction de la route', 'rw': 'Tanga ikibuza inzira'});
  String get drvReportOtherIncidentTitle => _t({'en': 'Report other incident', 'fr': 'Signaler un autre incident', 'rw': 'Tanga ikindi kibazo'});
  String get drvReportIncidentTitle => _t({'en': 'Report incident', 'fr': 'Signaler un incident', 'rw': 'Tanga ikibazo'});
  String get drvDelayHint => _t({'en': 'What is causing the delay?', 'fr': 'Quelle est la cause du retard ?', 'rw': 'Ni iki gitera ubutinzi?'});
  String get drvRoadObstructionHint => _t({'en': 'What is blocking or affecting the road?', 'fr': 'Qu\'est-ce qui bloque ou affecte la route ?', 'rw': 'Ni iki gibuza cyangwa gikangiza inzira?'});
  String get drvWriteMessageHint => _t({'en': 'Write a message', 'fr': 'Écrivez un message', 'rw': 'Andika ubutumwa'});
  String get drvSelectAffectedStudentsTitle => _t({'en': 'Select affected students', 'fr': 'Sélectionner les élèves affectés', 'rw': 'Hitamo abana bagizweho ingaruka'});
  String get drvSelectInvolvedStudentsTitle => _t({'en': 'Select involved students', 'fr': 'Sélectionner les élèves impliqués', 'rw': 'Hitamo abana bagizemo uruhare'});
  String get drvSelectStudentsTitle => _t({'en': 'Select students', 'fr': 'Sélectionner des élèves', 'rw': 'Hitamo abana'});
  String get drvSelectAffectedStudentsMedicalSubtitle => _t({'en': 'Choose the student or students affected by the medical incident.', 'fr': 'Choisissez le ou les élèves affectés par l\'incident médical.', 'rw': 'Hitamo umwana cyangwa abana bagizweho ingaruka n\'ikibazo cy\'ubuzima.'});
  String get drvSelectInvolvedStudentsBehaviorSubtitle => _t({'en': 'Choose the student or students involved in the behavior incident.', 'fr': 'Choisissez le ou les élèves impliqués dans l\'incident de comportement.', 'rw': 'Hitamo umwana cyangwa abana bagizemo uruhare mu kibazo cy\'imyitwarire.'});
  String get drvSelectAffectedStudentsSubtitle => _t({'en': 'Choose the affected students.', 'fr': 'Choisissez les élèves affectés.', 'rw': 'Hitamo abana bagizweho ingaruka.'});
  String get drvSelectAtLeastOneStudent => _t({'en': 'Select at least one student', 'fr': 'Sélectionnez au moins un élève', 'rw': 'Hitamo nibura umwana umwe'});
  String drvSelectedCount(int n) => _t({'en': '$n selected', 'fr': '$n sélectionné(s)', 'rw': '$n bahiswemo'});
  String get drvNoChildrenAssignedToThisBus => _t({'en': 'No children are assigned to this bus', 'fr': 'Aucun enfant n\'est assigné à ce bus', 'rw': 'Nta mwana washyizweho kuri iyi bisi'});
  String get drvNoMatchingChildren => _t({'en': 'No matching children', 'fr': 'Aucun enfant correspondant', 'rw': 'Nta mwana uhuye n\'ishakiro'});
  String get drvContinueBtn => _t({'en': 'Continue', 'fr': 'Continuer', 'rw': 'Komeza'});
  String get drvSearchChildHint => _t({'en': 'Search a child', 'fr': 'Rechercher un enfant', 'rw': 'Shakisha umwana'});
  String get drvAccidentReportSentTitle => _t({'en': 'Accident report sent', 'fr': 'Rapport d\'accident envoyé', 'rw': 'Raporo y\'impanuka yoherejwe'});
  String get drvBreakdownReportedTitle => _t({'en': 'Mechanical issue reported', 'fr': 'Problème mécanique signalé', 'rw': 'Ikibazo cya moteri cyatanzwe'});
  String get drvDelayReportSentTitle => _t({'en': 'Delay report sent', 'fr': 'Rapport de retard envoyé', 'rw': 'Raporo y\'ubutinzi yoherejwe'});
  String get drvRoadObstructionReportedTitle => _t({'en': 'Road obstruction reported', 'fr': 'Obstruction de la route signalée', 'rw': 'Ikibuza inzira cyatanzwe'});
  String get drvMedicalReportSentTitle => _t({'en': 'Medical report sent', 'fr': 'Rapport médical envoyé', 'rw': 'Raporo y\'ubuzima yoherejwe'});
  String get drvBehaviorIncidentReportedTitle => _t({'en': 'Behavior incident reported', 'fr': 'Incident de comportement signalé', 'rw': 'Ikibazo cy\'imyitwarire cyatanzwe'});
  String get drvIncidentReportSentTitle => _t({'en': 'Incident report sent', 'fr': 'Rapport d\'incident envoyé', 'rw': 'Raporo y\'ikibazo yoherejwe'});
  String get drvIncidentReportedTitle => _t({'en': 'Incident reported', 'fr': 'Incident signalé', 'rw': 'Ikibazo cyatanzwe'});
  String get drvAccidentReportedBody => _t({'en': 'The accident has been reported successfully. The relevant people can now be informed about the incident.', 'fr': 'L\'accident a été signalé avec succès. Les personnes concernées peuvent maintenant être informées de l\'incident.', 'rw': 'Impanuka yatanzwe neza. Abantu babireba barashobora kumenyeshwa iki kibazo.'});
  String get drvBreakdownReportedBody => _t({'en': 'The mechanical issue has been reported successfully. The relevant people can now be informed about the incident.', 'fr': 'Le problème mécanique a été signalé avec succès. Les personnes concernées peuvent maintenant être informées de l\'incident.', 'rw': 'Ikibazo cya moteri cyatanzwe neza. Abantu babireba barashobora kumenyeshwa iki kibazo.'});
  String get drvDelayReportedBody => _t({'en': 'The journey delay has been reported successfully. The relevant people can now be informed about the delay.', 'fr': 'Le retard du trajet a été signalé avec succès. Les personnes concernées peuvent maintenant être informées du retard.', 'rw': 'Ubutinzi bw\'urugendo bwatanzwe neza. Abantu babireba barashobora kumenyeshwa ubu butinzi.'});
  String get drvRoadObstructionReportedBody => _t({'en': 'The road obstruction has been reported successfully. The relevant people can now be informed about the incident.', 'fr': 'L\'obstruction de la route a été signalée avec succès. Les personnes concernées peuvent maintenant être informées de l\'incident.', 'rw': 'Ikibuza inzira cyatanzwe neza. Abantu babireba barashobora kumenyeshwa iki kibazo.'});
  String get drvMedicalReportedBody => _t({'en': 'The medical incident has been reported successfully. The relevant people can now be informed about the affected student.', 'fr': 'L\'incident médical a été signalé avec succès. Les personnes concernées peuvent maintenant être informées de l\'élève affecté.', 'rw': 'Ikibazo cy\'ubuzima cyatanzwe neza. Abantu babireba barashobora kumenyeshwa ku mwana wagizweho ingaruka.'});
  String get drvBehaviorReportedBody => _t({'en': 'The student behavior incident has been reported successfully. The relevant people can now be informed about the incident.', 'fr': 'L\'incident de comportement de l\'élève a été signalé avec succès. Les personnes concernées peuvent maintenant être informées de l\'incident.', 'rw': 'Ikibazo cy\'imyitwarire y\'umwana cyatanzwe neza. Abantu babireba barashobora kumenyeshwa iki kibazo.'});
  String get drvOtherIncidentReportedBody => _t({'en': 'The incident has been reported successfully. The relevant people can now be informed about it.', 'fr': 'L\'incident a été signalé avec succès. Les personnes concernées peuvent maintenant en être informées.', 'rw': 'Ikibazo cyatanzwe neza. Abantu babireba barashobora kumenyeshwa kuri cyo.'});
  String get drvIncidentReportedBodyDefault => _t({'en': 'The incident has been reported successfully.', 'fr': 'L\'incident a été signalé avec succès.', 'rw': 'Ikibazo cyatanzwe neza.'});
  String get drvOnTripIncidentsTitle => _t({'en': 'On Trip Incidents', 'fr': 'Incidents en cours de trajet', 'rw': 'Ibibazo mu rugendo'});
  String get drvIncidentOptionAccident => _t({'en': 'Bus accident or collision', 'fr': 'Accident ou collision de bus', 'rw': 'Impanuka cyangwa ikindi gikomeretsa bisi'});
  String get drvIncidentOptionMedical => _t({'en': 'Sick / injured student', 'fr': 'Élève malade / blessé', 'rw': 'Umwana murwayi / wakomeretse'});
  String get drvIncidentOptionBreakdown => _t({'en': 'Bus mechanical issue', 'fr': 'Problème mécanique du bus', 'rw': 'Ikibazo cya moteri ya bisi'});
  String get drvIncidentOptionDelay => _t({'en': 'Journey delay', 'fr': 'Retard de trajet', 'rw': 'Ubutinzi bw\'urugendo'});
  String get drvIncidentOptionRoadObstruction => _t({'en': 'Road obstruction', 'fr': 'Obstruction de la route', 'rw': 'Ikibuza inzira'});
  String get drvIncidentOptionBehavior => _t({'en': 'Student behavior issue', 'fr': 'Problème de comportement de l\'élève', 'rw': 'Ikibazo cy\'imyitwarire y\'umwana'});
  String get drvIncidentOptionOther => _t({'en': 'Other incidents', 'fr': 'Autres incidents', 'rw': 'Ibindi bibazo'});
  String get drvOtherIncidentSingular => _t({'en': 'Other incident', 'fr': 'Autre incident', 'rw': 'Ikindi kibazo'});
  String get drvSearchIncidentsHint => _t({'en': 'Search incidents', 'fr': 'Rechercher des incidents', 'rw': 'Shakisha ibibazo'});
  String get drvNoIncidentsFound => _t({'en': 'No incidents found', 'fr': 'Aucun incident trouvé', 'rw': 'Nta kibazo cyabonetse'});
  String get drvOngoingLabel => _t({'en': 'ONGOING', 'fr': 'EN COURS', 'rw': 'BIRACYAKOMEJE'});
  String get drvResolvedLabel => _t({'en': 'RESOLVED', 'fr': 'RÉSOLU', 'rw': 'BYAKEMUWE'});
  String get drvActiveLabel => _t({'en': 'ACTIVE', 'fr': 'ACTIF', 'rw': 'BIRAKOMEJE'});
  String get drvEditBtn => _t({'en': 'Edit', 'fr': 'Modifier', 'rw': 'Hindura'});
  String get drvResolveBtn => _t({'en': 'Resolve', 'fr': 'Résoudre', 'rw': 'Kemura'});
  String drvJourneyImpactPrefix(String impact) => _t({'en': 'Journey: $impact', 'fr': 'Trajet : $impact', 'rw': 'Urugendo: $impact'});
  String drvTodayTime(String time) => _t({'en': 'Today, $time', 'fr': 'Aujourd\'hui, $time', 'rw': 'Uyu munsi, $time'});
  String drvYesterdayTime(String time) => _t({'en': 'Yesterday, $time', 'fr': 'Hier, $time', 'rw': 'Ejo hashize, $time'});
  String get drvLangEnglish => _t({'en': 'English', 'fr': 'Anglais', 'rw': 'Icyongereza'});
  String get drvLangFrench => _t({'en': 'Français', 'fr': 'Français', 'rw': 'Igifaransa'});
  String get drvLangKinyarwanda => _t({'en': 'Kinyarwanda', 'fr': 'Kinyarwanda', 'rw': 'Ikinyarwanda'});
  String get drvResolveIncidentTitle => _t({'en': 'Resolve incident?', 'fr': 'Résoudre l\'incident ?', 'rw': 'Kemura ikibazo?'});
  String get drvResolveIncidentBody => _t({'en': 'Are you sure this incident has been resolved? It will move to the resolved incidents section.', 'fr': 'Êtes-vous sûr que cet incident a été résolu ? Il sera déplacé vers la section des incidents résolus.', 'rw': 'Uzi neza ko iki kibazo cyakemuwe? Kizimukira mu gice cy\'ibibazo byakemuwe.'});
  String drvChildCountLabel(int n) => _t({'en': '$n child(ren)', 'fr': '$n enfant(s)', 'rw': 'Abana $n'});
  String drvAbsentCountLabel(int n) => _t({'en': '$n absent', 'fr': '$n absent(s)', 'rw': '$n ntabaho'});
  String get drvNoChildrenOnThisBus => _t({'en': 'No children on this bus', 'fr': 'Aucun enfant dans ce bus', 'rw': 'Nta mwana uri muri bisi'});
  String get drvAbbrevAM => _t({'en': 'AM', 'fr': 'Matin', 'rw': 'Mu gitondo'});
  String get drvAbbrevPM => _t({'en': 'PM', 'fr': 'Après-midi', 'rw': 'Nimugoroba'});
  String get drvBoardedLabel => _t({'en': 'Boarded', 'fr': 'Monté', 'rw': 'Yinjiye'});
  String get drvAbsentLockedLabel => _t({'en': 'Absent — locked', 'fr': 'Absent — verrouillé', 'rw': 'Ntahari — birafunze'});
  String get drvUndoBtn => _t({'en': 'Undo', 'fr': 'Annuler', 'rw': 'Garuka inyuma'});

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
