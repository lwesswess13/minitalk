*Ce projet a été réalisé dans le cadre du cursus 42 par *sbouchib*.*

# Minitalk

## Description

Minitalk est un petit projet de communication inter-processus (IPC). L'objectif est de construire un **client** et un **serveur** qui communiquent exclusivement via les signaux UNIX (`SIGUSR1` et `SIGUSR2`).

Le client prend en arguments le PID du serveur et un message texte, puis transmet le message bit par bit à l'aide de signaux. Le serveur reçoit les signaux, reconstruit chaque caractère bit par bit, et affiche le message sur la sortie standard.

### Fonctionnement

- Chaque caractère est envoyé sous forme de 8 bits (LSB en premier).
- `SIGUSR1` encode un bit à **1**, `SIGUSR2` encode un bit à **0**.
- Après chaque bit, le serveur renvoie `SIGUSR1` au client comme accusé de réception (ACK), garantissant une communication synchronisée et fiable.
- Le serveur écrit chaque caractère directement avec `write()` dès que 8 bits sont reçus (pas de buffer, pas de `malloc`).
- Lorsque le serveur reçoit un caractère nul (`'\0'`), il affiche un retour à la ligne pour marquer la fin du message.

### Fonctionnalités bonus

- Le client bonus affiche `"Message received by server!"` une fois que le message complet a été acquitté.

## Instructions

### Compilation

```bash
make          # Compile server et client (obligatoire)
make bonus    # Compile server_bonus et client_bonus
make clean    # Supprime les fichiers objets
make fclean   # Supprime les fichiers objets et les binaires
make re       # Recompilation complète
```

### Exécution

```bash
# 1. Lancer le serveur dans un terminal (il affiche son PID)
./server
# Server PID: 12345

# 2. Dans un autre terminal, envoyer un message
./client 12345 "Hello, World!"
```

Bonus :
```bash
./server_bonus
# Server PID: 12345

./client_bonus 12345 "Hello!"
# Le client affiche : Message received by server!
```

### Structure du projet

```
minitalk/
├── minitalk.h          # Header (obligatoire)
├── minitalk_bonus.h    # Header (bonus)
├── server.c            # Serveur — gestionnaire de signal + main
├── client.c            # Client — envoi des bits + main
├── utils.c             # ft_putchar, ft_putstr, ft_putnbr, ft_atoi
├── server_bonus.c      # Serveur bonus (même logique)
├── client_bonus.c      # Client bonus (avec message de confirmation)
├── utils_bonus.c       # Mêmes utils pour le bonus
├── Makefile            # Règles de compilation
└── DOCUMENTATION.md    # Explication détaillée fonction par fonction
```

## Ressources

- [Page man `signal(7)`](https://man7.org/linux/man-pages/man7/signal.7.html) — Vue d'ensemble des signaux UNIX.
- [Page man `sigaction(2)`](https://man7.org/linux/man-pages/man2/sigaction.2.html) — L'appel système `sigaction`.
- [Page man `kill(2)`](https://man7.org/linux/man-pages/man2/kill.2.html) — Envoi de signaux à des processus.
- [Opérateurs bit à bit en C](https://www.geeksforgeeks.org/bitwise-operators-in-c-cpp/) — Explication de `>>`, `<<`, `|`, `&` utilisés pour la manipulation de bits.

### Utilisation de l'IA

L'IA (GitHub Copilot) a été utilisée pour :
- **Documentation** : génération de pages de documentations.
- **Débogage** : identification de la raison pour laquelle IntelliSense de VSCode signalait des erreurs sur `sigaction`/`siginfo_t` (`_POSIX_C_SOURCE` manquant pour le linter).

L'IA n'a pas été utilisée pour écrire la logique principale des le depart — l'encodage/décodage bit par bit, la gestion des signaux et le mécanisme d'ACK ont été implémentés manuellement.
