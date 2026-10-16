/// Libelles metier partages entre les ecrans (statuts, roles, modes de paiement).
///
/// Le back-office web expose des codes en base (brouillon, payee_partiel, a_faire...).
/// L'interface doit les traduire, sinon l'utilisateur lit des codes SQL.
library;

/// Libelle lisible d'un statut, quel que soit le module.
String labelStatut(dynamic code) {
  final valeur = code?.toString() ?? '';
  return switch (valeur) {
    '' => '',
    // Chantiers
    'planifie' => 'Planifié',
    'en_cours' => 'En cours',
    'suspendu' => 'Suspendu',
    'termine' => 'Terminé',
    'annule' => 'Annulé',
    // Lots
    'a_faire' => 'À faire',
    // Devis
    'envoye' => 'Envoyé',
    'accepte' => 'Accepté',
    'refuse' => 'Refusé',
    'converti' => 'Converti en facture',
    // Achats
    'commande' => 'Commande',
    'recu' => 'Réceptionné',
    'partiellement_recu' => 'Partiellement réceptionné',
    // Factures
    'brouillon' => 'Brouillon',
    'emise' => 'Émise',
    'payee_partiel' => 'Partiellement payée',
    'payee' => 'Payée',
    'annulee' => 'Annulée',
    'en_retard' => 'En retard',
    // Paiements
    'especes' => 'Espèces',
    'cheque' => 'Chèque',
    'virement' => 'Virement',
    'mobile_money' => 'Mobile money',
    'autre' => 'Autre',
    _ => valeur,
  };
}

/// Couleur associee a un statut (vert / orange / rouge / neutre).
int couleurStatut(dynamic code) {
  final valeur = code?.toString() ?? '';
  return switch (valeur) {
    'termine' || 'accepte' || 'recu' || 'payee' || 'converti' => 0xFF1B7A46,
    'en_cours' || 'emise' || 'partiellement_recu' || 'payee_partiel' =>
      0xFFB4741A,
    'annule' || 'annulee' || 'refuse' || 'en_retard' => 0xFF9C422B,
    _ => 0xFF68756E,
  };
}

/// Libelle d'un role (identique a la nomenclature du back-office).
String labelRole(dynamic role) => switch (role?.toString() ?? '') {
  'directeur' => 'Directeur',
  'chef_chantier' => 'Chef de chantier',
  'comptable' => 'Comptable',
  'magasinier' => 'Magasinier',
  final autre => autre,
};

/// Libelle d'une entite du journal d'audit.
String labelEntite(String? entite) => switch (entite ?? '') {
  'utilisateur' => 'Utilisateur',
  'chantier' => 'Chantier',
  'lot' => 'Lot',
  'client' => 'Client',
  'fournisseur' => 'Fournisseur',
  'employe' => 'Employé',
  'materiau' => 'Matériau',
  'engin' => 'Engin',
  'achat' => 'Achat',
  'devis' => 'Devis',
  'facture' => 'Facture',
  'paiement' => 'Paiement',
  'pointage' => 'Pointage',
  'profil' => 'Profil',
  'parametres' => 'Paramètres',
  final autre => autre,
};

/// Libelle du mode de paiement accepte par l'API.
const modesPaiement = <String, String>{
  'especes': 'Espèces',
  'cheque': 'Chèque',
  'virement': 'Virement',
  'mobile_money': 'Mobile money',
  'autre': 'Autre',
};

/// Modes d'etat d'un engin.
const etatsEngin = <String, String>{
  'disponible': 'Disponible',
  'en_service': 'En service',
  'maintenance': 'Maintenance',
  'hors_service': 'Hors service',
};

/// Formate un montant en Ariary avec separateur de milliers.
String formatMontant(dynamic value) {
  if (value == null) return '—';
  final montant = num.tryParse(value.toString());
  if (montant == null) return '$value Ar';
  final entier = montant.round();
  final groupes = entier.abs().toString().replaceAllMapped(
    RegExp(r'(?<=\d)(?=(\d{3})+$)'),
    (_) => '\u202f',
  );
  return '${entier < 0 ? '-' : ''}$groupes\u202fAr';
}

/// Formate un pourcentage borne a 0-100.
double? pourcent(dynamic value) {
  final nombre = num.tryParse(value?.toString() ?? '');
  if (nombre == null) return null;
  return (nombre / 100).clamp(0.0, 1.0);
}

/// Date ISO (yyyy-mm-dd) formatee en date lisible francaise.
String formatDate(dynamic value) {
  final brut = value?.toString().trim() ?? '';
  if (brut.isEmpty) return '';
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(brut);
  if (match == null) return brut;
  return '${match.group(3)}/${match.group(2)}/${match.group(1)}';
}