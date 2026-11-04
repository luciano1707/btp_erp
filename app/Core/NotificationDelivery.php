<?php

namespace App\Core;

use PDO;

/** Distribution des notifications applicatives vers les canaux externes. */
final class NotificationDelivery
{
    private static ?string $orangeToken = null;
    private static int $orangeTokenExpireLe = 0;

    public static function envoyer(
        int $utilisateurId,
        string $titre,
        string $message,
        ?string $lien
    ): void {
        $emailActive = (bool) Env::get('NOTIFICATION_EMAIL_ENABLED', true);
        $smsActive = (bool) Env::get('NOTIFICATION_SMS_ENABLED', false);
        if (!$emailActive && !$smsActive) {
            return;
        }

        try {
            $stmt = Database::connexion()->prepare(
                'SELECT email, telephone, prenom FROM utilisateurs WHERE id = :id AND actif = 1'
            );
            $stmt->execute(['id' => $utilisateurId]);
            $utilisateur = $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (\Throwable $e) {
            Logger::erreur('Impossible de charger le destinataire d une notification externe.', [
                'utilisateur_id' => $utilisateurId,
                'erreur' => $e->getMessage(),
            ]);
            return;
        }

        if (!is_array($utilisateur)) {
            return;
        }

        $nomApp = (string) Env::get('APP_NAME', 'Digital Chantier');
        $corps = 'Bonjour ' . trim((string) ($utilisateur['prenom'] ?? '')) . ",\n\n"
            . $titre . "\n\n" . $message;
        $url = self::urlNotification($lien);
        if ($url !== null) {
            $corps .= "\n\nOuvrir : " . $url;
        }
        $corps .= "\n\n" . $nomApp;

        if ($emailActive) {
            $email = trim((string) ($utilisateur['email'] ?? ''));
            if (filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
                Logger::avertissement('Notification e-mail ignoree : adresse absente ou invalide.', [
                    'utilisateur_id' => $utilisateurId,
                ]);
            } else {
                Mailer::envoyerNotification($email, $nomApp . ' - ' . $titre, $corps);
            }
        }

        if ($smsActive) {
            $telephone = self::normaliserTelephone((string) ($utilisateur['telephone'] ?? ''));
            if ($telephone === null) {
                Logger::avertissement('Notification SMS ignoree : numero absent ou invalide.', [
                    'utilisateur_id' => $utilisateurId,
                ]);
                return;
            }

            $texteSms = $nomApp . ' - ' . $titre . ' : ' . $message;
            if ($url !== null) {
                $texteSms .= ' ' . $url;
            }
            self::envoyerSms($utilisateurId, $telephone, mb_substr($texteSms, 0, 1500));
        }
    }

    private static function envoyerSms(int $utilisateurId, string $telephone, string $message): bool
    {
        $clientId = trim((string) Env::get('ORANGE_CLIENT_ID', ''));
        $clientSecret = trim((string) Env::get('ORANGE_CLIENT_SECRET', ''));
        $expediteur = self::normaliserTelephone((string) Env::get('ORANGE_SENDER_ADDRESS', ''));
        if ($clientId === '' || $clientSecret === '' || $expediteur === null) {
            Logger::erreur('Configuration Orange SMS incomplete. Verifier ORANGE_CLIENT_ID, ORANGE_CLIENT_SECRET et ORANGE_SENDER_ADDRESS.');
            return false;
        }
        if (!function_exists('curl_init')) {
            Logger::erreur('Extension cURL requise pour envoyer des SMS Orange.');
            return false;
        }

        $token = self::obtenirJetonOrange($clientId, $clientSecret, $utilisateurId);
        if ($token === null) {
            return false;
        }

        $url = 'https://api.orange.com/smsmessaging/v1/outbound/'
            . rawurlencode('tel:' . $expediteur)
            . '/requests';
        $curl = curl_init($url);
        if ($curl === false) {
            Logger::erreur('Impossible d initialiser la connexion SMS Orange.', [
                'utilisateur_id' => $utilisateurId,
            ]);
            return false;
        }

        $payload = [
            'outboundSMSMessageRequest' => [
                'address' => 'tel:' . $telephone,
                'senderAddress' => 'tel:' . $expediteur,
                'outboundSMSTextMessage' => ['message' => $message],
            ],
        ];
        curl_setopt_array($curl, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $token,
                'Content-Type: application/json',
                'Accept: application/json',
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSL_VERIFYHOST => 2,
        ]);

        $reponse = curl_exec($curl);
        $erreur = $reponse === false ? curl_error($curl) : '';
        $statutHttp = (int) curl_getinfo($curl, CURLINFO_HTTP_CODE);
        curl_close($curl);

        if ($reponse === false) {
            Logger::erreur('Echec de la requete SMS Orange.', [
                'utilisateur_id' => $utilisateurId,
                'erreur' => $erreur,
            ]);
            return false;
        }
        if ($statutHttp < 200 || $statutHttp >= 300) {
            Logger::erreur('Orange a refuse l envoi du SMS.', [
                'utilisateur_id' => $utilisateurId,
                'statut_http' => $statutHttp,
            ]);
            return false;
        }
        return true;
    }

    private static function obtenirJetonOrange(string $clientId, string $clientSecret, int $utilisateurId): ?string
    {
        if (self::$orangeToken !== null && self::$orangeTokenExpireLe > time() + 30) {
            return self::$orangeToken;
        }

        $curl = curl_init('https://api.orange.com/oauth/v3/token');
        if ($curl === false) {
            Logger::erreur('Impossible d initialiser l authentification SMS Orange.', [
                'utilisateur_id' => $utilisateurId,
            ]);
            return null;
        }

        curl_setopt_array($curl, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => 'grant_type=client_credentials',
            CURLOPT_USERPWD => $clientId . ':' . $clientSecret,
            CURLOPT_HTTPAUTH => CURLAUTH_BASIC,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/x-www-form-urlencoded',
                'Accept: application/json',
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSL_VERIFYHOST => 2,
        ]);

        $reponse = curl_exec($curl);
        $erreur = $reponse === false ? curl_error($curl) : '';
        $statutHttp = (int) curl_getinfo($curl, CURLINFO_HTTP_CODE);
        curl_close($curl);

        if ($reponse === false) {
            Logger::erreur('Echec de l authentification SMS Orange.', [
                'utilisateur_id' => $utilisateurId,
                'erreur' => $erreur,
            ]);
            return null;
        }

        $donnees = json_decode($reponse, true);
        if (
            $statutHttp < 200
            || $statutHttp >= 300
            || !is_array($donnees)
            || !is_string($donnees['access_token'] ?? null)
            || $donnees['access_token'] === ''
        ) {
            Logger::erreur('Orange a refuse l authentification SMS.', [
                'utilisateur_id' => $utilisateurId,
                'statut_http' => $statutHttp,
            ]);
            return null;
        }

        $expiration = max(60, (int) ($donnees['expires_in'] ?? 3600));
        self::$orangeToken = $donnees['access_token'];
        self::$orangeTokenExpireLe = time() + $expiration;
        return self::$orangeToken;
    }

    private static function normaliserTelephone(string $telephone): ?string
    {
        $telephone = preg_replace('/[\s().-]+/', '', trim($telephone)) ?? '';
        if (str_starts_with($telephone, '00')) {
            $telephone = '+' . substr($telephone, 2);
        } elseif (str_starts_with($telephone, '0')) {
            $indicatif = preg_replace('/\D+/', '', (string) Env::get('ORANGE_DEFAULT_COUNTRY_CODE', '261')) ?? '';
            if ($indicatif === '') {
                return null;
            }
            $telephone = '+' . $indicatif . substr($telephone, 1);
        }

        return preg_match('/^\+[1-9]\d{7,14}$/', $telephone) === 1 ? $telephone : null;
    }

    private static function urlNotification(?string $lien): ?string
    {
        $base = rtrim((string) Env::get('APP_URL', ''), '/');
        if ($lien === null || $lien === '' || $base === '') {
            return null;
        }
        return $base . '/' . ltrim($lien, '/');
    }
}
