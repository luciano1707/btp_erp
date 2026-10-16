<?php

namespace App\Core;

/**
 * Validateur de donnees simple, base sur des regles textuelles.
 * Regles supportees : requis, email, numerique, entier, min:n, max:n, longueur_min:n,
 * longueur_max:n, dans:a,b,c, confirme.
 * Les messages d'erreur sont en francais.
 */
final class Validator
{
    /** @var array<string,string[]> */
    private array $erreurs = [];

    /**
     * @param array<string,mixed>  $donnees
     * @param array<string,string> $regles  ex: ['email' => 'requis|email', 'age' => 'entier|min:18']
     */
    public function __construct(
        private readonly array $donnees,
        private readonly array $regles
    ) {
    }

    /** Fabrique + validation immediate. */
    public static function verifier(array $donnees, array $regles): self
    {
        $v = new self($donnees, $regles);
        $v->valider();
        return $v;
    }

    public function valider(): bool
    {
        foreach ($this->regles as $champ => $chaineRegles) {
            $valeur = $this->donnees[$champ] ?? null;

            foreach (explode('|', $chaineRegles) as $regle) {
                [$nom, $param] = array_pad(explode(':', $regle, 2), 2, null);
                $this->appliquer($champ, $nom, $param, $valeur);
            }
        }

        return $this->erreurs === [];
    }

    private function appliquer(string $champ, string $nom, ?string $param, mixed $valeur): void
    {
        $vide = $valeur === null || $valeur === '';

        // Les autres regles ne s'appliquent pas a une valeur absente non requise
        if ($vide && $nom !== 'requis') {
            return;
        }

        switch ($nom) {
            case 'requis':
                if ($vide) {
                    $this->ajouter($champ, "Le champ « $champ » est obligatoire.");
                }
                break;

            case 'email':
                if (!filter_var($valeur, FILTER_VALIDATE_EMAIL)) {
                    $this->ajouter($champ, "Le champ « $champ » doit etre une adresse e-mail valide.");
                }
                break;

            case 'numerique':
                if (!is_numeric($valeur)) {
                    $this->ajouter($champ, "Le champ « $champ » doit etre un nombre.");
                }
                break;

            case 'entier':
                if (filter_var($valeur, FILTER_VALIDATE_INT) === false) {
                    $this->ajouter($champ, "Le champ « $champ » doit etre un entier.");
                }
                break;

            case 'min':
                if (is_numeric($valeur) && $valeur < (float) $param) {
                    $this->ajouter($champ, "Le champ « $champ » doit etre superieur ou egal a $param.");
                }
                break;

            case 'max':
                if (is_numeric($valeur) && $valeur > (float) $param) {
                    $this->ajouter($champ, "Le champ « $champ » doit etre inferieur ou egal a $param.");
                }
                break;

            case 'longueur_min':
                if (mb_strlen((string) $valeur) < (int) $param) {
                    $this->ajouter($champ, "Le champ « $champ » doit contenir au moins $param caracteres.");
                }
                break;

            case 'longueur_max':
                if (mb_strlen((string) $valeur) > (int) $param) {
                    $this->ajouter($champ, "Le champ « $champ » ne doit pas depasser $param caracteres.");
                }
                break;

            case 'dans':
                $options = explode(',', (string) $param);
                if (!in_array((string) $valeur, $options, true)) {
                    $this->ajouter($champ, "Le champ « $champ » doit etre l'une des valeurs : $param.");
                }
                break;

            case 'confirme':
                if (($this->donnees[$champ . '_confirmation'] ?? null) !== $valeur) {
                    $this->ajouter($champ, "La confirmation du champ « $champ » ne correspond pas.");
                }
                break;
        }
    }

    private function ajouter(string $champ, string $message): void
    {
        $this->erreurs[$champ][] = $message;
    }

    public function echoue(): bool
    {
        return $this->erreurs !== [];
    }

    /** @return array<string,string[]> */
    public function erreurs(): array
    {
        return $this->erreurs;
    }
}
