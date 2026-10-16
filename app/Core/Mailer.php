<?php

namespace App\Core;

use PHPMailer\PHPMailer\PHPMailer;

/** Envoi des courriels applicatifs via SMTP authentifie. */
final class Mailer
{
    public static function envoyerCodeOtp(string $destinataire, string $code): bool
    {
        $nomApp = (string) Env::get('APP_NAME', 'Digital Chantier');
        $expediteur = trim((string) Env::get('MAIL_FROM', ''));
        $nomExpediteur = (string) Env::get('MAIL_FROM_NAME', $nomApp);
        $hote = trim((string) Env::get('MAIL_HOST', ''));
        $port = filter_var(Env::get('MAIL_PORT'), FILTER_VALIDATE_INT);
        $utilisateur = trim((string) Env::get('MAIL_USERNAME', ''));
        $motDePasse = (string) Env::get('MAIL_PASSWORD', '');
        $chiffrement = strtolower(trim((string) Env::get('MAIL_ENCRYPTION', '')));

        if (
            $hote === ''
            || $port === false
            || $port < 1
            || $port > 65535
            || $utilisateur === ''
            || $motDePasse === ''
            || filter_var($expediteur, FILTER_VALIDATE_EMAIL) === false
            || !in_array($chiffrement, ['tls', 'ssl'], true)
        ) {
            Logger::erreur('Configuration SMTP incomplete ou invalide. Verifier MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD, MAIL_ENCRYPTION et MAIL_FROM.');
            return false;
        }

        if (strtolower($hote) === 'smtp.gmail.com' && strcasecmp($expediteur, $utilisateur) !== 0) {
            Logger::avertissement('MAIL_FROM different du compte SMTP Gmail ; utilisation du compte authentifie.');
            $expediteur = $utilisateur;
        }

        if (filter_var($expediteur, FILTER_VALIDATE_EMAIL) === false) {
            Logger::erreur('MAIL_FROM doit etre une adresse e-mail valide.');
            return false;
        }

        $sujet = 'Code de réinitialisation - ' . $nomApp;
        $message = "Bonjour,\n\nVotre code de réinitialisation est : $code\n\n"
            . "Ce code expire dans 15 minutes. Si vous n'êtes pas à l'origine de cette demande, ignorez ce message.\n\n"
            . $nomApp;

        try {
            $mail = new PHPMailer(true);
            $mail->isSMTP();
            $mail->Host = $hote;
            $mail->Port = $port;
            $mail->SMTPAuth = true;
            $mail->Username = $utilisateur;
            $mail->Password = $motDePasse;
            $mail->SMTPSecure = $chiffrement === 'ssl'
                ? PHPMailer::ENCRYPTION_SMTPS
                : PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Timeout = 20;
            $mail->CharSet = 'UTF-8';
            $mail->setFrom($expediteur, $nomExpediteur);
            $mail->addAddress($destinataire);
            $mail->Subject = $sujet;
            $mail->Body = $message;
            $mail->isHTML(false);
            $mail->send();
            return true;
        } catch (\Throwable $e) {
            Logger::erreur('Impossible d envoyer le courriel SMTP.', [
                'erreur' => $e->getMessage(),
            ]);
            return false;
        }
    }
}
