<?php

namespace App\Core;

use RuntimeException;

/**
 * Routeur HTTP maison.
 * Gere les routes web (rendu HTML) et API (JSON), avec parametres nommes {id}
 * et chaine de middlewares executee avant le controleur.
 */
final class Router
{
    /** @var array<int,array{methode:string,motif:string,action:mixed,middlewares:array<int,class-string>}> */
    private array $routes = [];

    public function get(string $motif, mixed $action, array $middlewares = []): void
    {
        $this->ajouter('GET', $motif, $action, $middlewares);
    }

    public function post(string $motif, mixed $action, array $middlewares = []): void
    {
        $this->ajouter('POST', $motif, $action, $middlewares);
    }

    public function put(string $motif, mixed $action, array $middlewares = []): void
    {
        $this->ajouter('PUT', $motif, $action, $middlewares);
    }

    public function patch(string $motif, mixed $action, array $middlewares = []): void
    {
        $this->ajouter('PATCH', $motif, $action, $middlewares);
    }

    public function delete(string $motif, mixed $action, array $middlewares = []): void
    {
        $this->ajouter('DELETE', $motif, $action, $middlewares);
    }

    /**
     * @param array{0:class-string,1:string}|callable $action
     * @param array<int,class-string>                  $middlewares
     */
    public function ajouter(string $methode, string $motif, mixed $action, array $middlewares = []): void
    {
        $this->routes[] = [
            'methode'     => strtoupper($methode),
            'motif'       => $motif,
            'action'      => $action,
            'middlewares' => $middlewares,
        ];
    }

    /**
     * Trouve la route correspondante et l'execute.
     */
    public function dispatch(Request $requete): void
    {
        $cheminMatche = false;

        foreach ($this->routes as $route) {
            if (!preg_match($this->compiler($route['motif']), $requete->chemin, $correspondances)) {
                continue;
            }

            $cheminMatche = true;
            if ($route['methode'] !== $requete->methode) {
                continue;
            }

            // Extraction des parametres nommes d'URL
            foreach ($correspondances as $cle => $valeur) {
                if (!is_int($cle)) {
                    $requete->params[$cle] = $valeur;
                }
            }

            // Chaine de middlewares (ex: authentification, controle de role).
            // Un middleware peut etre une classe seule, ou un tableau [Classe, arg1, arg2...]
            // pour passer des parametres (ex: [RoleMiddleware::class, 'directeur', 'comptable']).
            foreach ($route['middlewares'] as $middleware) {
                if (is_array($middleware)) {
                    [$classe, $arguments] = [$middleware[0], array_slice($middleware, 1)];
                    (new $classe())->traiter($requete, ...$arguments);
                } else {
                    (new $middleware())->traiter($requete);
                }
            }

            $this->executer($route['action'], $requete);
            return;
        }

        // Le chemin existe mais pas pour cette methode => 405
        if ($cheminMatche) {
            $this->methodeNonAutorisee($requete);
        }

        $this->nonTrouve($requete);
    }

    /** Compile un motif de route (avec {param}) en expression reguliere. */
    private function compiler(string $motif): string
    {
        $motif = '/' . trim($motif, '/');
        $motif = $motif === '/' ? '/' : rtrim($motif, '/');
        $regex = preg_replace('#\{([a-zA-Z_][a-zA-Z0-9_]*)\}#', '(?<$1>[^/]+)', $motif);
        return '#^' . $regex . '$#';
    }

    /** Execute l'action (couple [Controleur, methode] ou fonction anonyme). */
    private function executer(mixed $action, Request $requete): void
    {
        if (is_array($action)) {
            [$classe, $methode] = $action;
            if (!class_exists($classe)) {
                throw new RuntimeException("Controleur introuvable : $classe");
            }
            $instance = new $classe();
            if (!method_exists($instance, $methode)) {
                throw new RuntimeException("Methode introuvable : $classe::$methode");
            }
            $instance->$methode($requete);
            return;
        }

        if (is_callable($action)) {
            $action($requete);
            return;
        }

        throw new RuntimeException('Action de route invalide.');
    }

    private function nonTrouve(Request $requete): void
    {
        if ($requete->estApi()) {
            Response::erreur('Ressource introuvable.', 404);
        }
        Response::vue('erreurs.404', [], 404);
    }

    private function methodeNonAutorisee(Request $requete): void
    {
        if ($requete->estApi()) {
            Response::erreur('Methode HTTP non autorisee.', 405);
        }
        Response::vue('erreurs.404', [], 405);
    }
}
