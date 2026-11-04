/* Selects de relation avec recherche (progressive enhancement).
 * Le <select> natif reste la source de verite (name/value/required),
 * ce qui preserve les formulaires et scripts existants. */
(function () {
    'use strict';

    const SELECTEUR = 'select[data-recherche], select[id$="_id"], select[name$="_id"]';
    let compteur = 0;

    function normaliser(valeur) {
        return (valeur || '').toString()
            .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
            .toLowerCase().trim();
    }

    function dejaInitialise(el) {
        return !el || el.dataset.rsInitialise === '1';
    }

    function initialiser(select) {
        if (dejaInitialise(select) || select.multiple || (select.size || 0) > 1) {
            return;
        }
        select.dataset.rsInitialise = '1';

        const idBase = select.id || ('rs-' + (++compteur));
        const inputId = idBase + '-recherche';
        const listeId = idBase + '-liste';

        const boite = document.createElement('div');
        boite.className = 'rs';
        select.parentNode.insertBefore(boite, select);
        boite.appendChild(select);
        select.classList.add('rs-select');
        select.setAttribute('tabindex', '-1');

        const input = document.createElement('input');
        input.type = 'text';
        input.id = inputId;
        input.className = 'rs-input';
        input.autocomplete = 'off';
        input.placeholder = 'Rechercher…';
        input.setAttribute('role', 'combobox');
        input.setAttribute('aria-autocomplete', 'list');
        input.setAttribute('aria-expanded', 'false');
        input.setAttribute('aria-controls', listeId);

        const fleche = document.createElement('button');
        fleche.type = 'button';
        fleche.className = 'rs-fleche';
        fleche.setAttribute('aria-label', 'Ouvrir la liste');
        fleche.textContent = '▾';

        const liste = document.createElement('ul');
        liste.id = listeId;
        liste.className = 'rs-liste';
        liste.hidden = true;
        liste.setAttribute('role', 'listbox');

        boite.appendChild(input);
        boite.appendChild(fleche);
        boite.appendChild(liste);

        const label = document.querySelector('label[for="' + idBase + '"]');
        if (label) {
            label.setAttribute('for', inputId);
        }

        if (select.required) {
            input.required = true;
            select.required = false;
        }

        let options = [];
        let actif = -1;
        let ouvert = false;

        function lireOptions() {
            options = Array.prototype.slice.call(select.options).map(function (o) {
                return {
                    valeur: o.value,
                    libelle: (o.textContent || '').trim(),
                    desactive: o.disabled
                };
            });
        }

        function libelleSelectionne() {
            const option = select.options[select.selectedIndex];
            if (!option || option.value === '') {
                return '';
            }
            return (option.textContent || '').trim();
        }

        function synchroniser() {
            input.disabled = select.disabled;
            fleche.disabled = select.disabled;
            if (select.disabled) {
                fermer();
            }
            if (!ouvert || document.activeElement !== input) {
                input.value = libelleSelectionne();
            }
        }

        function positionner() {
            if (!ouvert) {
                return;
            }
            const rect = input.getBoundingClientRect();
            const espaceBas = window.innerHeight - rect.bottom;
            const versHaut = espaceBas < 200 && rect.top > espaceBas;
            liste.style.left = Math.round(rect.left) + 'px';
            liste.style.width = Math.round(rect.width) + 'px';
            if (versHaut) {
                liste.style.top = 'auto';
                liste.style.bottom = Math.round(window.innerHeight - rect.top + 4) + 'px';
            } else {
                liste.style.top = Math.round(rect.bottom + 4) + 'px';
                liste.style.bottom = 'auto';
            }
        }

        function definirActif(index) {
            const items = liste.querySelectorAll('.rs-option');
            if (!items.length) {
                actif = -1;
                return;
            }
            actif = Math.max(0, Math.min(index, items.length - 1));
            Array.prototype.forEach.call(items, function (li, i) {
                li.classList.toggle('actif', i === actif);
            });
            const courant = items[actif];
            if (courant) {
                input.setAttribute('aria-activedescendant', courant.id);
                courant.scrollIntoView({ block: 'nearest' });
            }
        }

        function rendre(filtre) {
            const recherche = normaliser(filtre);
            liste.innerHTML = '';
            let index = 0;
            let indexSelection = -1;

            options.forEach(function (option) {
                if (option.desactive) {
                    return;
                }
                if (recherche && normaliser(option.libelle).indexOf(recherche) === -1) {
                    return;
                }
                const li = document.createElement('li');
                li.className = 'rs-option';
                li.id = listeId + '-opt-' + index;
                li.setAttribute('role', 'option');
                li.dataset.valeur = option.valeur;
                li.textContent = option.libelle || '(vide)';
                if (option.valeur === select.value) {
                    li.setAttribute('aria-selected', 'true');
                    indexSelection = index;
                }
                li.addEventListener('mouseenter', function () {
                    definirActif(Array.prototype.indexOf.call(liste.children, li));
                });
                li.addEventListener('mousedown', function (evenement) {
                    evenement.preventDefault();
                    choisir(option.valeur);
                });
                liste.appendChild(li);
                index++;
            });

            if (!index) {
                const vide = document.createElement('li');
                vide.className = 'rs-vide';
                vide.textContent = 'Aucun resultat';
                liste.appendChild(vide);
            }
            definirActif(indexSelection >= 0 ? indexSelection : 0);
        }

        function ouvrir() {
            if (ouvert || select.disabled) {
                return;
            }
            ouvert = true;
            boite.classList.add('rs-ouvert');
            liste.hidden = false;
            input.setAttribute('aria-expanded', 'true');
            lireOptions();
            rendre('');
            positionner();
            input.focus();
            input.select();
        }

        function fermer() {
            if (!ouvert) {
                return;
            }
            ouvert = false;
            boite.classList.remove('rs-ouvert');
            liste.hidden = true;
            input.setAttribute('aria-expanded', 'false');
            input.removeAttribute('aria-activedescendant');
            input.value = libelleSelectionne();
            actif = -1;
        }

        function choisir(valeur) {
            select.value = valeur;
            select.dispatchEvent(new Event('input', { bubbles: true }));
            select.dispatchEvent(new Event('change', { bubbles: true }));
            fermer();
        }

        input.addEventListener('mousedown', function (evenement) {
            if (!ouvert) {
                evenement.preventDefault();
                ouvrir();
            }
        });
        input.addEventListener('focus', ouvrir);

        input.addEventListener('input', function () {
            if (!ouvert) {
                ouvrir();
            }
            rendre(input.value);
            positionner();
        });

        input.addEventListener('keydown', function (evenement) {
            const items = liste.querySelectorAll('.rs-option');
            if (!ouvert && (evenement.key === 'ArrowDown' || evenement.key === 'ArrowUp')) {
                evenement.preventDefault();
                ouvrir();
                return;
            }
            if (!ouvert) {
                return;
            }
            if (evenement.key === 'ArrowDown') {
                evenement.preventDefault();
                definirActif(actif + 1);
            } else if (evenement.key === 'ArrowUp') {
                evenement.preventDefault();
                definirActif(actif - 1);
            } else if (evenement.key === 'Home') {
                evenement.preventDefault();
                definirActif(0);
            } else if (evenement.key === 'End') {
                evenement.preventDefault();
                definirActif(items.length - 1);
            } else if (evenement.key === 'Enter') {
                evenement.preventDefault();
                if (actif >= 0 && items[actif]) {
                    choisir(items[actif].dataset.valeur);
                }
            } else if (evenement.key === 'Escape') {
                evenement.preventDefault();
                fermer();
            } else if (evenement.key === 'Tab') {
                fermer();
            }
        });

        fleche.addEventListener('mousedown', function (evenement) {
            evenement.preventDefault();
            if (ouvert) {
                fermer();
            } else {
                ouvrir();
            }
        });

        document.addEventListener('mousedown', function (evenement) {
            if (ouvert && !boite.contains(evenement.target)) {
                fermer();
            }
        });

        window.addEventListener('scroll', positionner, true);
        window.addEventListener('resize', positionner);

        try {
            const descripteur = Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value');
            if (descripteur && descripteur.get && descripteur.set) {
                Object.defineProperty(select, 'value', {
                    configurable: true,
                    enumerable: true,
                    get: function () {
                        return descripteur.get.call(this);
                    },
                    set: function (valeur) {
                        descripteur.set.call(this, valeur);
                        synchroniser();
                    }
                });
            }
        } catch (erreur) { /* navigateur sans descripteur : synchronisation via change/option */ }

        const observateur = new MutationObserver(function () {
            lireOptions();
            synchroniser();
            if (ouvert) {
                rendre('');
            }
        });
        observateur.observe(select, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['disabled', 'selected']
        });

        select.addEventListener('change', synchroniser);

        lireOptions();
        synchroniser();
    }

    function parcourir(racine) {
        if (!racine || racine.nodeType !== 1) {
            return;
        }
        if (racine.matches && racine.matches(SELECTEUR)) {
            initialiser(racine);
        }
        if (racine.querySelectorAll) {
            Array.prototype.forEach.call(racine.querySelectorAll(SELECTEUR), initialiser);
        }
    }

    function demarrer() {
        parcourir(document.body);
        new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.target.closest && mutation.target.closest('.rs')) {
                    return;
                }
                Array.prototype.forEach.call(mutation.addedNodes, parcourir);
            });
        }).observe(document.body, { childList: true, subtree: true });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', demarrer);
    } else {
        demarrer();
    }
})();
