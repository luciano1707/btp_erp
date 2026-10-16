<?php

namespace App\Core;

/**
 * Controleur de base. Fournit des raccourcis communs aux controleurs API et Web.
 */
abstract class Controller
{
    /**
     * Valide les donnees ; en cas d'echec, renvoie directement une reponse 422 (API).
     *
     * @param array<string,mixed>  $donnees
     * @param array<string,string> $regles
     * @return array<string,mixed> Les donnees (inchangees) si la validation reussit
     */
    protected function valider(array $donnees, array $regles): array
    {
        $validateur = Validator::verifier($donnees, $regles);
        if ($validateur->echoue()) {
            Response::erreur('Donnees invalides.', 422, $validateur->erreurs());
        }
        return $donnees;
    }
}
